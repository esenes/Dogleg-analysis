function interlock_BDcell(Timestamp, BDcell)
%	interlock_BDcell: 
%   
%   Inputs:
%     - timestamp: list of the timestamps of the BDs in double format
%     - BDcell: cell position or delta time
%     
%   Outputs:
%     - cal_data
%     
%   Last modified: xx.03.2016 by Jorge Ginger-Navarro


N = length(BDcell);

folder = '\\cern.ch\dfs\Experiments\CTF3\DATA\mkx\TD26_Dogleg\2015_Run1\ProdData\';
%folder = 'C:\Users\jginerna\Dropbox\PhD\DogLeg experiment\Interlocks\Interlock_values_flag_vs_BDcell_for_Theo_script\interlock_files\';

TRAen=[]; REFen=[]; REFmax=[]; KREFmax=[];
TRAen_pp=[]; REFen_pp=[]; REFmax_pp=[]; KREFmax_pp=[];
TRAen_th=[]; REFen_th=[]; REFmax_th=[]; KREFmax_th=[];
BDflag= [];
keep_index = true(N,1);
for i = 1:N
    day = datestr(Timestamp(i),'yyyymmdd');
    tBD = datestr(Timestamp(i),'yyyymmddHHMMSS.FFF');
    
    file = [folder 'INTLK_Prod_' day '.txt'];
    
    A= dlmread(file,'\t',1,0); time= A(:,14);
    
    ii = find(abs(time-str2double(tBD))<=0.15);
    if isempty(ii)
        display(['Time is :',tBD])
        keep_index(i) = false;
    end
    
    TRAen= [TRAen; A(ii,1)];
    REFen= [REFen; A(ii,2)];
    REFmax= [REFmax; A(ii,3)];
    KREFmax= [KREFmax; A(ii,4)];
    TRAen_pp= [TRAen_pp; A(ii,6)];
    REFen_pp= [REFen_pp; A(ii,7)];
    REFmax_pp= [REFmax_pp; A(ii,8)];
    KREFmax_pp= [KREFmax_pp; A(ii,9)];
    TRAen_th= [TRAen_th; A(ii,10)];
    REFen_th= [REFen_th; A(ii,11)];
    REFmax_th= [REFmax_th; A(ii,12)];
    KREFmax_th= [KREFmax_th; A(ii,13)];
    BDflag = [BDflag; A(ii,5)];

end
BDcell = BDcell(keep_index);
size(BDcell)
size(TRAen_th)
figure;
subplot(221)
plot(BDcell, TRAen_th,'g+'); hold on
plot(BDcell, TRAen,'b.'); 
plot(BDcell, TRAen_pp,'rx');
xlabel('BD position'); ylabel('TRAen interlock [bits*4ns]')

subplot(222)
plot(BDcell, REFen_th,'g+'); hold on
plot(BDcell, REFen,'b.'); 
plot(BDcell, REFen_pp,'rx');
xlabel('BD position'); ylabel('REFen interlock [bits*4ns]')

subplot(223)
plot(BDcell, REFmax_th,'g+'); hold on
plot(BDcell, REFmax,'b.'); 
plot(BDcell, REFmax_pp,'rx');
xlabel('BD position'); ylabel('REFmax interlock [V]')

subplot(224)
plot(BDcell, REFmax_th,'g+'); hold on
plot(BDcell, REFmax,'b.'); 
plot(BDcell, REFmax_pp,'rx');
xlabel('BD position'); ylabel('KREFmax interlock [V]')




end