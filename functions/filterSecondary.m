function [keep_index] = filterSecondary(timeSeconds,deltaTime,varargin)
% deltaTime is in s
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
    
end