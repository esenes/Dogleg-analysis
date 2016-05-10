clearvars -except data_struct; clc; close all;
if false
    tic
    load('W:\Experiments_data\Exp_Loaded43MW.mat');
    disp('Loaded')
    toc
end

filed_names = fieldnames(data_struct);
fn = {};

for i=1:length(filed_names)
    if strcmp(filed_names{i}(end-1:end),'B0') 
        fn = [fn filed_names{i}];
    end
end

fail1 = zeros(1,length(fn));
fail2 = zeros(1,length(fn));
slope = zeros(1,2);
bend_up = zeros(1,2);
bend_down = zeros(1,2);

for j=1:length(fn)
    
    disp(fn{j})
    fail1(j) = data_struct.(fn{j}).tuning.fail_m1;
    fail2(j) = data_struct.(fn{j}).tuning.fail_m2;
    
    if data_struct.(fn{j}).tuning.fail_m1 ~= 1 && data_struct.(fn{j}).tuning.fail_m2 ~= 1
        slope = [slope data_struct.(fn{j}).tuning.slope];
        bend_up = [bend_up data_struct.(fn{j}).tuning.top.xm - data_struct.(fn{j}).tuning.mid.xm];
        bend_down = [bend_down data_struct.(fn{j}).tuning.mid.xm - data_struct.(fn{j}).tuning.bot.xm];
    end
end