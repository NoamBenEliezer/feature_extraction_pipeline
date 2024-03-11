function [ROI_list_all, Slice_labels_all] = ROIs_gather_BA(ROI_list_orig, Slice_labels_orig)

ROI_list_all=ROI_list_orig;
Slice_labels_all=Slice_labels_orig;

% ROI_list, Slice_labels , T2_map_3D

%% Remove small structures (<30 voxels)
Counter=0;
for idx_labels=1:length(ROI_list_all)
    
    if ROI_list_all(idx_labels,2)<30
        Counter=Counter+1;
        ROI_chronological_idx(Counter)=idx_labels;
        %         ROI_FS_idx(Counter)=ROI_list_small(idx_labels,1);
    end
end

for idx_correction=1:Counter
    
    % ROI list
    ROI_list_tmp=ROI_list_all(1:ROI_chronological_idx(idx_correction)-idx_correction,:);
    ROI_list_tmp (size(ROI_list_tmp,1)+1:length(ROI_list_all)-1,:)=ROI_list_all(ROI_chronological_idx(idx_correction)+2-idx_correction:end,:);
    ROI_list_all=ROI_list_tmp;
    clear ROI_list_tmp;
    
    % Slice_labels
    Slice_labels_tmp=Slice_labels_all(1:ROI_chronological_idx(idx_correction)-idx_correction);
    Slice_labels_tmp (length(Slice_labels_tmp)+1:length(Slice_labels_all)-1)=Slice_labels_all((ROI_chronological_idx(idx_correction)+2-idx_correction):end);
    Slice_labels_all=Slice_labels_tmp;
    clear Slice_labels_tmp;
    
end

clear ROI_chronological_idx; clear ROI_FS_idx;

%% Cortex
Counter=0;
ctx_3D_map=zeros(size(T2_map_3D_small{1}));
ctx_Seg_3D_map=zeros(size(T2_map_3D_small{1}));

ctx_N_pix=0;
for idx_labels=1:length(Slice_labels_all)
    
%     ROIname=convertStringsToChars(Slice_labels_small(idx_labels));
    ROIname=char(Slice_labels_all(idx_labels));
try
    if strcmp(ROIname(1:3),'ctx')
        Counter=Counter+1;
        ROI_chronological_idx(Counter)=idx_labels;
        %         ROI_FS_idx(Counter)=ROI_list_small(idx_labels,1);
        ctx_3D_map= ctx_3D_map + T2_map_3D_small{ROI_chronological_idx(Counter)};
        ctx_Seg_3D_map=ctx_Seg_3D_map+Seg_ROI_3D_small{ROI_chronological_idx(Counter)};
        ctx_N_pix=ctx_N_pix+ROI_list_all(ROI_chronological_idx(Counter),2);
    end
catch
    woperpweor=5345;
end
end

% ROI list
ctx_stats=[ROI_list_all(ROI_chronological_idx(1),1) ...
    ctx_N_pix ...
    mean(ROI_list_all(ROI_chronological_idx,3)) ...
    std(ROI_list_all(ROI_chronological_idx,3))];

ROI_list_all(ROI_chronological_idx(1),:)=ctx_stats;
ROI_list_all=ROI_list_all(1:ROI_chronological_idx(1),:);

% Slice_labels
Slice_labels_all(ROI_chronological_idx(1))='ctx_combined';
Slice_labels_all=Slice_labels_all(1:ROI_chronological_idx(1));

clear ROI_chronological_idx; clear ROI_FS_idx;

%% Ventricles
Counter=0;
Ventricle_3D_map=zeros(size(T2_map_3D_small{1}));
Ventricle_Seg_3D_map=Ventricle_3D_map;
Ventricle_N_pix=0;
for idx_labels=1:length(Slice_labels_all)
    
%     ROIname=convertStringsToChars(Slice_labels_small(idx_labels));
        ROIname=char(Slice_labels_all(idx_labels));

    if (contains(ROIname,'Vent') && (~contains(ROIname,'Ventral')))
        Counter=Counter+1;
        ROI_chronological_idx(Counter)=idx_labels;
        %         ROI_FS_idx(Counter)=ROI_list_small(idx_labels,1);
        Ventricle_3D_map= Ventricle_3D_map + T2_map_3D_small{ROI_chronological_idx(Counter)};
        Ventricle_Seg_3D_map=Ventricle_Seg_3D_map+Seg_ROI_3D_small{ROI_chronological_idx(Counter)};
        Ventricle_N_pix=Ventricle_N_pix+ROI_list_all(ROI_chronological_idx(Counter),2);
    end
    
end

% Slice_labels
Slice_labels_all(end+1)='Ventricles_combined';

% ROI list
Vent_stats=[ROI_list_all(ROI_chronological_idx(1),1) ...
    Ventricle_N_pix ...
    mean(ROI_list_all(ROI_chronological_idx,3)) ...
    std(ROI_list_all(ROI_chronological_idx,3))];

ROI_list_all(end+1,:)=Vent_stats;

% T2_map_3D
T2_map_3D_small(end+1)={Ventricle_3D_map};

%Seg_ROI_3D
Seg_ROI_3D_small(end+1)={Ventricle_Seg_3D_map};

for idx_correction=1:Counter
    
    % ROI list
    ROI_list_tmp=ROI_list_all(1:ROI_chronological_idx(idx_correction)-idx_correction,:);
    ROI_list_tmp (size(ROI_list_tmp,1)+1:length(ROI_list_all)-1,:)=ROI_list_all(ROI_chronological_idx(idx_correction)+2-idx_correction:end,:);
    ROI_list_all=ROI_list_tmp;
    clear ROI_list_tmp;
    
    % Slice_labels
    Slice_labels_tmp=Slice_labels_all(1:ROI_chronological_idx(idx_correction)-idx_correction);
    Slice_labels_tmp (length(Slice_labels_tmp)+1:length(Slice_labels_all)-1)=Slice_labels_all((ROI_chronological_idx(idx_correction)+2-idx_correction):end);
    Slice_labels_all=Slice_labels_tmp;
    clear Slice_labels_tmp;
    
    % T2_map_3D
    T2_map_3D_tmp=T2_map_3D_small(1:ROI_chronological_idx(idx_correction)-idx_correction);
    T2_map_3D_tmp (length(T2_map_3D_tmp)+1:length(T2_map_3D_small)-1)=T2_map_3D_small((ROI_chronological_idx(idx_correction)+2-idx_correction):end);
    T2_map_3D_small=T2_map_3D_tmp;
    clear T2_map_3D_tmp;
    
    %Seg_ROI_3D
    Seg_ROI_3D_tmp=Seg_ROI_3D_small(1:ROI_chronological_idx(idx_correction)-idx_correction);
    Seg_ROI_3D_tmp (length(Seg_ROI_3D_tmp)+1:length(Seg_ROI_3D_small)-1)=Seg_ROI_3D_small((ROI_chronological_idx(idx_correction)+2-idx_correction):end);
    Seg_ROI_3D_small=Seg_ROI_3D_tmp;
    clear Seg_ROI_3D_tmp;
    
end

clear ROI_chronological_idx; clear ROI_FS_idx;


%% Corpus callosum
Counter=0;
CC_3D_map=zeros(size(T2_map_3D_small{1}));
CC_Seg_3D_map=CC_3D_map;

CC_N_pix=0;
for idx_labels=1:length(Slice_labels_all)
    
%     ROIname=convertStringsToChars(Slice_labels_small(idx_labels));
        ROIname=char(Slice_labels_all(idx_labels));

    if  contains(ROIname,'CC_')
        Counter=Counter+1;
        ROI_chronological_idx(Counter)=idx_labels;
        %         ROI_FS_idx(Counter)=ROI_list_small(idx_labels,1);
        CC_3D_map= CC_3D_map + T2_map_3D_small{ROI_chronological_idx(Counter)};
        CC_Seg_3D_map=CC_Seg_3D_map+Seg_ROI_3D_small{ROI_chronological_idx(Counter)};
        CC_N_pix=CC_N_pix+ROI_list_all(ROI_chronological_idx(Counter),2);
    end
    
end


% Slice_labels
Slice_labels_all(end+1)='CC_combined';

% ROI list
CC_stats=[ROI_list_all(ROI_chronological_idx(1),1) ...
    CC_N_pix ...
    mean(ROI_list_all(ROI_chronological_idx,3)) ...
    std(ROI_list_all(ROI_chronological_idx,3))];

ROI_list_all(end+1,:)=CC_stats;

% T2_map_3D
T2_map_3D_small(end+1)={CC_3D_map};

%Seg_ROI_3D
Seg_ROI_3D_small(end+1)={CC_Seg_3D_map};


for idx_correction=1:Counter
    
    % ROI list
    ROI_list_tmp=ROI_list_all(1:ROI_chronological_idx(idx_correction)-idx_correction,:);
    ROI_list_tmp (size(ROI_list_tmp,1)+1:length(ROI_list_all)-1,:)=ROI_list_all(ROI_chronological_idx(idx_correction)+2-idx_correction:end,:);
    ROI_list_all=ROI_list_tmp;
    clear ROI_list_tmp;
    
    % Slice_labels
    Slice_labels_tmp=Slice_labels_all(1:ROI_chronological_idx(idx_correction)-idx_correction);
    Slice_labels_tmp (length(Slice_labels_tmp)+1:length(Slice_labels_all)-1)=Slice_labels_all((ROI_chronological_idx(idx_correction)+2-idx_correction):end);
    Slice_labels_all=Slice_labels_tmp;
    clear Slice_labels_tmp;
    
    % T2_map_3D
    T2_map_3D_tmp=T2_map_3D_small(1:ROI_chronological_idx(idx_correction)-idx_correction);
    T2_map_3D_tmp (length(T2_map_3D_tmp)+1:length(T2_map_3D_small)-1)=T2_map_3D_small((ROI_chronological_idx(idx_correction)+2-idx_correction):end);
    T2_map_3D_small=T2_map_3D_tmp;
    clear T2_map_3D_tmp;
    
    %Seg_ROI_3D
    Seg_ROI_3D_tmp=Seg_ROI_3D_small(1:ROI_chronological_idx(idx_correction)-idx_correction);
    Seg_ROI_3D_tmp (length(Seg_ROI_3D_tmp)+1:length(Seg_ROI_3D_small)-1)=Seg_ROI_3D_small((ROI_chronological_idx(idx_correction)+2-idx_correction):end);
    Seg_ROI_3D_small=Seg_ROI_3D_tmp;
    clear Seg_ROI_3D_tmp;
    
end

clear ROI_chronological_idx; clear ROI_FS_idx;


%% Left-right pairs
Counter=0;
idx_labels=0; 
Original_length=length(Slice_labels_all);
while (Original_length-Counter > idx_labels)
idx_labels=idx_labels+1;
%     ROIname=convertStringsToChars(Slice_labels_small(idx_labels));
        ROIname=char(Slice_labels_all(idx_labels));

    if  contains(ROIname,'Left')
        ROIname_cut=ROIname(5:end);
        if sum(contains(Slice_labels_all (1:end), ROIname_cut))
            Counter=Counter+1;
            ROI_chronological_idx=find(contains(Slice_labels_all (1:end), ROIname_cut));
            %         ROI_FS_idx=ROI_list_small(idx_labels,1);
            tmp_3D_map=T2_map_3D_small{ROI_chronological_idx(1)}+T2_map_3D_small{ROI_chronological_idx(2)};
            tmp_Seg_3D_map=Seg_ROI_3D_small{ROI_chronological_idx(1)}+Seg_ROI_3D_small{ROI_chronological_idx(2)};

            tmp_N_pix=ROI_list_all(ROI_chronological_idx(1),2)+ROI_list_all(ROI_chronological_idx(2),2);
            tmp_T2=[mean(ROI_list_all(ROI_chronological_idx,3)) mean(ROI_list_all(ROI_chronological_idx,4))];
        end
        
        % Slice_labels
        Slice_labels_all(ROI_chronological_idx(1))=[ROIname_cut(2:end) '_combined'];
        
        Slice_labels_tmp=Slice_labels_all(1:ROI_chronological_idx(2)-1);
        Slice_labels_tmp (length(Slice_labels_tmp)+1:length(Slice_labels_all)-1)=Slice_labels_all((ROI_chronological_idx(2)+1):end);
        Slice_labels_all=Slice_labels_tmp;
        clear Slice_labels_tmp;
        
        % ROI list
        tmp_stats=[ROI_list_all(ROI_chronological_idx(1),1), tmp_N_pix, tmp_T2(1), tmp_T2(2)];
        ROI_list_all(ROI_chronological_idx(1),:)=tmp_stats;
        
        ROI_list_tmp=ROI_list_all(1:ROI_chronological_idx(2)-1,:);
        ROI_list_tmp (size(ROI_list_tmp,1)+1:length(ROI_list_all)-1,:)=ROI_list_all(ROI_chronological_idx(2)+1:end,:);
        ROI_list_all=ROI_list_tmp;
        clear ROI_list_tmp;
        
        % T2_map_3D
        T2_map_3D_small(ROI_chronological_idx(1))={tmp_3D_map};
              
        T2_map_3D_tmp=T2_map_3D_small(1:ROI_chronological_idx(2)-1);
        T2_map_3D_tmp (length(T2_map_3D_tmp)+1:length(T2_map_3D_small)-1)=T2_map_3D_small((ROI_chronological_idx(2)+1):end);
        T2_map_3D_small=T2_map_3D_tmp;
        clear T2_map_3D_tmp;
        
        % Seg_ROI_3D
        Seg_ROI_3D_small(ROI_chronological_idx(1))={tmp_Seg_3D_map};
              
        Seg_ROI_3D_tmp=Seg_ROI_3D_small(1:ROI_chronological_idx(2)-1);
        Seg_ROI_3D_tmp (length(Seg_ROI_3D_tmp)+1:length(Seg_ROI_3D_small)-1)=Seg_ROI_3D_small((ROI_chronological_idx(2)+1):end);
        Seg_ROI_3D_small=Seg_ROI_3D_tmp;
        clear Seg_ROI_3D_tmp;
        
        
        
    end 
end

clear ROI_chronological_idx; clear ROI_FS_idx;





