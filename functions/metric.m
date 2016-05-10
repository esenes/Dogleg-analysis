function [ val ] = metric( INC, TRA )
%	metric.m returns 
%   (sum(INC) - sum(TRA))/(sum(INC) + sum(TRA)) 
%   !!! calculating the sums, is subtracted the baseline (mean of first 30 data)
%
%   REV1. Last modification: 12.04.2106 by Eugenio Senes
INC_sum = sum(INC-mean(INC(1:30)));
TRA_sum = sum(TRA-mean(TRA(1:30)));

val = (INC_sum - TRA_sum)/(INC_sum + TRA_sum);

end
