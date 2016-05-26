function [ deltay ] = getDeltaPower( slope, x1, x2, varargin )
%   getDeltaPower.m returns the difference in height between the two points
%   of height y1 and y2, using a straight line of slope m
%   if varargin is 'abs' then give back the absolute value of the diference
%   !!!! x1 and x2 are in bins !

deltay = slope*(x2-x1);

if strcmpi(varargin, 'abs')
deltay = abs(deltay);
end
    
end

