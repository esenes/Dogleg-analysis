function [ hasBeam, bpm1_flag, bpm2_flag ] = beamCheck( bpm1, bpm1_thr, bpm2, bpm2_thr )
%	beamCheck.m: returns a list of bool if in both the bpms the charge is
%	overcoming the treshold
%
%   Last modified: 18.04.2016 by Eugenio Senes

    % remeber negative signals !
    bpm1_flag = bpm1 < bpm1_thr;
    bpm2_flag = bpm2 < bpm2_thr;
    hasBeam = bpm1_flag & bpm2_flag;

end

