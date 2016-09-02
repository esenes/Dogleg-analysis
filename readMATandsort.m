%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sort events:  
% This script is intended to grasp and perform a first analysis of the 
% data of the TD26CC structure, which is under test now in the dogleg.
% 
% In details it should perform for every file:
% - read the matfiles with the data "Prod_<date>.mat"
% - create a list of events with BD (flag B0) and if is it possible the 
%   backup pulses L1 and L2.
% - add the field timestamp into the Props field in every event
% - SPIKE DETECTION:
%   - For events with B0, L1 and L2 is used an algorythm which involves the
%     use of the previous pulse
%   - For events with only the B0 trace is used an algorythm which uses a 
%     digital filter 
% - METRIC is also calculated and saved into the struct
% - BEAM CHARGE is calculated and saved also for both BPM1 and BPM2
% - DISTANCE IN PULSE from the last BD. The distance in pulse from the
%   final BD is stored into the struture as 'pulse_delay_from_<lastBD_name>'
% - PULSE TUNING: 
%   - METOD1: is using the pulse width at the 3 treshold levels and
%     calculating the middle point
%   - METHOD2: is fitting the flattop with a straight line (the flattop edges
%     detection is a bit tricky, but it works)
% After the analysis of every file is saved the 'Data_<date>.mat' file,
% which is the equivalent of the 'Prod_<date>.mat' file, but containing the
% results of the analysis. The file 'Norm_<date>.mat' is saved as well, and
% contains the backup pulses which didn' triggered any interlock.
%
% When all files have been processed, the Data files are merged in the
% 'Exp_<name>.mat' and 'Norm_full_<name>.mat'
%
%   NOTE ON FILE LOADING: the loading of the 'Prod_<date>.mat' files is
%   loading 2 variables, which are 'tdms_struct' and 'field_names'
%
% REV. 1. by Eugenio Senes and Theodoros Argyropoulos
%
% Last modified 10.05.2016 by Eugenio Senes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% Read setup file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clearvars; clc;
%include folder to path
[dirpath,~,~]=fileparts(mfilename('fullpath'));
addpath(genpath(dirpath))
%read setup
[datapath_read, datapath_write, exppath_write, ~, ~] = readSetup();
%%%%%%%%%%%%%%%%%%%%%%%%% End of setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%run10
startDate = '20160601';
endDate = '20160603';
startTime = '19:30:00';
endTime = '14:56:00';

buildExperiment = true; %merge all the data files at the end
buildBackupPulses = true; %merge all the backupd data files at the end
expName = 'UnLoaded_1';

mode = 'Loaded';
%%%%%%%%%%%%%%%%%%%%%%%% End of Initialization %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SAMPLING PERIOD
fs = 1/(4e-9);
% SPIKE DETECTION (B0,F1,F2 method)
%%Threshold setting
if strcmpi(mode,'Loaded')
    spike_thr = 4.5;
elseif strcmpi(mode,'UnLoaded')
    spike_thr = 4.5;
elseif strcmpi(mode,'Antiloaded')
    spike_thr = 1;
else
    error('Unknown mode')
end
% TUNING DETECTION PARAMETERS
%%windowing (bins)
comp_pulse_start = 400;
comp_pulse_end = 475;
flattop_start = 425;%is a good norm set it ~22 bins after the comp_pulse_start
flattop_end = 464;
flattop_end_off = 5;
%%tresholds settings (percentage of maximum)
thr1 = 0.85;    %the highest
thr2 = 0.65;
thr3 = 0.4;     %the lowest
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%check the date and times input
if datenum([startDate startTime],'YYYYmmddHH:MM:SS') > datenum([endDate endTime],'YYYYmmddHH:MM:SS')
    error('End is preceding the start !')
end

%build file list
[filenames_full] = files2Analyse(startDate, endDate, datapath_read, 1);
filename = get_dates(filenames_full);
disp('Start processing files:')
%%

for j = 1:length(filename) %loop over dates
    tic
    disp(['Loading file ' num2str(j) ' on ' num2str(length(filename)) ])
    %% Load the files
    load([datapath_read filesep 'Prod_' filename{j} '.mat']);

    %% Select just events in range
    field_names_out = eventSelection( startDate, endDate, startTime, endTime, filename, j, field_names );
    
    %% Init variables
    %init some counters for the content of the file
    B0_ctr = 0;
    L0_ctr = 0; 
    LL_ctr = 0; %counts where are present B0,L1,L2
    FF_ctr = 0; %counts where is the B0, but not one of L1 or L2
    %init the output data structure
    data_struct = struct;
    %init the output structure for backup pulses
    normal_struct = struct;
    %init BPM signals
    BPM1 = zeros(1,800);
    BPM2 = zeros(1,800);
    BPM1_cal = zeros(1,800);
    BPM2_cal = zeros(1,800);
    %init calibrated log signals
    INC_cal = zeros(1,800);
    TRA_cal = zeros(1,800);
    REF_cal = zeros(1,800);
    %init calibrated prevous log signals
    INC_cal_n1 = zeros(1,800);
    TRA_cal_n2 = zeros(1,800);
    %init calibrated IQ signals
    amplitude = zeros(1,4000);
    phase = zeros(1,4000);
    timescale_IQ = zeros(1,4000);
    % Init for pulse difference counter
    pulseDelta = 0;
    lastBD_name = '';
    % Open a progress bar
    progBar = waitbar(0,['Elaborating file ' num2str(j) ' on ' num2str(length(filename)) ]);
    %ADD THE PROPS FIELD
    data_struct.Props.filetype = 'Data';   
    %CALCULATE FILTER TAPS FOR THE SPIKE FILTER
    d = fdesign.bandpass('N,F3dB1,F3dB2',10,15e6,50e6,fs);
    Hd = design(d,'butter');
           
    %% select file B0 with L1 and L2 for the data, the L0 for the normal operation check
    for i = 1:length(field_names_out) %loop over events
        %Filter definition for spike treatment
        if i == 2
            dt = tdms_struct.(field_names_out{i}).INC.Props.wf_increment;
            fs = 1/dt;
            d = fdesign.bandpass('N,F3dB1,F3dB2',10,15e6,50e6,fs);
            Hd = design(d,'butter');
        end
        %sorting
%         disp(field_names_out{i})
        switch field_names_out{i}(end-1:end)
            case 'B0' %bd detected
                B0_ctr = B0_ctr +1;
                %ADD THE TIMESTAMPS IN THE 'Props' FIELD
                    data_struct.(field_names_out{i}).Props.timestamp = get_tsString(field_names_out{i});  
                %COPY THE FIELD the B0 field into the output struct           
                    data_struct.(field_names_out{i}) = tdms_struct.(field_names_out{i});
                %REMOVE MOTOR FIELDS
                    if isfield(data_struct.(field_names_out{i}),'Motor_Right')
                        data_struct.(field_names_out{i}) = rmfield(data_struct.(field_names_out{i}),'Motor_Right');
                    end
                    if isfield(data_struct.(field_names_out{i}),'Motor_Left')
                        data_struct.(field_names_out{i}) = rmfield(data_struct.(field_names_out{i}),'Motor_Left');
                    end
                %INCLUDING CALIBRATING SIGNALS
                    %log detector
                    INC_cal = log_cal(tdms_struct.(field_names_out{i}).INC.data,...
                            tdms_struct.(field_names_out{i}).INC.Props.Offset,...
                            tdms_struct.(field_names_out{i}).INC.Props.Scale,...
                            tdms_struct.(field_names_out{i}).INC.Props.Att__factor,...
                            tdms_struct.(field_names_out{i}).INC.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i}).INC.Props.Unit_scale);
                    data_struct.(field_names_out{i}).INC.data_cal = INC_cal;
                    TRA_cal = log_cal(tdms_struct.(field_names_out{i}).TRA.data,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Offset,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Scale,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Att__factor,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Unit_scale);
                    data_struct.(field_names_out{i}).TRA.data_cal = TRA_cal;
                    REF_cal = log_cal(tdms_struct.(field_names_out{i}).REF.data,...
                            tdms_struct.(field_names_out{i}).REF.Props.Offset,...
                            tdms_struct.(field_names_out{i}).REF.Props.Scale,...
                            tdms_struct.(field_names_out{i}).REF.Props.Att__factor,...
                            tdms_struct.(field_names_out{i}).REF.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i}).REF.Props.Unit_scale);   
                    data_struct.(field_names_out{i}).REF.data_cal = REF_cal;
                    %IQ signals
                    %disp(field_names_out{i})
                    try
                    [amplitude,phase,timescale_IQ] = getIQSignal(tdms_struct.(field_names_out{i}).Fast_INC_I,tdms_struct.(field_names_out{i}).Fast_INC_Q);
                    data_struct.(field_names_out{i}).Fast_INC_I.Amplitude = amplitude;
                    data_struct.(field_names_out{i}).Fast_INC_I.Phase = phase;
                    data_struct.(field_names_out{i}).Fast_INC_I.timescale_IQ = timescale_IQ;
                    [amplitude,phase,timescale_IQ] = getIQSignal(tdms_struct.(field_names_out{i}).Fast_TRA_I,tdms_struct.(field_names_out{i}).Fast_TRA_Q);
                    data_struct.(field_names_out{i}).Fast_TRA_I.Amplitude = amplitude;
                    data_struct.(field_names_out{i}).Fast_TRA_I.Phase = phase;
                    data_struct.(field_names_out{i}).Fast_TRA_I.timescale_IQ = timescale_IQ;
                    [amplitude,phase,timescale_IQ] = getIQSignal(tdms_struct.(field_names_out{i}).Fast_REF_I,tdms_struct.(field_names_out{i}).Fast_REF_Q);
                    data_struct.(field_names_out{i}).Fast_REF_I.Amplitude = amplitude;
                    data_struct.(field_names_out{i}).Fast_REF_I.Phase = phase;
                    data_struct.(field_names_out{i}).Fast_REF_I.timescale_IQ = timescale_IQ;
                    catch
                        %if unable to calibrate IQ, just don't do it
                    end
                %NUMBER OF PULSES BETWEEN BDs
                    pulseDelta = pulseDelta + tdms_struct.(field_names_out{i}).Props.Pulse_Delta;
                    if i == 0 %first BD of the experiment don't have a previous one
                        pulseDelta = 0;
                    end
                    data_struct.(field_names_out{i}).Props.Prev_BD_Pulse_Delay = pulseDelta;
                    pulseDelta = 0;
                    lastBD_name = field_names_out{i};
                %METRIC calculation
                    %INC-TRA
                    data_struct.(field_names_out{i}).inc_tra = metric(tdms_struct.(field_names_out{i}).INC.data,tdms_struct.(field_names_out{i}).TRA.data);
                    %INC-REF
                    data_struct.(field_names_out{i}).inc_ref = metric(tdms_struct.(field_names_out{i}).INC.data,tdms_struct.(field_names_out{i}).REF.data);
                %BPMs
                    %calibration and sum
                    BPM1 = tdms_struct.(field_names_out{i}).BPM1.data;
                    BPM1_cal = bpmcal(BPM1,'BPM1');
                    data_struct.(field_names_out{i}).BPM1.data_cal = BPM1_cal;
                    data_struct.(field_names_out{i}).BPM1.sum_cal = sum(BPM1_cal);
                    BPM2 = tdms_struct.(field_names_out{i}).BPM2.data;
                    BPM2_cal = bpmcal(BPM2,'BPM2');
                    data_struct.(field_names_out{i}).BPM2.data_cal = BPM2_cal;
                    data_struct.(field_names_out{i}).BPM2.sum_cal = sum(BPM2_cal);
                %SPIKES
                    %filter the spikes
                    [hasSpike, filteredSignal] = filterSpikes_W(INC_cal,Hd,spike_thr);
                    if hasSpike
                        data_struct.(field_names_out{i}).spike.flag = 1;
                        data_struct.(field_names_out{i}).spike.filtered_signal = filteredSignal;
                    else
                        data_struct.(field_names_out{i}).spike.flag = 0;
                    end
                    %method1: events with B0, L1 and L2
                    if ( strcmp(field_names_out{i+1}(end-1:end),'L1') && strcmp(field_names_out{i+2}(end-1:end),'L2') )%try to read the next 2 events
                        LL_ctr = LL_ctr +1; %increment the counter of usable BDs        
                    %method2: events with B0 only
                    else
                        FF_ctr = FF_ctr+1;                    
                    end
                % PULSE TUNING CHECK AND AVERAGE/PEAK CALCULATION
                [ tilt_str, peak_str, avg_str ] = checkTuning(INC_cal, comp_pulse_start, comp_pulse_end, ...
                                            flattop_start, flattop_end, flattop_end_off, thr1, thr2, thr3 );
                data_struct.(field_names_out{i}).tuning = tilt_str;
                % clean the unused fields
                data_struct.(field_names_out{i}) = rmfield(data_struct.(field_names_out{i}),'INC_max');
                data_struct.(field_names_out{i}) = rmfield(data_struct.(field_names_out{i}),'INC_average');
                data_struct.(field_names_out{i}) = rmfield(data_struct.(field_names_out{i}),'TRA_max');
                data_struct.(field_names_out{i}) = rmfield(data_struct.(field_names_out{i}),'INC_pulse_width');
                % fill it
                data_struct.(field_names_out{i}).INC.max = peak_str;
                data_struct.(field_names_out{i}).INC.avg = avg_str;
                data_struct.(field_names_out{i}).REF.max = max(REF_cal);
                data_struct.(field_names_out{i}).TRA.max = max(TRA_cal);
                
                
            case 'L1'
                % copy also L1 and L2 fields to the structure
                data_struct.(field_names_out{i}) = tdms_struct.(field_names_out{i});
                %INCLUDING CALIBRATING SIGNALS
                    %log detector
                    INC_cal = log_cal(tdms_struct.(field_names_out{i}).INC.data,...
                            tdms_struct.(field_names_out{i}).INC.Props.Offset,...
                            tdms_struct.(field_names_out{i}).INC.Props.Scale,...
                            tdms_struct.(field_names_out{i}).INC.Props.Att__factor,...
                            tdms_struct.(field_names_out{i}).INC.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i}).INC.Props.Unit_scale);
                    data_struct.(field_names_out{i}).INC.data_cal = INC_cal;
                    TRA_cal = log_cal(tdms_struct.(field_names_out{i}).TRA.data,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Offset,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Scale,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Att__factor,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Unit_scale);
                    data_struct.(field_names_out{i}).TRA.data_cal = TRA_cal;
                    REF_cal = log_cal(tdms_struct.(field_names_out{i}).REF.data,...
                            tdms_struct.(field_names_out{i}).REF.Props.Offset,...
                            tdms_struct.(field_names_out{i}).REF.Props.Scale,...
                            tdms_struct.(field_names_out{i}).REF.Props.Att__factor,...
                            tdms_struct.(field_names_out{i}).REF.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i}).REF.Props.Unit_scale);   
                    data_struct.(field_names_out{i}).REF.data_cal = REF_cal;
                %BPMs
                    %calibration and sum
                    BPM1 = tdms_struct.(field_names_out{i}).BPM1.data;
                    BPM1_cal = bpmcal(BPM1,'BPM1');
                    data_struct.(field_names_out{i}).BPM1.data_calibrated = BPM1_cal;
                    data_struct.(field_names_out{i}).BPM1.sum_calibrated = sum(BPM1_cal);
                    BPM2 = tdms_struct.(field_names_out{i}).BPM2.data;
                    BPM2_cal = bpmcal(BPM2,'BPM2');
                    data_struct.(field_names_out{i}).BPM2.data_calibrated = BPM2_cal;
                    data_struct.(field_names_out{i}).BPM2.sum_calibrated = sum(BPM2_cal);             
            case 'L2'    
                data_struct.(field_names_out{i}) = tdms_struct.(field_names_out{i});
                %INCLUDING CALIBRATING SIGNALS
                    %log detector
                    INC_cal = log_cal(tdms_struct.(field_names_out{i}).INC.data,...
                            tdms_struct.(field_names_out{i}).INC.Props.Offset,...
                            tdms_struct.(field_names_out{i}).INC.Props.Scale,...
                            tdms_struct.(field_names_out{i}).INC.Props.Att__factor,...
                            tdms_struct.(field_names_out{i}).INC.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i}).INC.Props.Unit_scale);
                    data_struct.(field_names_out{i}).INC.data_cal = INC_cal;
                    TRA_cal = log_cal(tdms_struct.(field_names_out{i}).TRA.data,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Offset,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Scale,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Att__factor,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Unit_scale);
                    data_struct.(field_names_out{i}).TRA.data_cal = TRA_cal;
                    REF_cal = log_cal(tdms_struct.(field_names_out{i}).REF.data,...
                            tdms_struct.(field_names_out{i}).REF.Props.Offset,...
                            tdms_struct.(field_names_out{i}).REF.Props.Scale,...
                            tdms_struct.(field_names_out{i}).REF.Props.Att__factor,...
                            tdms_struct.(field_names_out{i}).REF.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i}).REF.Props.Unit_scale);   
                    data_struct.(field_names_out{i}).REF.data_cal = REF_cal;
                %BPMs
                    %calibration and sum
                    BPM1 = tdms_struct.(field_names_out{i}).BPM1.data;
                    BPM1_cal = bpmcal(BPM1,'BPM1');
                    data_struct.(field_names_out{i}).BPM1.data_calibrated = BPM1_cal;
                    data_struct.(field_names_out{i}).BPM1.sum_calibrated = sum(BPM1_cal);
                    BPM2 = tdms_struct.(field_names_out{i}).BPM2.data;
                    BPM2_cal = bpmcal(BPM2,'BPM2');
                    data_struct.(field_names_out{i}).BPM2.data_calibrated = BPM2_cal;
                    data_struct.(field_names_out{i}).BPM2.sum_calibrated = sum(BPM2_cal);
            case 'L0' %no BD, not interesting unless for backup pulses
                L0_ctr = L0_ctr +1;
                %sum the pulse delay
                pulseDelta = pulseDelta + tdms_struct.(field_names_out{i}).Props.Pulse_Delta;
                %fill the backup data structure
                %ADD THE TIMESTAMPS IN THE 'Props' FIELD
                    normal_struct.(field_names_out{i}).Props.timestamp = get_tsString(field_names_out{i});  
                %COPY THE FIELD the B0 field into the output struct           
                    normal_struct.(field_names_out{i}) = tdms_struct.(field_names_out{i});
                %ADD THE PROPS FIELD
                    normal_struct.Props.filetype = 'Data';
                %REMOVE MOTOR FIELDS
                    if isfield(normal_struct.(field_names_out{i}),'Motor_Right')
                        normal_struct.(field_names_out{i}) = rmfield(normal_struct.(field_names_out{i}),'Motor_Right');
                    end
                    if isfield(normal_struct.(field_names_out{i}),'Motor_Left')
                        normal_struct.(field_names_out{i}) = rmfield(normal_struct.(field_names_out{i}),'Motor_Left');
                    end
                %INCLUDING CALIBRATING SIGNALS
                    %log detector
                    INC_cal = log_cal(tdms_struct.(field_names_out{i}).INC.data,...
                            tdms_struct.(field_names_out{i}).INC.Props.Offset,...
                            tdms_struct.(field_names_out{i}).INC.Props.Scale,...
                            tdms_struct.(field_names_out{i}).INC.Props.Att__factor,...
                            tdms_struct.(field_names_out{i}).INC.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i}).INC.Props.Unit_scale);
                    normal_struct.(field_names_out{i}).INC.data_cal = INC_cal;
                    TRA_cal = log_cal(tdms_struct.(field_names_out{i}).TRA.data,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Offset,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Scale,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Att__factor,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i}).TRA.Props.Unit_scale);
                    normal_struct.(field_names_out{i}).TRA.data_cal = TRA_cal;
                    REF_cal = log_cal(tdms_struct.(field_names_out{i}).REF.data,...
                            tdms_struct.(field_names_out{i}).REF.Props.Offset,...
                            tdms_struct.(field_names_out{i}).REF.Props.Scale,...
                            tdms_struct.(field_names_out{i}).REF.Props.Att__factor,...
                            tdms_struct.(field_names_out{i}).REF.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i}).REF.Props.Unit_scale);   
                    normal_struct.(field_names_out{i}).REF.data_cal = REF_cal;
                %IQ signals
                    try
                    [amplitude,phase,timescale_IQ] = getIQSignal(tdms_struct.(field_names_out{i}).Fast_INC_I,tdms_struct.(field_names_out{i}).Fast_INC_Q);
                    normal_struct.(field_names_out{i}).Fast_INC_I.Amplitude = amplitude;
                    normal_struct.(field_names_out{i}).Fast_INC_I.Phase = phase;
                    normal_struct.(field_names_out{i}).Fast_INC_I.timescale_IQ = timescale_IQ;
                    [amplitude,phase,timescale_IQ] = getIQSignal(tdms_struct.(field_names_out{i}).Fast_TRA_I,tdms_struct.(field_names_out{i}).Fast_TRA_Q);
                    normal_struct.(field_names_out{i}).Fast_TRA_I.Amplitude = amplitude;
                    normal_struct.(field_names_out{i}).Fast_TRA_I.Phase = phase;
                    normal_struct.(field_names_out{i}).Fast_TRA_I.timescale_IQ = timescale_IQ;
                    [amplitude,phase,timescale_IQ] = getIQSignal(tdms_struct.(field_names_out{i}).Fast_REF_I,tdms_struct.(field_names_out{i}).Fast_REF_Q);
                    normal_struct.(field_names_out{i}).Fast_REF_I.Amplitude = amplitude;
                    normal_struct.(field_names_out{i}).Fast_REF_I.Phase = phase;
                    normal_struct.(field_names_out{i}).Fast_REF_I.timescale_IQ = timescale_IQ;
                    catch
                    end
                %BPMs
                    %calibration and sum
                    BPM1 = tdms_struct.(field_names_out{i}).BPM1.data;
                    BPM1_cal = bpmcal(BPM1,'BPM1');
                    normal_struct.(field_names_out{i}).BPM1.data_cal = BPM1_cal;
                    normal_struct.(field_names_out{i}).BPM1.sum_cal = sum(BPM1_cal);
                    BPM2 = tdms_struct.(field_names_out{i}).BPM2.data;
                    BPM2_cal = bpmcal(BPM2,'BPM2');
                    normal_struct.(field_names_out{i}).BPM2.data_cal = BPM2_cal;
                    normal_struct.(field_names_out{i}).BPM2.sum_cal = sum(BPM2_cal);
                % PULSE TUNING CHECK AND AVERAGE/PEAK CALCULATION
                    [ tilt_str, peak_str, avg_str ] = checkTuning(INC_cal, comp_pulse_start, comp_pulse_end, ...
                                                flattop_start, flattop_end, flattop_end_off, thr1, thr2, thr3 );
                    normal_struct.(field_names_out{i}).tuning = tilt_str;
                    % clean the unused fields
                    normal_struct.(field_names_out{i}) = rmfield(normal_struct.(field_names_out{i}),'INC_max');
                    normal_struct.(field_names_out{i}) = rmfield(normal_struct.(field_names_out{i}),'INC_average');
                    normal_struct.(field_names_out{i}) = rmfield(normal_struct.(field_names_out{i}),'TRA_max');
                    % fill it
                    normal_struct.(field_names_out{i}).INC.max = peak_str;
                    normal_struct.(field_names_out{i}).INC.avg = avg_str;
                    normal_struct.(field_names_out{i}).REF.max = max(REF_cal);
                    normal_struct.(field_names_out{i}).TRA.max = max(TRA_cal);
        end
        %update the progress bar
        prog = round(i/length(field_names_out),1);
        waitbar(prog,progBar)

    end
    %close the progress bar
    close(progBar);
    %save last BD pulse delta
    disp(['Pulse_delta_remaining from final BD: ' num2str(pulseDelta)])
    data_struct.('pulse_delay_from_last') = pulseDelta;
    toc
    %export the data
    disp('Saving BD data ......')
    save([datapath_write filesep 'Data_' filename{j} '.mat'],'data_struct');
    fileattrib([datapath_write filesep 'Data_' filename{j} '.mat'],'-w','a');
    disp(['Saved BD file ' num2str(j) ' on ' num2str(length(filename)) ' : ' 'Data_' filename{j} '.mat'])
    toc
    disp('Saving normal data ......')
    save([datapath_write filesep 'Norm_' filename{j} '.mat'],'normal_struct');
    fileattrib([datapath_write filesep 'Norm_' filename{j} '.mat'],'-w','a');
    disp(['Saved normal file ' num2str(j) ' on ' num2str(length(filename)) ' : ' 'Data_' filename{j} '.mat'])
    toc
    disp(' ')
end
disp(' ')
disp('Data file generation complete')


    
%% now merge files for every experiment if required
if buildExperiment
    tic
    disp(' ')
    disp('Start to assembly the experiment structure')
    %clean memor before allocating the new structure
    clearvars -except datapath_write startDate startTime endDate endTime expName exppath_write buildBackupPulses
    data_struct = buildExperimentStruct(datapath_write,startDate,startTime,endDate,endTime);
    %add fields related to time interval
    data_struct.Props.filetype = 'Experiment';
    data_struct.Props.startDate = startDate;
    data_struct.Props.startTime = startTime;
    data_struct.Props.endDate = endDate;
    data_struct.Props.endTime = endTime;
    disp('Done');
    toc
    %save the file
    disp('Saving ...')
    save([exppath_write filesep 'Exp_' expName '.mat'],'data_struct','-v7.3');
    fileattrib([exppath_write filesep 'Exp_' expName '.mat'],'-w','a');
    disp('Done.')
    toc
    clearvars -except datapath_write startDate startTime endDate endTime expName exppath_write buildBackupPulses
end

if buildBackupPulses
    tic
    disp(' ')
    disp('Start to assembly the backup data structure')
    %clean memor before allocating the new structure
    clearvars -except datapath_write startDate startTime endDate endTime expName exppath_write
    data_struct = buildBackupStruct(datapath_write,startDate,startTime,endDate,endTime);
    %add fields related to time interval
    data_struct.Props.filetype = 'Backup pulses';
    data_struct.Props.startDate = startDate;
    data_struct.Props.startTime = startTime;
    data_struct.Props.endDate = endDate;
    data_struct.Props.endTime = endTime;
    disp('Done');
    toc
    %save the file
    disp('Saving ...')
    save([exppath_write filesep 'Norm_full_' expName '.mat'],'data_struct','-v7.3');
    fileattrib([exppath_write filesep 'Norm_full_' expName '.mat'],'-w','a');
    disp('Done.')
    toc
    clearvars
end