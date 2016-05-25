function [ deltay ] = getDeltaPower( slope, x1, x2 )
%   getDeltaPower.m returns the difference in height between the two points
%   of height y1 and y2, using a straight line of slope m
%
%   !!!! x1 and x2 are in bins !

deltay = slope*(x2-x1);
deltay = abs(deltay);

end

