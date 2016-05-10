function [hasSpike, filteredSignal] = filterSpikes_W(x,Hd,spikeThreshold,point2Start,point2Stop)
% filetrSpikes_W.m:  
% This script applies the digital filter in order to sort out the spikes
%   
%   Inputs:
%   - x: data
%   - Hd: filter's transfer function object
%   - point2start, point2stop: are options for manual windowing, default
%     values are hardcode if uncalled
%   
%   Outputs:
%   - hasSpike: is a boolean, true if a spike is detected
%   - filteredSignal: is the filtered signal waveform
%
% Last modified 13.04.2016 by Theodoros Argyropoulos
%
%
%   REV2. added the factor 1e6 to the x in order to call the filter in MW
%   insthead of in Watts. This is necessary in order to use the hardcoded 
%   tresholds. To call in Watts use filetrSpikes.m  (Eugenio 26.04.2016)

    if nargin<3
        spikeThreshold = 4.5;
        point2Start = 200; 
        point2Stop = 470;            
    elseif nargin<4
        point2Start = 200; 
        point2Stop = 470;            
    elseif nargin<5
        point2Stop = 470;                        
    end

    x = x*1e-6;
    
    filteredSignal = filter(Hd,x);
    if max(abs(filteredSignal(point2Start:point2Stop)))>= spikeThreshold;
        hasSpike = 1;
    else
        hasSpike = 0;
    end
end