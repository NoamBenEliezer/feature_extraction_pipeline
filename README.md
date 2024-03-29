# feature_extraction_pipeline
MATLAB pipeline for feature extraction from quantitative MRI (qMRI) maps using FreeSurfer segmentation masks.

Instructions for user input:
The feature extraction requires the user to input the following:
1.	Path to the root folder containing the data from all scan sessions and subjects. 
2.	Path to the segmentation matrix of all sessions and subjects.
3.	Names of the project, scan session folders, results folder name and results filename. 
4.	Subject folder name prefix (for example if ‘V’ for volunteer precedes volunteer number).
5.	qMRI value to ignore – for example 0 if that is the value of the background of the qMRI map, but it should not be 0 if 0 is a valid number that can appear in the qMRI map.
6.	Chauvenet flag – Chauvenet criterion is the number of SDs from the mean that values above or below will be removed.
7.	Threshold for percent of deducted voxels – Percent number of voxels the user allows to be deducted during erosion and Chauvenet. Any deviation will be noted and saved in a separate variable for the user to visually inspect.
8.	Erosion option – choose between MATLAB’s built in erosion function or a function for 3D erosion built for this pipeline (recommended). Also choose the number of voxels to erode and the minimum number of neighbors a voxel should have to not be removed (lower neighbor count results in a weaker erosion).
9.	If the experiment contains groups, edit “experiment_group” and “control_group” to contain the folder names of the respective subjects.
10.	Change “ROI_names” to contain the names of the user’s chosen brain regions to explore, according to the FreeSurfer lookup table.
11.	Change “ROIs_2_combine” to contain pairs of ROIs that the user wishes to combine to one ROI (for example left and right hippocampus).
Map type – choose the map type you wish to analyze out of the following: T1, T2, PD, ADC, ihMTR, MTRs, QSM, T2*, MTVF, WF, MTR, MTstat, M0, B1.

Pipeline for the feature extraction pipeline:
The user sets their global parameters in ‘qMRI_SET_GLOBALS.m” and then runs the pipeline from the main script: ‘extract_qMRI_features.m’. 
(1)	The data for the current subject is uploaded and entered into the ‘extract_qMRI_features_for_all_ROIs.m’ function to extract the statistical features from the ROIs in the given list. In this function the erosion and Chauvenet criterion are performed to clean the data. The resulting data structure is returned to the main script.
(2)	There it is inserted into the next function, ‘Consolidate_ROIs.m’ which create the combined ROIs of both hemispheres, as defined by the user.
(3)	The resulting data structure per subject is returned to the main script in which the data structures of all the subjects are combined into one data structure with the levels: session, group, subject, qMRI map, ROI, and feature. See appendix H for a visual outline of this structure.

![image](https://github.com/NoamBenEliezer/feature_extraction_pipeline/assets/105850627/e7f73c94-704b-4e52-a157-ff19ec35f12f)
