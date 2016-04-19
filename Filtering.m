% Filtering:  
% This script is intended to use the data generated by readMATandsort.m by
% the data of the TD26CC structure, which is under test now in the dogleg.
% 
% In details it works in two steps:
% - read the matfiles with the data of the experiment 'Exp_<experiment Name>.mat'
% 1)  Process one by one the events, building data lists
%       - 2 lists for the metric values
%       - a list with spike flag
%       - a list with beam charge
%       - a list of the number of pulses past after the previous BD
%       - a list of the time past after the previous BD
% 2)  Set the thresholds and convert lists above into lists of flags
%       - inc_tra_flag and inc_ref_flag are 1 if the event is respecting the metric
%       - bpm1_flag and bpm2_flag are 1 if the charge from BPM is
%         trepassing the treshold. 
%       - hasBeam is the logical AND of bpm1_flag and bpm2_flag
%       - isSpike inherits from the precedent analysis
% 
% --------AND STUFF-------
% 
% REV. 1. by Eugenio Senes and Theodoros Argyropoulos
%
% Last modified 15.04.2016 by Eugenio Senes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% User input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clearvars; clc;
datapath_read = '/Users/esenes/Dropbox/work';
expname = 'Data_20160402';
%%%%%%%%%%%%%%%%%% Select the desired output %%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%% End of user input %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% Parameters %%%%%%%%%%%%%%%%%%%%%%%
% METRIC
inc_ref_thr = 0.5;
inc_tra_thr = -0.02;
% BPM CHARGE THRESHOLDS
bpm1_thr = -100;
bpm2_thr = -90;
% DELTA TIME FOR SECONDARY DUE TO BEAM LOST
deltaTime_spike = 90;
deltaTime_bem_lost = 90;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Load the files
tic
load([datapath_read filesep expname '.mat']);
toc

%% Get field names and list of B0 events in the file
event_name = {};
j = 1;
foo = fieldnames(data_struct);
for i = 1:length(foo)
    if strcmp(foo{i}(end-1:end),'B0')
        event_name{j} = foo{i};
        j = j+1;
    end    
end    
clear j, foo;

%% Parse the interesting event one by one and build the arrays of data for selection
% allocation
    %metric
    inc_tra = zeros(1,length(event_name));
    inc_ref = zeros(1,length(event_name));
    %bool for the spike flag
    isSpike = false(1,length(event_name));
    %beam charge
    bpm1_ch = zeros(1,length(event_name));
    bpm2_ch = zeros(1,length(event_name));
    %timestamps list    
    ts_array = zeros(1,length(event_name));
    %pulse past from previous BD list
    prev_pulse = zeros(1,length(event_name));
    %beam lost events
    beam_lost = false(1,length(event_name));
% filling    
for i = 1:length(event_name) 
    inc_tra(i) = data_struct.(event_name{i}).inc_tra;
    inc_ref(i) = data_struct.(event_name{i}).inc_ref;
    isSpike(i) = data_struct.(event_name{i}).spike.flag;
    bpm1_ch(i) = data_struct.(event_name{i}).BPM1.sum_calibrated;
    bpm2_ch(i) = data_struct.(event_name{i}).BPM2.sum_calibrated;
    % build a timestamps array
    [~, ts_array(i)] = getFileTimeStamp(data_struct.(event_name{i}).name);
    %build the number of pulse pulse between BD array
    prev_pulse(i) = data_struct.(event_name{i}).Props.Prev_BD_Pulse_Delay;
    %look for beam lost events and flag it
    beam_lost(i) = beamWasLost(data_struct.(event_name{i}).name, bpm1_ch(i), bpm2_ch(i), bpm1_thr, bpm2_thr);
end

%% Metric plotting to check the tresholds
figure
p1 = plot(inc_tra, inc_ref,'b .','MarkerSize',12);
xlabel('(INC-TRA)/(INC+TRA)')
ylabel('(INC-REF)/(INC+REF)')
axis([-0.2 0.5 0.2 0.8])
line(xlim, [inc_ref_thr inc_ref_thr], 'Color', 'r','LineWidth',1) %horizontal line
line([inc_tra_thr inc_tra_thr], ylim, 'Color', 'r','LineWidth',1) %vertical line
title('Interlock criteria review')
legend('Interlocks')

%% Start the filtering 
% allocation
    %metric
    inc_tra_flag = false(1,length(event_name));
    inc_ref_flag = false(1,length(event_name));
    %beam charge
    bpm1_flag = false(1,length(event_name));
    bpm2_flag = false(1,length(event_name));
    %secondary 
    sec_spike = false(1,length(event_name));
    sec_beam_lost = false(1,length(event_name));
% filling
    %metric criteria
    [inMetric,~,~] = metricCheck(inc_tra, inc_tra_thr, inc_ref, inc_ref_thr);
    %beam charge
    [hasBeam,~,~] = beamCheck(bpm1_ch, bpm1_thr, bpm2_ch, bpm2_thr);
    %secondary filter by time after SPIKE
    [~, sec_spike] = filterSecondary(ts_array,deltaTime_spike,isSpike);
    %secondary filter by time after BEAM LOST
    [~, sec_beam_lost] = filterSecondary(ts_array,deltaTime_bem_lost,beam_lost);
    
    

%% Metric plotting to check the tresholds
figure
plot(inc_tra, inc_ref,'b .',inc_tra(inMetric), inc_ref(inMetric),'r .',inc_tra(isSpike), inc_ref(isSpike),'g .',...
    inc_tra(sec_spike), inc_ref(sec_spike),'c .',inc_tra(sec_beam_lost), inc_ref(sec_beam_lost),'m .','MarkerSize',15);
legend('Interlocks','Metric','Spikes','After spike','After beam lost')
xlabel('(INC-TRA)/(INC+TRA)')
ylabel('(INC-REF)/(INC+REF)')
axis([-0.2 0.5 0.2 0.8])
line(xlim, [inc_ref_thr inc_ref_thr], 'Color', 'r','LineWidth',1) %horizontal line
line([inc_tra_thr inc_tra_thr], ylim, 'Color', 'r','LineWidth',1) %vertical line

%%
ind = find(inMetric );
for i=ind
    figure(1)
    plot(data_struct.(event_name{i}).INC.data_cal)
    title([num2str(i) ' ' event_name{i} ' isSpike = ' num2str(isSpike(i))])
    pause;
    
end