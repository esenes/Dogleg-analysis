function [ struct_out ] = signalDelay( ts_list, struct_in, init_delay, max_delay, step_len, comp_start, comp_end)
%	dignalDelay.m: detects dinamically the delay between the INC and TRA
%	signals. It is done by calculating the difference in absolute value
%	between the INC and the TRA while moving the TRA signal backwards from
%	init_delay to max_delay of steps of step_len length.
%
%   The function adds a field called
%   data_struct.<event_name>.TRA.data_cal_trans and a field containing the
%   delay value called data_struct.<event_name>.TRA.delay
%   
%   Inputs:
%   - ts_list:                  list of the timestamps to use
%   - struct_in:                input data structure
%   - init_delay, max_delay:    initial and end delay in ns (multiples of wf_increment)
%   - step_len:                 step length (multiples of wf_increment)
%   - comp_start, comp_end:     ROI of the pulse, in ns
%   
%   Outputs:
%   - struct_out:               struct in with the delay field appended
%
%   Last modified: 17.05.2016 by Eugenio Senes

nstep = round((max_delay-init_delay)/step_len);
%build the timescale
timescale = 1:800;
timescale = timescale*struct_in.(ts_list{1}).INC.Props.wf_increment;
timescale_TRA = timescale;
%find portion of timescale to compare
ind_tsc = find(timescale<comp_end & timescale>comp_start );

% figure(1)
for i=1:length(ts_list)
    %grasp data
    ev = ts_list{i};
    y_INC = struct_in.(ev).INC.data_cal;
    y_TRA = struct_in.(ev).TRA.data_cal;

    %select ROI for INC signal
    x_inc_ROI = timescale(ind_tsc);
    y_inc_ROI = y_INC(ind_tsc);
    
    %alignment
    %%just for plotting
    tscale_min = timescale_TRA - init_delay;
    tscale_max = timescale_TRA - max_delay;
    %plot the attempts    
%     subplot(2,1,2)

    %find minimum difference
    scart = zeros(1,nstep);
    
    for j = 0:nstep
        %move the timescale
        timescale_TRA = timescale - init_delay - j*step_len;
        ind_tsc_tra = find(timescale_TRA<comp_end & timescale_TRA>comp_start );
        x_tra_ROI = timescale_TRA(ind_tsc_tra);
        y_tra_ROI = y_TRA(ind_tsc_tra);
        %calculate the difference
        diff = abs(y_inc_ROI-y_tra_ROI);
        scart(j+1) = sum(diff);
    end   
    
    [~, min_idx] = min(scart);%loop starts from zero!!!
    del = init_delay + (min_idx -1 )*step_len;
    %add fields for signals
    struct_in.(ev).TRA.data_cal_trans = struct_in.(ev).TRA.data_cal - del;
    struct_in.(ev).TRA.delay = del;
end

    %pass the structure with the modified fields to the output
    struct_out = struct_in;
end

