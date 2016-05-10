function [ inMetric, inc_tra_flag, inc_ref_flag ] = metricCheck( inc_tra, inc_tra_thr, inc_ref, inc_ref_thr )
%	metricCheck.m: returns a list of bool if both the metrics are
%	overcoming the tresholds
%
%   Last modified: 18.04.2016 by Eugenio Senes

    inc_tra_flag = inc_tra > inc_tra_thr;
    inc_ref_flag = inc_ref < inc_ref_thr;
    inMetric = inc_tra_flag & inc_ref_flag;
    
end

