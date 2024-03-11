% %#ok<*AGROW> 
% #ok<*MATCH3>
% #ok<*ALIGN>
% 
% Function's original name: ROI_3D_collector
% This function extracts the ROIs that exist in the data of the current subject and session, calculates and returns their statistical features.
% 
% inputs:
% Seg_map                            3D double with Free surfer label number according to the ROI location.
% qMRI_map                           3D double with qMRI values for each voxel.
% erosion_op                         choice of erosion type, number of voxels to erode and number of minimum neighbors(if relevant)
% chauvenet_flag                     remove voxels where value > mean ± chauvenet_flag*SD
% NUM_STAT_FEATURES                  number of statistical features the user wishes to extract. To change which and how many features you want, edit the script "create_stat_array"
% prct_of_deducted_voxels_thresh     maximum number of voxels allowed to be deducted by erosion and outlier removal
% ROI_names                          names of ROIs to analyze, according to Free surfer look up table
% qMRI_VAL_IGNORED                   value to ignore in qMRI map when extracting features. a number which is not a validqMRI value for the specific map. for example "0" or "NaN"
% 
% outputs:
% final_stats_values                           contains the unique Free surfer label number of ROIs in ROI_names (1st column) and their statistical features (one row per ROI)
%                                              num_of_ROIs (rows) x num_stat_parameters (columns)
%                                              2nd  column is qMRI mean in ROI.
%                                              3rd  column is std in ROI.
%                                              4th  column is CV.
%                                              5th  column is Median.
%                                              6th  column is 90th percentile.
%                                              7th  column is 75th percentile.
%                                              8th  column is 25th percentile.
%                                              9th column is 10th percentile.
%                                              10th column is the skewness of the qMRI values
%                                              11th column is the kurtosis of the qMRI values
% qMRI_map_masked_ROIs_cell_arr                Cell array. Each cell in the array contains a 3D matrix with masked qMRI values for a specific ROI.
%									           num_of_ROIs x 1 cells
% N_vox_in_ROI                                 matrix containing the number of voxels in each ROI (rows). See documentation throughout script
% missing_ROIs                                 cell array containing free surfer label name and label number of desired ROIs that were missing from data
% ROIs_w_prct_deducted_voxels_above_thresh     ROIs that "lost" too many voxels due to erosion and outlier removal
%                                              1st column ROI label name, 2nd column ROI free surfer label number
%                                              3rd column 3D double with original masked ROI
%                                              4th column 3D double with masked ROI after erosion and outlier removal

function [subject_all_ROI_stats        , ...
		  N_vox_in_ROI                 , ...
          missing_ROIs                 , ...
          qMRI_map_masked_ROIs_cell_arr, ...
          ROIs_in_data                 , ...
          ROIs_w_prct_deducted_voxels_above_thresh] = extract_qMRI_features_for_all_ROIs(Seg_map     , ...
		                                                                                 qMRI_map    , ...
																						 ROI_names   )

% Extract pairs of label names and corresponding indices from FreeSurfer lookup table ("FS_Color_label_list" in Matlab_Scripts/Fs)
[FS_label_nums, FS_label_names] = Label_reader;                                             

% GLOBAL Definitions
qMRI_STATS_SET_GLOBALS;

% Initialize variables
ROIs_in_data = {};
missing_ROIs            				 = cell(1,2);
missing_ROIs_count      				 = 0;
ROIs_w_prct_deducted_voxels_above_thresh = cell(1,4);
ROIs_above_deduction_thresh_count		 = 0; 
qMRI_map_masked_ROIs_cell_arr            = cell(1,N_SINGLE_ROIS);
N_vox_in_ROI                             = zeros(N_SINGLE_ROIS,4);

% Loop over all ROIs in our list of ROIs and extract statistical values for each ROI
% If ROI exists - add FS label num to final_stats_values (1st column).
% If not, add FS label num and name to missing_ROIs.
for roi_loop_idx = 1:N_SINGLE_ROIS
    roi_name = char(ROI_names(roi_loop_idx));
    roi_loc_in_FS_list = strmatch(roi_name,FS_label_names,"exact"); 
    roi_FS_label_num = FS_label_nums(roi_loc_in_FS_list);
	roi_name = strrep(roi_name, '-', '_');
	roi_name = strrep(roi_name, '*', '');
	roi_fn = [ROI_NAME_PREFIX '_' roi_name]; % roi field name for final stats structure

    % Register ROI name and FS num
    tmp = Seg_map(Seg_map==roi_FS_label_num); % double
	if sum(tmp(:)) == 0 % If wanted ROI is missing from data
        missing_ROIs_count                 = missing_ROIs_count+1;
        missing_ROIs{missing_ROIs_count,1} = {roi_name};
        missing_ROIs{missing_ROIs_count,2} = roi_FS_label_num;
		N_vox_in_ROI(roi_loop_idx,:)       = zeros(1,size(N_vox_in_ROI,2));

		continue;
    else
        ROIs_in_data{end+1,1} = {roi_name};
        ROIs_in_data{end,2} = roi_FS_label_num;
	end

	% Extract segmentation of current ROI
    roi_mask = logical(Seg_map == roi_FS_label_num);
	N_vox_in_ROI(roi_loop_idx,1) = sum(roi_mask(:)); % save original number of voxels to N_vox variable 1st column

	% -----------
	% Erode maps
	% -----------
    if (EROSION_OPT.NBE_nPx > 0) 
		roi_mask_eroded = erode_3D_mat(roi_mask, EROSION_OPT.NBE_nPx, EROSION_OPT.NBE_n_Neighbors);

	elseif (EROSION_OPT.MATLAB_nPx > 1) % Do not use imerode unless you know what you are doing and check the results manually!
		uiwait(msgbox('MATLAB erosion: Please choose erosion dimensionality (and check erosion level between 1 and 2 (non integer)'))
		error('Exiting');
		% erosion_se      = strel('line',erosion_op.MATLAB,90); % 2D
		% erosion_se      = strel('cube',3); % 3D (The example in MATLAB's help for imerode does cube strel with dimensionality 3. notice MATLAB_nPx is not used here)
		% erosion_se      = strel('sphere',erosion_op.MATLAB); % 3D
		% roi_mask_eroded = imerode(roi_mask,erosion_se);
	else
		roi_mask_eroded = roi_mask; % [RH - name is confusing if no erosion was done, but it keeps the rest of the script the same]
    end
    N_vox_in_ROI(roi_loop_idx,2) = sum(roi_mask_eroded(:)); % 2nd column - after erosion
	
    qmap_ROI_3D = qMRI_map .* roi_mask_eroded; % Create ROI mask with qMRI values
    
	% Remove NaN values
	tmp_Nan_map = isnan(qmap_ROI_3D);
	if (sum(tmp_Nan_map(:)) ~= 0)
		tmp_qmap              = qmap_ROI_3D;
		tmp_qmap(tmp_Nan_map) = 0;
		qmap_ROI_3D           = tmp_qmap;
	end
	clear tmp_qmap tmp_Nan_map;
   
	% ------------------------
	% Perform outlier removal
	% ------------------------
    if (CHAUVENET_FLAG)
		qmap_tmp = nbe_remove_outliers(qmap_ROI_3D,CHAUVENET_FLAG,qMRI_VAL_IGNORED);
        qmap_ROI_3D = qmap_tmp;
    end

	% Update the number of voxels after erosion and outlier removal and the total percentage of deducted voxels from original ROI size
	qmap_tmp  = qmap_ROI_3D;
    N_vox_in_ROI(roi_loop_idx,3) = length(qmap_tmp(qmap_tmp ~= 0));
    N_vox_in_ROI(roi_loop_idx,4) = (100*((N_vox_in_ROI(roi_loop_idx,1) - N_vox_in_ROI(roi_loop_idx,3)) / N_vox_in_ROI(roi_loop_idx,1)));
     
    % user can specify the max percent of voxels to be deducted from ROIs
    if N_vox_in_ROI(roi_loop_idx,4) > PRCT_OF_DEDUCTED_VOXELS_THRESH
        ROIs_above_deduction_thresh_count                                             = ROIs_above_deduction_thresh_count + 1;
        ROIs_w_prct_deducted_voxels_above_thresh{ROIs_above_deduction_thresh_count,1} = roi_name;
        ROIs_w_prct_deducted_voxels_above_thresh{ROIs_above_deduction_thresh_count,2} = roi_FS_label_num; 
        ROIs_w_prct_deducted_voxels_above_thresh{ROIs_above_deduction_thresh_count,3} = qMRI_map(roi_mask);
        ROIs_w_prct_deducted_voxels_above_thresh{ROIs_above_deduction_thresh_count,4} = qmap_ROI_3D;
    end
    
	% ------------------------------
    % extract statistical features
	% ------------------------------
	% qmap_ROI_3D = qMRI_map_masked_ROIs_cell_arr{roi_loop_idx};
	qmap_ROI_vec = qmap_ROI_3D(qmap_ROI_3D~=qMRI_VAL_IGNORED); 
    
	stats_st = calc_stat_feature_vals(qmap_ROI_vec, roi_FS_label_num);
	subject_all_ROI_stats.(roi_fn)           = stats_st;
	subject_all_ROI_stats.(roi_fn).qMRI_mask = qmap_ROI_3D;
	subject_all_ROI_stats.(roi_fn).(VOX_NUM_FN) = N_vox_in_ROI(roi_loop_idx,:);
    qMRI_map_masked_ROIs_cell_arr{roi_loop_idx} = qmap_ROI_3D; % needed for Consolidate_ROIs
	
    % final_stats_values.(session_fn).(subject_fn).(map_fn).(roi_fn) = stats_arr;
    % final_stats_values.(session_fn).(subject_fn).(map_fn).(roi_fn).(VOX_NUM_FN) = roi_FS_label_num; % I put it inside the calculate statistical feature function
	% [stats_arr] = calc_stat_feature_vals(qmap_ROI); 
	% final_stats_values(roi_loop_idx, COLUMN_IDX_STATS:(COLUMN_IDX_STATS+length(stats_arr)-1)) = stats_arr; % start from 3 because FS label num and number of voxels are in the first 2 columns

end

% % Remove ROIs with number of voxels under threshold
% if min_num_of_voxels_in_ROI > 0 
%     idx_lower_than_min = find((final_stats_values(:,COLUMN_IDX_NUM_OF_VOXELS) < min_num_of_voxels_in_ROI) & (final_stats_values(:,COLUMN_IDX_FS_LBL) ~= qMRI_VAL_IGNORED)); % because we want to find ROIs that are too small but exist, their FS label num is in the matrix
%     if ~isempty(idx_lower_than_min) % Remove the ROIs with less than minimum voxels from all variables
%     	final_stats_values(idx_lower_than_min,:)          = qMRI_VAL_IGNORED;     
%     	ROI_labels{idx_lower_than_min}                    = {};
%     	qMRI_map_masked_ROIs_cell_arr{idx_lower_than_min} = {};
%     	N_vox_in_ROI(idx_lower_than_min,:)                = qMRI_VAL_IGNORED;
%     end
% end

% return
