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
if data_struct.Analysis.postioning == 0
    error('Positioning has not been done during filtering')
end

%generate the list of times
BDs_ts = BDs;

time_edge_ref = [];
time_edge_tra = [];

flag_corr_fail = zeros(1,length(BDs_ts));

count=0;
for k=1:144
    if isfield(data_struct.(BDs_ts{k}),'position')
        disp(BDs_ts{k})
        count = count+ 1;
        
        if isfield(data_struct.(BDs_ts{k}).position.correlation,'fail')
            flag_corr_fail(k) = data_struct.(BDs_ts{k}).correlation.fail;
            disp('fail flag')
        else
            flag_corr_fail(k) = 0;
        end
    end
    
end
disp(count)