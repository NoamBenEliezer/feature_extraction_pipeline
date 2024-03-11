
% subj_no_improv = {'V451'; 'V452'};
% subj_most_improv = {'V157','V192'};
scripts_path = '/home/noambe/Public/Statistics/Matlab_Scripts/';
addpath(genpath(scripts_path));

% GLOBAL Definitions
qMRI_STATS_SET_GLOBALS;

num_rows = 6;
subj_list = {'V278'; 'V192'; 'V117'; 'V452'};
% subj_list_M = {'V157'; 'V192'; 'V230'; 'V236'; 'V274'; 'V278'; 'V297'; 'V307'};
% subj_list_C = {'V260'; 'V340'; 'V294'; 'V470'; 'V451'; 'V452'; 'V142'; 'V117'};
figure_title = 'Opposite Trends of Change in T2 values Across Time';
subj_fieldname_prefix = 'subject_';
ROI = 'Cerebral_White_Matter_RL';
map = MAP_TYPE_T2;
feature = 'qMRI_mask';
nbins = 20;
hist_objects = cell(num_rows, length(subj_list));
% bins_range = [0 100];
% bins_width = 1;
% rows
% session1_hist_object_row  = 1;
% session3_hist_object_row  = 2;
% session1_bins_row     = 3;
% session1_bin_vals_row = 4;
% session3_bins_row     = 5;
% session3_bin_vals_row = 6;


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
    % h1 = histogram(subj_ROI_vals_S1,nbins);
    % h3 = histogram(subj_ROI_vals_S3,nbins);
    figure(1); sgtitle(figure_title); subplot(length(subj_list)/2,2,subj_idx);
    h1 = histogram(subj_ROI_vals_S1,nbins);
    plot(h1.BinEdges(1:end-1)+(h1.BinWidth/2),h1.Values,'.-');
    if subj_idx ==1
        a = axis;
    end
    hold on;
    h3 = histogram(subj_ROI_vals_S3,nbins,'FaceAlpha',0,'EdgeAlpha',0);
    plot(h3.BinEdges(1:end-1)+(h3.BinWidth/2),h3.Values,'r.-');
    % ylim([a(3) a(4)]);
    ylim([0 52000]);
    xlim([20 120]);
    % set(gca,'XColor','white','YColor', 'white','xtick',[],'ytick',[])
    title(subject_name);
    
    % h1 = histogram(subj_ROI_vals_S1,'BinLimits',bins_range,'BinWidth',bins_width);
    % h1_bins     = h1.BinEdges;
    % h1_bins(1)  = [];
    % h1_bin_vals = h1.Values;
    % hist_objects{session1_hist_object_row,subj_idx} = h1;
    % hist_objects{session1_bins_row,subj_idx}        = h1_bins;
    % hist_objects{session1_bin_vals_row,subj_idx}    = h1_bin_vals;
    % h2 = histogram(subj_ROI_vals_S3,'BinLimits',bins_range,'BinWidth',bins_width);
    % h2_bins     = h2.BinEdges;
    % h2_bins(1)  = [];
    % h2_bin_vals = h2.Values;
    % hist_objects{session3_hist_object_row,subj_idx} = h2;
    % hist_objects{session3_bins_row,subj_idx}        = h2_bins;
    % hist_objects{session3_bin_vals_row,subj_idx}    = h2_bin_vals;
end

%%

% for subj_num = 1:size(hist_objects,2)
%     % subplot(1,2,plot_num)
%     h1          = hist_objects{1,subj_num};
%     h1_bins     = h1.BinEdges;
%     h1_bins(1)  = [];
%     h1_bin_vals = h1.Values;
%     hist_objects(session1_bins_row,subj_num)     = h1_bins;
%     hist_objects(session1_bin_vals_row,subj_num) = h1_bin_vals;
%     h2          = hist_objects{2,subj_num};
%     h2_bins     = h2.BinEdges;
%     h2_bins(1)  = [];
%     h2_bin_vals = h2.Values;
%     hist_objects(session3_bins_row,subj_num)     = h2_bins;
%     hist_objects(session3_bin_vals_row,subj_num) = h2_bin_vals;
% end

%% 
figure();
for plot_num = 1:length(subj_list)
    subplot(length(subj_list)/2,length(subj_list)/2,plot_num)
    plot(hist_objects{session1_bins_row,plot_num},hist_objects{session1_bin_vals_row,plot_num})
    hold on
    plot(hist_objects{session3_bins_row,plot_num},hist_objects{session3_bin_vals_row,plot_num})
    title(subj_list{plot_num});
end

%%
figure()
for plot_num = 1:length(subj_list)
    subplot(length(subj_list)/2,length(subj_list)/2,plot_num)
    subj_mask_3D_S1 = qMRI_stats_get(stats_all_subj,1,group,subject_name,map,ROI,feature);
    subj_ROI_vals_S1 = subj_mask_3D_S1(:);
    subj_ROI_vals_S1 = subj_ROI_vals_S1(subj_ROI_vals_S1~=0);
    subj_mask_3D_S3 = qMRI_stats_get(stats_all_subj,3,group,subject_name,map,ROI,feature);
    subj_ROI_vals_S3 = subj_mask_3D_S3(:);
    subj_ROI_vals_S3 = subj_ROI_vals_S3(subj_ROI_vals_S3~=0);
    % histogram(subj_ROI_vals_S1,DisplayStyle='stairs')
    histogram(subj_ROI_vals_S1)
    hold on
    % histogram(subj_ROI_vals_S3,DisplayStyle='stairs')
    histogram(subj_ROI_vals_S3)
    title(subj_list{plot_num})
end


