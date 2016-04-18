function [ beamLost ] = beamWasLost( event_name, bpm1_sum, bpm2_sum, bpm1_thr, bpm2_thr  )
%	beamWasLostk.m: check if the beam was lost using previous pulses
%
%   Last modified: 18.04.2016 by Eugenio Senes
try
    %extract from event name the name of prevous pulses
    name_L1 = [event_name(1:end-2) 'L1'];
    bpm1_sum_L1 = data_struct.name_L1.BPM1.sum_calibrated;
    bpm2_sum_L1 = data_struct.name_L1.BPM2.sum_calibrated;
    name_L2 = [event_name(1:end-2) 'L2'];
    bpm1_sum_L2 = data_struct.name_L2.BPM1.sum_calibrated;
    bpm2_sum_L2 = data_struct.name_L1.BPM2.sum_calibrated;

    %check if previous pulses had the beam
    prevBeam = bpm1_sum_L1<bpm1_thr | bpm2_sum_L1<bpm2_thr | bpm1_sum_L2<bpm1_thr | bpm2_sum_L2<bpm2_thr ;
    %check if both BPMs have the beam now
    nowBeam = bpm1_sum<bpm1_thr & bpm2_sum<bpm2_thr
    %output
    beamOk = prevBeam & nowBeam;
    beamLost = ~beamOk;

catch
    %error can be thrown for pulses with B0 only but not L1 and/or L2. In
    %that case just assume that the beam was not lost
    beamLost = 0;    
end

end

