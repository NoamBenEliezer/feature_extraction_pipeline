% #ok<*AGROW>

% This function combines together ROIs according to the variable ROIs_2_combine which is set by the user in the main script "extract_qMRI_features".
% The function saves the masked qMRI map of the combined ROI and its statistical features.

function [subject_all_ROI_stats, N_vox_in_ROI, missing_ROIs, ROIs_in_data] =...
          Consolidate_ROIs(subject_all_ROI_stats, qMRI_map_masked_ROIs_cell_arr, N_vox_in_ROI, missing_ROIs, ROIs_in_data)

% GLOBAL Definitions
qMRI_STATS_SET_GLOBALS;

% Extract line by line, cell triplets of {1st ROI num, 2nd ROI num, name of combined ROI}
for pair_count = 1:size(ROIs_2_COMBINE,1)
    curr_pair        = ROIs_2_COMBINE(pair_count,:);
	ROI1_idx         = curr_pair{1};
	ROI2_idx         = curr_pair{2};
	ROI_combined_idx = str2double(['-' num2str(ROI1_idx) num2str(ROI2_idx)]); % Combine the indices of the two ROIs into a single index number and add a '-' sign to signify that this is a combined ROI.
    roi_name         = char(curr_pair{3});
	roi_name         = strrep(roi_name, '-', '_');
	roi_name         = strrep(roi_name, '*', '');
	roi_fn           = [ROI_NAME_PREFIX '_' roi_name]; % roi field name for final stats structure

	% Extract qMRI map, masked to each ROI
	qMRI_map_ROI1 = qMRI_map_masked_ROIs_cell_arr{ROI1_idx};
	qMRI_map_ROI2 = qMRI_map_masked_ROIs_cell_arr{ROI2_idx};

	% Transform qMRI ROI to a logical mask
	qMRI_map_ROI1_msk = logical(qMRI_map_ROI1);
	qMRI_map_ROI2_msk = logical(qMRI_map_ROI2);
	
	if (sum(qMRI_map_ROI1_msk(:)) == 0) || (sum(qMRI_map_ROI2_msk(:)) == 0)
        % final_stats_values(N_single_ROIs+pair_count,:) = [ROI_COMBINED_idx, zeros(1,(size(final_stats_values,2)-1))]; % Need to add it some place else
        missing_ROIs_count                       = length(missing_ROIs)+1;
        missing_ROIs{missing_ROIs_count,1}       = {roi_name};
        missing_ROIs{missing_ROIs_count,2}       = ROI_combined_idx;
		N_vox_in_ROI(N_SINGLE_ROIS+pair_count,:) = zeros(1,size(N_vox_in_ROI,2));
        % qMRI_map_masked_ROIs_cell_arr{end+1}     = []; % Not needed because we are not saving this cell array in the end.
		continue;
    else
        ROIs_in_data{end+1,1} = {roi_name};
        ROIs_in_data{end,2}   = ROI_combined_idx;
	end

    qMap_ROI_combined = qMRI_map_ROI1 + qMRI_map_ROI2;
    % qMRI_map_masked_ROIs_cell_arr{end+1} = qMap_ROI_combined; % Not needed because we are not saving this cell array in the end.

	% Extract the actual set of values for the combined ROI
	qMap_ROI_combined_vectorized = qMap_ROI_combined(qMap_ROI_combined ~= qMRI_VAL_IGNORED);
	qMap_ROI_combined_vectorized = qMap_ROI_combined_vectorized(:); % probably redundant but let's make sure it was vectorized

    N_vox_in_pair         = N_vox_in_ROI(ROI1_idx,1:3) + N_vox_in_ROI(ROI2_idx,1:3);
    N_vox_in_pair(4)      = (100*(N_vox_in_pair(1) - N_vox_in_pair(3)) / N_vox_in_pair(1));
    N_vox_in_ROI(end+1,:) = N_vox_in_pair;

	% Sanity test
	if (N_vox_in_pair(3) ~= length(qMap_ROI_combined_vectorized))
		error('Mismatch in number of voxels');
	end

	[stats_arr] = calc_stat_feature_vals(qMap_ROI_combined_vectorized, ROI_combined_idx);
	subject_all_ROI_stats.(roi_fn)              = stats_arr;
	subject_all_ROI_stats.(roi_fn).qMRI_mask    = qMap_ROI_combined;
	subject_all_ROI_stats.(roi_fn).(VOX_NUM_FN) = N_vox_in_pair;
	% final_stats_values.(session_fn).(subject_fn).(map_fn).(roi_fn) = stats_arr;
	% final_stats_values.(session_fn).(subject_fn).(map_fn).(roi_fn).(VOX_NUM_FN) = ROI_COMBINED_idx;
	% final_stats_values(N_single_ROIs+pair_count,COLUMN_IDX_FS_LBL) = ROI_COMBINED_idx;
    % final_stats_values(N_single_ROIs+pair_count,COLUMN_IDX_FS_LBL+1:end) = stats_arr;
end

return;
