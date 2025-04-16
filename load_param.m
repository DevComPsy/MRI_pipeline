function param = load_param()
%----------------------------------------------------------------------
%                  Parameters
%----------------------------------------------------------------------

param.MPM = 0;                  param.dopreproc   = 1;
param.indLev=1;                 param.physio      = 0;
param.dartel = 0;               param.segm_dartel = 0;
param.createtemplate = 1;       param.dartelnorm  = 0;
param.avgbrain = 0;             param.dartelnormEPI = 0;
param.groupLevel = 1;           param.exclude     = []; %1 is pilot
param.mri_path = 'D:\InformationGatheringMRI\sourcedata\';

% ROI_choice = 'VSI_both';
% % Used to regress out nuisance regressors and extract clean bold timeseries
% % from the appropriate ROI
% switch ROI_choice
%     case 'VTA'
%         ROI = 'D:\data\NaDaEL_MRI/VTASNAvgKK.nii';
%         name_ROI = 'VTA';
%         foldername = '\Connectivity\';
%         regress_name = 'allreg.txt'; %Need to update the value
% 
%     case 'NaCC'
%         ROI = 'D:\data\NaDaEL_MRI/NaCC_kk.nii';
%         foldername = '\Connectivity_striatum\';
%         name_ROI = 'NaCC';
%         regress_name = 'allreg_striatum.txt';
%     case 'VSI_Left'
%         ROI = 'D:\data\atlases/VSI_left.nii';
%         foldername = '\VSI_Left\';
%         name_ROI = 'VSI_left';
%         regress_name = 'allreg_VSI_left.txt';
%     case 'VSI_Right'
%         ROI = 'D:\data\atlases/VSi_R.nii';
%         foldername = '\VSI_Right\';
%         name_ROI = 'VSI_Right';
%         regress_name = 'allreg_VSI_Right.txt';
%     case 'VSI_both'
%         ROI = 'D:\data\atlases/VSI_both.nii';
%         foldername = '\VSI\';
%         name_ROI = 'VSI_both';
%         regress_name = 'allreg_VSI_both.txt';
% end
end