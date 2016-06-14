%% Normal pulses analysis report

%% General information
% Running period: 
disp([sdatestr ' ' data_struct.Props.startTime ' - ' edatestr ' ' data_struct.Props.endTime ])
disp(['Generated:   ' datestr(datetime('now'))])
disp(['Filename:    ' fileName])

%% Tresholds
disp(['BPM1: ' num2str(bpm1_thr)])
disp(['BPM2: ' num2str(bpm2_thr)])

%% Number of pulses
disp(['With beam:       ' num2str(l1)])
disp(['Without beam:    ' num2str(l2)])
%piechart?

%% Plots

report reportSetup