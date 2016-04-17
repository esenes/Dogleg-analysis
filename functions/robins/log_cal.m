function y = log_cal(x,offset,scale,att_factor,att_factor_dB,unit_scale)
% Calibrate log-detector signals (written for Dogleg)
%
% Last modified: 12.08.2015

% Conversion to double
x = double(x);
offset = double(offset);
scale = double(scale);
att_factor = double(att_factor);
att_factor_dB = double(att_factor_dB);
unit_scale = double(unit_scale);

% Calibration
win_offset = 1:50; % baseline window
% y=exp((x-mean(x(win_offset))+offset)*scale)*att_factor;
y = exp((x-mean(x(win_offset))+offset)*scale)*att_factor*10^(att_factor_dB/10)*unit_scale;
    
end