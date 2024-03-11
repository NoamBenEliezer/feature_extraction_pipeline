% This function extracts the ROIs that exist in the data of the current subject and session, calculates and returns their statistical features.
% 
% inputs:
% Seg_vol              3D double with ROIs according to their location.
% qmap_Arr             3D double with qMRI values for each voxel.
% erosion_op           erosion flag
% chauvenet_flag       remove voxels where value > mean ± variable*SD
% 
% outputs:
% FS_ROIs_for_processing             contains the unique values of ROIs that are found in Seg_vol (my sample) and their statistical features (one row per ROI)
%                                    num_of_ROIs (rows) x num_stat_parameters (columns)
%                                    num_of_ROIs (rows) x num_stat_parameters (columns)
%                                    1st  column is ROI number for FS index (starts from 2).
%                                    2nd  column is number of voxels in ROI.
%                                    3rd  column is qMRI mean in ROI.
%                                    4th  column is std in ROI.
%                                    5th  column is CV.
%                                    6th  column is Median.
%                                    7th  column is 90th percentile.
%                                    8th  column is 75th percentile.
%                                    9th  column is 25th percentile.
%                                    10th column is 10th percentile.
%                                    11th column is the skewness of the qMRI values
%                                    12th column is the kurtosis of the qMRI values
% ROI_labels                    list of strings. list of ROI names (labels) according to FS lookuptable, that exist in the data.
%                               num_of_ROIs (rows) x 1 (columns)
% qMRI_map_3D                   Cell array. Each cell in the array contains a 3D matrix with qMRI values for a specific ROI.
%                               num_of_ROIs x 1 cells --> each cell is a 3D matrix of 181x217x82
% Seg_ROI_3D                    Cell array. Each cell in the array contains a 3D matrix with the FS_index of a specific ROI in its location.
%                               num_of_ROIs x 1 cells --> each cell is a 3D matrix of 181x217x82

function [FS_ROIs_for_processing     , ...
		  ROI_labels                 , ...
		  qmap_3D                    , ...
		  Seg_ROI_3D                 , ...
		  N_vox_in_ROI               , ...
          missing_ROIs               , ...
          tiny_ROIs_removed_FS_idx   , ...
          ROIs_w_prct_deducted_voxels_above_thresh] = ROI_3D_collector_NBE (Seg_map, qMRI_map, erosion_op, chauvenet_flag, prct_of_deducted_voxels_thresh, min_voxel_in_ROI, ROI_names)

tiny_ROIs_removed_FS_idx = [];
% Extract label names and indices from FreeSurfer lookup table ("FS_Color_label_list" in Matlab_Scripts/Fs)
[FS_label_num, FS_label_name] = Label_reader;                                             

FS_ROIs_for_processing = [];
missing_ROIs = cell(1,2);
missing_count = 0;
above_thresh_count = 0;
ROIs_w_prct_deducted_voxels_above_thresh = cell(1,4);
% find FS index of chosen ROIs and look for them in my data. If exist - add
% FS index to FS_ROIs_for_processing. If not, add FS label num to missing_ROIs.
for roi_count = 1:length(ROI_names)
    roi_name = char(ROI_names(roi_count));
    roi_chronological_idx = strmatch(roi_name,FS_label_name,"exact");
    roi_FS_idx = FS_label_num(roi_chronological_idx);
   
    if sum(Seg_map(Seg_map==roi_FS_idx)) == 0 % If wanted ROI is missing from data
        missing_count = missing_count+1;
        missing_ROIs{missing_count,1} = {roi_name};
        missing_ROIs{missing_count,2} = roi_FS_idx;

    else % If wanted ROI exists in data
        FS_ROIs_for_processing(roi_count,1) = roi_FS_idx;
        ROI_labels{roi_count} = roi_name;
          
    % Initialize variables
    qmap_3D   {roi_count} = zeros(size(qMRI_map(:,:,:)));
    Seg_ROI_3D{roi_count} = zeros(size(qMRI_map(:,:,:)));
    
	% Extract quantitative map values for current Freesurfer ROI
    seg_mask = (Seg_map==roi_FS_idx);
    qmap_3D   {roi_count}(seg_mask) = qMRI_map(seg_mask); % each cell contains a 3D array with qMRI values only in the location of the ROI (with ROI mask)
    Seg_ROI_3D{roi_count}(seg_mask) = Seg_map (seg_mask); % each cell contains a 3D array with Label_num_loc only in the location of the ROI (the ROI mask itself)
    
	% Remove NaN values from the quantitative map
	tmp_Nan_map = isnan(qmap_3D{roi_count});
	if (sum(tmp_Nan_map(:)))
		tmp_qmap              = qmap_3D{roi_count};
		tmp_qmap(tmp_Nan_map) = 0;
		qmap_3D{roi_count}    = tmp_qmap;
	end
	clear tmp_qmap tmp_Nan_map;
    
    % Count the number of voxels in each ROI: original number, and after erosion and Chauvenet outlier-removal respectively
    N_vox_in_ROI(roi_count,1) = length(qmap_3D{roi_count}(qmap_3D{roi_count} ~= 0)); % original number
    Seg_map_orig = Seg_ROI_3D; % save ROI seg before changes for later comparison

	% -----------
	% Erode maps
	% -----------    
    if (erosion_op.NBE > 0)
		qmap_3D   {roi_count} = erode_2D_mat(qmap_3D   {roi_count},erosion_op.NBE);
		Seg_ROI_3D{roi_count} = erode_2D_mat(Seg_ROI_3D{roi_count},erosion_op.NBE);
	elseif (erosion_op.MATLAB > 1)
		erosion_se            = strel('line',erosion_op.MATLAB,90); 
        qmap_3D{roi_count}    = imerode     (qmap_3D   {roi_count},erosion_se    );
		Seg_ROI_3D{roi_count} = imerode     (Seg_ROI_3D{roi_count},erosion_se    );
	end
    N_vox_in_ROI(roi_count,2) = length(qmap_3D{roi_count}(qmap_3D{roi_count}~=0)); % after erosion
	
	% ------------------------
	% Perform outlier removal
	% ------------------------
    if (chauvenet_flag)
        qmap_tmp  = qmap_3D{roi_count};
        qmap_mean = mean(qmap_tmp(qmap_tmp~=0)); % mean value of current ROI ("roi_name")
        qmap_SD   =  std(qmap_tmp(qmap_tmp~=0));
        qmap_tmp(qmap_tmp < (qmap_mean - chauvenet_flag*qmap_SD)) = 0;
        qmap_tmp(qmap_tmp > (qmap_mean + chauvenet_flag*qmap_SD)) = 0;
        qmap_mask = logical(qmap_tmp);
        qmap_3D   {roi_count} = qmap_3D   {roi_count}.*qmap_mask;
        Seg_ROI_3D{roi_count} = Seg_ROI_3D{roi_count}.*qmap_mask;
	end
    N_vox_in_ROI(roi_count,3) = length(qmap_3D{roi_count}(qmap_3D{roi_count}~=0)); % after erosion & chauvenet
    N_vox_in_ROI(roi_count,4) = (100*((N_vox_in_ROI(roi_count,1) - N_vox_in_ROI(roi_count,3)) / N_vox_in_ROI(roi_count,1))); % percent of deducted voxels
    
    % user can specify the max percent of voxels to be deducted from ROI
    if N_vox_in_ROI(roi_count,4) > prct_of_deducted_voxels_thresh
        above_thresh_count = above_thresh_count+1;
        ROIs_w_prct_deducted_voxels_above_thresh{above_thresh_count,1} = {roi_name};
        ROIs_w_prct_deducted_voxels_above_thresh{above_thresh_count,2} = roi_FS_idx; 
        ROIs_w_prct_deducted_voxels_above_thresh{above_thresh_count,3} = Seg_map_orig{1};
        ROIs_w_prct_deducted_voxels_above_thresh{above_thresh_count,4} = Seg_ROI_3D{roi_count};
%        error('The number of voxels deducted from "%s" is exceptional. Please examine the segmentation manually (before and after corrections).',roi_name);
    end
    
    % Remove ROIs with number of voxels under threshold
    if min_voxel_in_ROI > 0 
    [FS_ROIs_for_processing, ROI_labels, qmap_3D, Seg_ROI_3D, N_vox_in_ROI, tiny_ROIs_removed_FS_idx] = ...
    remove_tiny_ROIs_gal_salomon(FS_ROIs_for_processing, ROI_labels , qmap_3D, Seg_ROI_3D, N_vox_in_ROI, min_voxel_in_ROI);
    end

	% ------------------------------
    % extract statistical features
	% ------------------------------
      
    qmap_ROI = nonzeros(qmap_3D{roi_count});
%   N_scans_mat_loc = 2 + (Scan_session*2-1);
    
	stats_arr = [N_vox_in_ROI(roi_count,3)             ...     % no. of voxels in ROI (after criteria)
		         mean(qmap_ROI)                        ...     % Mean
	             std(qmap_ROI)                         ...     % Standard deviation
                 100*std(qmap_ROI)/mean(qmap_ROI)      ...     % CV
		         median(qmap_ROI)                      ...     % Median
		         prctile(qmap_ROI,90)                  ...     % 90th percentile
		         prctile(qmap_ROI,75)                  ...     % 75th percentile
                 prctile(qmap_ROI,25)                  ...     % 25th percentile
		         prctile(qmap_ROI,10)                  ...     % 10th percentile
                 skewness(qmap_ROI)                    ...     % skewness of qMRI values
		         kurtosis(qmap_ROI)];						   % kurtosis of qMRI values 

	FS_ROIs_for_processing(roi_count, 2:(1+length(stats_arr))) = stats_arr; % change the 2 to a variable that represents the number of parameters that already exists in FS_ROIs_for_processing
%   FS_ROIs_for_processing(roi, N_scans_mat_loc:(N_scans_mat_loc+(num_stat_parameters - 2))) = 
    end
end
