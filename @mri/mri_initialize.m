function mri = mri_initialize(mri)
global param
mri.nblocks = 4;
mri.ndummies = 6;
mri.fun_dir = [param.mri_path 'sub-' num2str(mri.ID) '\func\'];
mri.ana_dir = [param.mri_path 'sub-' num2str(mri.ID) '\anat\'];
mri.beh_dir = [param.mri_path 'sub-' num2str(mri.ID) '\beh\'];
mri.physio_dir = [param.mri_path 'sub-' num2str(mri.ID) '\physio\'];
mri.fmap_dir = [param.mri_path 'sub-' num2str(mri.ID) '\fmap\'];
mri.res_dir = 'D:\InformationGatheringMRI\derivatives\';
mri.data_dir = [mri.res_dir 'sub-' num2str(mri.ID) '\'];  % where mri object is stored
mri.epi_params.TR = 1.5;    % seconds
mri.epi_params.TRperSlice = 70; % ms
mri.epi_params.nSlicesPerTR = (mri.epi_params.TR*1000)/mri.epi_params.TRperSlice;
mri.epi_params.FWHM = 4.8;    % smoothing in mm
mri.epi_params.orth = 0;    % orthogonalisation for GLM
mri.settings.dir_spm = '~\Documents\MATLAB\spm12\';
mri.settings.dir_hmri = '~\Documents\MATLAB\hMRI-toolbox-0.6.0\hMRI-toolbox-0.6.0';
mri.settings.dir_physio = '~\Documents\MATLAB\tapas\tapas-master';
mri.history = {'initialized'};
mri.warnings = {};
mri.verbose = 1;
end