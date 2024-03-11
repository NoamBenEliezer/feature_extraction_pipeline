function [ROI_list, Slice_labels, ROI_counter] = ROI_collector_bySlice (Seg_vol, qT2_Arr, SSE_T2_map)

[Label_num, Label_name] = Label_reader;

% Slice_loc=80; % out of 256
% N_scans=size(qT2_Arr,2);
% Scan_session=1;
    SE = strel('disk',2);

for Series_num=1:size(qT2_Arr,2)+1
    
    if Series_num==6
        Curr_T2_map=SSE_T2_map;
        Slice_seg=Seg_vol{1,3}; %SSE_like=3
    else
        if Series_num==4
            Slice_num=2;
            Seg_vol{1,Series_num}=Seg_vol{1,Series_num}(:,:,Slice_num);
            qT2_Arr{1,Series_num}=qT2_Arr{1,Series_num}(:,:,Slice_num);
        else
            Slice_num=3;
            Seg_vol{1,Series_num}=Seg_vol{1,Series_num}(:,:,Slice_num);
            qT2_Arr{1,Series_num}=qT2_Arr{1,Series_num}(:,:,Slice_num);
        end
        Slice_seg=Seg_vol{1,Series_num};
        Curr_T2_map=qT2_Arr{1,Series_num};
    end
    
    ROI_counter=0;
    
    for i=1:14175
        N_voxels=length(Slice_seg(Slice_seg==i));
        if (N_voxels>15)
            
            %             if Series_num>1
            %                 if isempty(find(ROI_list(:,1)==i))
            %                     continue;
            %                 end
            %             end
            N_scans_mat_loc= (Series_num*4-3);
            
            
            ROI_counter=ROI_counter+1;
            ROI_list(ROI_counter,N_scans_mat_loc)=i ; % ;
            
            Label_num_loc=find(i==Label_num);
            Label_ROI=string(Label_name{Label_num_loc});
            Slice_labels(ROI_counter)=Label_ROI;
            
            mask_ROI=Slice_seg;
            mask_ROI(Slice_seg==i)=1;
            mask_ROI(Slice_seg~=i)=0;
            mask_ROI = logical(mask_ROI);
            
            mask_ROI=imerode(mask_ROI,SE);
            
            ROI_list(ROI_counter,N_scans_mat_loc+1)= length(Slice_seg(mask_ROI==1));
            T2_ROI=Curr_T2_map(mask_ROI==1);
            ROI_list(ROI_counter,(N_scans_mat_loc+2):(N_scans_mat_loc+3))=[mean(T2_ROI) std(T2_ROI)];
            
            
        end
    end
end




end


