%% BEAM INDUCED RF
close all; clearvars; clc;
%include folder to path
[dirpath,~,~]=fileparts(mfilename('fullpath'));
addpath(genpath(dirpath))

fpath = '/Users/esenes/swap_out/exp/';
fname = 'Exp_analized_AntiLoaded6_5MW_';
fnum = {'1','2','3','4'};
fext = '.mat';

timescale = 0:4e-9:799*4e-9;

%assembly the big dataset
BD_full_struct = struct;
ts_lst_tmp = {};
for k=1:length(fnum)
    fullName = [fpath fname fnum{k} fext];
    disp(['Processing file: ' fullName])
    
    load(fullName,'BDs_ts_new','BD_struct','BDs_ts','edge_delay')
    if exist('BDs_ts_new') %legacy for the BDs lists
        ts_lst = BDs_ts_new;
    else
        ts_lst = BDs_ts;
    end
    
    %concatenate structure and timestamp list
    fields_bd = fieldnames(BD_struct); disp(['# of fields = ' num2str(length(fields_bd))])
    for b=1:length(fields_bd)
        BD_full_struct.(fields_bd{b}) = BD_struct.(fields_bd{b});
    end
    ts_lst_tmp = [ts_lst_tmp ts_lst ];
end
clear ts_lst;%vars legacy management
ts_lst = ts_lst_tmp;
clear ts_lst_tmp;

%% training sets
train_antiLoaded = {'g_20160405061905_076_B0','g_20160405061923_392_B0',...
    'g_20160405171205_075_B0','g_20160405171232_486_B0','g_20160406112116_214_B0',...
    'g_20160406112143_152_B0','g_20160406112215_046_B0','g_20160406112240_591_B0',...
    'g_20160406165438_828_B0','g_20160406212501_469_B0','g_20160408150822_260_B0',...
    'g_20160625163211_395_B0'};
prepulse_antiloaded = {'g_20160611095839_741_B0'};
%g_20160604025302_201_B0

train_loaded38MW = {'g_20160409033850_676_B0','g_20160701182314_288_B0','g_20160702095342_217_B0',...
    'g_20160703090651_139_B0','g_20160703090658_901_B0','g_20160703090726_910_B0','g_20160703090751_480_B0'...
    'g_20160703121658_079_B0','g_20160704031132_251_B0','g_20160704031141_332_B0','g_20160704031204_698_B0',...
    'g_20160704055409_125_B0','g_20160704055417_447_B0','g_20160704061848_990_B0','g_20160716185457_576_B0',...
    'g_20160716185527_705_B0','g_20160716185536_428_B0','g_20160716185544_310_B0','g_20160716185544_550_B0',...
    'g_20160722171904_484_B0','g_20160722171912_202_B0','g_20160722172502_194_B0','g_20160723013918_242_B0',...
    'g_20160723013935_156_B0','g_20160723013950_231_B0','g_20160723014024_949_B0','g_20160723093216_893_B0',...
    'g_20160723232432_876_B0','g_20160724042251_954_B0','g_20160724042543_884_B0','g_20160724042552_125_B0',...
    'g_20160724052515_587_B0','g_20160724192405_012_B0','g_20160730135321_530_B0','g_20160805165122_265_B0',...
    'g_20160805165123_346_B0','g_20160805191923_199_B0','g_20160805215417_325_B0','g_20160805221629_571_B0',...
    'g_20160812195436_843_B0','g_20160812234007_270_B0','g_20160813181939_186_B0','g_20160813182016_157_B0',...
    'g_20160813182026_478_B0','g_20160813182027_519_B0','g_20160813220910_649_B0','g_20160813220956_624_B0',...
    'g_20160813221005_786_B0','g_20160813221023_826_B0','g_20160813221036_186_B0','g_20160813221037_226_B0',...
    'g_20160814095926_839_B0','g_20160825183250_042_B0','g_20160825194315_979_B0','g_20160825194317_059_B0',...
    'g_20160825194746_229_B0','g_20160825225624_745_B0','g_20160825225626_384_B0','g_20160825225801_035_B0',...
    'g_20160825225802_075_B0','g_20160825230622_497_B0','g_20160826082741_549_B0','g_20160826082742_669_B0',...
    'g_20160826140120_724_B0','g_20160826141422_250_B0','g_20160826160435_737_B0','g_20160826174708_895_B0',...
    'g_20160826174726_943_B0','g_20160826174811_559_B0','g_20160826174815_360_B0','g_20160826174816_401_B0',...
    'g_20160826174834_410_B0','g_20160826175316_199_B0','g_20160826175317_279_B0','g_20160827025106_194_B0',...
    'g_20160908170040_260_B0','g_20160908192453_171_B0','g_20160909081232_446_B0','g_20160909081233_526_B0',...
    'g_20160909162212_994_B0','g_20160909162212_994_B0','g_20160909162309_634_B0','g_20160909162310_713_B0',...
    'g_20160909162311_754_B0','g_20160910215953_084_B0','g_20160910220004_044_B0','g_20160910220005_284_B0',...
    'g_20160910222101_417_B0','g_20160910222103_495_B0','g_20160910222112_927_B0','g_20160910222126_676_B0',...
    'g_20160910222137_430_B0','g_20160911070322_398_B0','g_20161119190718_955_B0','g_20161119214530_406_B0',...
    'g_20161119231847_467_B0','g_20161119231857_426_B0'};

%% plotting loop
ts_lst = train_antiLoaded;


RFprod = struct;
f1 = figure;
f2 = figure;
figure(f1);
for m=1:length(ts_lst)
    prev_ts = [ts_lst{m}(1:end-2) 'L1'];
    %gather data
    INC_c = BD_full_struct.(ts_lst{m}).INC.data_cal;
    TRA_c = BD_full_struct.(ts_lst{m}).TRA.data_cal;
    REF_c = BD_full_struct.(ts_lst{m}).REF.data_cal;
    if isfield(BD_full_struct,prev_ts)
        INC_prev = BD_full_struct.(prev_ts).INC.data_cal;
        TRA_prev = BD_full_struct.(prev_ts).TRA.data_cal;
        REF_prev = BD_full_struct.(prev_ts).REF.data_cal;
    end
    TRA_fall = BD_full_struct.(ts_lst{m}).position.edge.time_TRA;
    REF_raise = BD_full_struct.(ts_lst{m}).position.edge.time_REF;


    %plot calibrated
    figure(f1);
    try
        plot(timescale, INC_c, '- b',...
             timescale, INC_prev, '-- b',...
             timescale, TRA_c,'- r',...
             timescale, TRA_prev,'-- r',...
             timescale, REF_c,'- g',...
             timescale, REF_prev,'-- g')
        disp(BD_full_struct.(ts_lst{m}).name)
        legend({'INC','INC prev','TRA','TRA prev','REF','REF prev'})
    catch
        plot(timescale, INC_c, '-',...
             timescale, TRA_c,'-',...
             timescale, REF_c,'-')
        disp(BD_full_struct.(ts_lst{m}).name)
        legend({'INC','TRA','REF'})
    end

    xlim([0.450e-6 2.70e-6])
    xlabel('Time (s)')
    ylabel('Power (W)')

    line([TRA_fall TRA_fall], ylim, 'Color', 'r','LineWidth',1) %vertical line
    line([REF_raise REF_raise], ylim, 'Color', 'g','LineWidth',1) %vertical line

    %plot log detectors
    INC_c_l = BD_full_struct.(ts_lst{m}).INC.data;
    TRA_c_l = BD_full_struct.(ts_lst{m}).TRA.data;
    REF_c_l = BD_full_struct.(ts_lst{m}).REF.data;
    if isfield(BD_full_struct,prev_ts)
        INC_prev_l = BD_full_struct.(prev_ts).INC.data;
        TRA_prev_l = BD_full_struct.(prev_ts).TRA.data;
        REF_prev_l = BD_full_struct.(prev_ts).REF.data;
    end
    figure(f2);
    try
        plot(timescale,                 INC_c_l, '- b',...
             timescale,                 INC_prev_l, '-- b',...
             timescale, TRA_c_l,'- r',...
             timescale, TRA_prev_l,'-- r',...
             timescale,                 REF_c_l,'- g',...
             timescale,                 REF_prev_l,'-- g')
        disp(BD_full_struct.(ts_lst{m}).name)
        legend({'INC','INC prev','TRA','TRA prev','REF','REF prev'})
    catch
        plot(timescale,                 INC_c_l, '-',...
             timescale, TRA_c_l,'-',...
             timescale,                 REF_c_l,'-')
        disp(BD_full_struct.(ts_lst{m}).name)
        legend({'INC','TRA','REF'})
    end

    xlim([0.450e-6 2.70e-6])
    xlabel('Time (s)')
    ylabel('Power (arb.u.)')

    line([TRA_fall TRA_fall], ylim, 'Color', 'r','LineWidth',1) %vertical line
    line([REF_raise REF_raise], ylim, 'Color', 'g','LineWidth',1) %vertical line
    
    %findpeaks routine
    %positive peaks
    [pksP,locsP,wP,pP] = findpeaks(TRA_c_l,timescale);
    hold on
    plot(locsP,pksP,'. b')
    %negative peaks
    [pksN,locsN,wN,pN] = findpeaks(-TRA_c_l,timescale);
    hold on
    plot(locsN,-pksN,'. k')
    hold on
    
    %detect overshoot
    %first detect the negative fall (after the edge)
    fpNeg_idx = find(locsN>TRA_fall,1,'first');
    fpNeg = locsN(fpNeg_idx);
    plot(fpNeg,-pksN(fpNeg_idx), '* m')
    hold on
    %then the raise 
    fpPos_idx = find(locsP>fpNeg,1,'first');
    fpPos = locsP(fpPos_idx);
    plot(fpPos,pksP(fpPos_idx), '* c')
    hold on
    %find the end of the plateau
    loffset = 4;
    endplat_idx = find(TRA_c_l > (-pksN(fpNeg_idx)),1,'last');
    endplat_idx = endplat_idx-loffset;
    plot(timescale(endplat_idx),TRA_c_l(endplat_idx),'* k')
    roffset = 4;
    startplt_idx = find(fpNeg >= timescale,1,'last' ) + roffset;
    startplt = timescale(startplt_idx);
    plot(timescale(startplt_idx),TRA_c_l(startplt_idx),'* k')
    hold off
    %save the values
    
    RFprod.(ts_lst{m}).TRAfall_time = fpNeg;
    RFprod.(ts_lst{m}).TRAfall_log_power = -pksN(fpNeg_idx);
    RFprod.(ts_lst{m}).TRAfall_cal_power = log_cal_single(-pksN(fpNeg_idx),...
                            BD_full_struct.(ts_lst{m}).INC.Props.Offset,...
                            BD_full_struct.(ts_lst{m}).INC.Props.Scale,...
                            BD_full_struct.(ts_lst{m}).INC.Props.Att__factor,...
                            BD_full_struct.(ts_lst{m}).INC.Props.Att__factor__dB_,...
                            BD_full_struct.(ts_lst{m}).INC.Props.Unit_scale);
    RFprod.(ts_lst{m}).TRAovershoot_time = fpPos;
    RFprod.(ts_lst{m}).TRAovershoot_log_power = pksP(fpPos_idx);
    RFprod.(ts_lst{m}).TRAovershoot_cal_power = log_cal_single(pksP(fpPos_idx),...
                            BD_full_struct.(ts_lst{m}).INC.Props.Offset,...
                            BD_full_struct.(ts_lst{m}).INC.Props.Scale,...
                            BD_full_struct.(ts_lst{m}).INC.Props.Att__factor,...
                            BD_full_struct.(ts_lst{m}).INC.Props.Att__factor__dB_,...
                            BD_full_struct.(ts_lst{m}).INC.Props.Unit_scale);
    RFprod.(ts_lst{m}).TRAraise_log_mean = mean(TRA_c_l(startplt_idx:endplat_idx));
    RFprod.(ts_lst{m}).TRAraise_log_devsta = std(TRA_c_l(startplt_idx:endplat_idx));
    RFprod.(ts_lst{m}).TRAraise_cal_mean = mean(TRA_c(startplt_idx:endplat_idx));
    RFprod.(ts_lst{m}).TRAraise_cal_devsta = std(TRA_c(startplt_idx:endplat_idx));
    
    pause
end

%% gather overall results and do plotting
clearvars prodP sigmaProdP pFall pOverShoot tTRAfall tREFrise delayCorr delayEdge

fieldLst = fieldnames(RFprod);
prodP = []; sigmaProdP = []; 
pFall = []; pOverShoot = [];
tTRAfall = []; tREFrise = []; 
delayEdge = []; delayCorr = [];
for g=1:length(fieldLst)
    prodP = [prodP RFprod.(fieldLst{g}).TRAraise_cal_mean];
    sigmaProdP = [sigmaProdP RFprod.(fieldLst{g}).TRAraise_cal_devsta];
    pFall = [pFall RFprod.(fieldLst{g}).TRAfall_cal_power];
    pOverShoot = [pOverShoot RFprod.(fieldLst{g}).TRAovershoot_cal_power];
    tTRAfall = [tTRAfall BD_full_struct.(fieldLst{g}).position.edge.time_TRA];
    tREFrise = [tREFrise BD_full_struct.(fieldLst{g}).position.edge.time_REF];
    delayCorr = [delayCorr BD_full_struct.(fieldLst{g}).position.correlation.delay_time];
end
delayEdge = tREFrise - tTRAfall;
% Power producted vs pulse length
f3 = figure;
figure(f3)
errorbar(tTRAfall,prodP,sigmaProdP,'. b')
xlabel('t_{fall TRA} (s)')
ylabel('Power (W)')
title('Power producted vs pulse length')

% Power producted vs initial position
f4 = figure;
figure(f4)
errorbar(delayEdge,prodP,sigmaProdP,'. b')
xlabel('t_{rise REF} - t_{fall TRA} (s)')
ylabel('Power (W)')
title('Power producted vs edge method')

% Power producted vs migration
f5 = figure;
figure(f5)
errorbar(delayEdge-delayCorr,prodP,sigmaProdP,'. b')
xlabel('t_{EDGE} - t_{CORR} (s)')
ylabel('Power (W)')
title('Power producted vs migration')

% Power overshoot vs initial position
f6 = figure;
figure(f6)
plot(delayEdge,pOverShoot-pFall,'. b')
xlabel('t_{rise REF} - t_{fall TRA} (s)')
ylabel('Power difference(W)')
title('Power relative overshoot vs initial position (edge method)')

