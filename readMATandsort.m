% Sort events:  
% This script is intended to grasp and performa a first analysis of the 
% data of the TD26CC structure, which is under test now in the dogleg.
% 
% In details it should perform for every file:
% - read the matfiles with the data "Prod_<date>.mat"
% - create a list of events with BD (flag B0) and if is it possible the 
%   backup pulses L1 and L2.
% - SPIKE DETECTION:
%   - For events with B0, L1 and L2 is used an algorythm which involves the
%     use of the previous pulse
%   - For events with only the B0 trace is used an algorythm which uses a 
%     digital filter 
% - METRIC is also calculated and saved into the struct
% - BEAM CHARGE is calculated and saved also for both BPM1 and BPM2
% - DISTANCE IN PULSE from the last BD. The distance in pulse from the
%   final BD is stored into the struture as 'pulse_delay_from_<lastBD_name>'
%
% REV. 1. by Eugenio Senes and Theodoros Argyropoulos
%
% Last modified 19.04.2016 by Eugenio Senes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clearvars; clc;
datapath_read = 'Z:\matfiles';
datapath_write = 'W:';
% datapath_read = '/Users/esenes/Dropbox/work/Analysis_with_beam';
% datapath_write = '/Users/esenes/Dropbox/work';

startDate = '20160402';
endDate = '20160402';
startTime = '18:30:00';
endTime = '16:00:00';

buildExperiment = false; %merge all files at the end
expName = 'Loaded43MW_2';

%%%%%%%%%%%%%%%%%%%%%%%% End of Initialization %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPIKE DETECTION (B0,F1,F2 method)
%%windowing (bins)
spike_window_start = 140;
spike_window_end = 468;
%%Threshold setting
spike_thr = 8e6;
ratio_setPoint = 0.3;
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
    progBar = waitbar(0,['Elaborating ' filename{j}]);

    %% select just file B0 with L1 and L2
    for i = 1:length(field_names) %loop over events
        %Filter definition, once per file, skipping the 'Prop' field
        if i == 2
            dt = tdms_struct.(field_names{i}).INC.Props.wf_increment;
            fs = 1/dt;
            d = fdesign.bandpass('N,F3dB1,F3dB2',10,15e6,50e6,fs);
            Hd = design(d,'butter');
        end
        %sorting
        switch field_names{i}(end-1:end)
            case 'B0' %bd detected
                B0_ctr = B0_ctr +1;
                %COPY THE FIELD the B0 field into the output struct           
                    data_struct.(field_names{i}) = tdms_struct.(field_names{i});
                %INCLUDING CALIBRATING SIGNALS
                    %log detector
                    INC_cal = log_cal(tdms_struct.(field_names{i}).INC.data,...
                            tdms_struct.(field_names{i}).INC.Props.Offset,...
                            tdms_struct.(field_names{i}).INC.Props.Scale,...
                            tdms_struct.(field_names{i}).INC.Props.Att__factor,...
                            tdms_struct.(field_names{i}).INC.Props.Att__factor__dB_,...
                            tdms_struct.(field_names{i}).INC.Props.Unit_scale);
                    data_struct.(field_names{i}).INC.data_cal = INC_cal;
                    TRA_cal = log_cal(tdms_struct.(field_names{i}).TRA.data,...
                            tdms_struct.(field_names{i}).TRA.Props.Offset,...
                            tdms_struct.(field_names{i}).TRA.Props.Scale,...
                            tdms_struct.(field_names{i}).TRA.Props.Att__factor,...
                            tdms_struct.(field_names{i}).TRA.Props.Att__factor__dB_,...
                            tdms_struct.(field_names{i}).TRA.Props.Unit_scale);
                    data_struct.(field_names{i}).TRA.data_cal = TRA_cal;
                    REF_cal = log_cal(tdms_struct.(field_names{i}).REF.data,...
                            tdms_struct.(field_names{i}).REF.Props.Offset,...
                            tdms_struct.(field_names{i}).REF.Props.Scale,...
                            tdms_struct.(field_names{i}).REF.Props.Att__factor,...
                            tdms_struct.(field_names{i}).REF.Props.Att__factor__dB_,...
                            tdms_struct.(field_names{i}).REF.Props.Unit_scale);   
                    data_struct.(field_names{i}).REF.data_cal = REF_cal;
                    %IQ signals
                    [amplitude,phase,timescale_IQ] = getIQSignal(tdms_struct.(field_names{i}).Fast_INC_I,tdms_struct.(field_names{i}).Fast_INC_Q);
                    data_struct.(field_names{i}).Fast_INC_I.Amplitude = amplitude;
                    data_struct.(field_names{i}).Fast_INC_I.Phase = phase;
                    data_struct.(field_names{i}).Fast_INC_I.timescale_IQ = timescale_IQ;
                    [amplitude,phase,timescale_IQ] = getIQSignal(tdms_struct.(field_names{i}).Fast_TRA_I,tdms_struct.(field_names{i}).Fast_TRA_Q);
                    data_struct.(field_names{i}).Fast_TRA_I.Amplitude = amplitude;
                    data_struct.(field_names{i}).Fast_TRA_I.Phase = phase;
                    data_struct.(field_names{i}).Fast_TRA_I.timescale_IQ = timescale_IQ;
                    [amplitude,phase,timescale_IQ] = getIQSignal(tdms_struct.(field_names{i}).Fast_REF_I,tdms_struct.(field_names{i}).Fast_REF_Q);
                    data_struct.(field_names{i}).Fast_REF_I.Amplitude = amplitude;
                    data_struct.(field_names{i}).Fast_REF_I.Phase = phase;
                    data_struct.(field_names{i}).Fast_REF_I.timescale_IQ = timescale_IQ;
                %NUMBER OF PULSES BETWEEN BDs
                    pulseDelta = pulseDelta + tdms_struct.(field_names{i}).Props.Pulse_Delta;
                    if i == 0 %first BD of the experiment don't have a previous one
                        pulseDelta = 0;
                    end
                    data_struct.(field_names{i}).Props.Prev_BD_Pulse_Delay = pulseDelta;
                    pulseDelta = 0;
                    lastBD_name = field_names{i};
                %METRIC calculation
                    %INC-TRA
                    data_struct.(field_names{i}).inc_tra = metric(tdms_struct.(field_names{i}).INC.data,tdms_struct.(field_names{i}).TRA.data);
                    %INC-REF
                    data_struct.(field_names{i}).inc_ref = metric(tdms_struct.(field_names{i}).INC.data,tdms_struct.(field_names{i}).REF.data);
                %BPMs
                    %calibration and sum
                    BPM1 = tdms_struct.(field_names{i}).BPM1.data;
                    BPM1_cal = bpmcal(BPM1,'BPM1');
                    data_struct.(field_names{i}).BPM1.data_cal = BPM1_cal;
                    data_struct.(field_names{i}).BPM1.sum_cal = sum(BPM1_cal);
                    BPM2 = tdms_struct.(field_names{i}).BPM2.data;
                    BPM2_cal = bpmcal(BPM2,'BPM2');
                    data_struct.(field_names{i}).BPM2.data_cal = BPM2_cal;
                    data_struct.(field_names{i}).BPM2.sum_cal = sum(BPM2_cal);
                %SPIKES
                    %method1: events with B0, L1 and L2
                    if ( strcmp(field_names{i+1}(end-1:end),'L1') && strcmp(field_names{i+2}(end-1:end),'L2') )%try to read the next 2 events
                        LL_ctr = LL_ctr +1; %increment the counter of usable BDs        
                        %filter the spikes
                        try
                        %calibrate the INC for spare pulse
                        INC_cal_n1 = log_cal(tdms_struct.(field_names{i+1}).INC.data,...
                            tdms_struct.(field_names{i+1}).INC.Props.Offset,...
                            tdms_struct.(field_names{i+1}).INC.Props.Scale,...
                            tdms_struct.(field_names{i+1}).INC.Props.Att__factor,...
                            tdms_struct.(field_names{i+1}).INC.Props.Att__factor__dB_,...
                            tdms_struct.(field_names{i+1}).INC.Props.Unit_scale);
                        INC_cal_n2 = log_cal(tdms_struct.(field_names{i+2}).INC.data,...
                            tdms_struct.(field_names{i+2}).INC.Props.Offset,...
                            tdms_struct.(field_names{i+2}).INC.Props.Scale,...
                            tdms_struct.(field_names{i+2}).INC.Props.Att__factor,...
                            tdms_struct.(field_names{i+2}).INC.Props.Att__factor__dB_,...
                            tdms_struct.(field_names{i+2}).INC.Props.Unit_scale);                        
                        %test the spikes
                        [sf, ~, ~, ~, ~, ~, ~, str_1, str_2] = spike_test_cal( INC_cal,... 
                            spike_window_start, spike_window_end, spike_thr,...
                            INC_cal_n1, INC_cal_n2 ,ratio_setPoint  );
                            if sf
                                %method flag = Prev_pulses
                                data_struct.(field_names{i}).spike.method = 'Prev_pulses';
                                data_struct.(field_names{i}).spike.flag = 1;
                                data_struct.(field_names{i}).spike.thr1 = str_1;
                                data_struct.(field_names{i}).spike.thr2 = str_2;
                            else
                                data_struct.(field_names{i}).spike.method = 'Prev_pulses';
                                data_struct.(field_names{i}).spike.flag = 0;
                            end
                        catch %if the method fails, then use the other method
                            warning(['Bad windowing detected for ' field_names{i} ' , will be processed using the digital filter'])
                            [hasSpike, filteredSignal] = filterSpikes_W(INC_cal,Hd);
                            if hasSpike
                                %method flag = Freq_filter
                                data_struct.(field_names{i}).spike.method = 'Freq_filter';
                                data_struct.(field_names{i}).spike.flag = 1;
                                data_struct.(field_names{i}).spike.filtered_signal = filteredSignal;
                            else
                                data_struct.(field_names{i}).spike.method = 'Freq_filter';
                                data_struct.(field_names{i}).spike.flag = 0;
                            end
                        end%of try/catch
                    %method2: events with B0 only 
                    else
                        FF_ctr = FF_ctr+1;                    
                        [hasSpike, filteredSignal] = filterSpikes_W(INC_cal,Hd);
                        if hasSpike
                            %method flag = Freq_filter
                            data_struct.(field_names{i}).spike.method = 'Freq_filter';
                            data_struct.(field_names{i}).spike.flag = 1;
                            data_struct.(field_names{i}).spike.filtered_signal = filteredSignal;
                        else
                            data_struct.(field_names{i}).spike.method = 'Freq_filter';
                            data_struct.(field_names{i}).spike.flag = 0;
                        end
                    end
            case 'L1'
                % copy also L1 and L2 fields to the structure
                data_struct.(field_names{i}) = tdms_struct.(field_names{i});
                %INCLUDING CALIBRATING SIGNALS
                    %log detector
                    INC_cal = log_cal(tdms_struct.(field_names{i}).INC.data,...
                            tdms_struct.(field_names{i}).INC.Props.Offset,...
                            tdms_struct.(field_names{i}).INC.Props.Scale,...
                            tdms_struct.(field_names{i}).INC.Props.Att__factor,...
                            tdms_struct.(field_names{i}).INC.Props.Att__factor__dB_,...
                            tdms_struct.(field_names{i}).INC.Props.Unit_scale);
                    data_struct.(field_names{i}).INC.data_cal = INC_cal;
                    TRA_cal = log_cal(tdms_struct.(field_names{i}).TRA.data,...
                            tdms_struct.(field_names{i}).TRA.Props.Offset,...
                            tdms_struct.(field_names{i}).TRA.Props.Scale,...
                            tdms_struct.(field_names{i}).TRA.Props.Att__factor,...
                            tdms_struct.(field_names{i}).TRA.Props.Att__factor__dB_,...
                            tdms_struct.(field_names{i}).TRA.Props.Unit_scale);
                    data_struct.(field_names{i}).TRA.data_cal = TRA_cal;
                    REF_cal = log_cal(tdms_struct.(field_names{i}).REF.data,...
                            tdms_struct.(field_names{i}).REF.Props.Offset,...
                            tdms_struct.(field_names{i}).REF.Props.Scale,...
                            tdms_struct.(field_names{i}).REF.Props.Att__factor,...
                            tdms_struct.(field_names{i}).REF.Props.Att__factor__dB_,...
                            tdms_struct.(field_names{i}).REF.Props.Unit_scale);   
                    data_struct.(field_names{i}).REF.data_cal = REF_cal;
                %BPMs
                    %calibration and sum
                    BPM1 = tdms_struct.(field_names{i}).BPM1.data;
                    BPM1_cal = bpmcal(BPM1,'BPM1');
                    data_struct.(field_names{i}).BPM1.data_calibrated = BPM1_cal;
                    data_struct.(field_names{i}).BPM1.sum_calibrated = sum(BPM1_cal);
                    BPM2 = tdms_struct.(field_names{i}).BPM2.data;
                    BPM2_cal = bpmcal(BPM2,'BPM2');
                    data_struct.(field_names{i}).BPM2.data_calibrated = BPM2_cal;
                    data_struct.(field_names{i}).BPM2.sum_calibrated = sum(BPM2_cal);             
            case 'L2'    
                data_struct.(field_names{i}) = tdms_struct.(field_names{i});
                %INCLUDING CALIBRATING SIGNALS
                    %log detector
                    INC_cal = log_cal(tdms_struct.(field_names{i}).INC.data,...
                            tdms_struct.(field_names{i}).INC.Props.Offset,...
                            tdms_struct.(field_names{i}).INC.Props.Scale,...
                            tdms_struct.(field_names{i}).INC.Props.Att__factor,...
                            tdms_struct.(field_names{i}).INC.Props.Att__factor__dB_,...
                            tdms_struct.(field_names{i}).INC.Props.Unit_scale);
                    data_struct.(field_names{i}).INC.data_cal = INC_cal;
                    TRA_cal = log_cal(tdms_struct.(field_names{i}).TRA.data,...
                            tdms_struct.(field_names{i}).TRA.Props.Offset,...
                            tdms_struct.(field_names{i}).TRA.Props.Scale,...
                            tdms_struct.(field_names{i}).TRA.Props.Att__factor,...
                            tdms_struct.(field_names{i}).TRA.Props.Att__factor__dB_,...
                            tdms_struct.(field_names{i}).TRA.Props.Unit_scale);
                    data_struct.(field_names{i}).TRA.data_cal = TRA_cal;
                    REF_cal = log_cal(tdms_struct.(field_names{i}).REF.data,...
                            tdms_struct.(field_names{i}).REF.Props.Offset,...
                            tdms_struct.(field_names{i}).REF.Props.Scale,...
                            tdms_struct.(field_names{i}).REF.Props.Att__factor,...
                            tdms_struct.(field_names{i}).REF.Props.Att__factor__dB_,...
                            tdms_struct.(field_names{i}).REF.Props.Unit_scale);   
                    data_struct.(field_names{i}).REF.data_cal = REF_cal;
                %BPMs
                    %calibration and sum
                    BPM1 = tdms_struct.(field_names{i}).BPM1.data;
                    BPM1_cal = bpmcal(BPM1,'BPM1');
                    data_struct.(field_names{i}).BPM1.data_calibrated = BPM1_cal;
                    data_struct.(field_names{i}).BPM1.sum_calibrated = sum(BPM1_cal);
                    BPM2 = tdms_struct.(field_names{i}).BPM2.data;
                    BPM2_cal = bpmcal(BPM2,'BPM2');
                    data_struct.(field_names{i}).BPM2.data_calibrated = BPM2_cal;
                    data_struct.(field_names{i}).BPM2.sum_calibrated = sum(BPM2_cal);
            case 'L0' %no BD, not interesting
                L0_ctr = L0_ctr +1;
                %sum the pulse delay
                pulseDelta = pulseDelta + tdms_struct.(field_names{i}).Props.Pulse_Delta;
        end
        %update the progress bar
        prog = round(i/length(field_names),1);
        waitbar(prog,progBar)
    end
    %close the progress bar
    close(progBar);
    %save last BD pulse delta
    disp(['Pulse_delta_remaining from final BD: ' num2str(pulseDelta)])
    data_struct.('pulse_delay_from_last') = pulseDelta;
    toc
    %export the data
    save([datapath_write filesep 'Data_' filename{j} '.mat'],'data_struct');
    disp(['Saved file ' num2str(j) ' on ' num2str(length(filename)) ' : ' 'Data_' filename{j} '.mat'])
    toc
    disp(' ')
end
disp(' ')
disp('Data file generation complete')

%% now merge files for every experiment
if buildExperiment
    tic
    disp(' ')
    disp('Start to assembly the experiment structure')
    %clean memor before allocating the new structure
    clearvars -except datapath_write startDate startTime endDate endTime expName
    data_struct = buildExperimentStruct(datapath_write,startDate,startTime,endDate,endTime);
    toc
    disp('Saving ...')
    save([datapath_write filesep 'Exp_' expName '.mat'],'data_struct','-v7.3');
    fileattrib([datapath_write filesep 'Exp_' expName '.mat'],'-w','a');
    disp('Done.')
    toc
    clearvars
end
