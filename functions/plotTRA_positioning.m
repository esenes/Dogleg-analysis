function plotTRA_positioning( timescale, TRA_c )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

subplot(4,6,[3 4])
plot(timescale, TRA_c, 'r -')
legend({'TRA'})
title('Edge method for TRA')
xlim([400*4e-9 550*4e-9])
xlabel('time (s)')
ylabel('Power (a.u.)')

end

