% Sort events:  
% This script is intended to grasp and performa a first analysis of the 
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
%
%   NOTE ON LOADING: the loading of the 'Prod_<date>.mat' files is loading
%   2 variables, which are 'tdms_struct' and 'field_names'
%
% REV. 1. by Eugenio Senes and Theodoros Argyropoulos
%
% Last modified 10.05.2016 by Eugenio Senes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clearvars; clc;
datapath_read = '/Users/esenes/swap';
datapath_write = '/Users/esenes/swap_out/data';
exppath_write = '/Users/esenes/swap_out/exp';

startDate = '20160422';
endDate = '20160425';
startTime = '18:00:00';
endTime = '10:00:00';

buildExperiment = true; %merge all files at the end
expName = 'Loaded43MW_5';

%%%%%%%%%%%%%%%%%%%%%%%% End of Initialization %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPIKE DETECTION (B0,F1,F2 method)
%%windowing (bins)
spike_window_start = 140;
spike_window_end = 468;
%%Threshold setting
spike_thr = 8e6;
ratio_setPoint = .25;
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
    %init the output structure
    data_struct = struct;
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

    %% select just file B0 with L1 and L2
    for i = 1:length(field_names_out) %loop over events
        %Filter definition
        if i == 2
            dt = tdms_struct.(field_names_out{i}).INC.Props.wf_increment;
            fs = 1/dt;
            d = fdesign.bandpass('N,F3dB1,F3dB2',10,15e6,50e6,fs);
            Hd = design(d,'butter');
        end
        %sorting
        switch field_names_out{i}(end-1:end)
            case 'B0' %bd detected
                B0_ctr = B0_ctr +1;
                %COPY THE FIELD the B0 field into the output struct           
                    data_struct.(field_names_out{i}) = tdms_struct.(field_names_out{i});
                %ADD THE TIMESTAMPS IN THE 'Props' FIELD
                    data_struct.(field_names_out{i}).Props.timestamp = get_tsString(field_names_out{i});  
                %ADD THE PROPS FIELD
                    data_struct.Props.filetype = 'Experiment';
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
                    disp(field_names_out{i})
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
                    %method1: events with B0, L1 and L2
                    if ( strcmp(field_names_out{i+1}(end-1:end),'L1') && strcmp(field_names_out{i+2}(end-1:end),'L2') )%try to read the next 2 events
                        LL_ctr = LL_ctr +1; %increment the counter of usable BDs        
                        %filter the spikes
                        try
                        %calibrate the INC for spare pulse
                        INC_cal_n1 = log_cal(tdms_struct.(field_names_out{i+1}).INC.data,...
                            tdms_struct.(field_names_out{i+1}).INC.Props.Offset,...
                            tdms_struct.(field_names_out{i+1}).INC.Props.Scale,...
                            tdms_struct.(field_names_out{i+1}).INC.Props.Att__factor,...
                            tdms_struct.(field_names_out{i+1}).INC.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i+1}).INC.Props.Unit_scale);
                        INC_cal_n2 = log_cal(tdms_struct.(field_names_out{i+2}).INC.data,...
                            tdms_struct.(field_names_out{i+2}).INC.Props.Offset,...
                            tdms_struct.(field_names_out{i+2}).INC.Props.Scale,...
                            tdms_struct.(field_names_out{i+2}).INC.Props.Att__factor,...
                            tdms_struct.(field_names_out{i+2}).INC.Props.Att__factor__dB_,...
                            tdms_struct.(field_names_out{i+2}).INC.Props.Unit_scale);                        
                        %test the spikes
                        [sf, ~, ~, ~, ~, ~, ~, str_1, str_2] = spike_test_cal( INC_cal,... 
                            spike_window_start, spike_window_end, spike_thr,...
                            INC_cal_n1, INC_cal_n2 ,ratio_setPoint  );
                            if sf
                                %method flag = Prev_pulses
                                data_struct.(field_names_out{i}).spike.method = 'Prev_pulses';
                                data_struct.(field_names_out{i}).spike.flag = 1;
                                data_struct.(field_names_out{i}).spike.thr1 = str_1;
                                data_struct.(field_names_out{i}).spike.thr2 = str_2;
                            else
                                data_struct.(field_names_out{i}).spike.method = 'Prev_pulses';
                                data_struct.(field_names_out{i}).spike.flag = 0;
                            end
                        catch %if the method fails, then use the other method
%                             warning(['Bad windowing detected or power setpoint changed for ' field_names_out{i} ' , will be processed using the digital filter'])
                            [hasSpike, filteredSignal] = filterSpikes_W(INC_cal,Hd);
                            if hasSpike
                                %method flag = Freq_filter
                                data_struct.(field_names_out{i}).spike.method = 'Freq_filter';
                                data_struct.(field_names_out{i}).spike.flag = 1;
                                data_struct.(field_names_out{i}).spike.filtered_signal = filteredSignal;
                            else
                                data_struct.(field_names_out{i}).spike.method = 'Freq_filter';
                                data_struct.(field_names_out{i}).spike.flag = 0;
                            end
                        end%of try/catch
                    %method2: events with B0 only 
                    else
                        FF_ctr = FF_ctr+1;                    
                        [hasSpike, filteredSignal] = filterSpikes_W(INC_cal,Hd);
                        if hasSpike
                            %method flag = Freq_filter
                            data_struct.(field_names_out{i}).spike.method = 'Freq_filter';
                            data_struct.(field_names_out{i}).spike.flag = 1;
                            data_struct.(field_names_out{i}).spike.filtered_signal = filteredSignal;
                        else
                            data_struct.(field_names_out{i}).spike.method = 'Freq_filter';
                            data_struct.(field_names_out{i}).spike.flag = 0;
                        end
                    end
                % PULSE TUNING CHECK AND AVERAGE/PEAK CALCULATION
                [ tilt_str, peak_str, avg_str ] = checkTuning(INC_cal, comp_pulse_start, comp_pulse_end, ...
                                            flattop_start, flattop_end, flattop_end_off, thr1, thr2, thr3 );
                data_struct.(field_names_out{i}).tuning = tilt_str;
                % clean the unused fields
                data_struct.(field_names_out{i}) = rmfield(data_struct.(field_names_out{i}),'INC_max');
                data_struct.(field_names_out{i}) = rmfield(data_struct.(field_names_out{i}),'INC_average');
                data_struct.(field_names_out{i}) = rmfield(data_struct.(field_names_out{i}),'TRA_max');
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
            case 'L0' %no BD, not interesting
                L0_ctr = L0_ctr +1;
                %sum the pulse delay
                pulseDelta = pulseDelta + tdms_struct.(field_names_out{i}).Props.Pulse_Delta;
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
    disp('Saving ......')
    save([datapath_write filesep 'Data_' filename{j} '.mat'],'data_struct');
    disp(['Saved file ' num2str(j) ' on ' num2str(length(filename)) ' : ' 'Data_' filename{j} '.mat'])
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
    clearvars -except datapath_write startDate startTime endDate endTime expName exppath_write
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
    clearvars
end
