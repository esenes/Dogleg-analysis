%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% positioningPlot.m:  
% This script is intended to genrate the positioning plot and the cell
% assignament of every BD, after the manual positioning in the 
% filtering.m stage.
% 
% REV. 1. by Eugenio Senes and Theodoros Argyropoulos
%
% Last modified 14.09.2016 by Eugenio Senes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load part
data_auto = data_struct;
clearvars -except data_auto

%check if the positioning has been done
if data_struct.Analysis.positioning == 0
    error('Positioning has not been done during filtering. Please come back and do it')
end

edge_tra_time = zeros(1,length(BDs_ts));
edge_ref_time = zeros(1,length(BDs_ts));
flag_corr_fail = zeros(1,length(BDs_ts));

count=0;
mancorr = {};
for k=1:length(BDs_ts)
    if isfield(data_struct.(BDs_ts{k}),'position')
        disp(BDs_ts{k})
        mancorr = [mancorr BDs_ts{k}];
        count = count+ 1;
        
        %data_bak.(BDs_ts{k}) = data_struct.(BDs_ts{k});
        
%         flag_corr_fail(k) = data_struct.(BDs_ts{k}).position.correlation.fail;
%         edge_tra_time(k) = data_struct.(BDs_ts{k}).position.edge.time_TRA;
%         edge_ref_time(k) = data_struct.(BDs_ts{k}).position.edge.time_REF;
        
%         if isfield(data_struct.(BDs_ts{k}).position.correlation,'fail')
%             flag_corr_fail(k) = data_struct.(BDs_ts{k}).position.correlation.fail;
%             disp('fail flag')
%         else
%             flag_corr_fail(k) = -1;
%         end
    end
end
disp(count)

for k=1:length(mancorr)
    
    disp(data_struct.(mancorr{k}).position.correlation.delay_time)
    if isfield(data_struct.(mancorr{k}).position.correlation,'fail') 
        disp(data_struct.(mancorr{k}).position.correlation.fail)
    else
        % add missing fail fields
        disp('no fail field')
        data_struct.(mancorr{k}).position.correlation.fail = false;
    end
        %data_full.(BD_s_tocorr{k}) = data_struct.(BD_s_tocorr{k});
    
end


data_bak = data_struct;
clearvars data_struct
data_struct = data_auto;
%data substitution
for k=1:length(mancorr)
    
    data_struct.(mancorr{k}).position = data_bak.(mancorr{k}).position;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate lists for plots
close all;


delayEdge = [];
delayCorr = [];
failCorrCount = 0;
for k = 1:length(BDs_ts)
    %edge
    tR = data_struct.(BDs_ts{k}).position.edge.time_REF;
    tT = data_struct.(BDs_ts{k}).position.edge.time_TRA;
    delayEdge = [delayEdge tR-tT];
    %correlation
    if data_struct.(BDs_ts{k}).position.correlation.fail == false
        delC = data_struct.(BDs_ts{k}).position.correlation.delay_time;
        delayCorr = [delayCorr delC];
    else
        failCorrCount = failCorrCount+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% do the actual plotting
figure(1)
hEdge = histogram(delayEdge);
hEdge.BinWidth = 4e-9;
title('Delay edge method')
xlabel('tREF-tTRA (s)')
ylabel('Counts (u.a.)')

figure(2)
hCorr = histogram(delayCorr);
hCorr.BinWidth = 4e-9;
title({'Delay correlation method';['Manual fails: ' num2str(failCorrCount) ' on ' num2str(length(BDs_ts))]})
xlabel('tREF-tINC (s)')
ylabel('Counts (u.a.)')
