
% ----------------------------------------------------------------------------
% Helper function
% ----------------------------------------------------------------------------
function [statsSt,outlier_stats,illegal_slice_label_list] = process_MS_n_Controls_ROI_stats_internal(...
	process_dir,ROIs_to_ignore,nSD_for_outlier,erode_nPx,erode_th,outlier_stats,num_of_roi_per_slc,ROIs_2_combine)

cd(process_dir);
subj_list                = dir;
statsSt_idx              = 1;
illegal_slice_label_list = {};
cummulative_roi_idx      = cumsum([0 num_of_roi_per_slc]);
hist_range_T2            = 1:1:1000;     % T2 Histogram range
hist_range_PD            = 0.01:0.01:1;  % PD Histogram range

% Loop of subjects - calculate statistics
for subject_idx = 1:length(subj_list)
	subj_name = subj_list(subject_idx).name;
	if (strcmp(subj_name(1),'.')) || ~strcmp(subj_name(end-3:end),'.mat')
		fprintf('Skipping subject %2.0f %-60s ...\n',statsSt_idx,subj_name);
		continue;
	else
		fprintf('Processing subject %2.0f %-60s ...',statsSt_idx,subj_name);
	end;
	
	% Load subject's EMC results
	res   = load(subj_name);
	res   = res.EMC_results;
	
	% Initialize data structure for collecting statistics
	stats = {};
	for tmp_idx = 1:sum(num_of_roi_per_slc)
	T2_dist(tmp_idx).EMC_T2hist = zeros(1,hist_range_T2(end));
	T2_dist(tmp_idx).EMC_PDhist = zeros(1,hist_range_PD(end));
	T2_dist(tmp_idx).EXP_T2hist = zeros(1,hist_range_T2(end));
	T2_dist(tmp_idx).EXP_PDhist = zeros(1,hist_range_PD(end));
	end;
	for tmp_idx = 1:sum(num_of_roi_per_slc)
	all_roi_vals(tmp_idx).EMC_T2 = [];
	all_roi_vals(tmp_idx).EMC_PD = [];
	all_roi_vals(tmp_idx).EXP_T2 = [];
	all_roi_vals(tmp_idx).EXP_PD = [];
	end;
	
	% Loop over slices
	for slc_idx = 1:length(res)
		% Skip slices with no manual ROI marked inside them
		if (~(isfield(res(slc_idx),'Nroi')) || isempty(res(slc_idx).Nroi) || (res(slc_idx).Nroi == 0))
			continue;
		end;
		slice_label        = res(slc_idx).slice_label;
		Nroi               = res(slc_idx).Nroi;
		T2emc              = res(slc_idx).T2map_SEMC;
		PDemc              = res(slc_idx).PDmap_SEMC;
		T2exp              = res(slc_idx).T2map_SEMC_monoexp;
		PDexp              = res(slc_idx).PDmap_SEMC_monoexp;
		ROIsMSK            = res(slc_idx).ROIsMSK;
		interpF            = res(slc_idx).interpF;

		% Interpolate maps to match msk dimensions
		if (interpF > 1)
			T2emc = imresize(T2emc,interpF);
			PDemc = imresize(PDemc,interpF);
			T2exp = imresize(T2exp,interpF);
			PDexp = imresize(PDexp,interpF);
		end;
		
% 		dbstop in process_MS_n_Controls_ROI_stats_internal.m at 70
		% Convert slice label to slice index. double command will convert to ascii number with A..F=65..70
		if (isempty(slice_label))
			uiwait(warndlg(sprintf('Empty slice label -- PLEASE CHECK')));
			continue;
		end;
		
		slice_label = double(slice_label) - 64;
		if (length(slice_label) > 1)
			illegal_slice_label_list{end+1} = [subj_name '-- ' res(slc_idx).slice_label];
% 			h=warndlg(sprintf('Illegal slice label\n(%s).\[%s]',res(sl_idx).slice_label,subj_name),'Warning');
% 			pause(0.5);
% 			try close(h); end;
			slice_label = slice_label(1);
		end;

% 		fprintf('Slice label = %s, Nrois = %2.2f\n',res(sl_idx).slice_label,Nroi);
		
		% ---------------
		% Loop over ROIs
		% ---------------
		for intra_slice_roi_idx = 1:Nroi
			
			roimsk         = ROIsMSK{intra_slice_roi_idx};
			tmp_avg_PD_val = roimsk.*PDemc;
			tmp_avg_PD_val = mean(tmp_avg_PD_val(tmp_avg_PD_val ~= 0));
			tmp_avg_T2_val = roimsk.*T2emc;
			tmp_avg_T2_val = mean(tmp_avg_T2_val(tmp_avg_T2_val ~= 0));
			
			% skip ROIs indicated by Tim, or ROIs marked outside the PD map head area
			if ((~isempty(ROIs_to_ignore) && (ROIs_to_ignore(statsSt_idx,slice_label,intra_slice_roi_idx)==1)) || ...
			    (tmp_avg_PD_val < 0.1) || isnan(tmp_avg_PD_val))
				stats{slice_label,intra_slice_roi_idx,1} = [];
				stats{slice_label,intra_slice_roi_idx,2} = [];
				stats{slice_label,intra_slice_roi_idx,3} = [];
				stats{slice_label,intra_slice_roi_idx,4} = [];
				fprintf('\nIgnoring Slice label = %s, roi_idx=%1.0f (avg PD=%3.3f, avg T2=%3.3f)',res(slc_idx).slice_label,intra_slice_roi_idx,tmp_avg_PD_val,tmp_avg_T2_val*1e3);
				continue;
			end;
			
			% Erode
			if (erode_nPx> 0)
				tmp_roimsk = erode_2D_mat(roimsk,erode_nPx);
				if (sum(tmp_roimsk) > erode_th*sum(roimsk(:)))
					roimsk = tmp_roimsk;
				end;
			end;
			
			global_roi_idx = cummulative_roi_idx(slice_label) + intra_slice_roi_idx;
			
			% -------------------------
			% T2 EMC
			% -------------------------
			% Collect Mean and SD
			mp=T2emc;  mp=mp.*roimsk; 
			outlier_stats{1}(end+1)=length(mp(:));
			mp=nbe_remove_outliers_for_mean(mp(:),0,1e-3,2,nSD_for_outlier);  % ignore 0; min=1ms; max=2000ms; # STDs
			outlier_stats{2}(end+1)=length(mp(:));
			mp = mp(:);
			mn1=mean(mp);  sd1=std(mp); nPx1=length(mp);
			% Consolidate T2 values from all subjects per slice and ROI
			T2_dist     (global_roi_idx).EMC_T2hist =  T2_dist     (global_roi_idx).EMC_T2hist + hist(mp*1e3,hist_range_T2);
			all_roi_vals(global_roi_idx).EMC_T2     = [all_roi_vals(global_roi_idx).EMC_T2            mp];
			

			% -------------------------
			% PD EMC
			% -------------------------
			mp=PDemc;  mp=mp.*roimsk;
			outlier_stats{3}(end+1)=length(mp(:));
			mp=nbe_remove_outliers_for_mean(mp(:),0,1e-3,2,nSD_for_outlier);
			outlier_stats{4}(end+1)=length(mp(:));
			mp = mp(:);
			mn2=mean(mp);  sd2=std(mp); nPx2=length(mp);
			T2_dist     (global_roi_idx).EMC_PDhist =  T2_dist     (global_roi_idx).EMC_PDhist + hist(mp,hist_range_PD);
			all_roi_vals(global_roi_idx).EMC_PD     = [all_roi_vals(global_roi_idx).EMC_PD            mp];
			
			
			% -------------------------
			% T2 EXP
			% -------------------------
			mp=T2exp;  mp=mp.*roimsk;
			outlier_stats{5}(end+1)=length(mp(:));
			mp=nbe_remove_outliers_for_mean(mp(:),0,1e-3,2,nSD_for_outlier);
			outlier_stats{6}(end+1)=length(mp(:));
			mp = mp(:);
			mn3=mean(mp);  sd3=std(mp); nPx3=length(mp);
			T2_dist     (global_roi_idx).EXP_T2hist =  T2_dist     (global_roi_idx).EXP_T2hist + hist(mp*1e3,hist_range_T2);
			all_roi_vals(global_roi_idx).EXP_T2     = [all_roi_vals(global_roi_idx).EXP_T2            mp];

			
			% -------------------------
			% PD EXP
			% -------------------------
			mp=PDexp;  mp=mp.*roimsk;
			outlier_stats{7}(end+1)=length(mp(:));
			mp=nbe_remove_outliers_for_mean(mp(:),0,1e-3,2,nSD_for_outlier);
			outlier_stats{8}(end+1)=length(mp(:));
			mp = mp(:);
			mn4=mean(mp);  sd4=std(mp); nPx4=length(mp);
			T2_dist     (global_roi_idx).EXP_PDhist =  T2_dist     (global_roi_idx).EXP_PDhist + hist(mp,hist_range_PD);
			all_roi_vals(global_roi_idx).EXP_PD     = [all_roi_vals(global_roi_idx).EXP_PD            mp];
			
			
			stats{slice_label,intra_slice_roi_idx,1} = [mn1*1e3, sd1*1e3, nPx1];
			stats{slice_label,intra_slice_roi_idx,2} = [mn2*1e3, sd2*1e3, nPx2];
			stats{slice_label,intra_slice_roi_idx,3} = [mn3*1e3, sd3*1e3, nPx3];
			stats{slice_label,intra_slice_roi_idx,4} = [mn4*1e3, sd4*1e3, nPx4];
		end;
	end;
	
	% Combine Left-Right ROIs
	for roi_combine_idx = 1:size(ROIs_2_combine,1)
		n_rois_2_combine = ROIs_2_combine{roi_combine_idx,2};
		rois_2_combine   = ROIs_2_combine{roi_combine_idx,1} + ((1:n_rois_2_combine)-1);
		v_EMC_T2 = [];
		v_EMC_PD = [];
		v_EXP_T2 = [];
		v_EXP_PD = [];
		for idx1 = rois_2_combine
			v_EMC_T2 = [v_EMC_T2 transpose(all_roi_vals(idx1).EMC_T2)];
			v_EMC_PD = [v_EMC_PD transpose(all_roi_vals(idx1).EMC_PD)];
			v_EXP_T2 = [v_EXP_T2 transpose(all_roi_vals(idx1).EXP_T2)];
			v_EXP_PD = [v_EXP_PD transpose(all_roi_vals(idx1).EXP_PD)];
		end;
		mn1=mean(v_EMC_T2);  sd1=std(v_EMC_T2);  nPx1=length(v_EMC_T2);
		mn2=mean(v_EMC_PD);  sd2=std(v_EMC_PD);  nPx2=length(v_EMC_PD);
		mn3=mean(v_EXP_T2);  sd3=std(v_EXP_T2);  nPx3=length(v_EXP_T2);
		mn4=mean(v_EXP_PD);  sd4=std(v_EXP_PD);  nPx4=length(v_EXP_PD);

		% First->fourth column contain the four maps
		stats_combined{roi_combine_idx,1} = [mn1*1e3, sd1*1e3, nPx1];
		stats_combined{roi_combine_idx,2} = [mn2*1e3, sd2*1e3, nPx2];
		stats_combined{roi_combine_idx,3} = [mn3*1e3, sd3*1e3, nPx3];
		stats_combined{roi_combine_idx,4} = [mn4*1e3, sd4*1e3, nPx4];
	end;
	
	statsSt(statsSt_idx).subj_name      = subj_name;
	statsSt(statsSt_idx).stats          = stats;
	statsSt(statsSt_idx).stats_combined = stats_combined;
	statsSt(statsSt_idx).T2_dist        = T2_dist;
	statsSt(statsSt_idx).hist_range_T2  = hist_range_T2;
	statsSt(statsSt_idx).hist_range_PD  = hist_range_PD;
	statsSt_idx = statsSt_idx + 1;
	fprintf('   Done\n');
end;


fprintf('\nInformative slice labels:\n');
for idx = 1:length(illegal_slice_label_list)
	fprintf('%s\n',illegal_slice_label_list{idx});
end;

return;
