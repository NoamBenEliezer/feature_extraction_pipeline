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

% The "all" variables include the ROIs with over 30 voxels and the packed ROIs.

function [FS_ROIs_for_processing     , ...
		  ROI_labels                 , ...
		  qmap_3D                    , ...
		  Seg_ROI_3D                 , ...
		  FS_ROIs_for_processing_all , ...
		  ROI_labels_all             , ...
		  qmap_3D_all                , ...
		  Seg_ROI_3D_all             , ...
		  N_vox_in_ROI] = ROI_3D_collector_BA (Seg_map, qMRI_map, erosion_op, chauvenet_flag, prct_of_deducted_voxels_thresh)

% Extract label names and indices from FreeSurfer lookup table ("FS_Color_label_list" in Matlab_Scripts/Fs)
[FS_label_num, FS_label_name] = Label_reader;

Scan_session = 1;

FS_ROIs_for_processing = []; %contains the unique values of ROIs that are found in Seg_vol
% parfor i=1:14175
max_FS_label_num = max(FS_label_num);
for FS_roi_idx = 1:max_FS_label_num %find which ROIs from the full freesurfer lookup table exist in the data.
    tmp = Seg_map(Seg_map == FS_roi_idx);
    % If Freesurfer index is found in our Segment volume then keep index for later processing
    if (sum(tmp(:)))
        FS_ROIs_for_processing = [FS_ROIs_for_processing FS_roi_idx];
    end
end
FS_ROIs_for_processing = transpose(FS_ROIs_for_processing);
N_ROIs_for_processing  = length(FS_ROIs_for_processing);

clear FS_roi_idx tmp

for roi_idx = 1:N_ROIs_for_processing
    % Extract freesurfer label of current ROI
    label_num_loc          = find(FS_ROIs_for_processing(roi_idx) == FS_label_num);
    % Label_ROI            = convertCharsToStrings(Label_name{Label_num_loc});
    Label_ROI              = string(FS_label_name{label_num_loc});
    ROI_labels(roi_idx)    = Label_ROI;
    
	% Initialize variables
    qmap_3D   {roi_idx} = zeros(size(qMRI_map(:,:,:,Scan_session)));
    Seg_ROI_3D{roi_idx} = zeros(size(qMRI_map(:,:,:,Scan_session)));
    
	% Extract quantitative map values for current Freesurfer ROI
    seg_mask = (Seg_map==FS_ROIs_for_processing(roi_idx));
    qmap_3D   {roi_idx}(seg_mask) = qMRI_map(seg_mask); % each cell contains a 3D array with qMRI values only in the location of the ROI (with ROI mask)
    Seg_ROI_3D{roi_idx}(seg_mask) = Seg_map (seg_mask); % each cell contains a 3D array with Label_num_loc only in the location of the ROI (the ROI mask itself)
    
    % New code
	% Remove NaN values from the quantitative map
	tmp_Nan_map = isnan(qmap_3D{roi_idx});
	if (sum(tmp_Nan_map(:)))
		tmp_qmap              = qmap_3D{roi_idx};
		tmp_qmap(tmp_Nan_map) = 0;
		qmap_3D{roi_idx}   = tmp_qmap;
	end
	clear tmp_qmap tmp_Nan_map;
	
    % Original code:
% 	if (~sum(sum(sum(isnan(qmap_3D{FS_roi_idx})))) == 0)
% 		tmp_qmap                 = qmap_3D{FS_roi_idx};
% 		tmp_Nan_map              = isnan(qmap_3D{FS_roi_idx});
% 		tmp_qmap(tmp_Nan_map==1) = 0;
% 		qmap_3D{FS_roi_idx}      = tmp_qmap;
% 		clear tmp_Nan_map tmp_T2_map
% 	end
%     
    % Count the number of voxels in each ROI: original number, and after erosion and Chauvenet outlier-removal respectively
    N_vox_in_ROI(roi_idx,1) = length(qmap_3D{roi_idx}(qmap_3D{roi_idx} ~= 0));

	% -----------
	% Erode maps
	% -----------    
    if (erosion_op.NBE > 0)
		qmap_3D   {roi_idx} = erode_2D_mat(qmap_3D   {roi_idx},erosion_op.NBE);
		Seg_ROI_3D{roi_idx} = erode_2D_mat(Seg_ROI_3D{roi_idx},erosion_op.NBE);
	elseif (erosion_op.MATLAB > 1)
		erosion_se          = strel('line',erosion_op.MATLAB,90); 
        qmap_3D{roi_idx}    = imerode     (qmap_3D   {roi_idx},erosion_se    );
		Seg_ROI_3D{roi_idx} = imerode     (Seg_ROI_3D{roi_idx},erosion_se    );
	end
    N_vox_in_ROI(roi_idx,2) = length(qmap_3D{roi_idx}(qmap_3D{roi_idx}~=0));
	
	% ------------------------
	% Perform outlier removal
	% ------------------------
    if (chauvenet_flag)
        qmap_tmp  = qmap_3D{roi_idx};
        qmap_mean = mean(qmap_tmp(qmap_tmp~=0)); % mean value of current ROI ("Label_ROI")
        qmap_SD   =  std(qmap_tmp(qmap_tmp~=0));
        qmap_tmp(qmap_tmp < (qmap_mean - chauvenet_flag*qmap_SD)) = 0;
        qmap_tmp(qmap_tmp > (qmap_mean + chauvenet_flag*qmap_SD)) = 0;
        qmap_mask = logical(qmap_tmp);
        qmap_3D   {roi_idx} = qmap_3D   {roi_idx}.*qmap_mask;
        Seg_ROI_3D{roi_idx} = Seg_ROI_3D{roi_idx}.*qmap_mask;
	end
    N_vox_in_ROI(roi_idx,3) = length(qmap_3D{roi_idx}(qmap_3D{roi_idx}~=0));
    N_vox_in_ROI(roi_idx,4) = (100*((N_vox_in_ROI(roi_idx,1) - N_vox_in_ROI(roi_idx,3)) / N_vox_in_ROI(roi_idx,1))); % percent of deducted voxels
    
    try
        N_vox_in_ROI(roi_idx,4) > prct_of_deducted_voxels_thresh;
    catch
        print(sprintf('The number of voxels deducted from "%s" is exceptional. Please examine the segmentation manually (before and after corrections).',Label_ROI));
    end

	% ------------------------------
    % extract statistical features
	% ------------------------------
    
%   FS_ROIs_for_processing(roi_idx,2) = length(Seg_vol(Seg_vol==ROI_list(FS_idx)));    % num of voxels before the criteria
    
    qmap_ROI = nonzeros(qmap_3D{roi_idx});
%   N_scans_mat_loc = 2 + (Scan_session*2-1);
    
	stats_arr = [N_vox_in_ROI(roi_idx,3)               ...     % no. of voxels in ROI (after criteria)
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

	FS_ROIs_for_processing(roi_idx, (1+1):(1+length(stats_arr))) = stats_arr; % change the one to a variable that represents the number of parameters that already exists in FS_ROIs_for_processing
%   FS_ROIs_for_processing(roi_idx, N_scans_mat_loc:(N_scans_mat_loc+(num_stat_parameters - 2))) = 
    
end


% [ROI_list_all, Slice_labels_all] = ROIs_gather_BA(ROI_list, Slice_labels);

[FS_ROIs_for_processing_all   ,...
 ROI_labels_all               ,...
 qmap_3D_all                  ,...
 Seg_ROI_3D_all] = ROIs_pack_BA(FS_ROIs_for_processing, ROI_labels , qmap_3D, Seg_ROI_3D, N_vox_in_ROI);


ROI_labels_all=ROI_labels_all';

