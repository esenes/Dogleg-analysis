function [ pathR, pathT, pathE, pathP, pathF ] = readSetup()
%	readSetup.m reads the setup.mat file and returns the paths for
%	reading, temp and exp_files and for saving plots
%
%   REV. 2: windows compatible
%   
%   Last modified: 31.08.2016 by Eugenio Senes

[dirpath,~,~]=fileparts(mfilename('fullpath'));
mainDir = dirpath(1:end-10);
setupPath = [mainDir filesep 'setup.mat'];

load(setupPath);

pathR = datapath_read_RMAS;
pathT = datapath_write_RMAS;
pathE = exppath_write_RMAS;
pathP = plot_path;
pathF = fig_path;



end