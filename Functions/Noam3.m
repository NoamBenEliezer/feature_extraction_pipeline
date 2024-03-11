%#ok<*UNRCH>

% Print statistics - export to Excel
function [T2_dist_all_subj] = process_MS_n_Controls_ROI_stats_print(statsSt,map_numbers,num_of_roi_per_slc,ROIs_2_combine,print_for_jim)

cummulative_roi_idx      = cumsum([0 num_of_roi_per_slc]);
hist_range_T2            = statsSt(1).hist_range_T2;   % 1:1:1000;     % T2 Histogram range
hist_range_PD            = statsSt(1).hist_range_PD;   % 0.01:0.01:1;  % PD Histogram range
print_combined_rois      = 1;
print_all_rois           = 0;

% fprintf('\n\n\n');
for tmpIdx = 1:sum(num_of_roi_per_slc)
T2_dist_all_subj(tmpIdx).EMC_T2hist = zeros(1,hist_range_T2(end));
T2_dist_all_subj(tmpIdx).EMC_PDhist = zeros(1,hist_range_PD(end));
T2_dist_all_subj(tmpIdx).EXP_T2hist = zeros(1,hist_range_T2(end));
T2_dist_all_subj(tmpIdx).EXP_PDhist = zeros(1,hist_range_PD(end));
end;

if (print_for_jim), disp('Start here------------'); end;

for subj_idx = 1:length(statsSt)
	stats          = statsSt(subj_idx).stats;
	stats_combined = statsSt(subj_idx).stats_combined;
	subj_nm        = statsSt(subj_idx).subj_name;
	T2_dist_subj   = statsSt(subj_idx).T2_dist;
	
	% Loop over map types
	for map_idx = map_numbers
		
		% Start each line with the subject name and map index
		locs = strfind(subj_nm,'_');
		if (isempty(locs))
				start_idx = 1;
				end_idx   = length(subj_nm)-4;
		else
			if locs(2) == locs(1)+1
				start_idx = locs(2)+1;
				end_idx   = locs(3)-1;
			else
				start_idx = locs(1)+1;
				end_idx   = locs(2)-1;
			end;
		end;

		if (~print_for_jim)
			fprintf('%s\t%1.0f\t',subj_nm(start_idx:end_idx),map_idx);
		end;
		
		if (print_all_rois)
			% Then, loop over slices
			for sl_idx = 1:size(stats,1)

				% and print out the [mean,SD,nPx] stats for each ROI
				for intra_slice_roi_idx = 1:num_of_roi_per_slc(sl_idx)
					cur_stats = stats{sl_idx,intra_slice_roi_idx,map_idx};

					if (print_for_jim)
						if (isempty(cur_stats)) || (isnan(cur_stats(1))) || (cur_stats(1)==0)
							fprintf('\t\t\t\n');
							continue;
						end;
						if (cur_stats(1) ~= 0), fprintf('%3.3f\t'  ,cur_stats(1));  else  fprintf('%3.3f\t'  ,'');  end;
						if (cur_stats(2) ~= 0), fprintf('%3.3f\t'  ,cur_stats(2));  else  fprintf('%3.3f\t'  ,'');  end;
						if (cur_stats(3) ~= 0), fprintf('%3.3f\t\n',cur_stats(3));  else  fprintf('%3.3f\t\n','');  end;
					else
						% print for excel database
						if (isempty(cur_stats)) || (isnan(cur_stats(1))) || (cur_stats(1)==0)
							fprintf('\t\t\t');
						else
							fprintf('%3.3f\t%3.3f\t%3.3f\t',cur_stats(1),cur_stats(2),cur_stats(3));
						end;
					end;

					% Collect T2 and PD distribution Histograms
					tmpIdx = cummulative_roi_idx(sl_idx) + intra_slice_roi_idx;

					T2_dist_all_subj(tmpIdx).EMC_T2hist = T2_dist_all_subj(tmpIdx).EMC_T2hist + T2_dist_subj(tmpIdx).EMC_T2hist;
					T2_dist_all_subj(tmpIdx).EMC_PDhist = T2_dist_all_subj(tmpIdx).EMC_PDhist + T2_dist_subj(tmpIdx).EMC_PDhist;
					T2_dist_all_subj(tmpIdx).EXP_T2hist = T2_dist_all_subj(tmpIdx).EXP_T2hist + T2_dist_subj(tmpIdx).EXP_T2hist;
					T2_dist_all_subj(tmpIdx).EXP_PDhist = T2_dist_all_subj(tmpIdx).EXP_PDhist + T2_dist_subj(tmpIdx).EXP_PDhist;
				end;
			end;
		end;
		
		if (print_combined_rois)
			% print out [mean,SD,nPx] stats for each combined ROI			
			for roi_combine_idx = 1:size(ROIs_2_combine,1)
				cur_stats = stats_combined{roi_combine_idx,map_idx};
				
				if (print_for_jim)
					if (isempty(cur_stats)) || (isnan(cur_stats(1))) || (cur_stats(1)==0)
						fprintf('\t\t\t\n');
						continue;
					else
						if (cur_stats(1) ~= 0), fprintf('%3.3f\t'  ,cur_stats(1));  else  fprintf('%3.3f\t'  ,'');  end;
						if (cur_stats(2) ~= 0), fprintf('%3.3f\t'  ,cur_stats(2));  else  fprintf('%3.3f\t'  ,'');  end;
						if (cur_stats(3) ~= 0), fprintf('%3.3f\t\n',cur_stats(3));  else  fprintf('%3.3f\t\n','');  end;
					end;

				else
					% print for excel database
					if (isempty(cur_stats)) || (isnan(cur_stats(1))) || (cur_stats(1)==0)
						fprintf('\t\t\t');
					else
						if (cur_stats(1) ~= 0), fprintf('%3.3f\t',cur_stats(1));  else  fprintf('%3.3f\t'  ,'');  end;
						if (cur_stats(2) ~= 0), fprintf('%3.3f\t',cur_stats(2));  else  fprintf('%3.3f\t'  ,'');  end;
						if (cur_stats(3) ~= 0), fprintf('%3.3f\t',cur_stats(3));  else  fprintf('%3.3f\t\n','');  end;
					end;
				end;
			end;
		end;

		
		% finished current map values - skip to next line
		if (~print_for_jim)
		fprintf('\n');
% 		else
% 		fprintf('\t%3.0f\t%s\n',subj_idx,subj_nm(start_idx:end_idx));
		end;
	end;
end;
fprintf('\n');


% slc_for_print = [4,5];
% roi_for_print = [2,3,4,5,6;
%                  3,4,5,6,7];
% 
% ax = [0 200];
% figure;
% % for tmpIdx1 = 1:length(num_of_roi_per_slc)   plot all slices
% % for tmpIdx2 = 1:num_of_roi_per_slc(tmpIdx1)  and  all rois
% for tmpIdx1 = 1:length(slc_for_print)
% for tmpIdx2 = roi_for_print(tmpIdx1,:)
% tmpIdx = cummulative_roi_idx(slc_for_print(tmpIdx1)) + tmpIdx2;
% subplot(221); plot(hist_range_T2,T2_dist_all_subj(tmpIdx).EMC_T2hist,'.-'); title('EMC T2'); a=axis; axis([ax(1) ax(2) a(3) a(4)]);
% subplot(222); plot(hist_range_PD,T2_dist_all_subj(tmpIdx).EMC_PDhist,'.-'); title('EMC PD');
% subplot(223); plot(hist_range_T2,T2_dist_all_subj(tmpIdx).EXP_T2hist,'.-'); title('EXP T2'); a=axis; axis([ax(1) ax(2) a(3) a(4)]);
% subplot(224); plot(hist_range_PD,T2_dist_all_subj(tmpIdx).EXP_PDhist,'.-');
% title(sprintf('EXP PD (slice %1.0f;  ROI %1.0f)',slc_for_print(tmpIdx1),tmpIdx2));
% uiwait(msgbox('Press OK to continue to next ROI'));
% end;
% end;

return;
