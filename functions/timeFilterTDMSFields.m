function [tdms_struct_out] = timeFilterTDMSFields(data_struct,startTime_num,endTime_num)
% filter the objects of the structure with respect 
%to time interval: (startTime_num< t <endTime_num)
    tdms_files = fieldnames(data_struct);
    tdms_struct_out = struct();
    for i=1:length(tdms_files)
        fileName = data_struct.(tdms_files{i}).name;
        timeStamp = fileName(3:20);
        timeStamp = strrep(timeStamp,'_','.');
        timeStamp_num = datenum(timeStamp,'yyyymmddHHMMSS.FFF');% * 24 * 3600; %in second
        if (timeStamp_num>=startTime_num && timeStamp_num<=endTime_num)
            tdms_struct_out.(tdms_files{i})=data_struct.(tdms_files{i});
        end
    end