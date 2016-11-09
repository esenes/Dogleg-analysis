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
close all; clc;
%load part


%check if the positioning has been done
if data_struct.Analysis.positioning == 0
    error('Positioning has not been done during filtering. Please come back and do it')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate lists for plots

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
f1 = figure;
figure(f1);
hEdge = histogram(delayEdge);
hEdge.BinWidth = 4e-9;
line([68e-9 68e-9], ylim, 'Color', 'r','LineWidth',2) %vertical line
line([-68e-9 -68e-9], ylim, 'Color', 'r','LineWidth',2) %vertical line
title('Delay edge method')
xlabel('$$t_{REF} - t_{TRA} $$ (s) ','interpreter','latex')
ylabel('Counts (arb.u.)')

% savefig([datapath_write_fig filesep expname '_Metric_plot'])
% print(f0,[datapath_write_plot filesep expname '_Metric_plot'],'-deps')

f2 = figure;
figure(f2);
hCorr = histogram(delayCorr);
hCorr.BinWidth = 4e-9;
title({'Delay correlation method';['Manual fails: ' num2str(failCorrCount) ' on ' num2str(length(BDs_ts))]})
xlabel('$$t_{REF} - t_{INC} $$ (s) ','interpreter','latex')
ylabel('Counts (arb.u.)')
