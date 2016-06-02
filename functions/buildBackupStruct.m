function [ exp_struct ] = buildBackupStruct( datapath, startDate, startTime, endDate, endTime )
%	Is the same of buildExperimentStruct.m, but it loads the structures
%	called normal_struct of the backup pulses from the files.
%
%   Inputs:
%   - datapath: path to load the files 'Data_<date>.mat', without the 
%     filesep at the end  
%   - startDate, endDate: in the format 'yyyymmdd'
%   - startTime, endTime: int the format 'HH:MM:SS'
%   
%   Outputs:
%   - exp_struct: a struct merging the data files in the interesting time
%     range
%
%   Last modified: 02.06.2016 by Eugenio Senes
fname = 'Norm_';

[filenames_full_gen] = files2Analyse(startDate, endDate, datapath, 2);
filename = get_dates(filenames_full_gen);
rem_pulses = [];
%init output struct
exp_struct = struct();


for i = 1:length(filename)
    load([datapath filesep fname filename{i} '.mat'])
    %delete the 'Props' field from the struct
    normal_struct = rmfield(normal_struct,'Props');
    
    %select only timestamps in range
    if i == 1 %discard everything before startTime
        %get fnames and reduce it to just the date/timestamps
        fnames = fieldnames(normal_struct);
        for j = 1:length(fnames) 
            timeStamp{j} = fnames{j}(3:20);
            timeStamp{j} = strrep(timeStamp{j},'_','.');
            timeStamp{j} = datenum(timeStamp{j},'yyyymmddHHMMSS.FFF');% * 24 * 3600; %in second
            if timeStamp{j} >= datenum([startDate startTime],'YYYYmmddHH:MM:SS')
                exp_struct.(fnames{j}) = normal_struct.(fnames{j});
            end
        end
    elseif i == length(filename) %copy everything up to the stop time
        fnames = fieldnames(normal_struct);
        for j = 1:length(fnames) 
            timeStamp{j} = fnames{j}(3:20);
            timeStamp{j} = strrep(timeStamp{j},'_','.');
            timeStamp{j} = datenum(timeStamp{j},'yyyymmddHHMMSS.FFF');% * 24 * 3600; %in second
            if timeStamp{j} <= datenum([endDate endTime],'YYYYmmddHH:MM:SS')
                exp_struct.(fnames{j}) = normal_struct.(fnames{j});
            end
        end
    else %other dates, fully loaded
        % add the remaining pulse count from the last file to first event
        fnames = fieldnames(normal_struct);
        % then copy all to the output
        for j = 1:length(fnames)
            exp_struct.(fnames{j}) = normal_struct.(fnames{j});
        end
    end
    %append normal_struct to exp_struct
end



end