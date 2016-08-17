function [time_ind] = getDeviationPoint(timescale,signal_B0,signal_L1,tsignal,deviationLevel,noiseLevel)

    y_in = abs(signal_B0 - signal_L1);

%     time_ind = find(y>=deviationLevel,1,'first');
%     if isempty(time_ind)
%         time_ind = length(timescale);
%     else
%         time_ind_min = find(y(1:time_ind)<=noiseLevel,1,'last');
%         time_ind = time_ind_min;
%     end
    
    
    %check after a certain time of the signal tsignal
%     tsignal = 1.69e-6; %seconds
    index_start = find(timescale>=tsignal,1,'first');
    y = y_in(index_start:end);
    time_ind = find(y>=deviationLevel,1,'first');
    try
        [pks_v,pks_i]  = findpeaks(y(1:time_ind),'MINPEAKHEIGHT',0.01);
    catch
        pks_i = [];
    end
    
    if ~isempty(pks_i)
        time_ind-pks_i(end);
    end
    
    if nargin<6
        noiseLevel = mean(y(1:10));
    end
    
    if ~isempty(pks_i) && time_ind-pks_i(end)<10
        time_ind = pks_i(end);
    end
    
    if isempty(time_ind)
        time_ind = length(timescale);
    else
        time_ind_min = find(y(1:time_ind)<=noiseLevel,1,'last');
        if isempty(time_ind_min)
            while isempty(time_ind_min) 
                noiseLevel = 0.02*noiseLevel + noiseLevel;
                time_ind_min = find(y(1:time_ind)<=noiseLevel,1,'last');
            end
        end
        if (time_ind-time_ind_min>15)
            while (time_ind-time_ind_min>15)
                noiseLevel = 0.02*noiseLevel + noiseLevel;
                time_ind_min = find(y(1:time_ind)<=noiseLevel,1,'last');
            end
        end        
        
        
        time_ind = time_ind_min + index_start - 1;

%         
%         if isempty(time_ind_min)
%             time_ind = length(timescale);
%         else
%             time_ind = time_ind_min + index_start - 1;
%         end
    end

    
    
%     figure
%     plot(timescale,signal_B0,timescale,signal_L1,timescale,y_in,timescale(index_start:end),y_in(index_start:end),timescale(time_ind),y_in(time_ind),'.','MarkerSize',18)