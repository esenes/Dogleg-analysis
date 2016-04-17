function [files2analyse] = files2Analyse(startDate, endDate, dir_analysis, filetype)
% files2Analyse.m:  
% This script returns the list of files to analyse in the folder within the
% dates:
%   Inputs:
%   - startDate, endDate: in the format 'yyyymmdd'
%   - dir_analysis: path to load the files 'Prod_*.mat' or 'Data_*.mat',
%     without the filesep at the end  
%   - filetype: 1 = 'Prod_*.mat'
%               2 = 'Data_*.mat'
%   
%   Outputs:
%   - files2analyse: is a char matrix containing the filenames.
%
% Last modified 17.04.2016 by Eugenio Senes
    if filetype==1
        nameString = 'Prod*.mat';
        fdate_indexes = (6:13);
    elseif filetype==2
        nameString = 'Data*.mat';
        fdate_indexes = (6:13);
    end
    
    datafiles = dir([[dir_analysis filesep],nameString]);
    
    StartDate_num = datenum(startDate,'yyyymmdd');
    EndDate_num = datenum(endDate,'yyyymmdd');
    counter = 0;
    files2analyse = [];
    for i=1:length(datafiles)
        fname = datafiles(i).name;
        fdate = fname(fdate_indexes);
        fDate_num = datenum(fdate,'yyyymmdd');
        if fDate_num>=StartDate_num && fDate_num<=EndDate_num
            if counter==0
                files2analyse = fname;
            else
                files2analyse = [files2analyse;fname];
            end
            counter = counter +1;
        end
    end    
end
 