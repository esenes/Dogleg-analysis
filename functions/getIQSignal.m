function [amplitude,phase,timescale] = getIQSignal(signalStruct_I,signalStruct_Q)
%	getIQSignal.m extract the raw IQ signals from the data structure.
%
%   Inputs:
%     - signalStruct_I: structure containing the I signal
%     - signalStruct_Q: structure containing the Q signal
%     
%   Outputs:
%     - amplitude:
%     - phase:
%     - timescale:
%     
%   Last modified: 13.04.2016 by Theodoros Argyropoulos 
    signal_I = signalStruct_I.data';
    signal_Q = signalStruct_Q.data';
    dt = signalStruct_I.Props.wf_increment;
%     npoints = signalStruct.Props.wf_samples;
%     timescale = 1e6*dt*(0:2000-1)';%in microseconds
    timescale = 1e6*dt*(0:length(signal_I)-1)';%in microseconds
    channel = signalStruct_I.Props.NI_ChannelName;
    channel = channel(6:8);
    sensitivity_I = signalStruct_I.Props.Sensitivity;
    sensitivity_Q = signalStruct_Q.Props.Sensitivity;
    
    calibFactors = IQ_calibFactors(channel);
    [amplitude, phase] = IQ_cal(signal_I,signal_Q,sensitivity_I,sensitivity_Q,calibFactors);
end