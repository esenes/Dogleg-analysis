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
% Last modified 13.06.2016 by Eugenio Senes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clearvars; clc;
if strcmp(computer,'MACI64') %just hit add to path when prompted
    addpath(genpath('/Users/esenes/scripts/Dogleg-analysis-master'))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% User input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datapath_read = '/Users/esenes/swap_out/exp';
datapath_write = '/Users/esenes/swap_out/exp';
datapath_write_plot = '/Users/esenes/swap_out/exp/plots';
datapath_write_fig = '/Users/esenes/swap_out/exp/figs';
expname = 'Exp_Loaded43MW_7';
savename = expname;
positionAnalysis = true;
manualCorrection = true;
%%%%%%%%%%%%%%%%%% Select the desired output %%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%% End of user input %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% Parameters %%%%%%%%%%%%%%%%%%%%%%%
% METRIC
inc_ref_thr = 0.48;
% inc_ref_thr = 0.6; %%antiloaded
inc_tra_thr = -0.02;
% BPM CHARGE THRESHOLDS
bpm1_thr = -100;
bpm2_thr = -90;
% DELTA TIME FOR SECONDARY DUE TO BEAM LOST
deltaTime_spike = 90;
deltaTime_beam_lost = 90;
deltaTime_cluster = 90;
% PULSE DELAY
init_delay = 60e-9;
max_delay = 80e-9;
step_len = 4e-9;
comp_start = 5e-7; %ROI start and end
comp_end = 5.5e-7;
%JITTER
sf = 4e-9;
sROI = 100;
eROI = 200;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pulse begin/end for probability
pbeg = 400;
pend = 474;



%% Create log file
%create log file and add initial parameters
logID = fopen([datapath_write filesep savename '.log'], 'w+' ); 
msg1 = ['Analysis log for the file ' expname '.mat' '\n' ...
'Created: ' datestr(datetime('now')) '\n \n' ...
'User defined tresholds: \n' ...
'METRIC: \n' ...
'- inc_ref_thr: %3.2f \n' ... 
'- inc_tra_thr: %3.2f \n' ... 
'BPM charge' '\n' ...
'- bpm1_thr: %3.2f' '\n' ...
'- bpm2_thr: %3.2f' '\n' ...
'Time window for clusters ' '\n' ...
'- deltaTime_spike: %3.2f' '\n' ...
'- deltaTime_bem_lost: %3.2f' '\n' ...
'\n'];
fprintf(logID,msg1,inc_ref_thr, inc_tra_thr, bpm1_thr, bpm2_thr,deltaTime_spike,deltaTime_beam_lost);
fclose(logID);

%% Load the BD files
tic
disp('Loading the data file ....')
load([datapath_read filesep expname '.mat']);
disp('Done.')
toc
disp(' ')

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
    %beam lost events
    prob = zeros(1,length(event_name));
% filling    
for i = 1:length(event_name) 
    inc_tra(i) = data_struct.(event_name{i}).inc_tra;
    inc_ref(i) = data_struct.(event_name{i}).inc_ref;
    isSpike(i) = data_struct.(event_name{i}).spike.flag;
    bpm1_ch(i) = data_struct.(event_name{i}).BPM1.sum_cal;
    bpm2_ch(i) = data_struct.(event_name{i}).BPM2.sum_cal;
    % build a timestamps array
    [~, ts_array(i)] = getFileTimeStamp(data_struct.(event_name{i}).name);
    %build the number of pulse pulse between BD array
    prev_pulse(i) = data_struct.(event_name{i}).Props.Prev_BD_Pulse_Delay;
    %look for beam lost events and flag it
    beam_lost(i) = beamWasLost(data_struct.(event_name{i}).name, bpm1_ch(i), bpm2_ch(i), bpm1_thr, bpm2_thr);
    
    %probability of BD is int(P^3 dt)
    p3 = data_struct.(event_name{i}).INC.data_cal (pbeg:pend);
    p3 = p3.^3;
    dt = 4e-9;
    prob(i) = sum(p3*dt);
end

%% filling for plotting
    %peak and average power
    pk_pwr = zeros(1,length(event_name));
    avg_pwr = zeros(1,length(event_name));
    pk_tra = zeros(1,length(event_name));
    pk_ref = zeros(1,length(event_name));
    %tuning
    tuning_slope = zeros(1,length(event_name));
    tuning_delta = zeros(1,length(event_name));
    failSlope = 0;
    failDelta = 0;
    %pulse length
    top_len = zeros(1,length(event_name));
    mid_len = zeros(1,length(event_name));
    bot_len = zeros(1,length(event_name));
    fail_m1=0;
for i = 1:length(event_name) 
    pk_pwr(i) = data_struct.(event_name{i}).INC.max;
    avg_pwr(i) = data_struct.(event_name{i}).INC.avg.INC_avg;
    pk_tra(i) = max(data_struct.(event_name{i}).TRA.data_cal);
    pk_ref(i) = max(data_struct.(event_name{i}).REF.data_cal);
    ft_end = 462; %change it if pulse length changes from nominal
    if data_struct.(event_name{i}).tuning.fail_m2 ~= true
        tuning_slope(i) = data_struct.(event_name{i}).tuning.slope;
        tuning_delta(i) = getDeltaPower(tuning_slope(i),...
            data_struct.(event_name{i}).tuning.x1,ft_end);
    else 
        tuning_slope(i) = NaN;
        tuning_delta(i) = NaN;
        failSlope = failSlope+1;
        failDelta = failDelta+1;
    end
    if data_struct.(event_name{i}).tuning.fail_m1 ~= true
        top_len(i) = 4e-9*(data_struct.(event_name{i}).tuning.top.x2 - data_struct.(event_name{i}).tuning.top.x1);
        mid_len(i) = 4e-9*(data_struct.(event_name{i}).tuning.mid.x2 - data_struct.(event_name{i}).tuning.mid.x1);
        bot_len(i) = 4e-9*(data_struct.(event_name{i}).tuning.bot.x2 - data_struct.(event_name{i}).tuning.bot.x1);
    else
        top_len(i) = NaN;
        mid_len(i) = NaN;
        bot_len(i) = NaN;
        fail_m1 = fail_m1+1;
    end
end
%% Parameters check plots 
%Get screen parameters in order to resize the plots
% screensizes = get(groot,'screensize'); %only MATLAB r2014b+
% screenWidth = screensizes(3);
% screenHeight = screensizes(4);
% winW = screenWidth/2;
% winH = screenHeight/2;
winW = 1420;
winH = 760;
moff = 0.05;%metric offset
%Metric plotting to check the tresholds
f0 = figure('position',[0 0 winW winH]);
figure(f0)
p1 = plot(inc_tra, inc_ref,'b .','MarkerSize',16);
xlabel('$$ \frac{\int INC - \int TRA}{\int INC + \int TRA} $$','interpreter','latex')
ylabel('$$ \frac{\int INC - \int REF}{\int INC + \int REF} $$','interpreter','latex')
axis([min(inc_tra)-moff max(inc_tra)+moff min(inc_ref)-moff max(inc_ref)+moff])
line(xlim, [inc_ref_thr inc_ref_thr], 'Color', 'r','LineWidth',1) %horizontal line
line([inc_tra_thr inc_tra_thr], ylim, 'Color', 'r','LineWidth',1) %vertical line
title('Interlock criteria review')
legend('Interlocks','Threshold')
savefig([datapath_write_fig filesep expname '_Metric_plot'])
print(f0,[datapath_write_plot filesep expname '_Metric_plot'],'-djpeg')
%Charge distribution plot
f1 = figure('position',[0 0 winW winH]);
figure(f1)
subplot(1,2,1)
plot(bpm1_ch,'.','MarkerSize',12);
line(xlim, [bpm1_thr bpm1_thr], 'Color', 'r','LineWidth',1) %horizontal line
title('BPM1 charge distribution')
xlabel('Event number')
ylabel('Integrated charge')
legend('Interlocks','threshold')
subplot(1,2,2)
plot(bpm2_ch,'.','MarkerSize',12)
line(xlim, [bpm2_thr bpm2_thr], 'Color', 'r','LineWidth',1) %horizontal line
title('BPM2 charge distribution')
xlabel('Event number')
ylabel('Integrated charge')
legend('Interlocks','threshold')
print(f1,[datapath_write_plot filesep expname '_charge_distribution'],'-djpeg')
savefig([datapath_write_fig filesep expname '_charge_distribution'])


%% Start the filtering 
% filling bool arrays
    %metric criteria
    [inMetric,~,~] = metricCheck(inc_tra, inc_tra_thr, inc_ref, inc_ref_thr);
    %beam charge
    [hasBeam,~,~] = beamCheck(bpm1_ch, bpm1_thr, bpm2_ch, bpm2_thr,'bpm1');
    %find indexes and elements for metric and non-metric events
    metr_idx = find(inMetric);
    nonmetr_idx = find(~inMetric);
    %secondary filter by time after SPIKE
    [~, sec_spike_in] = filterSecondary(ts_array(metr_idx),deltaTime_spike,isSpike(metr_idx));
    [~, sec_spike_out] = filterSecondary(ts_array(nonmetr_idx),deltaTime_spike,isSpike(nonmetr_idx));
    sec_spike = recomp_array(sec_spike_in,metr_idx,sec_spike_out,nonmetr_idx);
    %secondary filter by time after BEAM LOST
    [~, sec_beam_lost_in] = filterSecondary(ts_array(metr_idx),deltaTime_beam_lost,beam_lost(metr_idx));
    sec_beam_lost = recomp_array(sec_beam_lost_in,metr_idx,zeros(1,length(nonmetr_idx)),nonmetr_idx);
    %secondary after a normal BD
    BD_idx_met = inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost) & ~hasBeam;
    [~,clusters]=filterSecondary(ts_array,deltaTime_cluster,BD_idx_met);
% filling event arrays    
    %in the metric
    intoMetr = event_name(inMetric);
    outOfMetr = event_name(~inMetric);
    %candidates = inMetric, withBeam, not beam lost and not after spike and
    %not clusters
    BD_candidates = event_name(inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost));
    BD_candidates_beam = event_name(inMetric & hasBeam & ~isSpike & ~(sec_spike) & ~(sec_beam_lost));
    BD_candidates_nobeam = event_name(inMetric & ~hasBeam & ~isSpike & ~(sec_spike) & ~(sec_beam_lost));
    %clusters
    clusters_wb = event_name(inMetric & clusters & hasBeam);
    clusters_wob = event_name(inMetric & clusters & ~hasBeam);
    %final breakdowns
    BDs_flag = inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost) & hasBeam & ~clusters;
    BDs = event_name(inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost) & hasBeam & ~clusters);
    %interlocks = "candidates" out of metric
    interlocks_out = event_name(~inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost));
    %spikes
    spikes_inMetric =  event_name(inMetric & isSpike);
    spikes_outMetric =  event_name(~inMetric & isSpike);
    %missed beams
    missed_beam_in = event_name(inMetric &beam_lost);
    missed_beam_out = event_name(~inMetric &beam_lost);
    %clusters
    missed_beam_cluster = event_name(inMetric &sec_beam_lost);
    spike_cluster = event_name(inMetric & sec_spike & ~isSpike);
    spike_cluster_out = event_name(~inMetric & sec_spike & ~isSpike);

%% Cluster length detection

% Clusters from spikes
clust_spike_length = clusterDistribution( isSpike(metr_idx), sec_spike_in );
% Clusters from BD w/o beam
clust_BD_no_beam_wobeam_after = clusterDistribution( BD_idx_met, inMetric & clusters & ~hasBeam);
clust_BD_no_beam_wbeam_after = clusterDistribution( BD_idx_met, inMetric & clusters & hasBeam);

%% Report message and crosscheck of lengths
disp('Analysis done! ')
%open the log file and append
logID = fopen([datapath_write filesep savename '.log'], 'a' ); 
%gather data and build the message
%%INTO THE METRIC
l1 = length(BD_candidates);
l2 = length(spikes_inMetric);
l3 = length(spike_cluster);
l4 = length(missed_beam_in);
l5 = length(missed_beam_cluster);
msg2 = ['BD candidates found: ' num2str(length(inMetric)) ' of which ' num2str(length(intoMetr)) ' are into the metric' '\n' ...
    'Into the metric:' '\n' ...
' - ' num2str(l1) ' are good candidates' '\n' ...
' - ' num2str(l2) ' are spikes' '\n' ...
' - ' num2str(l3) ' are secondary triggered by spikes' '\n' ...
' - ' num2str(l4) ' are missed beam pulses' '\n' ...
' - ' num2str(l5) ' are secondary triggered by beam lost' '\n' ...
'-------' '\n' ...
'  ' num2str(l1+l2+l3+l4+l5) ' events in metric' '\n \n' ...
'Of the ' num2str(l1) ' good candidates:' '\n' ...
' - ' num2str(length(BD_candidates_beam)) ' have the beam' '\n' ...
' - ' num2str(length(BD_candidates_nobeam)) ' do not have the beam' '\n \n' ...
'Of the ' num2str(length(BD_candidates_beam)) ' BDs with the beam: \n' ...
' - '  num2str(length(clusters_wb)) ' are BDs with the beam present, but part of a cluster provoked by a BD happpened with beam' '\n'...
' - '  num2str(length(clusters_wob)) ' are BDs without the beam present, but part of a cluster provoked by a BD happpened without beam' '\n'...
'So the final number of breakdowns is ' num2str(length(BDs)) '\n' ...
'\n \n' ...
];
%%OUT OF THE METRIC
l1 = length(interlocks_out);
l2 = length(spikes_outMetric);
l3 = length(spike_cluster_out);
msg3 = ['Out of the metric:' '\n' ...
' - ' num2str(l1) ' are BDs ' '\n' ...
' - ' num2str(l2) ' are spikes' '\n' ...
' - ' num2str(l3) ' are secondary triggered by spikes' '\n' ...
'-------' '\n' ...
'  ' num2str(l1+l2+l3) ' events out of the metric' '\n \n' ...
];
% print to screen (1) and to log file
fprintf(1,msg2);
fprintf(1,msg3);
fprintf(logID,msg2);
fprintf(logID,msg3);
fclose(logID);

%% Distributions plots
% peak power distribution
f3 = figure('position',[0 0 winW winH]);
figure(f3)
xbins = linspace(0,round(max(pk_pwr),-6),(1e-6*round(max(pk_pwr),-6)+1));
h1 = hist(pk_pwr(inMetric & isSpike),xbins);
h2 = hist(pk_pwr(inMetric & sec_spike & ~isSpike),xbins);
h3 = hist(pk_pwr(inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost) & hasBeam & ~clusters),xbins);
bar([h3;h1;h2]','stack')
legend({'BDs','Spikes', 'Secondaries after spikes'},'Position',[.15 .8 .085 .085])
xlabel('Power (MW)')
ylabel('Counts')
title('Overall distribution of peak incident power')
print(f3,[datapath_write_plot filesep expname '_peak_power_distribution'],'-djpeg')
savefig([datapath_write_fig filesep expname '_peak_power_distribution'])

f60 = figure('position',[0 0 winW winH]);
figure(f60)
xbins = linspace(0,round(max(pk_ref(inMetric & ~isSpike)),-6),(1e-6*round(max(pk_ref(inMetric & ~isSpike)),-6)+1));
h1 = hist(pk_ref(inMetric & hasBeam & ~isSpike),xbins);
h2 = hist(pk_ref(inMetric & ~hasBeam & ~isSpike),xbins);
bar([h1;h2]','stack')
ax=gca;
%ax.XLim = [0 20]
legend({'With Beam','Without Beam'},'Position',[.15 .8 .085 .085])
xlabel('Power (MW)')
ylabel('Counts')
title('Distribution of peak reflected power of the BDs ')
% path60 = [datapath_write_plot filesep fileName '_peak_TRA_power_distribution'];
% print(f60,path60,'-djpeg')
% savefig([datapath_write_fig filesep fileName '_peak_TRA_power_distribution'])


% average power distribution
f4 = figure('position',[0 0 winW winH]);
figure(f4)
xbins = linspace(0,round(max(pk_pwr),-6),(1e-6*round(max(pk_pwr),-6)+1)); %1MW per bin
h1 = hist(avg_pwr(inMetric & isSpike),xbins);
h2 = hist(avg_pwr(inMetric & sec_spike & ~isSpike),xbins);
h3 = hist(avg_pwr(inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost) & hasBeam & ~clusters),xbins);
bar([h3;h1;h2]','stack')
legend({'BDs','Spikes', 'Secondaries after spikes'},'Position',[.15 .8 .085 .085])
xlabel('Power (MW)')
ylabel('Counts')
title('Overall distribution of average incident power')
print(f4,[datapath_write_plot filesep expname '_average_power_distribution'],'-djpeg')
savefig([datapath_write_fig filesep expname '_average_power_distribution'])


% Probability plot
f5 = figure('position',[0 0 winW winH]);
figure(f5)
%xbins = 0:4:(round(max(bot_len)*1e9)+2);
histogram(prob(inMetric));
xlabel('$$ \int P^3 d \tau $$','interpreter','latex')
ylabel('Counts')
title('BD probability')
print(f5,[datapath_write_plot filesep expname '_BD_probability_metric'],'-djpeg')
savefig([datapath_write_fig filesep expname '_BD_probability_metric'])
% 
% 
% % Spikes clusters length
% f6 = figure('position',[0 0 winW winH]);
% figure(f6)
% xb=1:max(clust_spike_length)+1;
% hist(clust_spike_length,xb)
% title({'Spike induced BDs distribution';['Interval duration = ' num2str(deltaTime_spike) ' s']})
% xlabel('# of BDs in the cluster')
% ylabel('Counts')
% print(f6,[datapath_write_plot filesep expname '_spike_clusters_length'],'-djpeg')
% savefig([datapath_write_fig filesep expname '_spike_clusters_length'])
% % BD induced clusters with no beam length
% f7 = figure('position',[0 0 winW winH]);
% figure(f7)
% xb=1:max(clust_BD_no_beam_wbeam_after)+1;
% h1 = hist(clust_BD_no_beam_wbeam_after,xb);
% h2 = hist(clust_BD_no_beam_wobeam_after,xb);
% bar([h1;h2]','stack')
% legend('Cluster with beam','Cluster w/o beam')
% title({'Normal BD induced BDs distribution';['Interval duration = ' num2str(deltaTime_cluster) ' s']})
% xlabel('# of BDs in the cluster')
% ylabel('Frequency')
% print(f7,[datapath_write_plot filesep expname '_BD_induced_clusters_length'],'-djpeg')
% savefig([datapath_write_fig filesep expname '_BD_induced_clusters_length'])
% tuning delta power distribution
f8 = figure('position',[0 0 winW winH]);
figure(f8)
subplot(2,1,1)
tmp_tuning = tuning_delta(inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost) & hasBeam & ~clusters);
xbins = linspace(-20e6,20e6,41); %1M per bin
histogram(tmp_tuning,xbins)
title({'BD pulses tuning distribution';['fitting errors = ' num2str(failSlope) ' on ' num2str(length(event_name))]})
xlabel('Power delta (W)')
ylabel('Counts')
subplot(2,1,2)
tmp_tuning = tuning_delta(inMetric & ~isSpike );
xbins = linspace(-20e6,20e6,41); %1M per bin
histogram(tmp_tuning,xbins)
title({'Pulses in metric tuning distribution (Spikes sorted out)';...
    ['fitting errors = ' num2str(failSlope) ' on ' num2str(length(event_name))]})
xlabel('Power delta (W)')
ylabel('Counts')
print(f8,[datapath_write_plot filesep expname '_tuning_delta_power_distribution'],'-djpeg')
savefig([datapath_write_fig filesep expname '_tuning_delta_power_distribution'])
% % peak normalized power distribution vs BDR
% f9 = figure('position',[0 0 winW winH]);
% figure(f9)
% xbins = linspace(0,round(max(pk_pwr),-6),(1e-6*round(max(pk_pwr),-6)+1));
% h3 = hist(pk_pwr(inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost) & hasBeam & ~clusters),xbins);
% h3 = h3/sum(h3);
% bar(h3,'stack')
% hold on
% BDR = h3(43) * ( ((xbins+1e6)/(43e6)).^15 );
% plot(BDR,'r')
% axis([0 50 0 max(h3)+.01])
% axis autox
% hold off
% legend({'BDs','BDR distribution'},'Position',[.15 .8 .085 .085])
% xlabel('Power (MW)')
% ylabel('Normalized frequency')
% title('Overall distribution of peak incident power')
% print(f9,[datapath_write_plot filesep expname '_peak_power_distribution_vs_BDR'],'-djpeg')
% savefig([datapath_write_fig filesep expname '_peak_power_distribution_vs_BDR'])
% pulse length
f10 = figure('position',[0 0 winW winH]);
figure(f10)
top_tmp = top_len(inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost) & hasBeam & ~clusters);
mid_tmp = mid_len(inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost) & hasBeam & ~clusters);
bot_tmp = bot_len(inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost) & hasBeam & ~clusters);
xbins = 0:4:(round(max(bot_len)*1e9)+2);
histogram(top_tmp*1e9,xbins);
title('Pulse width at various heights')
hold on
histogram(mid_tmp*1e9,xbins);
hold on
histogram(bot_tmp*1e9,xbins);
l = legend({'85%','65%','40%'},'Position',[.15 .8 .085 .085]);
xlabel('Pulse width (ns)')
ylabel('Counts')
hold off
print(f10,[datapath_write_plot filesep expname '_pulse_width_distribution'],'-djpeg')
savefig([datapath_write_fig filesep expname '_pulse_width_distribution'])


%% Positioning
if positionAnalysis
    %figure setup
    f666 = figure('position',[0 0 1920 1080]);
    figure(f666);
    set(gcf,'numbertitle','off','name','BD positioning check') 
    subplot(4,6,[13 14 19 20])
    plot(inc_tra(BDs_flag), inc_ref(BDs_flag),'b .','MarkerSize',20);
    xlabel('$$ \frac{\int INC - \int TRA}{\int INC + \int TRA} $$','interpreter','latex')
    ylabel('$$ \frac{\int INC - \int REF}{\int INC + \int REF} $$','interpreter','latex')
    axis([min(inc_tra(BDs_flag))-moff max(inc_tra(BDs_flag))+moff min(inc_ref(BDs_flag))-moff max(inc_ref(BDs_flag))+moff])
    line(xlim, [inc_ref_thr inc_ref_thr], 'Color', 'r','LineWidth',1) %horizontal line
    line([inc_tra_thr inc_tra_thr], ylim, 'Color', 'r','LineWidth',1) %vertical line
    title('Metric')
    legend('BDs','Threshold')
    hold on
    
    %data part
    timescale = 0:4e-9:799*4e-9;
    winStart = 1.6e-6;
    winStart_corr = 2.0e-6;
    wind = (1:100);
    %fill a matrix with data of the BDs
    for n=1:length(BDs)
        %get the current data
        INC_c = data_struct.(BDs{n}).INC.data;
        TRA_c = data_struct.(BDs{n}).TRA.data;
        REF_c = data_struct.(BDs{n}).REF.data;
        %check if the backup pulses are recorded
        precName = [BDs{n}(1:end-2) 'L1'];
        if isfield(data_struct,precName)% The backup pulse is present
            
            %grasp data 
            INC_prev = data_struct.(precName).INC.data;
            TRA_prev = data_struct.(precName).TRA.data;
            REF_prev = data_struct.(precName).REF.data;
            INC_prev_cal = data_struct.(precName).INC.data_cal;
            TRA_prev_cal = data_struct.(precName).TRA.data_cal;
            REF_prev_cal = data_struct.(precName).REF.data_cal;
            INC_c_cal = data_struct.(BDs{n}).INC.data_cal;
            TRA_c_cal = data_struct.(BDs{n}).TRA.data_cal;
            REF_c_cal = data_struct.(BDs{n}).REF.data_cal;
            BPM1_c = data_struct.(BDs{n}).BPM1.data_cal;
            BPM2_c = data_struct.(BDs{n}).BPM2.data_cal;
            inc_tra_c = data_struct.(BDs{n}).inc_tra;
            inc_ref_c = data_struct.(BDs{n}).inc_ref;
            
            %plotting
            positionPlot_prev( timescale, INC_c, INC_prev, TRA_c, TRA_prev, REF_c, REF_prev,...
                INC_c_cal, INC_prev_cal, TRA_c_cal, TRA_prev_cal, REF_c_cal, REF_prev_cal,...
                BPM1_c, BPM2_c)
            % plot metric red dot
            subplot(4,6,[13 14 19 20])
            if n~=1 
                delete(pm)
            end
            pm = plot(inc_tra_c, inc_ref_c,'m .','MarkerSize',20);

            %%%%%%%%%%%% Calculate the delay
            %TRA EDGE
            [ind_TRA, time_TRA] = getDeviationPoint(timescale,TRA_c,TRA_prev,winStart,0.07,0.005);
            
            subplot(4,6,[3 4])
            plot(timescale, TRA_c, 'r -',timescale, TRA_prev, 'r --')
            line([time_TRA time_TRA], ylim, 'Color', 'r','LineWidth',1) %vertical line
            legend({'TRA','prev TRA'})
            title('Edge method for TRA')
            xlim([400*4e-9 550*4e-9])
            xlabel('time (s)')
            ylabel('Power (a.u.)')

            %REF EDGE
            [ind_REF, time_REF] = getDeviationPoint(timescale,REF_c,REF_prev,winStart,0.1,0.02);
             
            subplot(4,6,[9 10])
            plot(timescale, REF_c, 'k -',timescale, REF_prev, 'k --')
            line([time_REF time_REF], ylim, 'Color', 'k','LineWidth',1) %vertical line
            legend({'REF','prev REF'})
            title('Edge method for REF')
            xlim([400*4e-9 550*4e-9])
            xlabel('time (s)')
            ylabel('Power (a.u.)')
            
            %add vertical bars to plots
            subplot(4,6,[1 2 7 8])
            hold on;
            line([time_TRA time_TRA], ylim, 'Color', 'r','LineWidth',1) %vertical line
            line([time_REF time_REF], ylim, 'Color', 'k','LineWidth',1) %vertical line
            subplot(4,6,[5 6 11 12])
            hold on;
            line([time_TRA time_TRA], ylim, 'Color', 'r','LineWidth',1) %vertical line
            line([time_REF time_REF], ylim, 'Color', 'k','LineWidth',1) %vertical line
            
            
            
            %CORRELATION
            [coeff_corr,gof,corr_err] = correlationMethod(timescale,INC_c',timescale,REF_c',wind,winStart_corr);
            
            subplot(4,6,[15 16 21 22])
            plot( timescale, REF_c, 'r', timescale, INC_c, 'k',...
                timescale-(coeff_corr(1)*1e-9), coeff_corr(2)*REF_c, 'g','LineWidth', 2 ...
                )
            xlim([1.848e-6 3.2e-6])
            title('Correlation method')
            legend({'REF','INC', 'REF delayed'})
            
            %JITTER check
            [ ~, delay_time ] = jitterCheck( data_struct.(BDs{n}).INC.data_cal, data_struct.(precName).INC.data_cal, sf, sROI, eROI);
            disp(['jitter = ' num2str(delay_time) ' ns'])
            if delay_time ~= 0
                warning('Jitter detected !')
            end
            
            % manual correction
            if manualCorrection
                str = input('Will you do any correction ?   ','s');
                if strcmp(str,'y')
                    str = input('Correct Edge Method ?   ','s');
                    if strcmp(str,'y')
                        str = input('time_ind_TRA =   ','s');
                        time_TRA = str2double(str);
                        ind_TRA = time_TRA/sf +1; %get index from time
                        str = input('time_ind_REF =   ','s');
                        time_REF = str2double(str);
                        ind_REF = time_REF/sf +1; %get index from time
                    end  
                    str = input('Correct Correlation Method ?   ','s');
                    if strcmp(str,'y')
                        str = input('time_peak_INC =   ','s');
                        time_inc = str2double(str) 
                        str = input('time_peak_REF =   ','s');
                        time_ref = str2double(str)
                       
                    else
                        continue;
                    end
                else
                    continue;
                end
            end
            
            %CREATE OUTPUT STRUCT
            %edge
            data_struct.(BDs{n}).position.edge.ind_REF = ind_REF; 
            data_struct.(BDs{n}).position.edge.time_REF = time_REF;
            data_struct.(BDs{n}).position.edge.ind_TRA = ind_TRA;
            data_struct.(BDs{n}).position.edge.time_TRA = time_TRA;
            %correlation
            data_struct.(BDs{n}).position.correlation.delay_bin = coeff_corr(1);
            data_struct.(BDs{n}).position.correlation.delay_time = timescale(coeff_corr(1));
            data_struct.(BDs{n}).position.correlation.gain = coeff_corr(2);

            %%%%%% STILL TO ADD THE MANUAL FAIL OF THE METHOD

            
            
        
        else
            % No backup pulse recorded
        end




        pause;
    end

    %flag data as positioning done
    data_struct.Analysis.postioning = true;

    % figure
    % plot(timescale, REF_c, 'r -',timescale, REF_prev, 'r --')
    % xlim([winStart 800*4e-9])
    % 
    % figure
    % plot(timescale,(REF_c - REF_prev))
    % xlim([winStart 800*4e-9])

else
    %flag data as positioning not done
    data_struct.Analysis.positioning = false;
end

%% Interactive plot (read version)

gone = false;
interactivePlot = false;
while ~gone
    str_input = input('Go to viewer ? (Y/N)','s');
    switch lower(str_input)
        case 'y'
            interactivePlot = true;
            gone = true;
        case 'n'
            interactivePlot = false;
            gone = true;
        otherwise
            disp('Enter a valid character')
            gone = false;
    end
end


if interactivePlot
    %Build the dataset to plot (IN METRIC):
    %candidates
    BDC_in_x = zeros(1,length(BD_candidates));
    BDC_in_y = zeros(1,length(BD_candidates));
    for k = 1:length(BD_candidates)
        BDC_in_x(k) = data_struct.(BD_candidates{k}).inc_tra;
        BDC_in_y(k) = data_struct.(BD_candidates{k}).inc_ref;
    end
    %spikes
    sp_in_x = zeros(1,length(spikes_inMetric));
    sp_in_y = zeros(1,length(spikes_inMetric));
    for k = 1:length(spikes_inMetric)
        sp_in_x(k) = data_struct.(spikes_inMetric{k}).inc_tra;
        sp_in_y(k) = data_struct.(spikes_inMetric{k}).inc_ref;
    end
    %spike cluster
    sp_c_in_x = zeros(1,length(spike_cluster));
    sp_c_in_y = zeros(1,length(spike_cluster));
    for k = 1:length(spike_cluster)
        sp_c_in_x(k) = data_struct.(spike_cluster{k}).inc_tra;
        sp_c_in_y(k) = data_struct.(spike_cluster{k}).inc_ref;
    end   
    %missed beam
    miss_in_x = zeros(1,length(missed_beam_in));
    miss_in_y = zeros(1,length(missed_beam_in));
    for k = 1:length(missed_beam_in)
        miss_in_x(k) = data_struct.(missed_beam_in{k}).inc_tra;
        miss_in_y(k) = data_struct.(missed_beam_in{k}).inc_ref;
    end
    %missed beam cluster
    miss_c_in_x = zeros(1,length(missed_beam_cluster));
    miss_c_in_y = zeros(1,length(missed_beam_cluster));
    for k = 1:length(missed_beam_cluster)
        miss_c_in_x(k) = data_struct.(missed_beam_cluster{k}).inc_tra;
        miss_c_in_y(k) = data_struct.(missed_beam_cluster{k}).inc_ref;
    end
    %OUT OF METRIC:
    %interlocks
    BDC_out_x = zeros(1,length(interlocks_out));
    BDC_out_y = zeros(1,length(interlocks_out));
    for k = 1:length(interlocks_out)
        BDC_out_x(k) = data_struct.(interlocks_out{k}).inc_tra;
        BDC_out_y(k) = data_struct.(interlocks_out{k}).inc_ref;
    end
    %spikes
    sp_out_x = zeros(1,length(spikes_outMetric));
    sp_out_y = zeros(1,length(spikes_outMetric));
    for k = 1:length(spikes_outMetric)
        sp_out_x(k) = data_struct.(spikes_outMetric{k}).inc_tra;
        sp_out_y(k) = data_struct.(spikes_outMetric{k}).inc_ref;
    end
    %spike cluster
    sp_c_out_x = zeros(1,length(spike_cluster_out));
    sp_c_out_y = zeros(1,length(spike_cluster_out));
    for k = 1:length(spike_cluster_out)
        sp_c_out_x(k) = data_struct.(spike_cluster_out{k}).inc_tra;
        sp_c_out_y(k) = data_struct.(spike_cluster_out{k}).inc_ref;
    end   
    % merge same type, in metric before
    BDC_x = [BDC_in_x BDC_out_x];
    BDC_y = [BDC_in_y BDC_out_y];
    sp_x = [sp_in_x sp_out_x];
    sp_y = [sp_in_y sp_out_y]; 
    sp_c_x = [sp_c_in_x sp_c_out_x];
    sp_c_y = [sp_c_in_y sp_c_out_y];

    %finally plot
    prompt = 'Select an event with the cursor and press ENTER (any other to exit)';
    f1 = figure('Position',[50 50 1450 700]);
    figure(f1);
    datacursormode on;
    subplot(5,5,[1 2 3 6 7 8 11 12 13])
    plot(BDC_x, BDC_y,'r .',sp_x,sp_y,'g .', sp_c_x,sp_c_y,'b .',...
        miss_in_x,miss_in_y,'c.',miss_c_in_x,miss_c_in_y,'m .','MarkerSize',15);
    legend('BDs','Spikes','After spike','Missed beam','After missed beam')
    xlabel('$$ \frac{\int INC - \int TRA}{\int INC + \int TRA} $$','interpreter','latex')
    ylabel('$$ \frac{\int INC - \int REF}{\int INC + \int REF} $$','interpreter','latex')
    axis([min(inc_tra)-moff max(inc_tra)+moff min(inc_ref)-moff max(inc_ref)+moff]);
    line(xlim, [inc_ref_thr inc_ref_thr], 'Color', 'r','LineWidth',1) %horizontal line
    line([inc_tra_thr inc_tra_thr], ylim, 'Color', 'r','LineWidth',1) %vertical line
    title('Interlock distribution');
    
    
    %color plot for saving
    f2 = figure('Position',[50 50 1450 700]);
    figure(f2);
    plot(BDC_x, BDC_y,'r .',sp_x,sp_y,'g .', sp_c_x,sp_c_y,'b .',...
        miss_in_x,miss_in_y,'c.',miss_c_in_x,miss_c_in_y,'m .','MarkerSize',16);
    legend('BDs','Spikes','After spike','Missed beam','After missed beam')
    xlabel('$$ \frac{\int INC - \int TRA}{\int INC + \int TRA} $$','interpreter','latex')
    ylabel('$$ \frac{\int INC - \int REF}{\int INC + \int REF} $$','interpreter','latex')
    axis([min(inc_tra)-moff max(inc_tra)+moff min(inc_ref)-moff max(inc_ref)+moff]);
    line(xlim, [inc_ref_thr inc_ref_thr], 'Color', 'r','LineWidth',1) %horizontal line
    line([inc_tra_thr inc_tra_thr], ylim, 'Color', 'r','LineWidth',1) %vertical line
    title('Interlock distribution');
    print(f2,[datapath_write_plot filesep expname '_metric_check_color'],'-djpeg')
    savefig([datapath_write_fig filesep expname '_metric_check_color'])
    close(f2);


    %x axis thicks for signals plotting
    timescale = 1:800;
    timescale = timescale*data_struct.(event_name{1}).INC.Props.wf_increment;

    %init the small graphs
    subplot(5,5,[4 5 9 10 14 15]) %RF signals plot
    title('RF signals');
    sp6 = subplot(5,5,[19 20 24 25]); %pulse tuning plot
    title('Pulse tuning')
    sp7 = subplot(5,5,[16 17 18 21 22 23]); %BPMs plot
    ylim(sp7, [-1.8 0.05]);
    title('BPM signals');
    % user interaction
    exitCond = false;
    while isempty ( input(prompt,'s') )%keep on spinning while pressing enter
        %get cursor position
        dcm_obj = datacursormode(f1);
        info_struct = getCursorInfo(dcm_obj);

        switch info_struct.Target.DisplayName
            % !!!! Must match the legend
            case 'BDs'
                if info_struct.DataIndex <= length(BDC_in_x)
                    fname = BD_candidates{info_struct.DataIndex};
                    print_subPlots(fname, timescale, data_struct,bpm1_thr,bpm2_thr)
                else
                    fname = interlocks_out{info_struct.DataIndex-length(BDC_in_x)};
                    print_subPlots(fname, timescale, data_struct,bpm1_thr,bpm2_thr)
                end
            case 'Spikes'
                if info_struct.DataIndex <= length(sp_in_x)
                    fname = spikes_inMetric{info_struct.DataIndex};
                    print_subPlots(fname, timescale, data_struct,bpm1_thr,bpm2_thr)
                else
                    fname = spikes_outMetric{info_struct.DataIndex-length(sp_in_x)};
                    print_subPlots(fname, timescale, data_struct,bpm1_thr,bpm2_thr)
                end
            case 'After spike'
                if info_struct.DataIndex <= length(sp_c_in_x)
                    fname = spike_cluster{info_struct.DataIndex};
                    print_subPlots(fname, timescale, data_struct,bpm1_thr,bpm2_thr)
                else
                    fname = spike_cluster_out{info_struct.DataIndex-length(sp_c_in_x)};
                    print_subPlots(fname, timescale, data_struct,bpm1_thr,bpm2_thr)
                end    
            case 'Missed beam'
                fname = missed_beam_in{info_struct.DataIndex};
                print_subPlots(fname, timescale, data_struct,bpm1_thr,bpm2_thr)
            case 'After missed beam'
                fname = missed_beam_cluster{info_struct.DataIndex};
                print_subPlots(fname, timescale, data_struct,bpm1_thr,bpm2_thr)
            otherwise
                warning('Type not recognized')
        end

    end
end %end user choice


%% Saving data

% adding fields for analysis parameters
data_struct.Analysis.Metric.inc_ref_thr = inc_ref_thr;
data_struct.Analysis.Metric.inc_tra_thr = inc_tra_thr;
data_struct.Analysis.Beam.bpm1_thr = bpm1_thr;
data_struct.Analysis.Beam.bpm2_thr = bpm2_thr;
data_struct.Analysis.Clusters.deltaTime_spike = deltaTime_spike;
data_struct.Analysis.Clusters.deltaTime_beam_lost = deltaTime_beam_lost;
data_struct.Analysis.Clusters.deltaTime_cluster = deltaTime_cluster;


% saving
tic
data_struct.Props.filetype = 'Experiment_analized';
disp('Saving ...')
save([datapath_write filesep 'Exp_analized' savename(4:end) '.mat'],...
    'data_struct','inMetric','isSpike','sec_spike','beam_lost','sec_beam_lost','hasBeam','clusters',...
    '-v7.3');
fileattrib([datapath_write filesep 'Exp_analized' savename(4:end) '.mat'],'-w','a');
disp('Done.')


%% Checking
% figure
% BDs = event_name;
% 
% 
% for i=1:length(BDs)
% %     BDs = {'g_20160604025302_201_B0'};
%     disp(max(data_struct.(BDs{i}).INC.data_cal))
%     disp(data_struct.(BDs{i}).name)
%     subplot(3,1,[1 2])
%     plot(timescale,data_struct.(BDs{i}).INC.data_cal);
%     hold on
%     plot(timescale-68e-9,data_struct.(BDs{i}).TRA.data_cal);
%     plot(timescale,data_struct.(BDs{i}).REF.data_cal);
%     hold off
%     legend({'INC','TRA','REF'})
%     title(data_struct.(BDs{i}).name)
%     xlabel('Time (s)')
%     ylabel('Power (W)')
%      
%     
%     subplot(3,1,3)
%     plot(timescale,data_struct.(BDs{i}).BPM1.data_cal)
%     hold on
%     plot(timescale,data_struct.(BDs{i}).BPM2.data_cal)
%     hold off
%     legend({'BPM1','BPM2'})
%     xlabel('Time (s)')
%     ylabel('Beam current (A)')
%     
% %     figure(5)
% %     plot(timescale,data_struct.(BDs{i}).INC.data);
% %     hold on
% %     plot(timescale-68e-9,data_struct.(BDs{i}).TRA.data);
% %     plot(timescale,data_struct.(BDs{i}).REF.data);
% %         plot(timescale,data_struct.(BDs{i}).KREF.data);
% % 
% %     hold off
% %     legend({'INC','TRA','REF','KREF'})
%     
%     pause
% end

%% debug tuning
% 
% delta = tuning_delta(inMetric & ~isSpike & ~(sec_spike) & ~beam_lost & ~(sec_beam_lost) & hasBeam & ~clusters);
% xb = 462;
% 
% figure
% for i = 1:length(BDs)
%     plot(data_struct.(BDs{i}).INC.data_cal)
%     x1 = data_struct.(BDs{i}).tuning.x1; x2 = data_struct.(BDs{i}).tuning.x2;
%     
%     maxim = max(data_struct.(BDs{i}).INC.data_cal);
%     y85 = 0.85*maxim;
%     line(xlim, [y85 y85], 'Color', 'r','LineWidth',1) %horizontal line
%     
%     line([x1 x1], ylim, 'Color', 'r','LineWidth',1) %vertical line
%     line([x2 x2], ylim, 'Color', 'r','LineWidth',1) %vertical line
%     line([xb xb], ylim, 'Color', 'g','LineWidth',1) %vertical line
%     title({['Tuning delta = ' num2str(delta(i))] ; ...
%            ['x1 = ' num2str(x1) ' x2 =  ' num2str(x2)]; ...
%            [' Delta (MW) = '];
%             tuning_slope(i)})
%     if data_struct.(event_name{i}).tuning.fail_m1 ~= true
%         disp([ 'TOP = '  num2str(1e9*top_tmp(i)) ' (ns)  MID = '  num2str(1e9*mid_tmp(i)) ' (ns)    BOT = ' ...
%             num2str(1e9*bot_tmp(i)) ' (ns)']);
%         
%         disp('P^3 delta t:')
%         disp([ 'TOP = '  num2str((maxim.^3) *top_tmp(i)) ' (s.W^3)  MID = '  num2str((maxim.^3) *mid_tmp(i)) ' (s.W^3)    BOT = ' ...
%             num2str((maxim.^3) *bot_tmp(i)) ' (s.W^3)']);
%     end
%     disp('  ')
%     pause
% end
