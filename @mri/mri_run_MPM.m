function mri = mri_run_MPM(mri)

fprintf('Aggregate MPM data.\n')

try
    addpath(mri.settings.dir_hmri)
catch
    mri = alert('could not add path to "hMRI" toolbox.',mri);
end


%% get the files
dirs = mri.mpm.dirs;


%% spm batch script for conversion


clear matlabbatch
mkdir([mri.ana_dir 'MPM\'])
mpm_output = [mri.ana_dir 'MPM\'];
    clear matlabbatch
    %Do the job
    matlabbatch{1}.spm.tools.hmri.hmri_config.hmri_setdef.customised = {'C:\Users\Kenza Kedri\Documents\GitHub\MRI\hMR_toolbox_VTASN\hmri_CBS_3TP_defaults.m'};
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.output.outdir = cellstr([mpm_output,'\']);
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.sensitivity.RF_once = cellstr(dirs.smaps)';
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.b1_type.i3D_AFI.b1input = cellstr(dirs.b0)';
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.b1_type.i3D_AFI.b1parameters.b1defaults = {'C:\Users\Kenza Kedri\Documents\GitHub\MRI\hMR_toolbox_VTASN\hmri_b1_CBS_3T_AFI3_60_defaults.m'};
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.raw_mpm.MT = cellstr(dirs.MT{1})';
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.raw_mpm.PD = cellstr(dirs.PD{1})';
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.raw_mpm.T1 = cellstr(dirs.T1{1})';
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.popup = false;

  for m = 1:length(matlabbatch)
    spm_jobman('run',matlabbatch(m));
   end

% %% spm batch script for segmentation and normalization
% spm('defaults', 'fmri')
% spm_jobman('initcfg')
% 
% % get out files
mri.mpm.res_dir = [mri.ana_dir 'MPM\Results\'];
tmp_list = dir([mri.mpm.res_dir '*.nii']);
mri.mpm.files.res_files = {tmp_list(:).name};
tmp_list = dir([mri.mpm.res_dir '*MTsat.nii']);

% 
% clear matlabbatch
% % segment
% matlabbatch{1}.spm.spatial.preproc.channel.vols = {[mri.mpm.res_dir tmp_list(1).name ',1']};
% matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 1; % 1 needed for MPM - use .001 for default regularisation
% matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
% matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];
% matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'D:\TOOLS\spm\tpm\TPM.nii,1'};
% matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
% matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1];
% matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [1 0];
% matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'D:\TOOLS\spm\tpm\TPM.nii,2'};
% matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
% matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1];
% matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [1 0];
% matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'D:\TOOLS\spm\tpm\TPM.nii,3'};
% matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
% matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 1];
% matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [1 0];
% matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'D:\TOOLS\spm\tpm\TPM.nii,4'};
% matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
% matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 1];
% matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
% matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'D:\TOOLS\spm\tpm\TPM.nii,5'};
% matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
% matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 1];
% matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
% matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'D:\TOOLS\spm\tpm\TPM.nii,6'};
% matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
% matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
% matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
% matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
% matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
% matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
% matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
% matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
% matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
% matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];
% 
% % normalize MT using deformation
% matlabbatch{2}.spm.spatial.normalise.write.subj.def = {[mri.mpm.res_dir 'y_' tmp_list(1).name]};
% matlabbatch{2}.spm.spatial.normalise.write.subj.resample = {[mri.mpm.res_dir tmp_list(1).name ',1']};
% matlabbatch{2}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
%                                                           78 76 85];
% matlabbatch{2}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
% matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = 4;
% 
% for i = 1:length(matlabbatch)
%     spm_jobman('run',matlabbatch(i));
% end

mri.mpm.norm_MT = [mri.mpm.res_dir 'w' tmp_list(1).name];
mri.mpm.deform = [mri.mpm.res_dir 'y_' tmp_list(1).name];
tmp = dir([mri.mpm.res_dir '\Supplementary\*MTw*.nii']);
% Exclude files with 'error' in their name
tmp = tmp(~contains({tmp.name}, 'error'));
mri.mpm.MT_preproc = [mri.mpm.res_dir '\Supplementary\' tmp.name];
tmp = dir([mri.mpm.res_dir 'sM*_MTsat.nii']);
mri.mpm.MTsat_preproc = [mri.mpm.res_dir tmp.name];

%%
mri = mri_set_history(mri,'aggregate MPM data');

% mri = mri_set_history(mri,'aggregate, segment & normalise MPM data');
