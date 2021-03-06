function [timeStamp_string_form] = get_tsString(fileName)
%get the file timestamp in the matlab format 'dd-mm-yyyy HH:MM:SS.FFF'
%
%   Last modified: 12.05.2016 by Eugenio Senes
    timeStamp = fileName(3:20);
    timeStamp_str = strrep(timeStamp,'_','.');
    timeStamp = datenum(timeStamp_str,'yyyymmddHHMMSS.FFF');
    timeStamp_string_form = datestr(timeStamp,'dd-mm-yyyy HH:MM:SS.FFF');
end

