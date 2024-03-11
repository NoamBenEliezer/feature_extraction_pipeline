
% This function initiates the data structure that will contain the calculated statistical features of a certain ROI for a certain subject, map and session, 
% and will later be combined with the final data structure containing the features for all sessions, subjects, maps and rois.
% The function temporarilly assigns an illegal value specified by the user in "qMRI_SET_GLOBALS" to all fields.

function stats_st = init_stats_st()

qMRI_STATS_SET_GLOBALS;

stats_st.(MEAN_FN)     = qMRI_ILLEGAL_VAL;
stats_st.(SD_FN)       = qMRI_ILLEGAL_VAL; 
stats_st.(CV_FN)       = qMRI_ILLEGAL_VAL;
stats_st.(MEDIAN_FN)   = qMRI_ILLEGAL_VAL;
stats_st.(PRCTL_90_FN) = qMRI_ILLEGAL_VAL;
stats_st.(PRCTL_75_FN) = qMRI_ILLEGAL_VAL;
stats_st.(PRCTL_25_FN) = qMRI_ILLEGAL_VAL;
stats_st.(PRCTL_10_FN) = qMRI_ILLEGAL_VAL;
stats_st.(SKEWNESS_FN) = qMRI_ILLEGAL_VAL;
stats_st.(KURTOSIS_FN) = qMRI_ILLEGAL_VAL;

return;

% stats_arr = zeros(1,NUM_STAT_FEATURES+COLUMN_IDX_FS_LBL);
% stats_arr(:,:) = qMRI_ILLEGAL_VALS;