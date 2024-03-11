% This function receives the name of the qMRI map type currently being
% processed and returns the variables associated with the qMRI map name and
% segmentation file name. (Was originally in the Main analysis pipeline).

% qMRI_map_name     Name of the file containing the qMRI map values
% qMRI_map_subname  Name of field in which the qMRI map is stored in the maps variable.
% Seg_map_name      Name of the file containing the segmentation map. Number labels correspond to the Free Surfer lookup table
% map_def           
% Seg_def           

function [qMRI_map_name, Seg_map_name, map_def, Seg_def, qMRI_map_subname] = qMRI_map_variables(map_type, subj_foldername)

qMRI_map_name = 0;
Seg_map_name = 0;
map_def = 0;
Seg_def = 0;
qMRI_map_subname = 0;

switch map_type
    case 'T2'
        qMRI_map_name = ['V' subj_foldername(2:end) '_EMC_results'];
        Seg_map_name  = 'qT2_seg';
        map_def       = 'T2map_SEMC_masked';
        % Seg_def       = 'qT2_seg_rot_flip';
    case 'PD'
        qMRI_map_name = ['S' subj_foldername(2:end) '_EMC_results'];
        Seg_map_name  = 'qT2_seg';
        map_def       = 'PDmap_SEMC';
        % Seg_def       = 'qT2_seg_rot_flip';
    case 'ADC'
        qMRI_map_name = 'ADC_map';
        Seg_map_name  = 'Segments_DTI';
        map_def       = 'ADC_map';
        Seg_def       = 'Segments_DTI';
    case 'FA'
        qMRI_map_name = 'FA_map';
        Seg_map_name  = 'Segments_DTI';
        map_def       = 'FA_map';
        Seg_def       = 'Segments_DTI';
    case 'ihMTR'
        qMRI_map_name = 'ihMTR_map';
        Seg_map_name  = 'Segments_ihMT';
        map_def       = 'ihMTR_map';
        Seg_def       = 'ihMTR_seg';
    case 'MTRs'
        qMRI_map_name = 'MTRs_map';
        Seg_map_name  = 'Segments_ihMT';
        map_def       = 'MTRs_map';
        Seg_def       = 'ihMTR_seg';
    case 'QSM'
        qMRI_map_name = 'QSM_map_new';
%       Seg_map_name  = 'Segments_QSM';
        Seg_map_name  = 'Segments_T2s';
        map_def       = 'QSM_map_new';
%       Seg_def       = 'QSM_seg_new';
        Seg_def       = 'qT2s_seg_rot_flip';
    case 'T2s'
        qMRI_map_name = 'T2_star_map';
        Seg_map_name  = 'Segments_T2s';
        map_def       = 'T2s_map';
        Seg_def       = 'qT2s_seg_rot_flip';
    case 'T1'
        qMRI_map_name     = 'mrQ_maps';
        qMRI_map_subname  = 'T1';
        Seg_map_name      = 'Segments';
    case 'MTVF'
        qMRI_map_name     = 'mrQ_maps';
        qMRI_map_subname  = 'mrQ_maps.TV';
        Seg_map_name      = 'mrQ_maps.Segments';
    case 'WF'
        qMRI_map_name     = 'mrQ_maps';
        qMRI_map_subname  = 'mrQ_maps.WF';
        Seg_map_name      = 'mrQ_maps.Segments';
    case 'MTR'
        qMRI_map_name     = 'mrQ_maps';
        qMRI_map_subname  = 'mrQ_maps.MTR_DR';
        Seg_map_name      = 'mrQ_maps.Segments';
    case 'MTsat'
        qMRI_map_name     = 'mrQ_maps';
        qMRI_map_subname  = 'mrQ_maps.MTsat';
        Seg_map_name      = 'mrQ_maps.Segments';
    case 'M0'
        qMRI_map_name     = 'mrQ_maps';
        qMRI_map_subname  = 'mrQ_maps.M0';
        Seg_map_name      = 'mrQ_maps.Segments';
    case 'B1'
        qMRI_map_name     = 'mrQ_maps';
        qMRI_map_subname  = 'mrQ_maps.B1';
        Seg_map_name      = 'mrQ_maps.Segments';
end