function [ tf ] = dateEnd( filename, currEvent, nextEvent )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%conversion
filedate = datenum([filename '00:00:00'],'yyyymmddHH:MM:SS');
currEvent = currEvent(3:16);
currEvent = datenum(currEvent,'yyyymmddHHMMSS');
nextEvent = nextEvent(3:16);
nextEvent = datenum(nextEvent,'yyyymmddHHMMSS');
%test
if currEvent < filedate && nextEvent > filedate
    tf = true;
else
    tf = false;
end

end