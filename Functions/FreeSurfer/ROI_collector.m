function [ROI_list, Slice_labels, ROI_counter] = ROI_collector (Seg_vol, qT2_Arr)

[Label_num, Label_name] = Label_reader;

Slice_loc=80; % out of 256
N_scans=size(qT2_Arr,4);
% Scan_session=1;

Slice_seg=squeeze(Seg_vol(:,Slice_loc,:));
% Slice_T2=squeeze(qT2_Arr(:,Slice_loc,:,Scan_session));
ROI_counter=0;
for i=1:14175
    
    if (Slice_seg(Slice_seg==i) & length(Slice_seg(Slice_seg==i))>15)
        
        
        % One pixel erosion
        % N pixels < 10 - remove from list
        
        
        ROI_counter=ROI_counter+1;
        ROI_list(ROI_counter,1)=i;
        
        
        Label_num_loc=find(i==Label_num);
        Label_ROI=convertCharsToStrings(Label_name{Label_num_loc});
        Slice_labels(ROI_counter)=Label_ROI;
        
            mask_ROI=Slice_seg;
            mask_ROI(Slice_seg==i)=1;
            mask_ROI(Slice_seg~=i)=0;
            mask_edge = edge(mask_ROI,'Roberts');
%             figure;imagesc(mask_ROI); title('Before edge removal');
            mask_ROI(mask_edge~=0)=0;
%             figure;imagesc(mask_ROI); title('After edge removal');
            ROI_list(ROI_counter,2)= length(Slice_seg(mask_ROI==1)); 


        for Scan_session=1:N_scans
            N_scans_mat_loc= 2 + (Scan_session*2-1);
            Slice_T2=squeeze(qT2_Arr(:,Slice_loc,:,Scan_session));
            figure;imagesc (Slice_T2); caxis ([0 150])
%             figure;imagesc (Slice_seg);
            T2_ROI=Slice_T2(mask_ROI==1);
            
            ROI_list(ROI_counter,N_scans_mat_loc:(N_scans_mat_loc+1))=[mean(T2_ROI) std(T2_ROI)];
        end
    end
end