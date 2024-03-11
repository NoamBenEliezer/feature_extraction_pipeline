function [ROI_list, Slice_labels , T2_map_3D, Seg_ROI_3D,...
    ROI_list_small, Slice_labels_small , T2_map_3D_small,Seg_ROI_3D_small]...
    = ROI_3D_collector (Seg_vol, qT2_Arr)

[Label_num, Label_name] = Label_reader;

% Slice_loc=80; % out of 256
N_scans=size(qT2_Arr,4);
Scan_session=1;

% T2_map_3D=zeros(size(qT2_Arr(:,:,:,curr_scan)));

ROI_counter=0;

% [Seg_vol, qT2_Arr]=Maps_Resize(Seg_vol, qT2_Arr);


ROI_list=[];
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
        
        ROI_list(FS_idx,2)= length(Seg_vol(Seg_vol==ROI_list(FS_idx)));
        T2_map_3D{FS_idx}=zeros(size(qT2_Arr(:,:,:,Scan_session)));
                 Seg_ROI_3D{FS_idx}= T2_map_3D{FS_idx};

        T2_map_3D{FS_idx}(Seg_vol==ROI_list(FS_idx))=qT2_Arr(Seg_vol==ROI_list(FS_idx));
    Seg_ROI_3D{FS_idx}(Seg_vol==ROI_list(FS_idx))=Seg_vol(Seg_vol==ROI_list(FS_idx));
        T2_ROI=qT2_Arr(Seg_vol==ROI_list(FS_idx));
    
        N_scans_mat_loc= 2 + (Scan_session*2-1);

        ROI_list(FS_idx,N_scans_mat_loc:(N_scans_mat_loc+2))=[mean(T2_ROI) std(T2_ROI) 100*std(T2_ROI)/mean(T2_ROI)]; % mean, SD, CV
end
% toc

Slice_labels=Slice_labels';

% [ROI_list_all, Slice_labels_all] = ROIs_gather_BA(ROI_list, Slice_labels);

[ROI_list_small, Slice_labels_small , T2_map_3D_small, Seg_ROI_3D_small]...
    = ROIs_pack(ROI_list, Slice_labels , T2_map_3D, Seg_ROI_3D);



