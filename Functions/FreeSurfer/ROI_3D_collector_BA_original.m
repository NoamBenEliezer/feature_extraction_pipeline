    function [ROI_list, Slice_labels , T2_map_3D, Seg_ROI_3D,...
    ROI_list_all, Slice_labels_all , T2_map_3D_all,Seg_ROI_3D_all]...
    = ROI_3D_collector_BA (Seg_vol, qT2_Arr, ROI_adj_flag, chauvenet_criterion)
%Seg_vol = 3D double with ROIs according to their location.
%qT2_Arr = 3D double with qMRI values for each voxel.
%ROI_adj_flag = erosion flag
%chauvenet_criterion = remove voxels where value > mean ± variable*SD

[Label_num, Label_name] = Label_reader;

% Slice_loc=80; % out of 256
N_scans=size(qT2_Arr,4); %=1 because qT2_Arr has 3 dims.
Scan_session=1;

% T2_map_3D=zeros(size(qT2_Arr(:,:,:,curr_scan)));
if ROI_adj_flag>1
    se = strel('line',ROI_adj_flag,90); %A structuring element is a matrix that
	%identifies the pixel in the image being processed and defines the neighborhood
	%used in the processing of each pixel. You typically choose a structuring element
	%the same size and shape as the objects you want to process in the input image.
end
ROI_counter=0;

% [Seg_vol, qT2_Arr]=Maps_Resize(Seg_vol, qT2_Arr);


ROI_list=[]; %contains the unique values of ROIs in Seg_vol
% parfor i=1:14175
for FS_idx=1:14175
    if (Seg_vol(Seg_vol==FS_idx))
        %       ROI_counter=ROI_counter+1;
        ROI_list=[ROI_list FS_idx];
    end
end
ROI_list=ROI_list';
ROI_counter=length(ROI_list);

% tic
for FS_idx=1:ROI_counter
    
    Label_num_loc=find(ROI_list(FS_idx)==Label_num);
    %         Label_ROI=convertCharsToStrings(Label_name{Label_num_loc});
    Label_ROI=string(Label_name{Label_num_loc});
    
    Slice_labels(FS_idx)=Label_ROI;
    
    T2_map_3D{FS_idx}=zeros(size(qT2_Arr(:,:,:,Scan_session))); 
    Seg_ROI_3D{FS_idx}= T2_map_3D{FS_idx};
    
    T2_map_3D{FS_idx}(Seg_vol==ROI_list(FS_idx))=qT2_Arr(Seg_vol==ROI_list(FS_idx)); %each cell contains a 3D array with qMRI values in the location of the ROI
    Seg_ROI_3D{FS_idx}(Seg_vol==ROI_list(FS_idx))=Seg_vol(Seg_vol==ROI_list(FS_idx)); %each cell contains a 3D array with Label_num_loc in the location of the ROI
    
    
    if ~sum(sum(sum(isnan(T2_map_3D{FS_idx}))))==0
    tmp_T2_map=T2_map_3D{FS_idx};
    tmp_Nan_map=isnan(T2_map_3D{FS_idx});
    tmp_T2_map(tmp_Nan_map==1)=0;
    T2_map_3D{FS_idx}=tmp_T2_map;
    clear tmp_Nan_map tmp_T2_map
    end
    
    % if erosion or chauvenet
    if ROI_adj_flag>1 
        T2_map_3D{FS_idx}= imerode(T2_map_3D{FS_idx},se);
        Seg_ROI_3D{FS_idx}=imerode(Seg_ROI_3D{FS_idx},se);
    end
    
    if (chauvenet_criterion) 
        T2mean = mean(T2_map_3D{FS_idx}(T2_map_3D{FS_idx}~=0));
        T2SD   =  std(T2_map_3D{FS_idx}(T2_map_3D{FS_idx}~=0));
        T2_tmp=T2_map_3D{FS_idx};
        T2_tmp(T2_tmp < (T2mean - chauvenet_criterion*T2SD)) = 0;
        T2_tmp(T2_tmp > (T2mean + chauvenet_criterion*T2SD)) = 0;
        T2_mask = logical(T2_tmp);
        T2_map_3D{FS_idx}=T2_map_3D{FS_idx}.*T2_mask;
        Seg_ROI_3D{FS_idx}=Seg_ROI_3D{FS_idx}.*T2_mask;
    end
    
%   ROI_list(FS_idx,2)= length(Seg_vol(Seg_vol==ROI_list(FS_idx)));
    ROI_list(FS_idx,2)= length(T2_map_3D{FS_idx}(T2_map_3D{FS_idx}~=0)); %add column with no. of voxels in ROI.
    
    %         T2_ROI=qT2_Arr(Seg_vol==ROI_list(FS_idx));
    T2_ROI=T2_map_3D{FS_idx}(T2_map_3D{FS_idx}~=0); %all T2 values in ROI.
    
    N_scans_mat_loc= 2 + (Scan_session*2-1);
    
    ROI_list(FS_idx,N_scans_mat_loc:(N_scans_mat_loc+2))=[mean(T2_ROI) std(T2_ROI) 100*std(T2_ROI)/mean(T2_ROI)]; % mean, SD, CV
    
    
end
% toc


% [ROI_list_all, Slice_labels_all] = ROIs_gather_BA(ROI_list, Slice_labels);

[ROI_list_all, Slice_labels_all , T2_map_3D_all, Seg_ROI_3D_all]...
    = ROIs_pack_BA(ROI_list, Slice_labels , T2_map_3D, Seg_ROI_3D);


Slice_labels_all=Slice_labels_all';

