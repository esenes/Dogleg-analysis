%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup.m:  
% Welcome to the dogeg analysis setup program. This script is going to
% create the setup file for the dogleg-analysis script.
%
% Just run it and follow instructions !
% 
% REV. 1. by Eugenio Senes and Theodoros Argyropoulos
%
% Last modified 29.08.2016 by Eugenio Senes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[dirpath,~,~]=fileparts(mfilename('fullpath'));

fileID = fopen([dirpath filesep 'setup.dogleg'],'w+');
%ask for paths
disp('Select Prod data folder:')
datapath_read_RMAS = uigetdir(dirpath, 'Selet Prod data source')
disp('Select temp data folder:')
datapath_write_RMAS = uigetdir(dirpath,'Select temp data folder:')
disp('Select analyzed data folder:')
exppath_write_RMAS = uigetdir(dirpath,'Select analyzed data folder:')
disp('Select plots folder:')
plot_path = uigetdir(dirpath,'Select plots folder:')
disp('Select figs folder:')
fig_path = uigetdir(dirpath,'Select fig folder:')
%check valid path
if ischar(datapath_read_RMAS) && ischar(datapath_write_RMAS) && ischar(exppath_write_RMAS) ...
        && ischar(plot_path) && ischar(fig_path)
    %build the file
    msg =['datapath_read= ' datapath_read_RMAS '\n'...
        'datapath_write= ' datapath_write_RMAS '\n'...
        'exppath_read= ' exppath_write_RMAS '\n'...
        'plot_path= ' plot_path '\n'...
        'fig_path= ' fig_path '\n'...
        ];
    fprintf(fileID,msg);
    fclose(fileID);    
else
    error('Entered an invalid path')
end
