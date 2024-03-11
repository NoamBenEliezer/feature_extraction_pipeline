function [top_ROIs_for_processing ,...
          top_ROI_labels          ,...
          qMRI_map_3D_top_ROIs    ,...
          Seg_ROI_3D_top_ROIs     ,...
          top_ROIs_FS_idx] = Top_ROIs_Mindfulness(FS_ROIs_for_processing_all, ROI_labels_all , qMRI_map_3D_all, Seg_ROI_3D_all, ROI_names)

% Top 15 ROIs from Brain Atlas:
% Top_15_list={'Cerebral-White-Matter_all','Caudate_all', 'Putamen_all','Pallidum_all','CC_all', 'Thalamus-Proper*_all', 'VentralDC_all',...
% 'Accumbens-area_all', 'Amygdala_all', 'Hippocampus_all', 'Brain-Stem', 'Cerebellum-White-Matter_all', 'Cerebellum-Cortex_all', ...
% 'ctx_insula_all', 'ctx_all'};

% This should be edited in the main qMRI analysis pipeline and added as an input for the function
top_ROIs_for_processing = ROI_names;

% frontal_idx = find(contains(Slice_labels_all,'frontal')); %find indices of ROIs containing frontal lobe
% frontal     = ROI_labels_all(frontal_idx); %find labels of ROIs containing frontal lobe

top_ROIs_chronological_idx = [];
excluded_ROIs   = [];
for i = 1:length(top_ROIs_for_processing)
    if find(ROI_labels_all==top_ROIs_for_processing{i})
       top_ROIs_chronological_idx = [top_ROIs_chronological_idx find(ROI_labels_all==top_ROIs_for_processing{i})]; % create list of chronological indices of wanted ROIs in the order of ROI_labels.
    else 
       excluded_ROIs = [excluded_ROIs i]; % chronological indices of top_ROIs_for_processing
    end
end

top_ROIs_FS_idx = FS_ROIs_for_processing_all(top_ROIs_chronological_idx,1);
% do we need this if we alredy have the for loop?
%      ROIs_loc=[];
%  1   ROIs_loc=[ROIs_loc find(ROI_labels_all=='Cerebral-White-Matter_all')];
%  2   ROIs_loc=[ROIs_loc find(Slice_labels_all=='Caudate_all')];
%  3   ROIs_loc=[ROIs_loc find(Slice_labels_all=='Putamen_all')];
%  4   ROIs_loc=[ROIs_loc find(Slice_labels_all=='Pallidum_all')];
%  5   ROIs_loc=[ROIs_loc find(Slice_labels_all=='CC_all')];
%  6   ROIs_loc=[ROIs_loc find(Slice_labels_all=='Thalamus-Proper*_all')];
%  7   ROIs_loc=[ROIs_loc find(Slice_labels_all=='VentralDC_all')];
%  8   ROIs_loc=[ROIs_loc find(Slice_labels_all=='Accumbens-area_all')];
%  9   ROIs_loc=[ROIs_loc find(Slice_labels_all=='Amygdala_all')];
%  10  ROIs_loc=[ROIs_loc find(Slice_labels_all=='Hippocampus_all')];
%  11  ROIs_loc=[ROIs_loc find(Slice_labels_all=='Brain-Stem')];
%  12  ROIs_loc=[ROIs_loc find(Slice_labels_all=='Cerebellum-White-Matter_all')];
%  13  ROIs_loc=[ROIs_loc find(Slice_labels_all=='Cerebellum-Cortex_all')];
%  14  ROIs_loc=[ROIs_loc find(Slice_labels_all=='ctx_insula_all')];
%  15  ROIs_loc=[ROIs_loc find(Slice_labels_all=='ctx_all')]; 
    
top_ROIs_for_processing = FS_ROIs_for_processing_all(top_ROIs_chronological_idx, 1:size(FS_ROIs_for_processing_all,2));
top_ROI_labels          = ROI_labels_all(top_ROIs_chronological_idx); 
qMRI_map_3D_top_ROIs    = qMRI_map_3D_all(top_ROIs_chronological_idx);
Seg_ROI_3D_top_ROIs     = Seg_ROI_3D_all(top_ROIs_chronological_idx);

% if length(excluded_ROIs)==1
%     for j=17:-1:excluded_ROIs+1
%         ROI_list_15(j, 1:4)=ROI_list_15(j-1, 1:4);
%     end
%     ROI_list_15(excluded_ROIs,1:4)=[0 0 0 0];
% elseif length(excluded_ROIs)>1
%     disp ('SHIT!')
% end
end



