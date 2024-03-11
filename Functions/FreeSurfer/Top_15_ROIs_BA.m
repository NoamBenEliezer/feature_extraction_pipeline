function [ROI_list_15, Slice_labels_15 , T2_map_3D_15, Seg_ROI_3D_15]...
    = Top_15_ROIs_BA (ROI_list_all, Slice_labels_all , T2_map_3D_all, Seg_ROI_3D_all)
%Top 15 ROIs from BA
%Top_15_list={'Cerebral-White-Matter_all','Caudate_all', 'Putamen_all','Pallidum_all','CC_all', 'Thalamus-Proper*_all', 'VentralDC_all',...
%     'Accumbens-area_all', 'Amygdala_all', 'Hippocampus_all', 'Brain-Stem', 'Cerebellum-White-Matter_all', 'Cerebellum-Cortex_all', ...
%     'ctx_insula_all', 'ctx_all'};

Top_15_list={'Cerebral-White-Matter_all','CC_Anterior', 'CC_Posterior', 'Thalamus-Proper*_all', 'Hippocampus_all',...
    'Amygdala_all'};

% frontal_idx = find(contains(Slice_labels_all,'frontal')); %find indices
% of ROIs containing frontal lobe
% frontal = Slice_labels_all(frontal_idx); %find labels of ROIs containing
% frontal lobe

ROIs_loc=[];
excluded_ROIs=[];
for i= 1:length(Top_15_list)
    if find(Slice_labels_all==Top_15_list{i})
       ROIs_loc=[ROIs_loc find(Slice_labels_all==Top_15_list{i})]; %create list of indices of wanted ROIs.
    else 
%         ROIs_loc=[ROIs_loc 0];
        excluded_ROIs=[excluded_ROIs i];
    end
end
    
%    ROIs_loc=[];
%  1   ROIs_loc=[ROIs_loc find(Slice_labels_all=='Cerebral-White-Matter_all')];
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
    
ROI_list_15     = ROI_list_all (ROIs_loc , 2:5);
Slice_labels_15 = Slice_labels_all (ROIs_loc); 
T2_map_3D_15    = T2_map_3D_all (ROIs_loc);
Seg_ROI_3D_15   = Seg_ROI_3D_all (ROIs_loc);
if length(excluded_ROIs)==1
    for j=15:-1:excluded_ROIs+1
        ROI_list_15(j, 1:4)=ROI_list_15(j-1, 1:4);
    end
    ROI_list_15(excluded_ROIs,1:4)=[0 0 0 0];
elseif length(excluded_ROIs)>1
    disp ('SHIT!')
end
end



