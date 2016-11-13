function [ exp_struct ] = buildExperimentStruct( datapath, startDate, startTime, endDate, endTime )
%	buildExperimentStruct.m:
%   This function merges the data_struct from the startDate and startTime
%   to the endDate at endTime.
%   The remaining number of pulses inherited from the last B0 is also
%   charged to the same counter to the next BD changing the file.
%   !!! This is not made for the last file, which is supposed to be the end
%   of the experiment !!!
%   The output is the merged structure containing the data of the whole
%   experiment.
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
%   Last modified: 17.04.2016 by Eugenio Senes
fname = 'Data_';

[filenames_full_gen] = files2Analyse(startDate, endDate, datapath, 2);
filename = get_dates(filenames_full_gen);
rem_pulses = [];
%init output struct
exp_struct = struct();


for i = 1:length(filename)
    load([datapath filesep fname filename{i} '.mat'])
    %data_struct is temporary now
    rem_pulses(i) = data_struct.pulse_delay_from_last;
    %delete the 'pulse_delay_from_last' field from the struct
    data_struct = rmfield(data_struct,'pulse_delay_from_last');
    data_struct = rmfield(data_struct,'Props');
    
    disp([num2str(i) ' / ' num2str(length(filename))])
    
    
    %select only timestamps in range
    if i == 1 %discard everything before startTime
        %get fnames and reduce it to just the date/timestamps
        fnames = fieldnames(data_struct);
        for j = 1:length(fnames) 
            timeStamp{j} = fnames{j}(3:20);
            timeStamp{j} = strrep(timeStamp{j},'_','.');
            timeStamp{j} = datenum(timeStamp{j},'yyyymmddHHMMSS.FFF');% * 24 * 3600; %in second
            if timeStamp{j} >= datenum([startDate startTime],'YYYYmmddHH:MM:SS')
                exp_struct.(fnames{j}) = data_struct.(fnames{j});
            end
        end
    elseif i == length(filename) %copy everything up to the stop time
        fnames = fieldnames(data_struct);
        for j = 1:length(fnames) 
            timeStamp{j} = fnames{j}(3:20);
            timeStamp{j} = strrep(timeStamp{j},'_','.');
            timeStamp{j} = datenum(timeStamp{j},'yyyymmddHHMMSS.FFF');% * 24 * 3600; %in second
            if timeStamp{j} <= datenum([endDate endTime],'YYYYmmddHH:MM:SS')
                exp_struct.(fnames{j}) = data_struct.(fnames{j});
            end
        end
    else %other dates, fully loaded
        % add the remaining pulse count from the last file to first event
        fnames = fieldnames(data_struct);
        data_struct.(fnames{1}).Props.Prev_BD_Pulse_Delay = data_struct.(fnames{1}).Props.Prev_BD_Pulse_Delay + rem_pulses(i-1);
        % then copy all to the output
        for j = 1:length(fnames)
            exp_struct.(fnames{j}) = data_struct.(fnames{j});
        end
    end
    %append data_struct to exp_struct
end



end