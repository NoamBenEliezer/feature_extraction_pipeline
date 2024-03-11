%#ok<*UNRCH>

% Process manual ROI selections done by Tim S on Control and MS groups.
% Results are sorted as two structures (one per group) containing a list of subject names and stats per subject.
% Stats   are sorted as an n-dimensional cell of:
%         {slice_label,       ,         }		label of slice [A..F] = [1..6]
%         {           ,roi_idx,         }		each slice [A..F] has a predifined list of ROIs indexed in increasing order
%         {           ,       , map_type}       each ROI stats are calclated for 4 map types: T2 & PD, EMC and EXP.
%         The content of each cell is a 2-element vector containing the mean and standard-deviation of the ROI map values


% Unavoidable MS lesions in the ROIs
% 
% Weber ? dorsomedial thalamus focal T2b (B5 and B6) I avoided big lesion in splenium C2
% 
% Please reject HOSEIN - the first data set - I only drew slice B before deciding too confluent disease to include for our current study.
% Reyna-Dolin is missing a slice A (& those 6 ROIs)
% A few have significant partial volume effects in the slice D ROI1 (body corpus callosum)
% Mercado-Nedd has figure-worthy periventricular lesions - slice D
% Patricello has lesions in slice A ROIs # 2 & 4 (maybe reject, but worth looking at numbers for fun?)

function process_MS_n_Controls_TimS_ROI_stats()

clcl;
set_globals;
RootDir             = nbePath('/Users/noambe/Dropbox/E/01 Post/06 Projects/T2/904 MS/EMC_res_mat_from_Tim_Controls_and_MS/');
process_dir_Ctl     = nbePath([RootDir 'EMC_Results_Controls_2015_05_10/']);
process_dir_MS      = nbePath([RootDir 'EMC_Results_MS_2015_11_18/']);

results_fn          = [RootDir 'Processed_MS_n_Controls_ResultsB.mat'];
overwrite_flag      = 0;
nMS_patients        = 30;
nControls           = 39;
nSD_for_outlier     = 2;
% map_numbers       = [3];  % [1,2,3,4] = [T2EMC, PDEMC, T2EXP, PDEXP]
erode_nPx           = 1;
erode_th            = 0.5;  % don't erode if erosion loses more than 40% of the ROI number of pixels
num_of_rois_per_slc = [6 8 2 6 7 9];
print_for_Jim       = 1;
% Slice name       A B C D E F

outlier_stats = {[],[],[],[],[],[],[],[]};

roi_names = {...
'Left optic radiations',...                                  % 1
'Right optic radiations',...                                 % 2
'Left temporal stem',...                                     % 3
'Right temporal stem',...                                    % 4
'Left Globus Pallidus',...                                   % 5
'Right Globus Pallidus',...                                  % 6
'Left caudate nucleus',...                                   % 7
'Right caudate nucleus',...                                  % 8
'Left putamen',...                                           % 9
'Right putamen',...                                          % 10
'Left thalamus',...                                          % 11
'Right thalamus',...                                         % 12
'Left PLIC Posterior limb internal capsule (WM)',...         % 13 
'Right PLIC Posterior limb internal capsule (WM)',...        % 14
'Genu corpus callosum',...                                   % 15
'Splenium corpus callosum',...                               % 16
'Body corpus callosum',...                                   % 17
'Periventricular WM (LFL      ) or LESION (for MS)',...      % 18
'Periventricular WM (RFL      ) or LESION (for MS)',...      % 19
'Periventricular WM (R-body LV) or LESION (for MS)',...      % 20
'Left  Periventricular WM (LPL)',...                         % 21
'Right Periventricular WM (RPL)',...                         % 22
'Left centrum semiovale',...                                 % 23
'Right centrum semiovale',...                                % 24
'Subcortical WM (LFL) or LESION',...                         % 25
'Subcortical WM (RFL) or LESION',...                         % 26
'Subcortical WM (RMFG) or LESION',...                        % 27
'Left Subcortical WM (LPL)',...                              % 28
'Right Subcortical WM (RPL)',...                             % 29
'Left hand knob cortex',...                                  % 30
'Right hand knob cortex',...                                 % 31
'Left hand knob Juxtacortical WM' ,...                       % 32
'Right hand knob Juxtacortical WM',...                       % 33
'Juxtacortical WM (LFL) or LESION',...                       % 34
'Juxtacortical WM (RFL) or LESION',...                       % 35
'Juxtacortical WM (RFO) or LESION',...                       % 36
'Left  Juxtacortical WM (LPL)',...                           % 37
'Right Juxtacortical WM (RPL)'};                             % 38 and last
ROIs_2_combine = {1 ,2;...
                  3 ,2;...
                  5 ,2;...
                  7 ,2;...
                  9 ,2;...
                  11,2;...
                  13,2;...
				  15,1;...
				  16,1;...
				  17,1;...
                  18,3;...
                  21,2;...
                  23,2;...
                  25,3;...
                  28,2;...
                  30,2;...
                  32,2;...
                  34,3;...
                  37,2};

idx = 1;
strct_roi_combine(idx).roi_indcs = [1,3,5];
strct_roi_combine(idx).combined_name = 'ctx_all'; idx=idx+1;
strct_roi_combine(idx).roi_indcs = [14,33,52];
strct_roi_combine(idx).combined_name = 'ctx_all'; idx=idx+1;


if (overwrite_flag)
	delete(results_fn);
end;

%% ---------------------------------------------------------------------------
% Controls
% ----------------------------------------------------------------------------
if (exist(results_fn,'file'))
	load(results_fn);
else
	ROIs_to_ignore = zeros(nControls,6,9);

	% Baldassarri (#2 );  B7, B8 (Left PLIC, Right PLIC)
	ROIs_to_ignore(2 ,1,1:4) = 1;     % VALUEs REMOVED DUE TO HIGH SD
	ROIs_to_ignore(2 ,2,1:8) = 1;
	% Masterson   (#19);  F3
	ROIs_to_ignore(19,6,3  ) = 1;
	% Raya        (#28);  F3
	ROIs_to_ignore(28,6,3  ) = 1;

	% Completely exclude all ROIs on outlier subjects
	% 36 Chung
	for subj_idx = 36
		for loc_sl_idx = 1:length(num_of_rois_per_slc)
			ROIs_to_ignore(subj_idx ,loc_sl_idx,1:num_of_rois_per_slc(loc_sl_idx)) = 1;
		end;
	end;
	
	declare_stage('Processing Controls');
	[Controls_statsSt,outlier_stats_Ctl,illegal_slice_label_list_Ctl] = process_MS_n_Controls_ROI_stats_internal(...
		process_dir_Ctl,ROIs_to_ignore,nSD_for_outlier,erode_nPx,erode_th,outlier_stats,num_of_rois_per_slc,ROIs_2_combine);
end;

declare_stage('Printing Controls');
tmp=inputdlg('Map number to process [1,2,3,4] = [T2EMC, PDEMC, T2EXP, PDEXP]');
map_numbers = str2double(tmp{1});
T2_dist_all_subj_Ctl = process_MS_n_Controls_ROI_stats_print(Controls_statsSt,map_numbers,num_of_rois_per_slc,ROIs_2_combine,print_for_Jim);


%% ---------------------------------------------------------------------------
% MS
% ----------------------------------------------------------------------------
fprintf('\n\n\nMS:\n');
if (exist(results_fn,'file'))
	load(results_fn);
else
	ROIs_to_ignore = zeros(nMS_patients,6,9);
	outlier_stats  = {[],[],[],[],[],[],[],[]};

	% 101  A1, A2, A3 A4
	ROIs_to_ignore(1 ,1,1:4) = 1;
	ROIs_to_ignore(1 ,5,1:2) = 1;     % ASK TIM TO RE-SEGMENT. VALUE REMOVED DUE TO HIGH SD

	% 103  A1
	ROIs_to_ignore(3 ,1,1  ) = 1;

	% 106  A3
	ROIs_to_ignore(6 ,1,3  ) = 1;

	% 107  ? dorsomedial thalamus focal T2b (B5 and B6) I avoided big lesion in splenium C2
	% ROIs_to_ignore(7 , , ) = 1;

	% 108  - no slice A - they started scan too high
	ROIs_to_ignore(8 ,1,1:6) = 1;

	% 109  A2 A4 B7 E1 E2, D5 - lesion in PVWM in periatal lobe
	ROIs_to_ignore(9 ,1,2  ) = 1;
	ROIs_to_ignore(9 ,1,4  ) = 1;
	ROIs_to_ignore(9 ,2,7  ) = 1;
	ROIs_to_ignore(9 ,5,1:2) = 1;
	ROIs_to_ignore(9 ,4,5  ) = 1;

	% 111  A1 A4 C2 E1 E2
	ROIs_to_ignore(11,1,1  ) = 1;
	ROIs_to_ignore(11,1,4  ) = 1;
	ROIs_to_ignore(11,3,2  ) = 1;
	ROIs_to_ignore(11,5,1:2) = 1;

	% 112  E1,2 (Left centrum semiovale, Right centrum semiovale)
	ROIs_to_ignore(12,5,1:2) = 1;     % ASK TIM TO RE-SEGMENT. VALUE REMOVED DUE TO HIGH SD

	% 118     -- A2, D5,6 - lesion in PVWM in periatal lobe
	ROIs_to_ignore(18,1,2  ) = 1;
	ROIs_to_ignore(18,4,5:6) = 1;

	% 121  D5,6 - lesion in PVWM in periatal lobe	
	ROIs_to_ignore(21,4,5:6) = 1;
	
	% 124    -- F - IGNORE 5&6
	ROIs_to_ignore(24,6,5:6) = 1;

	% 126     -- A - R1 IS IN LESION, D5,6 - lesion in PVWM in periatal lobe	
	ROIs_to_ignore(26,1,1  ) = 1;
	ROIs_to_ignore(26,4,5:6) = 1;

	% 127   -- D - DELETE 3
	ROIs_to_ignore(27,4,3  ) = 1;

	% Completely exclude all ROIs on non RRMS subjects
	% 105 ; 110 ; 128 
	for subj_idx   = [5,10,28]
		for loc_sl_idx = 1:length(num_of_rois_per_slc)
			ROIs_to_ignore(subj_idx ,loc_sl_idx,1:num_of_rois_per_slc(loc_sl_idx)) = 1;
		end;
	end;

	[MS_statsSt,outlier_stats_MS,illegal_slice_label_list_MS] = process_MS_n_Controls_ROI_stats_internal(...
		process_dir_MS,ROIs_to_ignore,nSD_for_outlier,erode_nPx,erode_th,outlier_stats,num_of_rois_per_slc,ROIs_2_combine);
end;

tmp=inputdlg('Map number to process [1,2,3,4] = [T2EMC, PDEMC, T2EXP, PDEXP]');
map_numbers = str2double(tmp{1});

T2_dist_all_subj_MS = process_MS_n_Controls_ROI_stats_print(MS_statsSt,map_numbers,num_of_rois_per_slc,ROIs_2_combine,print_for_Jim);

save(results_fn);

%% ---------------------------------------------------------------------------
% Controls vs. MS
% Plot histograms of Controls vs MS using EMC & EXP, T2 and PD
% ----------------------------------------------------------------------------
% save('/Users/noambe/Dropbox/E/01 Post/06 Projects/T2/904 MS/test_delete.mat');
% smooth_hist_flag = 3;
% process_MS_n_Controls_ROI_stats_print_Hist(Controls_statsSt    , MS_statsSt,...
%                                            T2_dist_all_subj_Ctl, T2_dist_all_subj_MS,...
% 										   num_of_rois_per_slc ,1,smooth_hist_flag,roi_names);
% process_MS_n_Controls_ROI_stats_print_ksTest(Controls_statsSt    , MS_statsSt,...
%                                              T2_dist_all_subj_Ctl, T2_dist_all_subj_MS,...
% 										     num_of_rois_per_slc ,1,smooth_hist_flag);

return;


% % ----------------------------------------------------------------------------
% % ----------------------------------------------------------------------------
% % Helper functions
% % ----------------------------------------------------------------------------
% % ----------------------------------------------------------------------------
% function [statsSt,outlier_stats,illegal_slice_label_list] = process_MS_n_Controls_ROI_stats_internal(...
% 	process_dir,ROIs_to_ignore,nSD_for_outlier,erode_nPx,erode_th,outlier_stats)
% 
% cd(process_dir);
% subj_list   = dir;
% statsSt_idx = 1;
% illegal_slice_label_list = {};
% 
% % Loop of subjects - calculate statistics
% for subj_idx = 1:length(subj_list)
% 	subj_name = subj_list(subj_idx).name;
% 	if (strcmp(subj_name(1),'.')) || ~strcmp(subj_name(end-3:end),'.mat')
% 		fprintf('Skipping subject %2.0f %-60s ...\n',statsSt_idx,subj_name);
% 		continue;
% 	else
% 		fprintf('Processing subject %2.0f %-60s ...',statsSt_idx,subj_name);
% 	end;
% 	
% 	res   = load(subj_name);
% 	res   = res.EMC_results;
% 	stats = {};
% 
% 	% Loop over slices
% 	for sl_idx = 1:length(res)
% 		if (~(isfield(res(sl_idx),'Nroi')) || isempty(res(sl_idx).Nroi) || (res(sl_idx).Nroi == 0))
% 			continue;
% 		end;
% 		Nroi               = res(sl_idx).Nroi;
% 		slice_label        = res(sl_idx).slice_label;
% 		T2emc              = res(sl_idx).T2map_SEMC;
% 		PDemc              = res(sl_idx).PDmap_SEMC;
% 		T2exp              = res(sl_idx).T2map_SEMC_monoexp;
% 		PDexp              = res(sl_idx).PDmap_SEMC_monoexp;
% 		ROIsMSK            = res(sl_idx).ROIsMSK;
% 		interpF            = res(sl_idx).interpF;
% 
% 		% Interpolate maps to match msk dimensions
% 		if (interpF > 1)
% 			T2emc = imresize(T2emc,interpF);
% 			PDemc = imresize(PDemc,interpF);
% 			T2exp = imresize(T2exp,interpF);
% 			PDexp = imresize(PDexp,interpF);
% 		end;
% 		
% 		% Convert slice label to slice index. double command will convert to ascii number with A..F=65..70
% 		if (isempty(slice_label))
% 			uiwait(warndlg(sprintf('Empty slice label -- PLEASE CHECK')));
% 			continue;
% 		end;
% 		
% 		slice_label = double(slice_label) - 64;
% 		if (length(slice_label) > 1)
% 			illegal_slice_label_list{end+1} = [subj_name '-- ' res(sl_idx).slice_label];
% % 			h=warndlg(sprintf('Illegal slice label\n(%s).\[%s]',res(sl_idx).slice_label,subj_name),'Warning');
% % 			pause(0.5);
% % 			try close(h); end;
% 			slice_label = slice_label(1);
% 		end;
% 
% % 		fprintf('Slice label = %s, Nrois = %2.2f\n',res(sl_idx).slice_label,Nroi);
% 		
% 		% Loop over ROIs
% 		for roi_idx = 1:Nroi
% 			
% 			roimsk     = ROIsMSK{roi_idx};
% 			avg_PD_val = roimsk.*PDemc;
% 			avg_PD_val = mean(avg_PD_val(avg_PD_val ~= 0));
% 			avg_T2_val = roimsk.*emc;
% 			avg_T2_val = mean(avg_T2_val(avg_T2_val ~= 0));
% 			
% 			% skip ROIs indicated by Tim, or ROIs marked outside the PD map head area
% 			if (~isempty(ROIs_to_ignore) && (ROIs_to_ignore(statsSt_idx,slice_label,roi_idx)==1)) || ...
% 			   (avg_PD_val < 0.1)
% 				stats{slice_label,roi_idx,1} = [];
% 				stats{slice_label,roi_idx,2} = [];
% 				stats{slice_label,roi_idx,3} = [];
% 				stats{slice_label,roi_idx,4} = [];
% 				fprintf('\nIgnoring Slice label = %s, roi_idx=%1.0f (avg PD=%3.3f, avg T2=%3.3f)',res(sl_idx).slice_label,roi_idx,avg_PD_val,avg_T2_val*1e3);
% 				continue;
% 			end;
% 			
% % 			dbstop in process_MS_n_Controls_TimS_ROI_stats at 151
% 			if (erode_nPx> 0)
% 				tmp_roimsk = erode_2D_mat(roimsk,erode_nPx);
% 				if (sum(tmp_roimsk) > erode_th*sum(roimsk(:)))
% 					roimsk = tmp_roimsk;
% 				end;
% 			end;
% 			
% 			mp=T2emc;  mp=mp.*roimsk; 
% 			outlier_stats{1}(end+1)=length(mp);
% 			mp=nbe_remove_outliers_for_mean(mp(:),0,1e-3,2,nSD_for_outlier);
% 			outlier_stats{2}(end+1)=length(mp);
% 			mn1=mean(mp);  sd1=std(mp); nPx1=length(mp); % ignore 0; min=1ms; max=2000ms; 5 STDs
% 			
% 			mp=PDemc;  mp=mp.*roimsk;
% 			outlier_stats{3}(end+1)=length(mp);
% 			mp=nbe_remove_outliers_for_mean(mp(:),0,1e-3,2,nSD_for_outlier);
% 			outlier_stats{4}(end+1)=length(mp);
% 			mn2=mean(mp);  sd2=std(mp); nPx2=length(mp);  % ignore 0; min=1ms; max=2000ms; 5 STDs
% 			
% 			mp=T2exp;  mp=mp.*roimsk;
% 			outlier_stats{5}(end+1)=length(mp);
% 			mp=nbe_remove_outliers_for_mean(mp(:),0,1e-3,2,nSD_for_outlier);
% 			outlier_stats{6}(end+1)=length(mp);
% 			mn3=mean(mp);  sd3=std(mp); nPx3=length(mp);  % ignore 0; min=1ms; max=2000ms; 5 STDs
% 			
% 			mp=PDexp;  mp=mp.*roimsk;
% 			outlier_stats{7}(end+1)=length(mp);
% 			mp=nbe_remove_outliers_for_mean(mp(:),0,1e-3,2,nSD_for_outlier);
% 			outlier_stats{8}(end+1)=length(mp);
% 			mn4=mean(mp);  sd4=std(mp); nPx4=length(mp);  % ignore 0; min=1ms; max=2000ms; 5 STDs
% 			
% 			stats{slice_label,roi_idx,1} = [mn1*1e3, sd1*1e3, nPx1];
% 			stats{slice_label,roi_idx,2} = [mn2*1e3, sd2*1e3, nPx2];
% 			stats{slice_label,roi_idx,3} = [mn3*1e3, sd3*1e3, nPx3];
% 			stats{slice_label,roi_idx,4} = [mn4*1e3, sd4*1e3, nPx4];
% 		end;
% 	end;
% 	statsSt(statsSt_idx).subj_name = subj_name;
% 	statsSt(statsSt_idx).stats     = stats;
% 	statsSt_idx = statsSt_idx + 1;
% 	fprintf('   Done\n');
% end;
% 
% 
% fprintf('\nInformative slice labels:\n');
% for idx = 1:length(illegal_slice_label_list)
% 	fprintf('%s\n',illegal_slice_label_list{idx});
% end;
% 
% return;


% % Print statistics - export to Excel
% function process_MS_n_Controls_ROI_stats_print(statsSt,map_numbers,number_of_rois,print_for_Jim)
% 
% fprintf('\n\n\n');
% for subj_idx = 1:length(statsSt)
% 	stats   = statsSt(subj_idx).stats;
% 	subj_nm = statsSt(subj_idx).subj_name;
% 
% 	% Loop over map types
% 	for map_idx = map_numbers
% 		
% 		% Start each line with the subject name and map index
% 		locs = strfind(subj_nm,'_');
% 		if locs(2) == locs(1)+1
% 			start_idx = locs(2)+1;
% 			end_idx   = locs(3)-1;
% 		else
% 			start_idx = locs(1)+1;
% 			end_idx   = locs(2)-1;
% 		end;
% 		fprintf('%s\t%1.0f\t',subj_nm(start_idx:end_idx),map_idx);
% 
% 		% Then, loop over slices
% 		for sl_idx = 1:size(stats,1)
% 
% 			% and print out the [mean,SD,nPx] stats for each ROI
% 			for roi_idx = 1:number_of_rois(sl_idx)
% 				cur_stats = stats{sl_idx,roi_idx,map_idx};
% 				if (isempty(cur_stats)) || (isnan(cur_stats(1))) || (cur_stats(1)==0)
% 					fprintf('\t\t\t');
% 				else
% 					fprintf('%3.3f\t%3.3f\t%3.3f\t',cur_stats(1),cur_stats(2),cur_stats(3));
% 				end;
% 			end;
% 		end;
% 		% finished current map values - skip to next line
% 		fprintf('\n');
% 	end;
% end;
% fprintf('\n');
% 
% return;

