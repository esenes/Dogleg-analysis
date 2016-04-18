function [amplitude, phase] = IQ_cal(signal_I,signal_Q,sensitivity_I,sensitivity_Q,calibFactors)
%	IQ_cal.m Calibrate IQ-signals (written for Dogleg)
%     
%   Inputs:
%     - signal_I: 
%     - signal_Q: 
%     - sensititvity_I: 
%     - sensititvity_Q: 
%     - calibFactors: 
%     
%   Outputs:
%     - amplitude:
%     - phase:
%
%   Modified before: 01.02.2016 by Robin Rajamäki 
    psi = calibFactors.psi;
    alpha = calibFactors.alpha;
    offset_I = calibFactors.offset_I;
    offset_Q = calibFactors.offset_Q;
    sf = calibFactors.sf;
    
    psi_rad = psi*pi/180;

    % conversion to double
    I = double(signal_I);
    Q = double(signal_Q);
    
    % Sensitivity
    I_cal_1 = double(sensitivity_I)*I;
    Q_cal_1 = double(sensitivity_Q)*Q;
    
    % Offset 1
    I_cal_2 = I_cal_1 - offset_I;
    Q_cal_2 = Q_cal_1 - offset_Q;
    
    % Ellipse to circle
    I_cal = I_cal_2/alpha;
    Q_cal = Q_cal_2/cos(psi_rad)-I_cal_2*tan(psi_rad)/alpha;
    
    % Offset 2
    win_offset = 1:50;
    I_cal = I_cal - mean(I_cal(win_offset));
    Q_cal = Q_cal - mean(Q_cal(win_offset));
    
    % Power and phase
    amplitude = I_cal.^2+Q_cal.^2;
    phase = atan2(Q_cal,I_cal);
   
    % Final scaling
    amplitude = amplitude/sf;
    
end
