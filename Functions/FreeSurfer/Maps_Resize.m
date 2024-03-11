function [Seg_vol, qT2_Arr]=Maps_Resize(Seg_vol, qT2_Arr)

qT2_Arr_slices=[];
for idx_axial=1:size(Seg_vol,3)
   if sum(sum(Seg_vol(:,idx_axial,:)))
      qT2_Arr_slices=[qT2_Arr_slices idx_axial];
   end
end
qT2_Arr=qT2_Arr(:,qT2_Arr_slices(1):qT2_Arr_slices(end),:,:);
Seg_vol=Seg_vol(:,qT2_Arr_slices(1):qT2_Arr_slices(end),:);

qT2_Arr_slices=[];
for idx_sagital=1:size(Seg_vol,1)
   if sum(sum(Seg_vol(idx_sagital,:,:)))
      qT2_Arr_slices=[qT2_Arr_slices idx_sagital];
   end
end
qT2_Arr=qT2_Arr(qT2_Arr_slices(1):qT2_Arr_slices(end),:,:,:);
Seg_vol=Seg_vol(qT2_Arr_slices(1):qT2_Arr_slices(end),:,:);

qT2_Arr_slices=[];
for idx_coronal=1:size(Seg_vol,2)
   if sum(sum(Seg_vol(:,:,idx_coronal)))
      qT2_Arr_slices=[qT2_Arr_slices idx_coronal];
   end
end
qT2_Arr=qT2_Arr(:,:,qT2_Arr_slices(1):qT2_Arr_slices(end),:);
Seg_vol=Seg_vol(:,:,qT2_Arr_slices(1):qT2_Arr_slices(end));


end
