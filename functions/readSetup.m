function [ pathR, pathT, pathE, pathP, pathF ] = readSetup()
%	readSetup.m reads the setup.dogleg file and returns the paths for
%	reading, temp and exp_files
%   
%   Last modified: 19.08.2016 by Eugenio Senes

[dirpath,~,~]=fileparts(mfilename('fullpath'));
mainDir = dirpath(1:end-10);
setupPath = [mainDir filesep 'setup.dogleg'];

fileID = fopen(setupPath, 'r');
if fileID == -1
    error('Generate a setup file first ! (Please run setup.m before this script)')
end

fullTxt = textscan(fileID,'%s %s %s %s %s %s %s %s %s %s');

pathR = fullTxt{2}{1};
pathT = fullTxt{2}{2};
pathE = fullTxt{2}{3};
pathP = fullTxt{2}{4};
pathF = fullTxt{2}{5};

fclose(fileID);

end