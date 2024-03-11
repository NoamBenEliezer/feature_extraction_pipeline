
% Load statistic results


% function [stats] = struct_2_excel(stats_all_subj, ROIs_in_data)

scripts_path='/home/noambe/Public/Statistics';
addpath(genpath(scripts_path));
qMRI_STATS_SET_GLOBALS;
results_folder     = '/home/noambe/Public/qMRI_qT2/Mindfulness/statistics_Results';
results_filename   = 'num_voxel_percent_change_between_sessions_T2_nNeighbors_4.xlsx';

groups             = {EXPERIMENT_GROUP_NAME, CONTROL_GROUP_NAME};
session_num        = ['1';'3']; % '3'; % '2';  
subj_2_ignore_S1   = {'V103','V107','V119', 'V160'};
subj_2_ignore_S2   = {'107', 'V192', 'V307', 'V160'};
subj_2_ignore_S3   = {'V303','V377', 'V160'};
map_name           = MAP_TYPE_T2;
stat_features      = {VOX_NUM_FN, MEAN_FN, SD_FN, CV_FN, MEDIAN_FN, PRCTL_90_FN, PRCTL_75_FN, PRCTL_25_FN, PRCTL_10_FN, SKEWNESS_FN, KURTOSIS_FN};
features_2_include = {VOX_NUM_FN};
Nrois              = size(ROIs_in_data,1);
Nsubj              = length(EXPERIMENT_GROUP)+length(CONTROL_GROUP);
Ncols_per_ROI      = 3; % num voxels in S1, num voxels in S3, perent change of num voxels between S1 and S3
voxel_change_arr   = zeros(Nsubj, Nrois*Ncols_per_ROI);

for curr_session = 1:length(session_num)
    session_field_name = [SESSION_NAME_PREFIX '_S' session_num(curr_session)]; % need in order to access list of subjects
    for group = 1:length(groups)
        curr_group       = groups{group};
        group_field_name = [GROUP_NAME_PREFIX curr_group];
        if isequal(curr_group, EXPERIMENT_GROUP_NAME)
            subj_list = EXPERIMENT_GROUP;
        elseif isequal(curr_group, CONTROL_GROUP_NAME)
            subj_list     = CONTROL_GROUP;
        end
        Nsubj_in_group    = length(subj_list);
        % subj_list        = fields(stats_all_subj.(session_field_name).(group_field_name));
        % Nsubj_in_group   = length(subj_list);
        if group == 1
            Nsubj_in_first_group = Nsubj_in_group;
        end
        for roi = 1:Nrois
            curr_roi = ROIs_in_data{roi};
            for feature = 1:length(features_2_include) %1:length(stat_features)
                curr_feature = extractAfter(features_2_include{feature},'_');
                for subj_idx = 1:Nsubj_in_group
                    subj_name = subj_list{subj_idx};
                    if session_num(curr_session) == '1' && any(contains(subj_2_ignore_S1,subj_name))
                        if group == 1
                            voxel_change_arr(subj_idx,Ncols_per_ROI*(roi-1)+curr_session) = 0;
                        else
                            voxel_change_arr(Nsubj_in_first_group+subj_idx,Ncols_per_ROI*(roi-1)+curr_session) = 0;
                        end
                        continue
                    elseif session_num(curr_session) == '2' && any(contains(subj_2_ignore_S2,subj_name))
                        if group == 1
                            voxel_change_arr(subj_idx,Ncols_per_ROI*(roi-1)+curr_session) = 0;
                        else
                            voxel_change_arr(Nsubj_in_first_group+subj_idx,Ncols_per_ROI*(roi-1)+curr_session) = 0;
                        end
                        continue
                    elseif session_num(curr_session) == '3' && any(contains(subj_2_ignore_S3,subj_name))
                        if group == 1
                            voxel_change_arr(subj_idx,Ncols_per_ROI*(roi-1)+curr_session) = 0;
                        else
                            voxel_change_arr(Nsubj_in_first_group+subj_idx,Ncols_per_ROI*(roi-1)+curr_session) = 0;
                        end
                        continue
                    end
                   if group == 1
                       if isequal(features_2_include{feature}, VOX_NUM_FN)
                           N_vox = qMRI_stats_get(stats_all_subj, session_num(curr_session), curr_group, subj_name, map_name, curr_roi, curr_feature);
                           if N_vox == 0
                               Num_vox_in_session = 0;
                               voxel_change_arr(subj_idx,Ncols_per_ROI*(roi-1)+curr_session) = Num_vox_in_session;
                           else
                               Num_vox_in_session = N_vox(3);
                               voxel_change_arr(subj_idx,Ncols_per_ROI*(roi-1)+curr_session) = N_vox(3);
                           end
                       % else
                           % voxel_change_arr(subj_idx,length(stat_features)*(roi-1)+feature,curr_session) = qMRI_stats_get(stats_all_subj, session_num(curr_session), curr_group, subj_name, map_name, curr_roi, curr_feature);
                       end
                   else
                       if isequal(features_2_include{feature}, VOX_NUM_FN)
                           N_vox = qMRI_stats_get(stats_all_subj, session_num(curr_session), curr_group, subj_name, map_name, curr_roi, curr_feature);
                           if N_vox == 0
                               Num_vox_in_session = 0;
                               voxel_change_arr(Nsubj_in_first_group+subj_idx,Ncols_per_ROI*(roi-1)+curr_session) = Num_vox_in_session;
                           else
                               Num_vox_in_session = N_vox(3);
                               voxel_change_arr(Nsubj_in_first_group+subj_idx,Ncols_per_ROI*(roi-1)+curr_session) = Num_vox_in_session;
                           end
                       % else
                       %     voxel_change_arr(Nsubj_in_first_group+subj_idx,length(stat_features)*(roi-1)+feature,curr_session) = qMRI_stats_get(stats_all_subj, session_num(curr_session), curr_group, subj_name, map_name, curr_roi, curr_feature);
                       end
                   end
                end
            end
        end
    end
end 

%%

for prct = 3:3:size(voxel_change_arr,2)
    for subj = 1:size(voxel_change_arr,1)
        num_vox_S1 = voxel_change_arr(subj, prct-2);
        num_vox_S3 = voxel_change_arr(subj, prct-1);
        if voxel_change_arr(subj, prct-2)>0 && voxel_change_arr(subj, prct-1)>0 
            prct_change = ((num_vox_S3-num_vox_S1)/num_vox_S1)*100;
            voxel_change_arr(subj,prct) = prct_change;
        else
            voxel_change_arr(subj,prct) = 0;
        end
    end
end

writematrix(voxel_change_arr, [results_folder filesep results_filename])



% end