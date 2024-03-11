%{
This pipeline extracts statistical features for all subjects for all chosen ROIs.
User needs to define:
Session path - if there are more than 1 scan sessions create a variable for each path.
Scripts path - path to Matlab helper functions.
Results_folder - define the folder in which to save the results.
expr, control - define which subjects are in which group (experiment or control). Enter folder names containing their data. Recommended: Start
folder names with 'V' (for volunteer).
Decide about desired analysis parameters: chauvenet criterion, erosion
using matlab function of NBE function, number of statistical parameters,
threshold of percent voxels deducted from ROI after erosion and
chauvenet, minimum number of voxels to include an ROI.
map types - the map types you wish to analyze.
roi_names - FS labels of ROIs you wish to process. 
ROIs_2_combine - FS labels of ROIs you wish to combine ex. left and right
hippocampus.
results_filename - name of the results file
%}

%%
clear all;
clc

scripts_path = '/home/noambe/Public/Statistics/Matlab_Scripts/';
addpath(genpath(scripts_path));

% GLOBAL Definitions
qMRI_STATS_SET_GLOBALS;

addpath(genpath(DATA_DIR));
Sessions_path_arr          = cell(1,length(SESSIONS));
for ses = 1:length(SESSIONS)
    Sessions_path_arr{ses} = [DATA_DIR SESSIONS{ses}];
end

addpath(genpath(RESULTS_FOLDER));
if (~exist(RESULTS_FOLDER,'dir'))
    mkdir(RESULTS_FOLDER);
end

% Validations
if (EROSION_OPT.NBE_nPx) && (EROSION_OPT.MATLAB_nPx > 1)
	error('Please choose only one erosion option');
end


% ---------------------------------------
% Loop over quantitative maps
% ---------------------------------------
for map_idx       = 1:length(MAP_TYPES)
    curr_map_type = MAP_TYPES{map_idx};
	map_fn        = [MAP_NAME_PREFIX '_' curr_map_type]; % map field name for final structure
   
    catch_errs    = {};
    err_count     = 0;
    
    % ---------------------------------------------------
    % Loop over all time points / sessions
    % ---------------------------------------------------
    for session_idx  = 1:length(Sessions_path_arr)
	    curr_session = char(SESSIONS(session_idx));
		session_dir  = dir(Sessions_path_arr{session_idx});
	    subj_list    = {};
		session_fn   = [SESSION_NAME_PREFIX '_' curr_session]; % session field name for final stats structure
	    
        % Collect names of all subjects which will be processed
	    for i=1:length (session_dir)
		    if session_dir(i).name(1)==SUBJECT_FOLDER_NAME_PREFIX
			    subj_list{end+1} = session_dir(i).name;
		    end
	    end
	    n_subjects = length(subj_list);
    
	    % ---------------------------------------------------
	    % Loop over all subjects
	    % ---------------------------------------------------
	    for subj_idx = 1:n_subjects
	    try
		    subj_foldername   = subj_list{subj_idx};
			subject_fn        = [SUBJECT_NAME_PREFIX '_' subj_foldername]; % subject field name for final stats structure
			[qMRI_map_name, Seg_map_name, map_def, Seg_def, qMRI_map_subname] = qMRI_map_variables(curr_map_type, subj_foldername);
		    subj_path         = [Sessions_path_arr{session_idx} filesep subj_foldername];
		    qMRI_map_filename = [Sessions_path_arr{session_idx} filesep subj_foldername filesep qMRI_map_name '.mat'];

            qMRI_map_file_data = load(qMRI_map_filename);
    
		    if  strcmp(qMRI_map_name,'mrQ_maps') % mrQ results
			    qMRI_map = qMRI_map_file_data.(qMRI_map_name).(qMRI_map_subname); 
			    seg_map  = qMRI_map_file_data.(qMRI_map_name).(Seg_map_name);
            elseif contains(qMRI_map_name, 'EMC') % qT2 results
                segmentation_path = [SEGMENTATION_ROOT PROJECT_NAME filesep char(curr_session) filesep subj_foldername filesep 'temp'];
                tmp = load([segmentation_path filesep Seg_map_name]);
                qT2_seg = tmp.qT2_seg;
                Nslices = size(qT2_seg,3);
                for slice_idx = 1:Nslices
                    qMRI_map(:,:,slice_idx) = qMRI_map_file_data.EMC_results(slice_idx).(map_def);
                    seg_map (:,:,slice_idx) = fliplr(rot90(squeeze(qT2_seg(:,:,slice_idx)),3));
                end
            else
			    qMRI_map = eval(map_def);
                Seg_map_fn = [char(Sessions_path_arr(session_idx)) filesep subj_foldername filesep Seg_map_name  '.mat'];
			    load (Seg_map_fn);
			    seg_map    = eval(Seg_def);
		    end
            
			if ~isequal(size(qMRI_map), size(seg_map))
				raiseError('qMRI map and Segmentation map have different dimensions!')
            end
			
			clear qMRI_map_file_data;

            % ------------------
            % Adjust qMRI data
            %-------------------
		    if strcmp(curr_map_type,'QSM')
			    seg_map = permute(seg_map, [2,1,3]);
			    seg_map = fliplr(seg_map);
		    end
    
		    if strcmp(curr_map_type,'ADC')
			    qMRI_map = double(qMRI_map);
			    qMRI_map = qMRI_map*1e4;   % (mm^2)/s --> (m^2)/s
		    end
    
			if strcmp(curr_map_type,'T1')
				qMRI_map = 1e3*(qMRI_map); % sec --> msec
			end
    
            if strcmp(curr_map_type,'T2')
			    qMRI_map = 1e3*(qMRI_map); % sec --> msec
            end
    
    % [RH] Debugged up to here 23/8/23
			% 1. At this stage you have a 3D qMRI map & 3D Seg_map with ALL (~120) FS segments
			% 2. Consolidate ROIs (e.g., right & left, ROIs that belong to a single parent ROI, etc.) 
			% 3. Extract features... 
 			[subject_all_ROI_stats         , ...
 			 N_vox_in_ROI                  , ...
 			 missing_ROIs                  , ...
             qMRI_map_masked_ROIs_cell_arr , ...
             ROIs_in_data                  , ...
 			 ROIs_w_prct_deducted_voxels_above_thresh] = extract_qMRI_features_for_all_ROIs(double(seg_map), double(qMRI_map), ROI_NAMES);
   
    % [RH] Do we need to return qMRI_map_masked_ROIs_cell_arr? I don't think so because we have all the masks savewd in the final structure.
            [subject_all_ROI_stats, ...
             N_vox_in_ROI         , ...
             missing_ROIs         , ...
             ROIs_in_data] = Consolidate_ROIs(subject_all_ROI_stats, qMRI_map_masked_ROIs_cell_arr, N_vox_in_ROI, missing_ROIs, ROIs_in_data);
            
            % combine statistics of all subjects to one structure array
            if any(contains(EXPERIMENT_GROUP, subj_foldername))
			    stats_all_subj.(session_fn).(EXPRg_FN).(subject_fn).(map_fn) = subject_all_ROI_stats;
            elseif any(contains(CONTROL_GROUP, subj_foldername))
                stats_all_subj.(session_fn).(CTRLg_FN).(subject_fn).(map_fn) = subject_all_ROI_stats;
            end
            
			% Save ROI masks and Number oif voxels before and after outlier removal - I already saved it as a feature
			% qMRI_map_masked_ROIs_all_subj{session_idx, subj_idx, map_idx} = qMRI_map_masked_ROIs_cell_arr;
            % N_vox_in_ROI_all_subj.(session_fn).(subject_fn).(map_fn). = N_vox_in_ROI;
	   
	    catch e
			err_count = err_count+1;
            catch_errs{err_count,1} = vol_ID;
            catch_errs{err_count,2} = e.message;
            catch_errs{err_count,3} = e.stack;
			% catch_errs{err_count} = {subj_list{1, subj_idx}, session_idx, e.identifier, e.message,e.stack, session_idx};
	    end
    
    end % end of volunteer loop
    end % end of session loop
    
	% Create combined list of all ROIs, single and combined
    processed_ROIs = transpose(ROI_NAMES);
	processed_ROIs(end+1:end+size(ROIs_2_COMBINE,1)) = ROIs_2_COMBINE(:,3);

    %-----------------------------------------------------
    % Save statistics as '<map_type>_all_results_<date>'
    %-----------------------------------------------------
	    
        save (fullfile([RESULTS_FOLDER filesep sprintf('%s_results_%s_%s.mat',curr_map_type,datetime('now', 'Format', 'ddMMyyyy'),RESULTS_FILENAME)]), ...
        'stats_all_subj'             , ...
        'N_vox_in_ROI'               , ...
        'missing_ROIs'               , ...
		'processed_ROIs'             , ... % need to save only the ROIs that existed in the data, now that there are no blank rows.
        'catch_errs'                 , ...
        'subj_list'                  , ...
        'CHAUVENET_FLAG'             , ...
        'EROSION_OPT'                , ...
        'ROIs_in_data'               , ...
        'ROIs_w_prct_deducted_voxels_above_thresh', '-v7.3')  
        
disp('Feature extraction complete!')

end % end of map type loop

return;
