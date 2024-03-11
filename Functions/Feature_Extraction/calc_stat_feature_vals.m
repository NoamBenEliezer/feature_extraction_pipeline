
% This function calculates the statistical features for a single ROI given the vector with the qMRI values of said ROI.

function [stats_st] = calc_stat_feature_vals(qMap_ROI_vectorized, ROI_label_num)
	
qMRI_STATS_SET_GLOBALS;
stats_st = init_stats_st();

stats_st.(FS_INDEX_FN) = ROI_label_num;
stats_st.(MEAN_FN)     = mean(qMap_ROI_vectorized);                                  % Mean
stats_st.(SD_FN)       = std(qMap_ROI_vectorized);                                   % Standard deviation
stats_st.(CV_FN)       = 100*(std(qMap_ROI_vectorized)/mean(qMap_ROI_vectorized));   % CV
stats_st.(MEDIAN_FN)   = median(qMap_ROI_vectorized);                                % Median
stats_st.(PRCTL_90_FN) = prctile(qMap_ROI_vectorized,90);                            % 90th percentile
stats_st.(PRCTL_75_FN) = prctile(qMap_ROI_vectorized,75);                            % 75th percentile
stats_st.(PRCTL_25_FN) = prctile(qMap_ROI_vectorized,25);                            % 25th percentile
stats_st.(PRCTL_10_FN) = prctile(qMap_ROI_vectorized,10);                            % 10th percentile
stats_st.(SKEWNESS_FN) = skewness(qMap_ROI_vectorized);                              % skewness of qMRI values
stats_st.(KURTOSIS_FN) = kurtosis(qMap_ROI_vectorized);					             % kurtosis of qMRI values 

% stats_arr = [mean(qMap_ROI_vectorized)                                ...     % Mean
%              std(qMap_ROI_vectorized)                                 ...     % Standard deviation
%              100*(std(qMap_ROI_vectorized)/mean(qMap_ROI_vectorized)) ...     % CV
% 	           median(qMap_ROI_vectorized)                              ...     % Median
% 	           prctile(qMap_ROI_vectorized,90)                          ...     % 90th percentile
% 	           prctile(qMap_ROI_vectorized,75)                          ...     % 75th percentile
%              prctile(qMap_ROI_vectorized,25)                          ...     % 25th percentile
% 	           prctile(qMap_ROI_vectorized,10)                          ...     % 10th percentile
%              skewness(qMap_ROI_vectorized)                            ...     % skewness of qMRI values
% 	           kurtosis(qMap_ROI_vectorized)];					                % kurtosis of qMRI values 

return

