function  positionPlot_noPrev( timescale, INC_c,  TRA_c, REF_c, ...
    INC_c_cal, TRA_c_cal, REF_c_cal,...
    BPM1, BPM2)
% plots for the interface of positioning. 
% Case without previous pulse recorded

%%%% general plots
% raw data
subplot(4,6,[1 2 7 8])
hold off
plot(timescale, INC_c, 'b -', ...
    timescale, TRA_c, 'r -',...
    timescale ,REF_c, 'k -')
legend({'INC','TRA','REF'})
title('Raw signals')
xlabel('time (s)')
ylabel('Power (a.u.)')
xlim([0.45e-6 3.2e-6])
% calibrated data
subplot(4,6,[5 6 11 12])
hold off
plot(timescale, INC_c_cal, 'b -', ...
    timescale, TRA_c_cal, 'r -', ...
    timescale, REF_c_cal, 'k -')
legend({'INC','TRA','REF',})
title('Calibrated signals')
xlabel('time (s)')
ylabel('Power (W)')
xlim([0.45e-6 3e-6])
% bpms
subplot(4,6,[17 18])
plot(timescale, BPM1, ...
    timescale,BPM2 ...
    );
legend({'BPM1','BPM2'})
title('Beam current')
xlabel('time (s)')
ylabel('Beam current (A)')
xlim([2.0e-6 3.2e-6])






end

