function calibFactors = IQ_calibFactors(channel)
%	IQ_calibFactors.m:
%   This function saves in the memory variables necessary to calibrate the IQ signals.
%
%   Inputs:
%   - channel: is the name of channel (INC, TRA, REF)
%
%   Outputs:
%   - calibFactors
%
%   Last modified: 13.04.2016 by Theodoros Argyropoulos 
    alpha = 'alpha';
    psi = 'psi';
    offset_I = 'offset_I';
    offset_Q = 'offset_Q';
    sf = 'sf';
    
    switch channel
        case 'INC'
            v_alpha = 0.9784;
            value_psi = 3.0257;
            value_offset_I = -3.8228;
            value_offset_Q = -8.7798;
%             value_sf = 10^(1/10)*2.927e-11;
            value_sf = 2.927e-11;
        case 'TRA'
            v_alpha = 0.9396;
            value_psi = 2.8976;
            value_offset_I = -3.9018;
            value_offset_Q = -9.5541;
%             value_sf = 10^(1/10)*1.829e-11; 
            value_sf = 1.829e-11;
        case 'REF'
            v_alpha = 0.9047;
            value_psi = 2.7508;
            value_offset_I = -5.1195;
            value_offset_Q = -9.6822;
%             value_sf = 10^(1/10)*2.144e-11;
            value_sf = 2.144e-11;
        otherwise
            warning('Unexpected channel name.');
    end
    
    calibFactors = struct(alpha,v_alpha,psi,value_psi,...
                          offset_I,value_offset_I,...
                          offset_Q,value_offset_Q,...
                          sf,value_sf);
                          
end        
