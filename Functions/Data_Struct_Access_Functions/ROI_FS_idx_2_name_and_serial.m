% Input: Free Surfer label number of specific ROI
% Output: 1x3 cell array with serial ROI index in ROI_names, Free Surfer label name, Free Surfer label number

function ROI_info = ROI_FS_idx_2_name_and_serial(FS_label_num,ROI_names)

	[FS_label_nums, FS_label_names] = Label_reader; % Read Free Surfer look up table

	roi_loc_in_FS_label_num_list = find(FS_label_nums==FS_label_num);
	roi_FS_label_name = FS_label_names{roi_loc_in_FS_label_num_list};
	roi_serial_idx = strmatch(roi_FS_label_name,ROI_names,"exact");
    
	ROI_info = {roi_serial_idx, roi_FS_label_name, FS_label_num};

	return

end