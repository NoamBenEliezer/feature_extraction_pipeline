
all_subj_path = '/data/Mindfulness_Data/qT1_mrQ';
stats_scripts_path = '/home/noambe/Public/Statistics/';
addpath(genpath(all_subj_path));
addpath(genpath(stats_scripts_path));

subj_name = 'V297';
ROI = 'CC_Posterior';
map = 'T2';
FS_label = ROI_Name_2_FS_idx(ROI);

mrQ_maps_S1   = load([all_subj_path filesep 'S1' filesep subj_name filesep 'mrQ_maps.mat']);
mrQ_maps_S3   = load([all_subj_path filesep 'S3' filesep subj_name filesep 'mrQ_maps.mat']);

EXPERIMENT_GROUP = ["V101", "V103", "V107", "V115", "V119", "V134", "V157", "V160", "V183", "V192", "V204", "V230", "V231",...
                       "V236", "V274", "V278", "V292", "V297", "V303", "V307", "V308", "V345", "V372"]; 
CONTROL_GROUP    = ["V106", "V117", "V122", "V131", "V142", "V154", "V211", "V225", "V260", "V294", "V329", "V340", "V377",...
                       "V400", "V432", "V438", "V448", "V451", "V452", "V470"];
if any(contains(CONTROL_GROUP,subj_name))
    group = 'Control';
else 
    group = 'Mindfulness';
end

ROI_mask_S1   = qMRI_stats_get(stats_all_subj,1,group, subj_name, map, ROI, 'qMRI_mask');
ROI_mask_S3   = qMRI_stats_get(stats_all_subj,3,group, subj_name, map, ROI, 'qMRI_mask');
ROI_mask_S1_inv = ~ROI_mask_S1;
ROI_mask_S3_inv = ~ROI_mask_S3;

T1_S1         = mrQ_maps_S1.mrQ_maps.T1;
T1_S3         = mrQ_maps_S3.mrQ_maps.T1;

T1_masked_S1  = T1_S1.*ROI_mask_S1_inv;
T1_masked_S3  = T1_S3.*ROI_mask_S3_inv;

figure(); sliceViewer(rot90(T1_masked_S1)); colormap parula; axis image; colorbar; title(['Subject ' subj_name ' - Session 1']);
figure(); sliceViewer(rot90(T1_masked_S3)); colormap parula; axis image; colorbar; title(['Subject ' subj_name ' - Session 3']);

% In order to compare the ROI before and after erosion, uncomment the following lines:

% ------- %
%   T1
%-------- %

% seg_S1 = mrQ_maps_S1.mrQ_maps.Segments;
% ROI_mask_S1_orig = seg_S1==FS_label;
% ROI_mask_S1_orig_inv = ~ROI_mask_S1_orig;
% T1_masked_orig_S1 = T1_S1.*ROI_mask_S1_orig_inv;
% 
% seg_S3 = mrQ_maps_S3.mrQ_maps.Segments;
% ROI_mask_S3_orig = seg_S3==FS_label;
% ROI_mask_S3_orig_inv = ~ROI_mask_S3_orig;
% T1_masked_orig_S3 = T1_S3.*ROI_mask_S3_orig_inv;
% 
% figure(); sliceViewer(rot90(T1_masked_orig_S1)); colormap parula; axis image; colorbar; title(['Subject ' subj_name ' - Session 1 ORIGINAL']);
% figure(); sliceViewer(rot90(T1_masked_orig_S3)); colormap parula; axis image; colorbar; title(['Subject ' subj_name ' - Session 3 ORIGINAL']);



