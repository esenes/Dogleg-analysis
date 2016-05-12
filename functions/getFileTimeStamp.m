function [timeStamp_str, timeStamp] = getFileTimeStamp(fileName)
%get the file timestamp in the matlab format 'yyyymmddHHMMSS.FFF'
%
%   Last modified: 13.04.2016 by Theodoros Argyropoulos 
    timeStamp = fileName(3:20);
    timeStamp_str = strrep(timeStamp,'_','.');
    timeStamp = datenum(timeStamp_str,'yyyymmddHHMMSS.FFF');
end