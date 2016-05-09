%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test of the pulse tuning algorithm    %
%                                       %
% calibration with nominal pulses       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except tdms_struct; clc; close all;
%load('D:\Dropbox\work\Analysis_with_beam\Prod_20160325.mat')
field_names = fieldnames(tdms_struct);

x = 1:800;
x = x';

comp_pulse_start = 400;
comp_pulse_end = 475;
flattop_start = comp_pulse_start + 25;
%flattop_end = comp_pulse_end - 11;
thr1 = 0.85;
thr2 = 0.65;
thr3 = 0.4;

fig1 = figure;
figure(fig1);

for i=2:length(field_names)
    %calibrate
    INC_data = log_cal(tdms_struct.(field_names{i}).INC.data,...
                        tdms_struct.(field_names{i}).INC.Props.Offset,...
                        tdms_struct.(field_names{i}).INC.Props.Scale,...
                        tdms_struct.(field_names{i}).INC.Props.Att__factor,...
                        tdms_struct.(field_names{i}).INC.Props.Att__factor__dB_,...
                        tdms_struct.(field_names{i}).INC.Props.Unit_scale);
    BPM1 = tdms_struct.(field_names{i}).BPM1.data;
    BPM1_cal = bpmcal(BPM1,'BPM1');
    BPM1_sum = sum(BPM1_cal);
    BPM2 = tdms_struct.(field_names{i}).BPM2.data;
    BPM2_cal = bpmcal(BPM2,'BPM2');
    BPM2_sum = sum(BPM2_cal);
    
    disp([field_names{i} ' BPM1= ' num2str(BPM1_sum) ' BPM2= ' num2str(BPM2_sum) ])
    
    
   
    
    if BPM1_sum < -100 && BPM2_sum < -90
     
        tit = '';
        %grasp the data
        x = 1:length(INC_data);
        x = x';
        y = INC_data;
        y = y';
        
        %METHOD 1
        x_cp = x(comp_pulse_start:comp_pulse_end);
        y_cp = y(comp_pulse_start:comp_pulse_end);
        [med_1, ~, x1_1, x2_1, y1] = fw(x_cp,y_cp,thr1);
        [med_2, ~, x1_2, x2_2, y2] = fw(x_cp,y_cp,thr2);
        [med_3, ~, x1_3, x2_3, y3] = fw(x_cp,y_cp,thr3);
        
        x_f1 = [med_1 med_2 med_3]';
        y_f1 = [y1,y2,y3]';
        
        fit1 = fit( x_f1, y_f1, 'poly1');
        tilt = fit1.p1;
        tit = ['tilt = ' num2str(tilt)];
        
        flattop_end = x2_1 - 4;
        if flattop_end <= flattop_start
            disp('hit')
        end
         
        disp(flattop_end)
        
        
        %METHOD 2
        %window setting
        x_ft = x(flattop_start:flattop_end);
        y_ft = y(flattop_start:flattop_end);
        %window resizing
%         if round(x2_1) < flattop_end
%             tmp_ft_end = round(x2_1);
%             
%             x_ft = x(flattop_start:tmp_ft_end);
%             y_ft = y(flattop_start:tmp_ft_end);
%         end
        %flattop fitting
        try
            fit2 = fit(x_ft,y_ft,'poly1');
            slope = fit2.p1;
        catch
            warning('METHOD2 FAIL')
        end
        %PLOTTING
        x_f1 = [med_1+2 med_2 med_3-2]';
        tit = [tit ' slope = ' num2str(slope)];
        
        plot(x,y,'k -', ...
                    x1_1,y1,'r.',x2_1,y1,'r.',med_1,y1,'r.',...
                    x1_2,y2,'g.',x2_2,y2,'g.',med_2,y2,'g.',...
                    x1_3,y3,'b.',x2_3,y3,'b.',med_3,y3,'b.',...
                    x_f1, fit1(x_f1),'m -',...
                    x_ft, fit2(x_ft),'c -',...
                    'LineWidth',1.5,'MarkerSize',18)
        title(tit);
        pause;
    end
    
    %x_ft, y_ft, 'k .',...
    %x_ft, f(x_ft), 'r -',
    
%         
%         plot(INC_cal) 
%         title(field_names{i})
%         % pulse tilt detection
%         tmp_ft_end = flattop_end;
%         y = INC_cal';
%         plot(y)
%         hold on
%         x_cp = x(comp_pulse_start:comp_pulse_end);
%         y_cp = y(comp_pulse_start:comp_pulse_end);
%         x_ft = x(flattop_start:flattop_end);
%         y_ft = y(flattop_start:flattop_end);
%         
%         % size dimension        
%         try
%             level = 0.85;
%             [MEAN_1, PEAK_1,t1_1,t2_1,level_1] = fw(x_cp,y_cp,level);
%         catch
%             continue;
%         end
%         
%         %autoadjust the window
%         if round(t2_1) < flattop_end
%             tmp_ft_end = round(t2_1);
%             
%             x_ft = x(flattop_start:tmp_ft_end);
%             y_ft = y(flattop_start:tmp_ft_end);
%         end
%         
%         try
%             level = 0.5;
%             [MEAN_2, PEAK_2,t1_2,t2_2,level_2] = fw(x_cp,y_cp,level);   
%             tilt = (MEAN_2-MEAN_1);
%         catch
%             continue;
%         end
%         
%         
%         % flattop fitting      
%         try
%             f = fit(x_ft,y_ft,'poly1');
%             slope = f.p1; 
%             sll = [sll slope];
%             offs = f.p2;
%             yfit = slope.*x + offs;
%             plot(x,y,'k -', ...
%                     x_ft, y_ft, 'k .',...
%                     t1_1,level_1,'r.',t2_1,level_1,'r.',MEAN_1,level_1,'r.',...
%                     t1_2,level_2,'g.',t2_2,level_2,'g.',MEAN_2,level_2,'g.',...
%                     x_ft, f(x_ft), 'r -','LineWidth',1.5,'MarkerSize',18)
% 
% 
% 
%             title(['Slope = ' num2str(slope) '  Width1 = ' num2str(t2_2-t1_2) '  Width2 = ' num2str(t2_1-t1_1) ])
%             hold off;
%             pause;
%         catch
%             disp('skip')
%             continue;
%         end
%         
%         hold off;
%         pause;
%     end
end