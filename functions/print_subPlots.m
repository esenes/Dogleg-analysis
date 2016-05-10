function [ output_args ] = print_subPlots( fname, timescale, data_struct, bpm1_thr, bpm2_thr)
%	print_subPlots.m: prints the subplot for the interactive program
%
%   Last modified: 18.04.2016 by Eugenio Senes
subplot(2,4,[3 4]) %RF signals plot
plot(timescale,data_struct.(fname).INC.data_cal, ...
    timescale,data_struct.(fname).TRA.data_cal, ...
    timescale,data_struct.(fname).REF.data_cal ...
    );
title(fname);
legend({'INC','TRA','REF'},'Location','northeast')
sp6 = subplot(2,4,[7 8]); %BPMs plot
plot(timescale,data_struct.(fname).BPM1.data_cal, ...
    timescale,data_struct.(fname).BPM2.data_cal ...
    );
xlim(sp6,[1.5e-6 3.1e-6])
title({'BPM signals', ['Integrated charge BPM1: ' num2str(data_struct.(fname).BPM1.sum_cal) ' / ' num2str(bpm1_thr)],... 
    ['Integrated charge BPM1: ' num2str(data_struct.(fname).BPM2.sum_cal) ' / '  num2str(bpm2_thr)] });
legend({'BPM1','BPM2'},'Location','northwest')

end