function [timeStamp_str, timeStamp_string_form,timeStamp] = getFileTimeStamp(fileName)
%get the file timestamp in the matlab format 'yyyymmddHHMMSS.FFF'
%
%   Last modified: 13.04.2016 by Theodoros Argyropoulos 
    timeStamp = fileName(3:20);
    timeStamp_str = strrep(timeStamp,'_','.');
    timeStamp = datenum(timeStamp_str,'yyyymmddHHMMSS.FFF');
    timeStamp_string_form = datestr(timeStamp,'dd-mm-yyyy HH:MM:SS.FFF');
end