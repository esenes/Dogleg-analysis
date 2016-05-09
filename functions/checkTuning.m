function [ str_out ] = checkTuning( INC_data, comp_pulse_start, comp_pulse_end, flattop_start, flattop_end, ft_end_offset, thr1, thr2, thr3  )
%	checkTuning.m checks if the xbox's pulse compressor is properly tuned
%	or not. This is realized calculating the slope of the flattop with
%	two methods:
%   1) an interpolation method elaborated by theo in the script fw.m
%   2) a linear fit of the flattop 
% 
%   NOTE: the flattop_start generally is placed around 24 bins lefter than comp_pulse_start
%
%   Last modified 03.05.2016 by Eugenio Senes
    
    %prepare the output
    str_out = struct;
    
    %grasp the data
    x = 1:length(INC_data);
    x = x';
    y = INC_data;
    y = y';

    %METHOD 1
    x_cp = x(comp_pulse_start:comp_pulse_end);
    y_cp = y(comp_pulse_start:comp_pulse_end);
    try
        [med_1, ~, x1_1, x2_1, y1] = fw(x_cp,y_cp,thr1);
        [med_2, ~, x1_2, x2_2, y2] = fw(x_cp,y_cp,thr2);
        [med_3, ~, x1_3, x2_3, y3] = fw(x_cp,y_cp,thr3);

        %save the output
        str_out.fail_m1 = false;
        str_out.top.x1 = x1_1;
        str_out.top.x2 = x2_1;
        str_out.top.xm = med_1;
        str_out.top.y = y1;
        str_out.top.thr = thr1;
        str_out.mid.x1 = x1_2;
        str_out.mid.x2 = x2_2;
        str_out.mid.xm = med_2;
        str_out.mid.y = y2;
        str_out.mid.thr = thr2;
        str_out.bot.x1 = x1_3;
        str_out.bot.x2 = x2_3;
        str_out.bot.xm = med_3;
        str_out.bot.y = y3;
        str_out.bot.thr = thr3;
        
        %find the flattop end for fitting
        flattop_end = x2_1 - ft_end_offset;
    catch
        str_out.fail_m1 = true;
        %use default flattop end for fitting
    end

    %METHOD 2
    if flattop_end > flattop_start
        %good case, at least 2 points
        %window setting
        x_ft = x(flattop_start:flattop_end);
        y_ft = y(flattop_start:flattop_end);
        %flattop fitting
        try
            fit2 = fit(x_ft,y_ft,'poly1');
            str_out.fail_m2 = false;
            str_out.slope = fit2.p1;
        catch
            str_out.fail_m2 = true;
        end
    else
        %flattop too short
        str_out.fail_m2 = true;
    end
end

