function [ delay, delay_time ] = jitterCheck( sig_last, sig_prev, sf, sROI, eROI)
%	jitterCkeck.m: detects the delay between two signals caused by Jitter
%	of the trigger. 
%   
%   Inputs:
%   - sig_last:      last measured signal
%   - sig_prev:      previous measured signal
%   - sf:            sampling frequency
%   - sROI, eROI:    end and start of the region of interest
%   
%   Outputs:
%   - delay:        IF POSITIVE -> last is later than prev
%   - delay_time: 
%
%   Last modified: 17.08.2016 by Eugenio Senes

sig_last_ROI = sig_last(sROI:eROI);
sig_prev_ROI = sig_prev(sROI:eROI);
%find peaks
[pks_last, idx_last] = findpeaks(sig_last_ROI);
[pks_prev, idx_prev] = findpeaks(sig_prev_ROI);
%find highest peak position
[~, pks_last_idx] = max(pks_last);
[~, pks_prev_idx] = max(pks_prev);
max1 = idx_last(pks_last_idx) + sROI -1;
max2 = idx_prev(pks_prev_idx) + sROI -1;

delay = max1-max2;
delay_time = delay*sf;

end