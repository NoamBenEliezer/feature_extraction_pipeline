
% ============================ %
%    to be defined by user
% ============================ %

global SEGMENTATION_ROOT             ; SEGMENTATION_ROOT              = '/home/noambe/Public/Segmentations_FS/';
global PROJECT_NAME                  ; PROJECT_NAME                   = 'Mindfulness';
global DATA_DIR                      ; DATA_DIR                       = '/home/noambe/Public/qMRI_qT2/Mindfulness/';
global RESULTS_FILENAME              ; RESULTS_FILENAME               = 'qT2_WM_CSF_vents_stats';
global RESULTS_FOLDER                ; RESULTS_FOLDER                 = '/home/noambe/Public/qMRI_qT2/Mindfulness/statistics_Results';   % folder in which to save the statistical results
global SESSIONS                      ; SESSIONS                       = {'S1', 'S3'}; % session foldernames
global SUBJECT_FOLDER_NAME_PREFIX    ; SUBJECT_FOLDER_NAME_PREFIX     = 'V';
global qMRI_VAL_IGNORED              ; qMRI_VAL_IGNORED               = 0 ;   % value to ignore in outlier removal. if 0 is not a valid value in your qMRI map then keep as 0
global CHAUVENET_FLAG                ; CHAUVENET_FLAG                 = 0 ;   % remove voxels where value > mean ± flag*SD
global PRCT_OF_DEDUCTED_VOXELS_THRESH; PRCT_OF_DEDUCTED_VOXELS_THRESH = 20;   % threshold above which segmentation should be checked manually after erosion and chauvenet
global EROSION_OPT                   ;
EROSION_OPT.MATLAB_nPx           = 0 ;   % 0/1 = no erosion, 2 = single voxel erosion, 3 = two voxels erosion... DO NOT USE WITHOUT MANUALLY CHECKING THE EROSION RESULTS!
EROSION_OPT.NBE_nPx              = 0 ;   % recommended, 0 = no erosion, 1 = single voxel erosion, 2 = two voxels erosion...
EROSION_OPT.NBE_n_Neighbors      = 4 ;   % 4 recommended
% Also set MAP_TYPES variable in line 72.

global qMRI_ILLEGAL_VAL              ; qMRI_ILLEGAL_VAL    = -999; % Illegal value to initialize final stats structure
global COLUMN_IDX_FS_LBL             ; COLUMN_IDX_FS_LBL   = 1;    % Index of the column containing the Freesrfer label
global COLUMN_IDX_STATS              ; COLUMN_IDX_STATS    = 2;    % Index of the first column containing statistical features 

global EXPERIMENT_GROUP_NAME         ; EXPERIMENT_GROUP_NAME = 'Mindfulness';
global CONTROL_GROUP_NAME            ; CONTROL_GROUP_NAME    = 'Control';

% Define foldernames of subjects by group
global EXPERIMENT_GROUP              ; global CONTROL_GROUP;

EXPERIMENT_GROUP = ["V101", "V103", "V107", "V115", "V119", "V134", "V157", "V160", "V183", "V192", "V204", "V230", "V231",...
                       "V236", "V274", "V278", "V292", "V297", "V303", "V307", "V308", "V345", "V372"]; 
CONTROL_GROUP    = ["V106", "V117", "V122", "V131", "V142", "V154", "V211", "V225", "V260", "V294", "V329", "V340", "V377",...
                       "V400", "V432", "V438", "V448", "V451", "V452", "V470"];

% PLEASE NOTICE: if any change in the order or names in ROI_names is made, ROIs_2_combine needs to be adjusted manually!

ROI_NAMES = {'ctx-lh-rostralanteriorcingulate', ...% 1
             'ctx-rh-rostralanteriorcingulate',... % 2
             'ctx-lh-caudalanteriorcingulate', ... % 3
             'ctx-rh-caudalanteriorcingulate', ... % 4
             'Left-Caudate',                   ... % 5
             'Right-Caudate',                  ... % 6
             'Left-Hippocampus',               ... % 7
             'Right-Hippocampus',              ... % 8
             'ctx-lh-posteriorcingulate',      ... % 9
             'ctx-rh-posteriorcingulate',      ... % 10
             'Left-Insula',                    ... % 11 
             'Right-Insula',                   ... % 12 
             'Left-Cerebellum-White-Matter',   ... % 13
             'Left-Cerebellum-Cortex',         ... % 14
             'Right-Cerebellum-White-Matter',  ... % 15
             'Right-Cerebellum-Cortex',        ... % 16
             'ctx-lh-parahippocampal',         ... % 17
             'ctx-rh-parahippocampal',         ... % 18
             'wm-lh-parahippocampal',          ... % 19 
             'wm-rh-parahippocampal',          ... % 20 
             'ctx-lh-fusiform',                ... % 21
             'ctx-rh-fusiform',                ... % 22
             'wm-lh-fusiform',                 ... % 23
             'wm-rh-fusiform',                 ... % 24
             'Left-Pallidum',                  ... % 25
             'Right-Pallidum',                 ... % 26
             'ctx-lh-prim-sec-somatosensory' , ... % 27
             'ctx-rh-prim-sec-somatosensory' , ... % 28
             'ctx-lh-prefrontal' ,             ... % 29
             'ctx-rh-prefrontal' ,             ... % 30
             'ctx-lh-inferiorparietal',        ... % 31
             'ctx-rh-inferiorparietal' ,       ... % 32
             'wm-lh-inferiorparietal' ,        ... % 33
             'wm-rh-inferiorparietal' ,        ... % 34
             'ctx-lh-inferiortemporal' ,       ... % 35
             'ctx-rh-inferiortemporal',        ... % 36
             'ctx-rh-lateralorbitofrontal',    ... % 37
             'ctx-rh-medialorbitofrontal' ,    ... % 38
             'Basolateral-nucleus' ,           ... % 39
             'ctx-rh-S_frontal_inferior' ,     ... % 40
             'ctx-rh-S_frontal_middle' ,       ... % 41
             'ctx-rh-G_frontal_middle' ,       ... % 42
             'ctx-lh-primary-motor' ,          ... % 43
             'ctx-rh-primary-motor' ,          ... % 44
             'ctx-lh-superiorfrontal' ,        ... % 45
             'ctx-rh-superiorfrontal' ,        ... % 46
             'Left-Thalamus-Proper*' ,         ... % 47
             'Right-Thalamus-Proper*' ,        ... % 48
             'wm-lh-parietal-lobe',            ... % 49
             'wm-lh-caudalanteriorcingulate',  ... % 50
             'wm-rh-caudalanteriorcingulate',  ... % 51
             'wm-lh-rostralanteriorcingulate', ... % 52
             'wm-rh-rostralanteriorcingulate', ... % 53
             'ctx-lh-insula',                  ... % 54
             'ctx-rh-insula',                  ... % 55
             'wm-lh-insula',                   ... % 56
             'wm-rh-insula',                   ... % 57
             'ctx-lh-precuneus',               ... % 58
             'ctx-rh-precuneus',               ... % 59
             'wm-lh-precuneus',                ... % 60
             'wm-rh-precuneus',                ... % 61
             'wm-rh-parietal-lobe',            ... % 62
             'ctx-rh-posterior-parietal',      ... % 63
             'wm-rh-superiorparietal',         ... % 64
             'LAntThalRadiation',              ... % 65
             'RAntThalRadiation',              ... % 66
	         'Left-Cerebral-White-Matter',     ... % 67
             'Right-Cerebral-White-Matter',    ... % 68
             'Cerebral_White_Matter',          ... % 69
             'WhiteMatter-FSL-FAST',           ... % 70
             'Left-UnsegmentedWhiteMatter',    ... % 71
             'Right-UnsegmentedWhiteMatter',   ... % 72
             'CC_Posterior',                   ... % 73
             'CC_Mid_Posterior',               ... % 74
             'CC_Central',                     ... % 75
             'CC_Mid_Anterior',                ... % 76
             'CC_Anterior',                    ... % 77
             };
 

ROIs_2_COMBINE = {1 ,2 ,'rostralanteriorcingulate_ctx_RL';...
                  3 ,4 ,'caudalanteriorcingulate_ctx_RL';...
                  5 ,6 ,'Caudate_RL';...
                  7 ,8 ,'Hippocampus_RL';...
                  9 ,10,'posteriorcingulate_ctx_RL';...
                  11,12,'Insula_RL';...
                  13,14,'Left-Cerebellum';...
                  15,16,'Right-Cerebellum';...
                  17,18,'parahippocampal_ctx_RL';...
                  19,20,'parahippocampal_wm_RL';...
                  21,22,'fusiform_ctx_RL';...
                  23,24,'fusiform_wm_RL';...
                  25,26,'Pallidum_RL';...
                  27,28,'prim-sec-somatosensory_ctx_RL';...
                  29,30,'prefrontal_ctx_RL';...
                  31,32,'inferiorparietal_ctx_RL';...
                  33,34,'inferiorparietal_wm_RL';...
                  31,33,'inferiorparietal_L';...
                  32,34,'inferiorparietal_R';...
                  35,36,'inferiortemporal_ctx_RL';...
                  37,38,'orbitofrontal_ctx_R';...
                  40,41,'frontal_ctx_R';...
                  43,44,'primary-motor_ctx_RL';...
                  45,46,'superiorfrontal_ctx_RL';...
                  47,48,'Thalamus_RL'; ...
                  50,52,'wm_anteriorcingulate_L'; ...
                  51,53,'wm_anteriorcingulate_R'; ...
                  54,55,'insula_ctx_RL'; ...
                  54,56,'insula_L'; ...
                  55,57,'insula_R'; ...
                  58,59,'precuneus_ctx_RL'; ...
                  58,60,'precuneus_L'; ...
                  59,61,'precuneus_R'; ...
                  65,66,'AntThalRadiation_RL'; ...
		          67,68,'Cerebral_White_Matter_RL';...
                  71,72,'Unsegmented_White_Matter_RL';...
		          };

% ============================ %
%           GENERAL
% ============================ %

global N_SINGLE_ROIS                 ; N_SINGLE_ROIS       = length(ROI_NAMES); 
global N_ROIs_total                  ; N_ROIs_total        = length(ROI_NAMES)+length(ROIs_2_COMBINE);
global MAP_TYPE_T1                   ; MAP_TYPE_T1         = 'T1'    ; % 1
global MAP_TYPE_T2                   ; MAP_TYPE_T2         = 'T2'    ; % 2
global MAP_TYPE_PD                   ; MAP_TYPE_PD         = 'PD'    ; % 3
global MAP_TYPE_ADC                  ; MAP_TYPE_ADC        = 'ADC'   ; % 4
global MAP_TYPE_ihMTR                ; MAP_TYPE_ihMTR      = 'ihMTR' ; % 5
global MAP_TYPE_MTRs                 ; MAP_TYPE_MTRs       = 'MTRs'  ; % 6
global MAP_TYPE_QSM                  ; MAP_TYPE_QSM        = 'QSM'   ; % 7
global MAP_TYPE_T2s                  ; MAP_TYPE_T2s        = 'T2s'   ; % 8
global MAP_TYPE_MTVF                 ; MAP_TYPE_MTVF       = 'MTVF'  ; % 9
global MAP_TYPE_WF                   ; MAP_TYPE_WF         = 'WF'    ; % 10
global MAP_TYPE_MTR                  ; MAP_TYPE_MTR        = 'MTR'   ; % 11
global MAP_TYPE_MTstat               ; MAP_TYPE_MTstat     = 'MTstat'; % 12
global MAP_TYPE_M0                   ; MAP_TYPE_M0         = 'M0'    ; % 13
global MAP_TYPE_B1                   ; MAP_TYPE_B1         = 'B1'    ; % 14

global MAP_TYPES                     ; MAP_TYPES           = {MAP_TYPE_T2};

global GROUP_NAME_PREFIX             ; GROUP_NAME_PREFIX   = 'group_'  ;
global SESSION_NAME_PREFIX           ; SESSION_NAME_PREFIX = 'session' ;
global SUBJECT_NAME_PREFIX           ; SUBJECT_NAME_PREFIX = 'subject' ;
global MAP_NAME_PREFIX               ; MAP_NAME_PREFIX     = 'map'     ;
global ROI_NAME_PREFIX               ; ROI_NAME_PREFIX     = 'roi'     ;
global FEATURE_NAME_PREFIX           ; FEATURE_NAME_PREFIX = 'feature_';

global EXPRg_FN                      ; EXPRg_FN            = [GROUP_NAME_PREFIX EXPERIMENT_GROUP_NAME];
global CTRLg_FN                      ; CTRLg_FN            = [GROUP_NAME_PREFIX CONTROL_GROUP_NAME];

global FS_INDEX_FN 		             ; FS_INDEX_FN         = 'FS_index';
global MEAN_FN                       ; MEAN_FN             = [FEATURE_NAME_PREFIX 'Mean'];
global SD_FN                         ; SD_FN               = [FEATURE_NAME_PREFIX 'SD'];
global CV_FN                         ; CV_FN               = [FEATURE_NAME_PREFIX 'CV'];
global MEDIAN_FN                     ; MEDIAN_FN           = [FEATURE_NAME_PREFIX 'Median'];
global PRCTL_90_FN                   ; PRCTL_90_FN         = [FEATURE_NAME_PREFIX '90th_Percentile'];
global PRCTL_75_FN                   ; PRCTL_75_FN         = [FEATURE_NAME_PREFIX '75th_Percentile'];
global PRCTL_25_FN                   ; PRCTL_25_FN         = [FEATURE_NAME_PREFIX '25th_Percentile'];
global PRCTL_10_FN                   ; PRCTL_10_FN         = [FEATURE_NAME_PREFIX '190th_Percentile'];
global SKEWNESS_FN                   ; SKEWNESS_FN         = [FEATURE_NAME_PREFIX 'Skewness'];
global KURTOSIS_FN                   ; KURTOSIS_FN         = [FEATURE_NAME_PREFIX 'Kurtosis'];
global VOX_NUM_FN                    ; VOX_NUM_FN          = [FEATURE_NAME_PREFIX 'Voxel_Count'];


% global FEATURE_MEAN                ; FEATURE_MEAN        = 1;
% global FEATURE_SD                  ; FEATURE_SD          = 2;
% global FEATURE_CV                  ; FEATURE_CV          = 3;
% global FEATURE_MEDIAN              ; FEATURE_MEDIAN      = 4;
% global FEATURE_PRCTL90             ; FEATURE_PRCTL90     = 5;
% global FEATURE_PRCTL75             ; FEATURE_PRCTL75     = 6;
% global FEATURE_PRCTL25             ; FEATURE_PRCTL25     = 7;
% global FEATURE_PRCTL10             ; FEATURE_PRCTL10     = 8;
% global FEATURE_SKEWNESS            ; FEATURE_SKEWNESS    = 9;
% global FEATURE_KURTOSIS            ; FEATURE_KURTOSIS    = 10;

% Commented because I decided to use a different technique to create a unique index for each combined ROI:
% global COMBINED_ROI_FIRST_IDX;  COMBINED_ROI_FIRST_IDX = 15000; % Make sure that this number is higher than Freesurfer's maximal segment number (FS numbers ROIs from 1 to ~4000)

% global NUM_STAT_FEATURES;         NUM_STAT_FEATURES = 10;   % number of statistical parameters wanted. If you want to change the parameters that are extracted, change stats arr to the functions you fancy
% min_voxel_in_ROI             = 30;   % minimum number of voxels allowed for an ROI - to use this, define your threshold and uncomment this section in extract_qMRI_features_for_all_ROIs


