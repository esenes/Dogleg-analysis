function [ tf ] = rampUpTest( INC_r, INC_r_prev, xstart, xend, thr )
%   rampUpTest.m detects if the klystron is ramping up or not
%
%   Inputs:
%       - INC_r:            calibrated INC signal for current pulse
%       - INC_r_prev:       calibrated INC signal for previous pulse
%       - xstart, xend:     bins to calculate the integral
%       - thr:              treshold to decide. Normally a ramp-up event
%                           a ratio of ~0.5
%   
%   Outputs:
%       - tf: boolean result, 1 is ramping up
%       
%   Last modified: 02.09.2016 by Eugenio Senes

%calculate integrals
INC_int = sum(INC_r(xstart:xend));
INC_int_prev = sum(INC_r_prev(xstart:xend));

ratio = INC_int_prev/INC_int;
tf = ratio < thr; % ratio<thr is ramping up

end

