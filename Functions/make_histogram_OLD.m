
% subj_no_improv = {'V451'; 'V452'};
% subj_most_improv = {'V157','V192'};
scripts_path = '/home/noambe/Public/Statistics/Matlab_Scripts/';
addpath(genpath(scripts_path));

% GLOBAL Definitions
qMRI_STATS_SET_GLOBALS;

subj_list = {'V451'; 'V452'; 'V157'; 'V192'};
subj_fieldname_prefix = 'subject_';
ROI = 'Cerebral_White_Matter_RL';
map = MAP_TYPE_T1;
feature = 'qMRI_mask';
hist_objects = cell(2, length(subj_list));


for subj_idx = 1:length(subj_list)
    % subject_fieldname = [subj_fieldname_prefix subj_list{subj_idx}];
    subject_name = subj_list{subj_idx};
    if any(contains(EXPERIMENT_GROUP,subject_name))
        group = EXPERIMENT_GROUP_NAME;
    else
        group = CONTROL_GROUP_NAME;
    end
    subj_mask_3D_S1 = qMRI_stats_get(stats_all_subj,1,group,subject_name,map,ROI,feature);
    subj_ROI_vals_S1 = subj_mask_3D_S1(:);
    subj_ROI_vals_S1 = subj_ROI_vals_S1(subj_ROI_vals_S1~=0);
    subj_mask_3D_S3 = qMRI_stats_get(stats_all_subj,3,group,subject_name,map,ROI,feature);
    subj_ROI_vals_S3 = subj_mask_3D_S3(:);
    subj_ROI_vals_S3 = subj_ROI_vals_S3(subj_ROI_vals_S3~=0);       
    h1 = histogram(subj_ROI_vals_S1);
    h2 = histogram(subj_ROI_vals_S3);
    hist_objects{1,subj_idx} = h1;
    hist_objects{2,subj_idx} = h2;
end

%%

figure()
for subj_num = 1:size(hist_objects,2)
    % subplot(1,2,plot_num)
    h1 = hist_objects{1,subj_num};
    h1_bins = h1.BinEdges;
    h1_bins(1) = [];
    h1_bin_vals = h1.Values;
    hist_objects(end+1,subj_num) = h1_bins;
    hist_objects(end+1,subj_num) = h1_bin_vals;
    h2 = hist_objects{2,subj_num};
    h2_bins = h2.BinEdges;
    h2_bins(1) = [];
    h2_bin_vals = h2.Values;
    hist_objects(end+1,subj_num) = h2_bins;
    hist_objects(end+1,subj_num) = h2_bin_vals;
end


figure;
plot(h1_bins,h1_bin_vals)
hold on
plot(h2_bins,h2_bin_vals)
title('V');

