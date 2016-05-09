% sistema error handling, poi fare un subscript
% ok per segnali
%   /|
%  / |
% |  |
% |  |
% 
% ma ancora male per segnali con pendenza opposta


clearvars -except data_struct
close all
evlst = fieldnames(data_struct);
figure(3)

%%

x = 1:800;
x = x';

comp_pulse_start = 400;
comp_pulse_end = 475;
flattop_start = 425;
flattop_end = 468;
thr1 = 0.85;
thr2 = 0.5;

sll = [];
tilt = [];


for i=1:length(evlst)-1
    if isfield( data_struct.(evlst{i}), 'spike') && data_struct.(evlst{i}).spike.flag == 0
        tmp_ft_end = flattop_end;
        
        y = data_struct.(evlst{i}).INC.data_cal;
%         [ slope, tilt ] = ...
%             checkTuning(y, comp_pulse_start, comp_pulse_end, flattop_start, flattop_end, thr1, thr2 );
%         tilt = [tilt (mean_t2-mean_t1)];

        y = y';
        plot(y)
        hold on
        
        x_cp = x(comp_pulse_start:comp_pulse_end);
        y_cp = y(comp_pulse_start:comp_pulse_end);
        x_ft = x(flattop_start:flattop_end);
        y_ft = y(flattop_start:flattop_end);
        
        
        try
            level = 0.85;
            [MEAN_1, PEAK_1,t1_1,t2_1,level_1] = fw(x_cp,y_cp,level);
        catch
            continue;
        end
        
        %autoadjust the window
        if round(t2_1) < flattop_end
            tmp_ft_end = round(t2_1);
            
            x_ft = x(flattop_start:tmp_ft_end);
            y_ft = y(flattop_start:tmp_ft_end);
        end
        
        try
            level = 0.5;
            [MEAN_2, PEAK_2,t1_2,t2_2,level_2] = fw(x_cp,y_cp,level);   
            tilt = (MEAN_2-MEAN_1);
        catch
            continue;
        end
        
        try
            f = fit(x_ft,y_ft,'poly1');
            slope = f.p1; 
            sll = [sll slope];
            offs = f.p2;
            yfit = slope.*x + offs;
            plot(x,y,'k -', ...
                    x_ft, y_ft, 'k .',...
                    t1_1,level_1,'r.',t2_1,level_1,'r.',MEAN_1,level_1,'r.',...
                    t1_2,level_2,'g.',t2_2,level_2,'g.',MEAN_2,level_2,'g.',...
                    x_ft, f(x_ft), 'r -','LineWidth',1.5,'MarkerSize',18)



            title(['Slope = ' num2str(slope) '  Width1 = ' num2str(t2_2-t1_2) '  Width2 = ' num2str(t2_1-t1_1) ])
            hold off;
            pause;
        catch
            disp('skip')
            continue;
        end 
        
        
    end
end