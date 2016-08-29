function [ pathR, pathT, pathE ] = readSetup()
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
%     - cal_data
%     
%   Last modified: 05.04.2016 by Eugenio Senes
[dirpath,~,~]=fileparts(mfilename('fullpath'));
mainDir = dirpath(1:end-10);
setupPath = [mainDir filesep 'setup.dogleg'];

fileID = fopen(setupPath, 'r');
fullTxt = textscan(fileID,'%s %s %s %s %s %s ');

pathR = fullTxt{2}{1};
pathT = fullTxt{2}{2};
pathE = fullTxt{2}{3};

fclose(fileID);

end