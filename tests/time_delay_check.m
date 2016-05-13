%% Signal alignment check
init_delay = 60e-9;
max_delay = 80e-9;
step_len = 4e-9;
nstep = round((max_delay-init_delay)/step_len);

comp_start = 5e-7;
comp_end = 5.5e-7;

timescale = 1:800;
timescale = timescale*data_struct.(event_name{1}).INC.Props.wf_increment;
timescale_TRA = timescale;
%find portion of timescale to compare
ind_tsc = find(timescale<comp_end & timescale>comp_start );

figure(1)
for i=1:1%length(BD_candidates)
    %grasp data
    ev = BD_candidates{i};
    y_INC = data_struct.(ev).INC.data_cal;
    y_TRA = data_struct.(ev).TRA.data_cal;
    %plot
    subplot(3,1,1)
    plot(timescale,y_INC,'b -',...
        timescale_TRA,y_TRA,'r -')
    title('Nominal signals')
    %select ROI for INC signal
    x_inc_ROI = timescale(ind_tsc);
    y_inc_ROI = y_INC(ind_tsc);
    
    %alignment
    %%just for plotting
    tscale_min = timescale_TRA - init_delay;
    tscale_max = timescale_TRA - max_delay;
    %plot the attempts    
    subplot(3,1,2)
    plot(timescale,y_INC,'b -',...
            tscale_min,y_TRA,'g --',...
            tscale_max,y_TRA,'g --')
    xlim([0.48e-6 0.6e-6])
    title('Delayed signals')
    hold on
    %find minimum difference
    scart = zeros(1,nstep);
    
    for i = 0:nstep
        timescale_TRA = timescale - init_delay - i*step_len;
        disp(['Testing delay: ' num2str((init_delay + i*step_len)*1e9) ' ns'])
        
        subplot(3,1,2)
        plot(timescale_TRA,y_TRA)
        
        ind_tsc_tra = find(timescale_TRA<comp_end & timescale_TRA>comp_start );
        x_tra_ROI = timescale_TRA(ind_tsc_tra);
        y_tra_ROI = y_TRA(ind_tsc_tra);
        
        diff = abs(y_inc_ROI-y_tra_ROI);
        scart(i+1) = sum(diff);
        disp(['differernce is: ' num2str(sum(diff)*1e-6)])
        disp(' ')
        
        subplot(3,1,3)
%         plot(x_inc_ROI,y_inc_ROI,'b-',x_tra_ROI,y_tra_ROI)
        plot(diff)
        hold on
    end   
    
    [~, min_idx] = min(scart);%loop starts from zero!!!
    del = init_delay + (min_idx -1 )*step_len;
    disp(['Delay = ' num2str(del*1e9) 'ns']);
    
   % pause;
end