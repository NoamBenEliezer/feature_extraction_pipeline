
% This function allows the user to easily access a certain value or area of the statistical features data structure.
% roi_name = can be given as the FS_name (string) or as the FS_number (double)

function out = qMRI_stats_get(stat_struct, session_num, group_name, subj_name, map_name, roi_name, feature)

qMRI_STATS_SET_GLOBALS;

if exist("roi_name","var")
	if isa(roi_name,'double')
		roi_name_tmp = ROI_FS_idx2name(roi_name);
    else
        roi_name_tmp = roi_name;
	end
	roi_name = strrep(roi_name_tmp, '-', '_');
	roi_name = strrep(roi_name, '*', '');
end

try
if exist("feature","var") % if all fields are given
    [session_field_name, group_field_name, subj_field_name, map_field_name, roi_field_name, feature_field_name] = get_field_names(session_num, group_name, subj_name, map_name, roi_name, feature);
    out = stat_struct.(session_field_name).(group_field_name).(subj_field_name).(map_field_name).(roi_field_name).(feature_field_name);
elseif ~exist("feature","var") && exist("roi_name","var") % if fields up to map_name are given
    [session_field_name, group_field_name, subj_field_name, map_field_name, roi_field_name] = get_field_names(session_num, group_name, subj_name, map_name, roi_name);
    out = stat_struct.(session_field_name).(group_field_name).(subj_field_name).(map_field_name).(roi_field_name);
elseif ~exist("roi_name","var") && exist("map_name","var") % if fields up to map_name are given
    [session_field_name, group_field_name, subj_field_name, map_field_name] = get_field_names(session_num, group_name, subj_name, map_name);
    out = stat_struct.(session_field_name).(group_field_name).(subj_field_name).(map_field_name);
elseif ~exist("map_name","var") && exist("subj_name","var") % if fields up to subj_name are given
    [session_field_name, group_field_name, subj_field_name] = get_field_names(session_num, group_name, subj_name);
    out = stat_struct.(session_field_name).(group_field_name).(subj_field_name);
elseif ~exist("subj_name","var") && exist("group_name","var") % if only group_name is given
    [session_field_name, group_field_name] = get_field_names(session_num);
    out = stat_struct.(session_field_name).(group_field_name);
elseif ~exist("group_name","var") && exist("session_num","var") % if only session_num is given
    [session_field_name] = get_field_names(group_name, session_num);
    out = stat_struct.(session_field_name);
else
    error('Please provide at least one input');
end
catch e
    disp(sprintf('%s for subject %s', e.message, subj_name));
    out = 0;
end


% if exist("feature","var") % if all fields are given
% 	[session_field_name, subj_field_name, map_field_name, feature_field_name] = get_field_names(session_num, subj_name, map_name, feature);
% 	out = stat_struct.(session_field_name).(subj_field_name).(map_field_name).(feature_field_name);
% elseif ~exist("feature","var") && exist("map_name","var") % if fields up to map_name are given
%     [session_field_name, subj_field_name, map_field_name] = get_field_names(session_num, subj_name, map_name);
% 	out = stat_struct.(session_field_name).(subj_field_name).(map_field_name);
% elseif ~exist("map_name","var") && exist("subj_name","var") % if fields up to subj_name are given
% 	[session_field_name, subj_field_name] = get_field_names(session_num, subj_name);
% 	out = stat_struct.(session_field_name).(subj_field_name);
% elseif ~exist("subj_num","var") && exist("session_num","var") % if only session_num is given
% 	[session_field_name] = get_field_names(session_num);
% 	out = stat_struct.(session_field_name);
% else
% 	error('Please provide atleast one input');
% end


end