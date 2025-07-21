function param = load_param()
%----------------------------------------------------------------------
%                  Parameters
%----------------------------------------------------------------------

param.MPM = 0;                  param.dopreproc   = 0;
param.indLev=0;                 param.physio      = 0;
param.dartel = 0;               param.segm_dartel = 0;
param.createtemplate = 1;       param.dartelnorm  = 0;
param.avgbrain = 0;             param.dartelnormEPI = 0;
param.groupLevel = 0;           param.exclude     = [23]; %1 is pilot
param.mri_path = 'D:\InformationGatheringMRI\sourcedata\';


end