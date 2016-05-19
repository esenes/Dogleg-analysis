function [ result_lst  ] = eventSelection( startDate, endDate, startTime, endTime, filename, iteration, field_names )
% eventselection.m: select the interesting events into the currently opened file in order 
% to remain into the interval of time defined into the input.
% This script is designed for tdms_struct ! (---> k starts by 2)
%   
%   Inputs:
%     - startDate, endDate: in the format 'yyyymmdd'
%     - stratTime, endTime: in the format 'HH:MM:SS'
%     - filename: name of the file processed at the moment
%     - iteration: number of the file processed at the moment
%     - field_names: list of the fields in the current file
%     
%   Outputs:
%     - cal_data: the list of calibrated data
% Last modified 27.04.2016 by Eugenio Senes

result_lst = {};
% one file case  
if length(filename) == 1     
    disp('One file case')

    for k=2:length(field_names)
        timeStamp{k} = field_names{k}(3:20);
        timeStamp{k} = strrep(timeStamp{k},'_','.');
        timeStamp{k} = datenum(timeStamp{k},'yyyymmddHHMMSS.FFF');% * 24 * 3600; %in second
        if timeStamp{k} >= datenum([startDate startTime],'YYYYmmddHH:MM:SS') && timeStamp{k} <= datenum([endDate endTime],'YYYYmmddHH:MM:SS')
            result_lst = [result_lst field_names{k}];
        end
    end
% many files, first case
elseif length(filename) ~= 1 && iteration == 1
        disp('first file case')

    for k=2:length(field_names)
        timeStamp{k} = field_names{k}(3:20);
        timeStamp{k} = strrep(timeStamp{k},'_','.');
        timeStamp{k} = datenum(timeStamp{k},'yyyymmddHHMMSS.FFF');% * 24 * 3600; %in second
        if timeStamp{k} >= datenum([startDate startTime],'YYYYmmddHH:MM:SS')
            result_lst = [result_lst field_names{k}];
        end
    end    
% many files, last case
elseif length(filename) ~= 1 && iteration == length(filename)
        disp('last file case')

    for k=2:length(field_names)
        timeStamp{k} = field_names{k}(3:20);
        timeStamp{k} = strrep(timeStamp{k},'_','.');
        timeStamp{k} = datenum(timeStamp{k},'yyyymmddHHMMSS.FFF');% * 24 * 3600; %in second
        if timeStamp{k} <= datenum([endDate endTime],'YYYYmmddHH:MM:SS')
            result_lst = [result_lst field_names{k}];
        end
    end
%many files, files in the middle    
else
        disp('middle file case')
        
    result_lst = [result_lst  field_names{2:end}];
end
    
end
