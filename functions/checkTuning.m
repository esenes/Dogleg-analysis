function [ str_out, str_peak, str_avg ] = checkTuning( INC_data, comp_pulse_start, comp_pulse_end, flattop_start, flattop_end, ft_end_offset, thr1, thr2, thr3  )
%	checkTuning.m checks if the xbox's pulse compressor is properly tuned
%	or not. This is realized calculating the slope of the flattop with
%	two methods:
%   1) an interpolation method elaborated by theo in the script fw.m
%   2) a linear fit of the flattop 
%   It also calculate the peak and the average power in the pulse. Note
%   that the average is calculated between the lefter bin with 85% of the
%   max power and the righter bin with the 85% of the max power. What happends
%   in the middle is not considered
% 
%   NOTE:   the flattop_start generally is placed around 24 bins lefter 
%           than comp_pulse_start
%   NOTE2:  the flattop_end is generally setted dynamically if no errors
%           occours
%   ATTENTION: thr1 is the higher!
%
%   Inputs:
%       - INC_data: data array
%       - comp_pulse_start, comp_pulse_end: start and end of the
%                                           compressed pulse
%       - flattop_start, flattop_end: start and end of the flattop
%       - ft_end_offset:    number of bins before the left point at thr1 to
%                           set the end of the flattop
%       - thr1,thr2,thr3:   the tresholds used, higher to lower
% 
%   Outputs:
%       - str_out:  a structure containing data about the 2 methods of
%                   tuning check
%       - str_peak: a structure containing infos on the peak power of the
%                   pulse
%       - str_avg: a structure containing infos on average power of the
%                   pulse, and the ROI
% 
%   Last modified 03.05.2016 by Eugenio Senes
    %minimal length 
    minL = 5;
    
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
        [med_1, peak, x1_1, x2_1, y1] = fw(x_cp,y_cp,thr1);
        [med_2, ~, x1_2, x2_2, y2] = fw(x_cp,y_cp,thr2);
        [med_3, ~, x1_3, x2_3, y3] = fw(x_cp,y_cp,thr3);

        %build the output 1
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
        %build the output 2
        str_peak = peak;
        %build the output 3
        str_avg.start = ceil(x1_1);
        str_avg.end = ceil(x2_1);
        str_avg.INC_avg = mean(y(str_avg.start:str_avg.end));
        
        %find the flattop end for fitting
        flattop_end = round(x2_1 - ft_end_offset);
        if flattop_end > flattop_start+minL
            %if the new end has at least 5 points, use the modified one,
            %else the 85% point
            flattop_end = round(x2_1 - ft_end_offset);
        else
            flattop_end = round(x2_1);
        end
    catch
        str_out.fail_m1 = true;
        str_peak = max(INC_data);
        %use default flattop end for fitting
        
        %for the average use the 
        overthr = find(INC_data > thr1*max(INC_data));
        str_avg.start = overthr(1);
        str_avg.end = overthr(end);
        str_avg.INC_avg = mean(y(str_avg.start:str_avg.end));
    end

    %METHOD 2
    %good case, at least 2 points
    %window setting
    x_ft = x(flattop_start:flattop_end);
    y_ft = y(flattop_start:flattop_end);
    %flattop fitting
    try
        fit2 = fit(x_ft,y_ft,'poly1');
        str_out.fail_m2 = false;
        str_out.slope = fit2.p1;
        str_out.x1 = x(1);
        str_out.x2 = x(end);
    catch
        str_out.fail_m2 = true;
    end

end
