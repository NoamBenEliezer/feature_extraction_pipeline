function [session_field_name, group_field_name, subj_field_name, map_field_name, roi_field_name, feature_field_name]...
           = get_field_names(session_num, group_name, subj_name, map_name, roi_name, feature)

qMRI_STATS_SET_GLOBALS;
stat_features    = {VOX_NUM_FN, MEAN_FN, SD_FN, CV_FN, MEDIAN_FN, PRCTL_90_FN, PRCTL_75_FN, PRCTL_25_FN, PRCTL_10_FN, SKEWNESS_FN, KURTOSIS_FN};

if exist("session_num","var")
    session_field_name = [SESSION_NAME_PREFIX '_S' num2str(session_num)];
    if exist("group_name","var")
        group_field_name = [GROUP_NAME_PREFIX group_name];
        if exist("subj_name","var")
	        subj_field_name    = [SUBJECT_NAME_PREFIX '_' num2str(subj_name)];
		    if exist("map_name","var")
		        map_field_name     = [MAP_NAME_PREFIX '_' map_name];
			    if exist("roi_name","var")
	                if isa(roi_name,'double')
		                roi_name_tmp = ROI_FS_idx2name(roi_name);
                    else
                        roi_name_tmp = roi_name;
	                end
	                roi_name = strrep(roi_name_tmp, '-', '_');
	                roi_name = strrep(roi_name, '*', '');
			        roi_field_name     = [ROI_NAME_PREFIX '_' roi_name];
				    if exist("feature","var")
                        if any(contains(stat_features,feature))
				            feature_field_name = char(strcat(FEATURE_NAME_PREFIX, feature));
                        else
                            feature_field_name = char(feature);
                        end
				    end
			    end
		    end
        end
    end
else
	error('Please provide at least one input');
end
end


% if exist("feature","var") % if all fields are given
% 	session_field_name = [SESSION_NAME_PREFIX '_' num2str(session_num)];
% 	subj_field_name    = [SUBJECT_NAME_PREFIX '_' num2str(subj_name)];
% 	map_field_name     = [MAP_NAME_PREFIX '_' map_name];
% 	roi_field_name     = [ROI_NAME_PREFIX '_' roi_name];
% 	feature_field_name = [FEATURE_NAME_PREFIX '_' feature];
% elseif ~exist("feature","var") && exist("map_name","var") % if fields up to map_name are given
% 	session_field_name = ['S' num2str(session_num)];
% 	subj_field_name = ['subj_' num2str(subj_name)];
% 	map_field_name = ['map_' map_name];
% elseif ~exist("map_name","var") && exist("subj_name","var") % if fields up to subj_name are given
% 	session_field_name = ['S' num2str(session_num)];
% 	subj_field_name = ['subj_' num2str(subj_name)];
% elseif ~exist("subj_num","var") && exist("session_num","var") % if fields up to session_num are given
% 	session_field_name = ['S' num2str(session_num)];
% else
% 	error('Please provide atleast one input');
% end
