function mr = run_MRI(ID)
spm fmri
global param

mr = mri(ID);
% mr.save;
% mr = mri_prepare_epis(mr);
% mr.save;
% 
% mr = mri_preproc_epi(mr);
% mr.save;
mr = mri_get_physio_regressors(mr);
mr.save;
% mr = mri_get_BEH_onsets(mr);
% mr.save;
% mr = EL_1stL_01(mr);
% mr.save;

%Group level function
mr = mri_create_average_brain(mr);



