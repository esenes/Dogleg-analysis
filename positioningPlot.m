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

%check if the positioning has been done
if data_struct.Analysis.positioning == 0
    error('Positioning has not been done during filtering. Please come back and do it')
end

edge_tra_time = zeros(1,length(BDs_ts));
edge_ref_time = zeros(1,length(BDs_ts));
flag_corr_fail = zeros(1,length(BDs_ts));

count=0;
for k=1:length(BDs_ts)
    if isfield(data_struct.(BDs_ts{k}),'position')
        disp(BDs_ts{k})
        count = count+ 1;
        
        flag_corr_fail(k) = data_struct.(BDs_ts{k}).position.correlation.fail;
        edge_tra_time(k) = data_struct.(BDs_ts{k}).position.edge.time_TRA;
        edge_ref_time(k) = data_struct.(BDs_ts{k}).position.edge.time_REF;
        
%         if isfield(data_struct.(BDs_ts{k}).position.correlation,'fail')
%             flag_corr_fail(k) = data_struct.(BDs_ts{k}).position.correlation.fail;
%             disp('fail flag')
%         else
%             flag_corr_fail(k) = -1;
%         end
    end
end
disp(count)


for k = 1:length(BDs_ts)
    disp( flag_corr_fail(k) )
end

for k = 1:length(BDs_ts)
    disp( edge_tra_time(k) )
end

for k = 1:length(BDs_ts)
    disp( edge_ref_time(k) )
end