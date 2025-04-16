function mri = mri_run_MPM(mri)

fprintf('Aggregate MPM data.\n')

try
    addpath(mri.settings.dir_hmri)
catch
    mri = alert('could not add path to "hMRI" toolbox.',mri);
end

mri = mri_get_MPM_dirs(mri);


%% get the files
dirs = mri.mpm.dirs;

% MT RF
n1 = dir([dirs.MT{1} '\*.nii']); n2 = dir([dirs.MT{2} '\*.nii']);
mri.mpm.files.MT_RF = {[dirs.MT{1} n1.name ',1'] [dirs.MT{2} n2.name ',1']};

% T1 RF
n1 = dir([dirs.T1{1} '\*.nii']); n2 = dir([dirs.T1{2} '\*.nii']);
mri.mpm.files.T1_RF = {[dirs.T1{1} n1.name ',1'] [dirs.T1{2} n2.name ',1']};

% PD RF
n1 = dir([dirs.PD{1} '\*.nii']); n2 = dir([dirs.PD{2} '\*.nii']);
mri.mpm.files.PD_RF = {[dirs.PD{1} n1.name ',1'] [dirs.PD{2} n2.name ',1']};

% B1
tmp = dir([dirs.B1{1} '*']);
fl = []; fls = find(~[tmp.isdir]); for f = 1:length(fls); fl{f} = [dirs.B1{:} tmp(fls(f)).name ',1']; end
mri.mpm.files.b1 = fl;
if length(mri.mpm.files.b1) ~= 2
    error(['There must be 2 B1 images, not ' int2str(length(mri.mpm.files.b1)) '.'])
end

% MT
tmp = dir([dirs.MT{3} '*']);
fl = []; fls = find(~[tmp.isdir]); for f = 1:length(fls); fl{f} = [dirs.MT{3} tmp(fls(f)).name ',1']; end
mri.mpm.files.MT = fl;
if length(mri.mpm.files.MT) ~= 6
    error(['There must be 6 MT images, not ' int2str(length(mri.mpm.files.MT)) '.'])
end

% T1
tmp = dir([dirs.T1{3} '*']);
fl = []; fls = find(~[tmp.isdir]); for f = 1:length(fls); fl{f} = [dirs.T1{3} tmp(fls(f)).name ',1']; end
mri.mpm.files.T1 = fl;
if length(mri.mpm.files.T1) ~= 8
    error(['There must be 8 MT images, not ' int2str(length(mri.mpm.files.T1)) '.'])
end

% PD
tmp = dir([dirs.PD{3} '*']);
fl = []; fls = find(~[tmp.isdir]); for f = 1:length(fls); fl{f} = [dirs.PD{3} tmp(fls(f)).name ',1']; end
mri.mpm.files.PD = fl;
if length(mri.mpm.files.PD) ~= 8
    error(['There must be 8 PD images, not ' int2str(length(mri.mpm.files.PD)) '.'])
end

%% spm batch script for conversion
spm('defaults', 'fmri')
spm_jobman('initcfg')

clear matlabbatch
mkdir([mri.mri_dir 'MPM\'])
matlabbatch{1}.spm.tools.hmri.create_mpm.subj.output.outdir = {[mri.mri_dir 'MPM\']};
matlabbatch{1}.spm.tools.hmri.create_mpm.subj.sensitivity.RF_per_contrast.raw_sens_MT = cellstr(mri.mpm.files.MT_RF(:));
matlabbatch{1}.spm.tools.hmri.create_mpm.subj.sensitivity.RF_per_contrast.raw_sens_PD = cellstr(mri.mpm.files.PD_RF(:));
matlabbatch{1}.spm.tools.hmri.create_mpm.subj.sensitivity.RF_per_contrast.raw_sens_T1 = cellstr(mri.mpm.files.T1_RF(:));
matlabbatch{1}.spm.tools.hmri.create_mpm.subj.b1_type.pre_processed_B1.b1input = cellstr(mri.mpm.files.b1(:));
matlabbatch{1}.spm.tools.hmri.create_mpm.subj.b1_type.pre_processed_B1.scafac = 0.1;
matlabbatch{1}.spm.tools.hmri.create_mpm.subj.raw_mpm.MT = cellstr(mri.mpm.files.MT(:));
matlabbatch{1}.spm.tools.hmri.create_mpm.subj.raw_mpm.PD = cellstr(mri.mpm.files.PD(:));
matlabbatch{1}.spm.tools.hmri.create_mpm.subj.raw_mpm.T1 = cellstr(mri.mpm.files.T1(:));
matlabbatch{1}.spm.tools.hmri.create_mpm.subj.popup = false;
spm_jobman('run',matlabbatch(1))

%% spm batch script for segmentation and normalization
spm('defaults', 'fmri')
spm_jobman('initcfg')

% get out files
mri.mpm.res_dir = [mri.mri_dir 'MPM\Results\'];
tmp_list = dir([mri.mpm.res_dir '*.nii']);
mri.mpm.files.res_files = {tmp_list(:).name};
tmp_list = dir([mri.mpm.res_dir '*MTsat.nii']);


clear matlabbatch
% segment
matlabbatch{1}.spm.spatial.preproc.channel.vols = {[mri.mpm.res_dir tmp_list(1).name ',1']};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 1; % 1 needed for MPM - use .001 for default regularisation
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'D:\TOOLS\spm\tpm\TPM.nii,1'};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'D:\TOOLS\spm\tpm\TPM.nii,2'};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'D:\TOOLS\spm\tpm\TPM.nii,3'};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'D:\TOOLS\spm\tpm\TPM.nii,4'};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'D:\TOOLS\spm\tpm\TPM.nii,5'};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'D:\TOOLS\spm\tpm\TPM.nii,6'};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];

% normalize MT using deformation
matlabbatch{2}.spm.spatial.normalise.write.subj.def = {[mri.mpm.res_dir 'y_' tmp_list(1).name]};
matlabbatch{2}.spm.spatial.normalise.write.subj.resample = {[mri.mpm.res_dir tmp_list(1).name ',1']};
matlabbatch{2}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{2}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = 4;

for i = 1:length(matlabbatch)
    spm_jobman('run',matlabbatch(i));
end

mri.mpm.norm_MT = [mri.mpm.res_dir 'w' tmp_list(1).name];
mri.mpm.deform = [mri.mpm.res_dir 'y_' tmp_list(1).name];
tmp = dir([mri.mpm.res_dir '\Supplementary\*MTw*.nii']);
mri.mpm.MT_preproc = [mri.mpm.res_dir '\Supplementary\' tmp.name];
tmp = dir([mri.mpm.res_dir 'sM*_MTsat.nii']);
mri.mpm.MTsat_preproc = [mri.mpm.res_dir tmp.name];

%%
mri = mri_set_history(mri,'aggregate, segment & normalise MPM data');
