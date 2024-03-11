
% function [stats] = struct_2_excel(stats_all_subj, ROIs_in_data)

scripts_path='/home/noambe/Public/Statistics';
addpath(genpath(scripts_path));
qMRI_STATS_SET_GLOBALS;

groups           = {EXPERIMENT_GROUP_NAME, CONTROL_GROUP_NAME};
session_num      = '3'; % '2';  ['1';'3']; 
subj_2_ignore_S1 = {'V103','V107','V119', 'V160'};
subj_2_ignore_S2 = {'107', 'V192', 'V307', 'V160'};
subj_2_ignore_S3 = {'V303','V377', 'V160'};
map_name         = MAP_TYPE_PD;
stat_features    = {VOX_NUM_FN, MEAN_FN, SD_FN, CV_FN, MEDIAN_FN, PRCTL_90_FN, PRCTL_75_FN, PRCTL_25_FN, PRCTL_10_FN, SKEWNESS_FN, KURTOSIS_FN};
Nrois            = size(ROIs_in_data,1);
Nsubj            = length(EXPERIMENT_GROUP)+length(CONTROL_GROUP);
stats            = zeros(Nsubj,length(stat_features)*Nrois*length(session_num));

for curr_session = 1:length(session_num)
    session_field_name = [SESSION_NAME_PREFIX '_S' session_num(curr_session)]; % need in order to access list of subjects
    for group = 1:length(groups)
        curr_group = groups{group};
        group_field_name = [GROUP_NAME_PREFIX curr_group];
        subj_list = fields(stats_all_subj.(session_field_name).(group_field_name));
        Nsubj_in_group     = length(subj_list);
        if group == 1
            Nsubj_in_first_group = Nsubj_in_group;
        end
        for roi = 1:Nrois
            curr_roi = ROIs_in_data{roi};
            for feature = 1:length(stat_features)
                curr_feature = extractAfter(stat_features(feature),'_');
                for subj_idx = 1:Nsubj_in_group
                    subj_name = extractAfter(subj_list{subj_idx},[SUBJECT_NAME_PREFIX '_']);
                    if session_num(curr_session) == '1' && any(contains(subj_2_ignore_S1,subj_name))
                        continue
                    elseif session_num(curr_session) == '2' && any(contains(subj_2_ignore_S2,subj_name))
                        continue
                    elseif session_num(curr_session) == '3' && any(contains(subj_2_ignore_S3,subj_name))
                        continue
                    end
	                % curr_subj_field_name = subj_list{subj_idx};
		                % expr_s1_subj_count = expr_s1_subj_count+1;
                        % s1_mean_vec(subj_idx) = qMRI_stats_get(curr_session, session_num(curr_session), subj_name, map_name, roi_FS_label, feature);
                   if group == 1
                       if isequal(stat_features{feature}, VOX_NUM_FN)
                           N_vox = qMRI_stats_get(stats_all_subj, session_num(curr_session), curr_group, subj_name, map_name, curr_roi, curr_feature);
                           if N_vox == 0
                               stats(subj_idx,length(stat_features)*(roi-1)+feature,curr_session) = 0;
                           else
                               stats(subj_idx,length(stat_features)*(roi-1)+feature,curr_session) = N_vox(3);
                           end
                       else
                           stats(subj_idx,length(stat_features)*(roi-1)+feature,curr_session) = qMRI_stats_get(stats_all_subj, session_num(curr_session), curr_group, subj_name, map_name, curr_roi, curr_feature);
                       end
                   else
                       if isequal(stat_features{feature}, VOX_NUM_FN)
                           N_vox = qMRI_stats_get(stats_all_subj, session_num(curr_session), curr_group, subj_name, map_name, curr_roi, curr_feature);
                           if N_vox == 0
                               stats(Nsubj_in_first_group+subj_idx,length(stat_features)*(roi-1)+feature,curr_session) = 0;
                           else
                               stats(Nsubj_in_first_group+subj_idx,length(stat_features)*(roi-1)+feature,curr_session) = N_vox(3);
                           end
                       else
                           stats(Nsubj_in_first_group+subj_idx,length(stat_features)*(roi-1)+feature,curr_session) = qMRI_stats_get(stats_all_subj, session_num(curr_session), curr_group, subj_name, map_name, curr_roi, curr_feature);
                       end
                   end
                end
            end
        end
    end
end 

writematrix(stats, '/home/noambe/Public/qMRI_qT2/Mindfulness/statistics_Results/All_ROIs_w.o._wm_S3.xlsx')



% end
