% Input: Free Surfer label name of specific ROI
% Output: 1x3 cell array with serial ROI index in ROI_names, Free Surfer label name, Free Surfer label number

function ROI_info = ROI_Name_2_FS_idx_and_serial_idx(ROI_name,ROI_names)

	[FS_label_nums, FS_label_names] = Label_reader; % Read Free Surfer look up table

	roi_serial_idx = strmatch(ROI_name,ROI_names,"exact");
    roi_loc_in_FS_list = strmatch(ROI_name,FS_label_names,"exact");
    roi_FS_label_num = FS_label_nums(roi_loc_in_FS_list);

	ROI_info = {roi_serial_idx, ROI_name, roi_FS_label_num};

	return

end