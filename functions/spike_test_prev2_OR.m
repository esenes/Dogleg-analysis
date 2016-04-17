function [ tf, r1, m1, d1, r2, m2, d2, real_thr1, real_thr2] = spike_test_prev2_OR( data, win_start1, win_end1, win_start2, win_end2, thr, data_n1, data_n2 )
%	spike_test_prev2.m checks if a spike appened
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%fare una reference
%   decente
%   !!!!!!!!!!!! returns true if at least one treshold is overcome !!!!!!!
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