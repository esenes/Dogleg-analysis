function [ tf, r1, m1, d1, r2, m2, d2, real_thr1, real_thr2] = spike_test_prev2_OR( data, win_start1, win_end1, win_start2, win_end2, thr, data_n1, data_n2 )
%	spike_test_prev2.m checks if a spike appened comparing the interlock
%	pulse with the two backup pulses.
%   The signal is first of all windowed, then is calculated the difference
%   between the interlock signal and the two previous pulses (separately).
%   To be detected as a spike the signal must overcome the treshold in at
%   least one of the two differences. 
%   The treshold is moving on the mean of the difference in order to avoid
%   the fake spike detection during klystrons ramp-ups.
%     
%   Inputs:
%     - data: list containing the interlock signal
%     - win_start1, win_end1: start and end of the first window (in bins)
%     - win_start2, win_end2: start and end of the second window (in bins)
%     - thr: level of treshold over the mean
%     - data_n1, data_n2: previous pulses
%     
%   Outputs:
%     - ts: bool output: 1=spike, 0=no spike
%     - r1: difference between the windowed data and the first spare pulse
%     - m1: mean of r1
%     - d1: standard deviation of r1
%     - r2: difference between the windowed data and the second spare pulse
%     - m2: mean of r2
%     - d2: standard deviation of r2
%     - real_thr1: used treshold for r1
%     - real_thr2: used treshold for r2
%
%   REV1. works quite well with the raw signals and the thr set at 0.015 
%   Last modified: 11.04.2016 by Eugenio Senes

%select just part of arrays and subtract
data = data([win_start1:win_end1 win_start2:win_end2]);
data_n1 = data_n1([win_start1:win_end1 win_start2:win_end2]);
data_n2 = data_n2([win_start1:win_end1 win_start2:win_end2]);
r1 = data-data_n1;
r2 = data-data_n2;

m1 = mean(r1);
d1 = std(r1);
m2 = mean(r2);
d2 = std(r2);

real_thr1 = m1+thr;
real_thr2 = m2+thr;

%test condition
if (max(r1)  > real_thr1 || max(r2) > real_thr2 )
    tf = true;
else
    tf = false;
end


end