close all; clearvars; clc;
% datapath_read = 'Z:\matfiles';
datapath_read = '/Users/esenes/Dropbox/work/Analysis_with_beam';
startDate = '20160324';
endDate = '20160326';
startTime = '19:30:00';
endTime = '12:59:59';

%%

%build file list
[filenames_full] = files2Analyse(startDate, endDate, datapath_read, 1);
filename = get_dates(filenames_full);
disp('Start processing files:')

if datenum([startDate startTime],'YYYYmmddHH:MM:SS') > datenum([endDate endTime],'YYYYmmddHH:MM:SS')
    error('End is preceding the start !')
end

fileOver  = false;

for j = 1:length(filename) %loop over dates
    disp(['Loading file ' num2str(j) ' on ' num2str(length(filename)) ])
    load([datapath_read filesep 'Prod_' filename{j} '.mat']);
    
    
    
    field_names_out = eventSelection( startDate, endDate, startTime, endTime, filename, j, field_names );
    disp(['first: ' field_names_out{1} ' second: ' field_names_out{2} ... 
        'last: ' field_names_out{end}])
    disp(' ')
    
    if 
        fileOver = true;
    end
    
    if fileOver
        save([datapath_read filesep 'out' num2str(j) '.mat'],)
        fileOver = false;
    end
end
