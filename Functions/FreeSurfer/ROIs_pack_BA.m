% This functins packs together ROIs that are separated into subareas into the full ROI and adds them to the list of ROIs in the data and the statistics.
% For example: cortex, white matter, cingulate cortex...
% FS_ROIs_for_processing_orig = list of ROIs that exist in the data with statistics in columns. (FS_ROIs_for_processing in ROI_3D_collector_BA)
% ROI_labels_orig = names of the ROIs that exist in the data. respective to FS_ROIs_for_processing_orig.
% qmap_3D_orig = 1x111 cell. each cell contains 3D matrix with qMRI values of a specific ROI. according to FS_ROIs_for_processing_orig.
% Seg_ROI_3D_orig = 1x111 cell. each cell contains 3D matrix with the FS number label of a specific ROI in its location.

function [FS_ROIs_for_processing_all, ROI_labels_all , qmap_3D_all, Seg_ROI_3D_all] =...
          ROIs_pack_BA(FS_ROIs_for_processing_orig, ROI_labels_orig , qmap_3D_orig, Seg_ROI_3D_orig, N_vox_in_ROI_orig)

% Create local variables in which to add the packed ROIs so as not to change the original variable.
FS_ROIs_for_processing_all = FS_ROIs_for_processing_orig;
ROI_labels_all             = ROI_labels_orig;
qmap_3D_all                = qmap_3D_orig;
Seg_ROI_3D_all             = Seg_ROI_3D_orig;
N_vox_in_ROI_all           = N_vox_in_ROI_orig(:,1); % number of voxels before corrections

% ROI_list, Slice_labels , qmap_3D

%% Cortex
% pack all cortex ROIs into one general cortex ROI named ctx_all
counter            = 0;
ctx_all_N_vox      = 0;
ctx_all_3D_map     = zeros(size(qmap_3D_all{1}));
ctx_all_Seg_3D_map = zeros(size(qmap_3D_all{1}));

for chronological_ROI_idx = 1:length(ROI_labels_all)
    ROI_name = char(ROI_labels_all(chronological_ROI_idx));
    try % why is this only in the cortex part and not the rest?
        if strcmp(ROI_name(1:3),'ctx')
            counter = counter+1;
            ctx_ROIs_chronological_idx(counter) = chronological_ROI_idx; % add chronological ROI idx to list of ctx ROIs
            ctx_all_3D_map     = ctx_all_3D_map + qmap_3D_all{ctx_ROIs_chronological_idx(counter)}; % T1 map of whole cortex % maybe we can change ctx_ROIs_chronological_idx(counter) to chronological_ROI_idx? we need the list of all the ctx idx for the summation of voxels later but here we can simplify it.
            ctx_all_Seg_3D_map = ctx_all_Seg_3D_map + Seg_ROI_3D_all{ctx_ROIs_chronological_idx(counter)}; % mask of whole cortex 
            ctx_all_N_vox      = ctx_all_N_vox + FS_ROIs_for_processing_all(ctx_ROIs_chronological_idx(counter),2); % num of voxels in whole cortex
        end
    catch
        woperpweor = 5345; % what is this? nothing in help or web. RH
    end
end

% FS_ROIs_for_processing_all
orig_N_vox_ctx_all  = sum(N_vox_in_ROI_all(1,ctx_ROIs_chronological_idx));
ctx_all_qmri_values = nonzeros(ctx_all_3D_map);

ctx_all_stats = [5000                                                        ... % new FS idx for ctx_all
                 ctx_all_N_vox                                               ... % No. of voxels in ctx_all (after criteria)
                 mean(ctx_all_qmri_values)                                   ... % Mean
                 std(ctx_all_qmri_values)                                    ... % Standard deviation
                 100*std(ctx_all_qmri_values)/mean(ctx_all_qmri_values)      ... % CV
                 median(ctx_all_qmri_values)                                 ... % Median
                 prctile(ctx_all_qmri_values,90)                             ... % 90th percentile
                 prctile(ctx_all_qmri_values,75)                             ... % 75th percentile
                 prctile(ctx_all_qmri_values,25)                             ... % 25th percentile
                 prctile(ctx_all_qmri_values,10)                             ... % 10th percentile
                 ((orig_N_vox_ctx_all-ctx_all_N_vox)/orig_N_vox_ctx_all)*100 ... % percent of voxels deducted during erosion and chauvenet
                 skewness(ctx_all_qmri_values)                               ... % skewness of qMRI values
                 kurtosis(ctx_all_qmri_values)];							     % kurtosis of qMRI values

ROI_labels_all(end+1)               = 'ctx_all'; % ROI_labels
FS_ROIs_for_processing_all(end+1,:) = ctx_all_stats; % FS_ROIs_for_processing_all
qmap_3D_all{end+1}                  = {ctx_all_3D_map}; % qmap_3D
Seg_ROI_3D_all{end+1}               = {ctx_all_Seg_3D_map}; %Seg_ROI_3D
N_vox_in_ROI_all(end+1)             = orig_N_vox_ctx_all;

clear chronological_ROI_idx ctx_ROIs_chronological_idx ctx_all_Seg_3D_map ctx_all_3D_map ctx_all_N_vox ctx_all_stats ctx_all_qmri_values orig_N_vox_ctx_all;


%% Corpus callosum
counter           = 0;
CC_all_N_vox      = 0;
CC_all_3D_map     = zeros(size(qmap_3D_all{1}));
CC_all_Seg_3D_map = zeros(size(qmap_3D_all{1}));

for chronological_ROI_idx = 1:length(ROI_labels_all)
    ROI_name = char(ROI_labels_all(chronological_ROI_idx));
    if  contains(ROI_name,'CC_') % why is this contains and not strcmp like in cortex?
        counter = counter+1;
        CC_ROIs_chronological_idx(counter) = chronological_ROI_idx;
        CC_all_3D_map     = CC_all_3D_map + qmap_3D_all{CC_ROIs_chronological_idx(counter)};
        CC_all_Seg_3D_map = CC_all_Seg_3D_map + Seg_ROI_3D_all{CC_ROIs_chronological_idx(counter)};
        CC_all_N_vox      = CC_all_N_vox + FS_ROIs_for_processing_all(CC_ROIs_chronological_idx(counter),2);
    end
end

% FS_ROIs_for_processing_all
orig_N_vox_CC_all  = sum(N_vox_in_ROI_all(1,CC_ROIs_chronological_idx));
CC_all_qmri_values = nonzeros(CC_all_3D_map);

CC_all_stats = [5001                                                     ... % new FS idx for CC_all
                CC_all_N_vox                                             ... % No. of voxels in ctx_all (after criteria)
                mean(CC_all_qmri_values)                                 ... % Mean
                std(CC_all_qmri_values)                                  ... % Standard deviation
                100*std(CC_all_qmri_values)/mean(CC_all_qmri_values)     ... % CV
                median(CC_all_qmri_values)                               ... % Median
                prctile(CC_all_qmri_values,90)                           ... % 90th percentile
                prctile(CC_all_qmri_values,75)                           ... % 75th percentile
                prctile(CC_all_qmri_values,25)                           ... % 25th percentile
                prctile(CC_all_qmri_values,10)                           ... % 10th percentile
                ((orig_N_vox_CC_all-CC_all_N_vox)/orig_N_vox_CC_all)*100 ... % percent of voxels deducted during erosion and chauvenet
                skewness(CC_all_qmri_values)                             ... % skewness of qMRI values
                kurtosis(CC_all_qmri_values)];                               % kurtosis of qMRI values

ROI_labels_all(end+1)               = 'CC_all'; % ROI_labels
FS_ROIs_for_processing_all(end+1,:) = CC_all_stats; % FS_ROIs_for_processing_all
qmap_3D_all{end+1}                  = {CC_all_3D_map}; % qmap_3D
Seg_ROI_3D_all{end+1}               = {CC_all_Seg_3D_map}; %Seg_ROI_3D
N_vox_in_ROI_all(end+1)             = orig_N_vox_CC_all;

clear chronological_ROI_idx CC_ROIs_chronological_idx CC_all_N_vox CC_all_3D_map CC_all_Seg_3D_map CC_ROIs_chronological_idx CC_all_stats CC_all_qmri_values orig_N_vox_CC_all;


%% Left-right pairs

for chronological_ROI_idx = 1:length(ROI_labels_all)
    ROI_name    = char(ROI_labels_all(chronological_ROI_idx));
    if  contains(ROI_name,'Left')
        curr_ROI_name                     = ROI_name(6:end);
        LR_pair_ROIs_chronological_idx(1) = chronological_ROI_idx;
        if find(ROI_labels_all            == ['Right-' curr_ROI_name])
        LR_pair_ROIs_chronological_idx(2) = find(ROI_labels_all==['Right-' curr_ROI_name]);
        else
            continue;
        end
        
        curr_LR_pair_qmri_map = qmap_3D_all{LR_pair_ROIs_chronological_idx(1)} + qmap_3D_all{LR_pair_ROIs_chronological_idx(2)};
        curr_LR_pair_seg      = Seg_ROI_3D_all{LR_pair_ROIs_chronological_idx(1)} + Seg_ROI_3D_all{LR_pair_ROIs_chronological_idx(2)};
%       curr_LR_ROI_all       = FS_ROIs_for_processing_all(LR_pairs_ROIs_chronological_idx(1),2) + FS_ROIs_for_processing_all(LR_pairs_ROIs_chronological_idx(2),2); %number of pixels in left right pair, priginal code.
        curr_LR_pair_N_vox    = FS_ROIs_for_processing_all(LR_pair_ROIs_chronological_idx(1),2) + FS_ROIs_for_processing_all(LR_pair_ROIs_chronological_idx(2),2);
        
        orig_N_vox_curr_LR_pair  = sum(N_vox_in_ROI_all(1,LR_pair_ROIs_chronological_idx));
        curr_LR_pair_qmri_values = nonzeros(curr_LR_pair_qmri_map);
        
        curr_LR_pair_stats = [6000+chronological_ROI_idx                                                 ...
                              curr_LR_pair_N_vox                                                         ...
                              mean(curr_LR_pair_qmri_values)                                             ...
                              std(curr_LR_pair_qmri_values)                                              ...
                              100*std(curr_LR_pair_qmri_values)/mean(curr_LR_pair_qmri_values)           ...
                              median(curr_LR_pair_qmri_values)                                           ...
                              prctile(curr_LR_pair_qmri_values,90)                                       ...
                              prctile(curr_LR_pair_qmri_values,75)                                       ...
                              prctile(curr_LR_pair_qmri_values,25)                                       ...
                              prctile(curr_LR_pair_qmri_values,10)                                       ...
                              ((orig_N_vox_curr_LR_pair-curr_LR_pair_N_vox)/orig_N_vox_curr_LR_pair)*100 ...
                              skewness(curr_LR_pair_qmri_values)                                         ...
                              kurtosis(curr_LR_pair_qmri_values)];
        
        ROI_labels_all(end+1)               = [curr_ROI_name '_all']; % ROI_labels
        FS_ROIs_for_processing_all(end+1,:) = curr_LR_pair_stats; % FS_ROIs_for_processing_all
        qmap_3D_all{end+1}                  = curr_LR_pair_qmri_map; % qmap_3D
        Seg_ROI_3D_all{end+1}               = curr_LR_pair_seg; %Seg_ROI_3D
        N_vox_in_ROI_all(end+1)             = orig_N_vox_curr_LR_pair;
        
        clear chronological_ROI_idx LR_pair_ROIs_chronological_idx curr_LR_pair_stats curr_LR_pair_qmri_map curr_LR_pair_seg curr_LR_pair_N_vox orig_N_vox_curr_LR_pair curr_LR_pair_qmri_values;
        
    end
    
    % DOCUMENT
    if  contains(ROI_name,'ctx-lh')
        curr_ROI_name                         = ROI_name(8:end);
        LR_pair_ROIs_chronological_idx(1)     = chronological_ROI_idx;
        if find(ROI_labels_all==['ctx-rh-' curr_ROI_name])
            LR_pair_ROIs_chronological_idx(2) = find(ROI_labels_all==['ctx-rh-' curr_ROI_name]);
        else
            continue;
        end

        curr_LR_pair_qmri_map = qmap_3D_all{LR_pair_ROIs_chronological_idx(1)} + qmap_3D_all{LR_pair_ROIs_chronological_idx(2)};
        curr_LR_pair_seg      = Seg_ROI_3D_all{LR_pair_ROIs_chronological_idx(1)} + Seg_ROI_3D_all{LR_pair_ROIs_chronological_idx(2)};
        curr_LR_pair_N_vox    = FS_ROIs_for_processing_all(LR_pair_ROIs_chronological_idx(1),2) + FS_ROIs_for_processing_all(LR_pair_ROIs_chronological_idx(2),2);
        
        orig_N_vox_curr_LR_pair  = sum(N_vox_in_ROI_all(1,LR_pair_ROIs_chronological_idx));
        curr_LR_pair_qmri_values = nonzeros(curr_LR_pair_qmri_map);

        curr_LR_pair_stats = [6000+chronological_ROI_idx                                                 ...
                              curr_LR_pair_N_vox                                                         ...
                              mean(curr_LR_pair_qmri_values)                                             ...
                              std(curr_LR_pair_qmri_values)                                              ...
                              100*std(curr_LR_pair_qmri_values)/mean(curr_LR_pair_qmri_values)           ...
                              median(curr_LR_pair_qmri_values)                                           ...
                              prctile(curr_LR_pair_qmri_values,90)                                       ...
                              prctile(curr_LR_pair_qmri_values,75)                                       ...
                              prctile(curr_LR_pair_qmri_values,25)                                       ...
                              prctile(curr_LR_pair_qmri_values,10)                                       ...
                              ((orig_N_vox_curr_LR_pair-curr_LR_pair_N_vox)/orig_N_vox_curr_LR_pair)*100 ...
                              skewness(curr_LR_pair_qmri_values)                                         ...
                              kurtosis(curr_LR_pair_qmri_values)];
        
        ROI_labels_all(end+1)               = ['ctx_' curr_ROI_name '_all'];
        FS_ROIs_for_processing_all(end+1,:) = curr_LR_pair_stats;
        qmap_3D_all{end+1}                  = curr_LR_pair_qmri_map;
        Seg_ROI_3D_all{end+1}               = curr_LR_pair_seg;
        N_vox_in_ROI_all(end+1)             = orig_N_vox_curr_LR_pair;
        
        clear chronological_ROI_idx LR_pair_ROIs_chronological_idx curr_LR_pair_stats curr_LR_pair_qmri_map curr_LR_pair_seg curr_LR_pair_N_vox orig_N_vox_curr_LR_pair curr_LR_pair_qmri_values;
    end
           




    if  contains(ROI_name,'wm-lh')
        curr_ROI_name                         = ROI_name(7:end);
        LR_pair_ROIs_chronological_idx(1)     = chronological_ROI_idx;
        if find(ROI_labels_all==['wm-rh-' curr_ROI_name])
            LR_pair_ROIs_chronological_idx(2) = find(ROI_labels_all==['wm-rh-' curr_ROI_name]);
        else
            continue;
        end

        curr_LR_pair_qmri_map = qmap_3D_all{LR_pair_ROIs_chronological_idx(1)} + qmap_3D_all{LR_pair_ROIs_chronological_idx(2)};
        curr_LR_pair_seg      = Seg_ROI_3D_all{LR_pair_ROIs_chronological_idx(1)} + Seg_ROI_3D_all{LR_pair_ROIs_chronological_idx(2)};
        curr_LR_pair_N_vox    = FS_ROIs_for_processing_all(LR_pair_ROIs_chronological_idx(1),2) + FS_ROIs_for_processing_all(LR_pair_ROIs_chronological_idx(2),2);

        orig_N_vox_curr_LR_pair  = sum(N_vox_in_ROI_all(1,LR_pair_ROIs_chronological_idx));
        curr_LR_pair_qmri_values = nonzeros(curr_LR_pair_qmri_map);

        curr_LR_pair_stats = [7000+chronological_ROI_idx                                                 ...
                              curr_Lurr_LR_pair_qmri_values,75)                                       ...
                              prctile(curr_LR_pair_qmri_values,25)                                       ...
                              prctile(cuR_pair_N_vox                                                         ...
                              mean(curr_LR_pair_qmri_values)                                             ...
                              std(curr_LR_pair_qmri_values)                                              ...
                              100*std(curr_LR_pair_qmri_values)/mean(curr_LR_pair_qmri_values)           ...
                              median(curr_LR_pair_qmri_values)                                           ...
                              prctile(curr_LR_pair_qmri_values,90)                                       ...
                              prctile(crr_LR_pair_qmri_values,10)                                       ...
                              ((orig_N_vox_curr_LR_pair-curr_LR_pair_N_vox)/orig_N_vox_curr_LR_pair)*100 ...
                              skewness(curr_LR_pair_qmri_values)                                         ...
                              kurtosis(curr_LR_pair_qmri_values)];

        ROI_labels_all(end+1)               = ['wm_' curr_ROI_name '_all'];
        FS_ROIs_for_processing_all(end+1,:) = curr_LR_pair_stats;
        qmap_3D_all{end+1}                  = curr_LR_pair_qmri_map;
        Seg_ROI_3D_all{end+1}               = curr_LR_pair_seg;
        N_vox_in_ROI_all(end+1)             = orig_N_vox_curr_LR_pair;
        
        clear chronological_ROI_idx LR_pair_ROIs_chronological_idx curr_LR_pair_stats curr_LR_pair_qmri_map curr_LR_pair_seg curr_LR_pair_N_vox orig_N_vox_curr_LR_pair curr_LR_pair_qmri_values;
        
    end
    
end


%% Ventricles
counter                     = 0;
ventricles_all_N_vox        = 0;
ventricles_all_qmri_map     = zeros(size(qmap_3D_all{1}));
ventricles_all_Seg_qmri_map = zeros(size(qmap_3D_all{1}));

for chronological_ROI_idx = 1:length(ROI_labels_all)
    ROIname               = char(ROI_labels_all(chronological_ROI_idx));
    if (contains(ROIname,'Vent') && (~contains(ROIname,'Ventral')))
        counter = counter+1;
        ventricles_chronological_idx(counter) = chronological_ROI_idx;
        ventricles_all_qmri_map     = ventricles_all_qmri_map + qmap_3D_all{ventricles_chronological_idx(counter)};
        ventricles_all_Seg_qmri_map = ventricles_all_Seg_qmri_map + Seg_ROI_3D_all{ventricles_chronological_idx(counter)};
        ventricles_all_N_vox        = ventricles_all_N_vox + FS_ROIs_for_processing_all(ventricles_chronological_idx(counter),2);
    end
    
end

orig_N_vox_ventricles  = sum(N_vox_in_ROI_all(1,ventricles_chronological_idx));
ventricles_qmri_values = nonzeros(ventricles_all_qmri_map);

ventricles_stats = [8000+chronological_ROI_idx                                               ...
                    ventricles_all_N_vox                                                     ...
                    mean(ventricles_qmri_values)                                             ...
                    std(ventricles_qmri_values)                                              ...
                    100*std(ventricles_qmri_values)/mean(ventricles_qmri_values)             ...
                    median(ventricles_qmri_values)                                           ...
                    prctile(ventricles_qmri_values,90)                                       ...
                    prctile(ventricles_qmri_values,75)                                       ...
                    prctile(ventricles_qmri_values,25)                                       ...
                    prctile(ventricles_qmri_values,10)                                       ...
                    ((orig_N_vox_ventricles-ventricles_all_N_vox)/orig_N_vox_ventricles)*100 ...
                    skewness(ventricles_qmri_values)                                         ...
                    kurtosis(ventricles_qmri_values)];

ROI_labels_all(end+1)               = 'Ventricles_all';
FS_ROIs_for_processing_all(end+1,:) = ventricles_stats;
qmap_3D_all(end+1)                  = {ventricles_all_qmri_map};
Seg_ROI_3D_all(end+1)               = {ventricles_all_Seg_qmri_map};
N_vox_in_ROI_all(end+1)             = orig_N_vox_ventricles;

clear chronological_ROI_idx ventricles_chronological_idx ventricles_all_qmri_map ventricles_all_Seg_qmri_map ventricles_stats ventricles_qmri_values orig_N_vox_ventricles ventricles_all_N_vox;

%fixed till here
%why do we need index correction if we are only adding the ventricles_all to the end of all the lists?
% for idx_correction=1:counter
%     
%     % ROI list
%     ROI_list_tmp=ROI_list_all(1:ventricles_chronological_idx(idx_correction)-idx_correction,:);
%     ROI_list_tmp (size(ROI_list_tmp,1)+1:length(ROI_list_all)-1,:)=ROI_list_all(ventricles_chronological_idx(idx_correction)+2-idx_correction:end,:);
%     ROI_list_all=ROI_list_tmp;
%     clear ROI_list_tmp;
%     
%     % Slice_labels
%     Slice_labels_tmp=ROI_labels_all(1:ventricles_chronological_idx(idx_correction)-idx_correction);
%     Slice_labels_tmp (length(Slice_labels_tmp)+1:length(ROI_labels_all)-1)=ROI_labels_all((ventricles_chronological_idx(idx_correction)+2-idx_correction):end);
%     ROI_labels_all=Slice_labels_tmp;
%     clear Slice_labels_tmp;
%     
%     % qmap_3D
%     qmap_3D_tmp=qmap_3D_all(1:ventricles_chronological_idx(idx_correction)-idx_correction);
%     qmap_3D_tmp (length(qmap_3D_tmp)+1:length(qmap_3D_all)-1)=qmap_3D_all((ventricles_chronological_idx(idx_correction)+2-idx_correction):end);
%     qmap_3D_all=qmap_3D_tmp;
%     clear qmap_3D_tmp;
%     
%     %Seg_ROI_3D
%     Seg_ROI_3D_tmp=Seg_ROI_3D_all(1:ventricles_chronological_idx(idx_correction)-idx_correction);
%     Seg_ROI_3D_tmp (length(Seg_ROI_3D_tmp)+1:length(Seg_ROI_3D_all)-1)=Seg_ROI_3D_all((ventricles_chronological_idx(idx_correction)+2-idx_correction):end);
%     Seg_ROI_3D_all=Seg_ROI_3D_tmp;
%     clear Seg_ROI_3D_tmp;
%     
% end
% 
% clear ventricles_chronological_idx; clear ROI_FS_idx;



