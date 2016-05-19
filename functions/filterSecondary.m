function [keep_index, discard_index] = filterSecondary(timeSeconds,deltaTime,varargin)
%	filtersecondary.m: checks if is there another event within deltatime
%	from the trigger flag in the bool array varargin.
%   Example of call: filterSecondary(timestampss_array,deltaTime_spike,isSpike)
%
%   NOTE: the events in the trigger list are flagged as ones.
% 
%   Inputs:
%       - timeseconds:  list of timestamps in datetime matlab fromat
%       - deltatime:    is the width of the search window
%       - varagin:      is the trigger list 
% 
%   Outputs: (both are bool arrays)
%       - keep_index:   elements out of the search window
%       - discard_index:elements into the search windows
% 
%   Last modified ??? by Theodoros Argyropoulos  

    N_all_BDs = length(timeSeconds);
    keep_index = ones(N_all_BDs,1);
    
    N = length(varargin);
    PreviousValue = zeros(1,N);
    timePrevious  = zeros(1,N);
    Flag = zeros(N_all_BDs,N);
    for k=1:N
        Flag(:,k) = varargin{k};
    end
            
    for i=1:N_all_BDs
        for j=1:N
            if PreviousValue(j)
                dtime = (timeSeconds(i)-timePrevious(j))* 24 * 3600; %in seconds
                if dtime>deltaTime
                    PreviousValue(j) = 0;
                else
                    keep_index(i) = 0;
                end
            end

            if Flag(i,j)
                PreviousValue(j) = 1;
                timePrevious(j) = timeSeconds(i);
            end
        end

    end
    keep_index = keep_index';
    discard_index = ~keep_index;
end