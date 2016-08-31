function  positionPlot_prev( timescale, INC_c, INC_prev, TRA_c, TRA_prev, REF_c, REF_prev,...
    INC_c_cal, INC_prev_cal, TRA_c_cal, TRA_prev_cal, REF_c_cal, REF_prev_cal,...
    BPM1, BPM2)
% plots for the interface of positioning. 
% Case with previous pulse recorded

%%%% general plots
% raw data
INC_TRA_timeOffset = 72e-9;

subplot(4,6,[1 2 7 8])
hold off
plot(timescale, INC_c, 'b -', timescale, INC_prev, 'b --',...
    timescale-INC_TRA_timeOffset, TRA_c, 'r -',timescale-INC_TRA_timeOffset, TRA_prev, 'r --',...
    timescale ,REF_c, 'k -', timescale, REF_prev, 'k --')
legend({'INC','prev INC','TRA','prev TRA','REF','prev REF'})
title('Raw signals')
xlabel('time (s)')
ylabel('Power (a.u.)')
xlim([0.45e-6 3.2e-6])
% calibrated data
subplot(4,6,[5 6 11 12])
hold off
plot(timescale, INC_c_cal, 'b -', timescale, INC_prev_cal, 'b --',...
    timescale-INC_TRA_timeOffset, TRA_c_cal, 'r -',timescale-INC_TRA_timeOffset, TRA_prev_cal, 'r --',...
    timescale, REF_c_cal, 'k -', timescale, REF_prev_cal, 'k --')
legend({'INC','prev INC','TRA','prev TRA','REF','prev REF'})
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

