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

% fullTxt = textscan(fileID,'%s %q','Delimiter', '\n')
fullTxt = textscan(fileID,'%s','Delimiter','\n');

pathR = fullTxt{1}{1}(16:end);
pathT = fullTxt{1}{2}(17:end);
pathE = fullTxt{1}{3}(15:end);
pathP = fullTxt{1}{4}(12:end);
pathF = fullTxt{1}{5}(11:end);

fclose(fileID);

end