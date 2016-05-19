function [ cal_data ] = bpmcal( data , BPM_name)
%	bpmcal.m take a list containing the bpm readings and calibrate it.
%   Calibration parameters are hardcoded and were provided by J.G.Navarro 
%   on 05.04.2016 via email
%   
%   Inputs:
%     - data: list containing the bpm signal
%     - BPM_name: string containing the name of the BPM. Not case
%       insensitive
%     
%   Outputs:
%     - cal_data: the list of calibrated data
%     
%   Last modified: 05.04.2016 by Eugenio Senes
Slope = 0;
Offset = 0;

switch upper(BPM_name)
    case 'BPM1'
        Slope = 3.6579;
        Offset = -3.6579;
    case 'BPM2'
        Slope = 3.7647;
        Offset = -3.7647;
    otherwise
        warning('BPM type not recognized, impossible to calibrate data')
end

cal_data = Slope*data + Offset;

end
