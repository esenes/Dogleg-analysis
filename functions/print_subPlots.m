function print_subPlots( fname, timescale, data_struct, bpm1_thr, bpm2_thr)
%	print_subPlots.m: prints the subplot for the interactive program
%
%   Last modified: 18.04.2016 by Eugenio Senes
prevName = [fname(1:end-2),'L1'];
subplot(5,5,[4 5 9 10 14 15]) %RF signals plot
try
    plot(timescale,data_struct.(fname).INC.data_cal, 'b -', timescale,data_struct.(prevName).INC.data_cal, 'b --', ...
         timescale,data_struct.(fname).TRA.data_cal, 'r -', timescale,data_struct.(prevName).TRA.data_cal, 'r --', ...
         timescale,data_struct.(fname).REF.data_cal, 'g -', timescale,data_struct.(prevName).REF.data_cal, 'g --', ...
        'LineWidth',1.5,'MarkerSize',18);
    legend({'INC','prev INC','TRA','prev TRA','REF','prev REF'},'Location','northeast')
catch
    plot(timescale,data_struct.(fname).INC.data_cal,  ...
         timescale,data_struct.(fname).TRA.data_cal,  ...
         timescale,data_struct.(fname).REF.data_cal,  ...
        'LineWidth',1.5,'MarkerSize',18);
    legend({'INC','TRA','REF'},'Location','northeast')
end
title(fname);
sp6 = subplot(5,5,[19 20 24 25]); %pulse tuning plot
% grasp the points for the fit
try
xdata = [data_struct.(fname).tuning.top.xm * data_struct.(fname).INC.Props.wf_increment ...
    data_struct.(fname).tuning.mid.xm * data_struct.(fname).INC.Props.wf_increment ...
    data_struct.(fname).tuning.bot.xm * data_struct.(fname).INC.Props.wf_increment]';
ydata = [data_struct.(fname).tuning.top.y data_struct.(fname).tuning.mid.y data_struct.(fname).tuning.bot.y]';
fit1 = fit(xdata,ydata,'poly1');
fitx = (1.5e-6:1e-8:2e-6);
catch
end
% plot
try
plot(timescale,data_struct.(fname).INC.data_cal,'b -', ...
    data_struct.(fname).tuning.top.x1 * data_struct.(fname).INC.Props.wf_increment, data_struct.(fname).tuning.top.y,'r .',...
    data_struct.(fname).tuning.top.x2 * data_struct.(fname).INC.Props.wf_increment, data_struct.(fname).tuning.top.y,'r .',...
    data_struct.(fname).tuning.top.xm * data_struct.(fname).INC.Props.wf_increment, data_struct.(fname).tuning.top.y,'r .',...
    data_struct.(fname).tuning.mid.x1 * data_struct.(fname).INC.Props.wf_increment, data_struct.(fname).tuning.mid.y,'g .',...
    data_struct.(fname).tuning.mid.x2 * data_struct.(fname).INC.Props.wf_increment, data_struct.(fname).tuning.mid.y,'g .',...
    data_struct.(fname).tuning.mid.xm * data_struct.(fname).INC.Props.wf_increment, data_struct.(fname).tuning.mid.y,'g .',...
    data_struct.(fname).tuning.bot.x1 * data_struct.(fname).INC.Props.wf_increment, data_struct.(fname).tuning.bot.y,'b .',...
    data_struct.(fname).tuning.bot.x2 * data_struct.(fname).INC.Props.wf_increment, data_struct.(fname).tuning.bot.y,'b .',...
    data_struct.(fname).tuning.bot.xm * data_struct.(fname).INC.Props.wf_increment, data_struct.(fname).tuning.bot.y,'b .',...
    fitx, fit1(fitx),'m -', ...
    'LineWidth',1.5,'MarkerSize',18);
xlim(sp6,[0.45e-6 2.5e-6])
ylim(sp6,[0 max(data_struct.(fname).INC.data_cal)+ 5e6])
catch
end
%title composition
% if data_struct.(fname).tuning.fail_m1 == 0 && data_struct.(fname).tuning.fail_m2 == 0
%     tit = ['Slope flattop = ' num2str(data_struct.(fname).tuning.slope) ' Pulse tilt = ' num2str(fit1.p1)];
% elseif data_struct.(fname).tuning.fail_m1 == 1 && data_struct.(fname).tuning.fail_m2 == 0
%     tit = ['Slope flattop = FAIL'  ' Pulse tilt = ' num2str(fit1.p1)];
% elseif data_struct.(fname).tuning.fail_m1 == 0 && data_struct.(fname).tuning.fail_m2 == 1
%     if isfield(data_struct.(fname).tuning.slope)
%         tit = ['Slope flattop = ' num2str(data_struct.(fname).tuning.slope) ' Pulse tilt = FAIL'];
%     end
% end
% title(tit)
sp7 = subplot(5,5,[16 17 18 21 22 23]); %BPMs plot
plot(timescale,data_struct.(fname).BPM1.data_cal, ...
    timescale,data_struct.(fname).BPM2.data_cal ...
    );
xlim(sp7,[1.5e-6 3.1e-6])
title(['Integrated charge BPM1: ' num2str(data_struct.(fname).BPM1.sum_cal) ' / ' num2str(bpm1_thr) ... 
    'Integrated charge BPM1: ' num2str(data_struct.(fname).BPM2.sum_cal) ' / '  num2str(bpm2_thr)] );
legend({'BPM1','BPM2'},'Location','northwest')

end