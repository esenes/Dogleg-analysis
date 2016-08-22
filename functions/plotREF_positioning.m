function plotREF_positioning( timescale, REF_c )

subplot(4,6,[9 10])
plot(timescale, REF_c, 'k -')
legend({'REF','prev REF'})
title('Edge method for REF')
xlim([400*4e-9 550*4e-9])
xlabel('time (s)')
ylabel('Power (a.u.)')

end

