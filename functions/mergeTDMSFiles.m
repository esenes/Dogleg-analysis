function [tdms_struct_out] = mergeTDMSFiles(files2analyse, dir_analysis,startTime,endTime)
if  ~isempty(files2analyse)
    if nargin>3        
        startDate = files2analyse(1,:);
        startDate = startDate(6:13);
        endDate = files2analyse(end,:);
        endDate = endDate(6:13);
        startTime_str = [startDate,strrep(startTime,':',''),'.000'];
        startTime_num = datenum(startTime_str,'yyyymmddHHMMSS.FFF');% * 24 * 3600; %in second
        endTime_str = [endDate,strrep(endTime,':',''),'.000'];        
        endTime_num = datenum(endTime_str,'yyyymmddHHMMSS.FFF');% * 24 * 3600; %in second
    end
    
    % load the structure of the first file
    load([[dir_analysis filesep],files2analyse(1,:)])
    
    if nargin>3
        [tdms_struct_out] = timeFilterTDMSFields(data_struct,startTime_num,endTime_num);
    else         
        tdms_struct_out = data_struct;
    end
    
    % load the structure of the rest of the files and combine them to one
    N_iter = size(files2analyse,1);
    for i=2:N_iter
        load([dir_analysis,files2analyse(i,:)])
        if i==N_iter && nargin>3
            [data_struct_out] = timeFilterTDMSFields(data_struct,startTime_num,endTime_num);
        end                     
        [tdms_struct_out] = combineTDMS_files(tdms_struct_out,data_struct_out);    
    end
else
    display('WARNING: The list of files to be merged is empty');
    tdms_struct_out = struct();
end
    
