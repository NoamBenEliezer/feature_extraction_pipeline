% Input: serial index of ROI in ROI_names
% Output: 1x3 cell array with serial ROI index in ROI_names, Free Surfer label name, Free Surfer label number

function ROI_info = ROI_SerialIdx_2_FS(serial_idx,ROI_names)

	[FS_label_nums, FS_label_names] = Label_reader; % Read Free Surfer look up table

	roi_name = char(ROI_names(serial_idx));
    roi_loc_in_FS_list = strmatch(roi_name,FS_label_names,"exact");
    roi_FS_label_num = FS_label_nums(roi_loc_in_FS_list);

	ROI_info = {serial_idx, roi_name, roi_FS_label_num};

	return

end