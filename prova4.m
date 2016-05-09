close all; clearvars; clc;
datapath = 'D:\Dropbox\work';
% datapath = '/Users/esenes/Dropbox/work';
startDate = '20160324';
endDate = '20160326';

%% converting dates and check
sd = datenum([startDate '00:00:00'],'yyyymmddHH:MM:SS');
ed = datenum([endDate '23:59:59'],'yyyymmddHH:MM:SS');

%list file in folder
d = dir([datapath filesep 'Data*.mat' ]);
d = d(~ismember({d.name},{'.','..'}));
filename = extractfield(d,'name');
datelist = {};
for i =1:length(filename)
    datelist = [datelist filename{i}(6:13)];
end
%init structures to store temp data

for i=1:(length(filename)-1)
    if i == 1 
        data(i) = load([datapath filesep filename{i}]);
    end
    data(i+1) = load([datapath filesep filename{i+1}]);
    
    %check if in the next file are there fields to move to the first one
    curr_date = datelist{i+1};
    fields_next = fieldnames(data(i+1).data_struct);
    good = {};
    bad = {};    
    for m = 1:length(fields_next)-1%discard last field
        if str2num(fields_next{m}(3:10)) < str2num(curr_date)
            disp(fields_next{m})
            data(i).data_struct.(fields_next{m}) = data(i+1).data_struct.(fields_next{m});
            data(i+1).data_struct = rmfield(data(i+1).data_struct,(fields_next{m}));
        end
    end

    
    disp(['Progress ' num2str(0.01* i/(length(filename)-1)) ' %'])
end


% 
% fileOver  = false;
% 
% for j = 1:length(filename) %loop over dates
%     disp(['Loading file ' num2str(j) ' on ' num2str(length(filename)) ])
%     load([datapath_read filesep 'Prod_' filename{j} '.mat']);
%     
%     
%     
%     field_names_out = eventSelection( startDate, endDate, startTime, endTime, filename, j, field_names );
%     disp(['first: ' field_names_out{1} ' second: ' field_names_out{2} ... 
%         'last: ' field_names_out{end}])
%     disp(' ')
%     
%     if 
%         fileOver = true;
%     end
%     
%     if fileOver
%         save([datapath_read filesep 'out' num2str(j) '.mat'],)
%         fileOver = false;
%     end
% end
