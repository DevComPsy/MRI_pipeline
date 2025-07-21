function mr = run_MRI(ID)
% Check if SPM is already open
% spmFigure = findall(0, 'Tag', 'SPMfigure');
% 
% if isempty(spmFigure)
%     spm('fmri'); % Start SPM only if it's not already open
% end


global param


mr = mri(ID);
mr.save;
if param.dopreproc ==1
    mr = mri_prepare_epis(mr);
    mr.save;
    mr = mri_preproc_epi(mr);
    mr.save;
end
if param.MPM ==1
    mr = mri_get_MPM_dirs(mr);
    mr.save;
    mr = mri_run_MPM(mr);

end
if param.physio ==1
    mr = mri_get_physio_regressors(mr);
    mr.save;
end
if param.indLev ==1
    mr = mri_get_BEH_onsets(mr);
    mr.save;
    mr = EL_1stL_01(mr);
    mr.save;
end
if param.avgbrain ==1
    mr = mri_create_average_brain(mr);
end

