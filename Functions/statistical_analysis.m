
scripts_path='/home/noambe/Public/Statistics';
addpath(genpath(scripts_path));
qMRI_STATS_SET_GLOBALS;

% ================================
% Load stats data
% ================================
% filename = 'T2_results_18092023_White_Matter_all';
% date     = '18092023';
% 
% stats_path='/home/noambe/Public/Statistics/Results-example';
% stats_path_dir=dir(stats_path);
% % load statistic variables
% for i=1:length (stats_path_dir)
%     if strcmp(stats_path_dir(i).name, sprintf('T2_results_%s_All_ROIs.mat',date))
%         load(stats_path_dir(i).name);
% 		break;
%     end
% end

% create vectors for subject numbers of experiment and control group
ctrlG = ["V106", "V117", "V122", "V131", "V142", "V154", "V211", "V225", "V260", "V294", "V329", "V340", "V377", "V400", "V432", "V438", "V448", "V451", "V452", "V470"];
groups = {EXPERIMENT_GROUP_NAME, CONTROL_GROUP_NAME};

%% Perform t-test beetween before and after scans - Mindfulness group

	% We do need to know which subject is missing because we are doing a paired t-test so we need pairs of data, if someone is missing from one session we 
    % need to take him out of the other too.
	% The first option currently does not save the missing subjects.
    % The problem with the second option is that when there was a missing subject (exists in experiment list but data is missing from struct) 
    % it jumped an index and made me miss another subject instead.
	
	% if any(contains(expr,subj_field_names{subj}(end-3:end))) % check if subject is in the experiment group
	% 	expr_subj_count = expr_subj_count+1;
	%     subj_name = expr(expr_subj_count);
	% 	curr_subj_field_name = [SUBJECT_NAME_PREFIX '_' char(subj_name)];
	%     if any(contains(subj_field_names,curr_subj_field_name)) % in case subject does not exist in data structure
	%         s1_mean_vec(end+1) = qMRI_stats_get(stat_struct, session_num, subj_name, map_name, roi_name, feature);
	% 	else
		% 	missing_subj{end+1} = subj_name;
	% 	end
	% end

session_num  = ['1','2','3'];
map_name     = MAP_TYPE_T2;
roi_FS_label = 11;
stat_features = {MEAN_FN, SD_FN, CV_FN, MEDIAN_FN, PRCTL_90_FN, PRCTL_75_FN, PRCTL_25_FN, PRCTL_10_FN, SKEWNESS_FN, KURTOSIS_FN}; % change to feature, not field name
curr_group = groups{1};
group_field_name = [GROUP_NAME_PREFIX curr_group];

% Add loop over features and ROIs
% s1_mean_vec        = [];
% expr_s1_subj_count = 0;
% s3_mean_vec        = [];
% expr_s3_subj_count = 0;
stats = cell(2, length(stat_features));


% for curr_session = 1:length(session_num)
%     session_field_name = [SESSION_NAME_PREFIX '_S' session_num(curr_session)]; % need in order to access list of subjects
%     subj_list = fields(stats_all_subj.(session_field_name).(group_field_name));
%     Nsubj     = length(subj_list);
%     for subj_idx = 1:Nsubj
%         subj_name = extractAfter(subj_list{subj_idx},[SUBJECT_NAME_PREFIX '_']);
% 	    curr_subj_field_name = subj_list{subj_idx};
%         for roi = 1:length(ROIs_in_data)
%             curr_roi = ROIs_in_data{roi};
%             for feature = 1:length(stat_features)
%                 curr_feature = extractAfter(stat_features(feature),'_');
%                 stats{curr_session, feature} = zeros(length(EXPERIMENT_GROUP),1); % make more  modular
%                 if any(contains(EXPERIMENT_GROUP,subj_name)) % check if subject is in the experiment group
% 		            % expr_s1_subj_count = expr_s1_subj_count+1;
%                     % s1_mean_vec(subj_idx) = qMRI_stats_get(curr_session, session_num(curr_session), subj_name, map_name, roi_FS_label, feature);
%                     stats{curr_session, feature}(subj_idx) = qMRI_stats_get(stats_all_subj, curr_group, session_num(curr_session), subj_name, map_name, curr_roi, curr_feature);
%                 end
%             end
%         end
%     end
% end 

% --------------------------



subj_list = fields(stats_all_subj.session_S3.group_Mindfulness); % make more modular
Nsubj = length(subj_list);
session_num = 3;
expr_s1_subj_count = 0;

for subj_idx = 1:Nsubj
    subj_name = extractAfter(subj_list{subj_idx},[SUBJECT_NAME_PREFIX '_']);
	disp(subj_name)
	curr_subj_field_name = subj_list{subj_idx};
	disp(curr_subj_field_name)

	if any(contains(EXPERIMENT_GROUP,subj_name)) % check if subject is in the experiment group
		expr_s1_subj_count = expr_s1_subj_count+1;
		disp(expr_s1_subj_count)
        s3_mean_vec(subj_idx) = qMRI_stats_get(stats_all_subj, curr_group, session_num(curr_session), subj_name, map_name, curr_roi, curr_feature);
	end
end

[h_expr_s1_s3, p_expr_s1_s3, c_expr_s1_s3, ttest_stats_expr_s1_s3] = ttest(s1_mean_vec, s3_mean_vec, 'Alpha',0.05,'Tail','both');



