%load a data_struct
evlst = fieldnames(data_struct);
figure

x = 1:800;
x = x';

comp_pulse_start = 400;
comp_pulse_end = 475;
flattop_start = 425;
flattop_end = 468;

thr_up = 1e6;
thr_dw = -1e6;

for i=1:length(evlst)-1
    if isfield( data_struct.(evlst{i}), 'spike') && data_struct.(evlst{i}).spike.flag == 0
        y = data_struct.(evlst{i}).INC.data_cal;
        y = y';
        subplot(1,2,1)
        plot(y)
        
        subplot(1,2,2)
        dy = diff(y);
        plot(dy)
        line(xlim, [thr_up thr_up], 'Color', 'r','LineWidth',1) %horizontal line
        line(xlim, [thr_dw thr_dw], 'Color', 'r','LineWidth',1) %horizontal line
        
        
        
        t_up = find(dy(comp_pulse_start:comp_pulse_end)>thr_up,1);
        t_up = t_up + comp_pulse_start;
        t_dw = find(dy(comp_pulse_start:comp_pulse_end)<thr_dw,1,'last');
        t_dw = t_dw + comp_pulse_start;
        plen = t_dw-t_up;
        disp(plen)
        
        
       	if ~isempty(t_up)
            line([t_up t_up], ylim, 'Color', 'm','LineWidth',1) %horizontal line
            hold on;
        else
            warning('missing compressed pulse (or bad treshold)') 
        end
        if ~isempty(t_dw)
            line([t_dw t_dw], ylim, 'Color', 'm','LineWidth',1) %horizontal line
        else
            warning('missing compressed pulse (or bad treshold)') 
        end
        hold off;
        %report on first plot
        subplot(1,2,1)        
        if ~isempty(t_up)
            line([t_up t_up], ylim, 'Color', 'm','LineWidth',1) %horizontal line
        end
        if ~isempty(t_dw)
            line([t_dw t_dw], ylim, 'Color', 'm','LineWidth',1) %horizontal line
        end        
        hold off;
        pause;
    end        
end   