% To compare ROI masks before and after erosion:
% run "extract_qMRI_features until after the erosion in "extract_qMRI_features_for_all_ROIs".
% You can skip straight to the ROI you want to compare.
% Then run this script.

% Compare the masks themselves
figure(1); sliceViewer(roi_mask);
figure(2); sliceViewer(roi_mask_eroded);

cmap = parula(256);

% original ROI mask on qMRI_map
roi_mask_inv = ~roi_mask;
qMRI_masked = qMRI_map.*roi_mask_inv;
figure(3); sliceViewer(qMRI_masked,'Colormap',cmap);
% figure(3); sliceViewer(qMRI_masked);

% eroded ROI mask on qMRI_map
eroded_roi_mask_inv = ~roi_mask_eroded;
qMRI_masked_eroded = qMRI_map.*eroded_roi_mask_inv;
figure(4); sliceViewer(qMRI_masked_eroded,'Colormap',cmap);

% To see a subplot of specific slices change the loop range to the slices you want (and the number of subplots accordingly):
figure;
p = 1;
sgtitle('n Neighbors = 4');
for ii = 14:22
	subplot(3,3,p); p=p+1;
	imagesc(squeeze(roi_mask_eroded(:,:,ii)));
	axis image;
	colormap parula;
	%colorbar;
	title(sprintf('%1.0f',ii));
	% axis([80   121    82   132]); % axis for left hippocampus, slices 1:9
	% axis([69   122    58   124]); % axis for left caudate, slices 7:16
	% axis([56   131    55   148]); % axis for left thalamus, slices 7:14
	axis([64   111    75   133]); % axis for left posterior cingulate cortex, slices 14:22
	%caxis([]);
end

% To use alphamask find "check_mrQ_segmentation" script under qT1 folder --> Mindfulness
