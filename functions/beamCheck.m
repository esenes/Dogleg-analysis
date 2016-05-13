function [ hasBeam, bpm1_flag, bpm2_flag] = beamCheck( bpm1, bpm1_thr, bpm2, bpm2_thr, mode)
%	beamCheck.m: returns a list of bool if in both the bpms the charge is
%	overcoming the treshold
%   
%   Inputs:
%       - [...]
%       - mode: is the logic function to determine the hasBeam value. 
%         Allowed 'or', 'and', 'bpm1', 'bpm2' (the last two just ignore 
%         the other BPM)

%   Outputs:
%       - hasBeam: bool returning the prescence of beam according to the 
%         mode logic function
%       - bpm1_flag: bool
%       - bpm2_flag: bool
%       
%
%   Last modified: 18.04.2016 by Eugenio Senes

    % remeber negative signals !
    bpm1_flag = bpm1 < bpm1_thr;
    bpm2_flag = bpm2 < bpm2_thr;
    if strcmpi(mode,'and')
        hasBeam = bpm1_flag & bpm2_flag;
    elseif strcmpi(mode,'or')
        hasBeam = bpm1_flag | bpm2_flag;
    elseif strcmpi(mode,'bpm1')
        hasBeam = bpm1_flag;
    elseif strcmpi(mode,'bpm2')
        hasBeam = bpm2_flag;
    else
        error('Unknown logical function')
    end
end