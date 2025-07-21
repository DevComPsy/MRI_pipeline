function mri = mri_preproc_epi(mri)

fprintf('Preprocessing functional data.\n')


%% get fieldmap images

fm_phase = []; fm_magn = {};
fm_phase = dir([mri.fmap_dir '*phase*']); 
fm_magn_temp = dir([mri.fmap_dir '*magn*']);
fm_magn_temp = fm_magn_temp(arrayfun(@(f) endsWith(f.name, '.nii.gz'), fm_magn_temp));
fm_phase = fm_phase(arrayfun(@(f) endsWith(f.name, '.nii.gz'), fm_phase));

%extract files
gunzip([mri.fmap_dir fm_phase.name],[mri.res_dir  'sub-' num2str(mri.ID) '\fmap\'])



for i = 1:length(fm_magn_temp)
gunzip([mri.fmap_dir fm_magn_temp(i).name],[mri.res_dir  'sub-' num2str(mri.ID) '\fmap\'])
end

%retrieving unzip data

fm_phase = dir([mri.res_dir  'sub-' num2str(mri.ID) '\fmap\*phase*']);
fm_magn = dir([mri.res_dir  'sub-' num2str(mri.ID) '\fmap\*magnitude1*']);




if isempty(fm_magn)
    error('Could not find B0 maps for EPIs')
elseif isempty(fm_phase)
    error('Could not find the phasediff for EPIS')
end



% 
%% run jobs
spm('defaults', 'fmri')
spm_jobman('initcfg')

clear matlabbatch
% calc vdm
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = {[fm_phase.folder '\' fm_phase.name]};
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = {[fm_magn.folder '\' fm_magn.name]};
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsfile = {'C:\Users\Kenza Kedri\Documents\MATLAB\spm12\toolbox\FieldMap\pm_defaults.m'};

for i = 1:length(mri.epi_dirs_org)
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.session(i).epi = {[mri.epi_dirs_org{i}]};
end
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'sess';
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 0;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.anat = '';
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;
spm_jobman('run',matlabbatch(1)); 
% 
% % select new vdm

vdm_temp = dir([fm_phase(1).folder '\vdm*sess*']);


if length(vdm_temp) > length(mri.epi_dirs_org) %b == max number of block
    error('too much vdm5 files')
end


% % realign & unwarp
for i = 1:length(mri.epi_dirs_org)
matlabbatch{2}.spm.spatial.realignunwarp.data(i).scans = {mri.epi_dirs_org{i}};
matlabbatch{2}.spm.spatial.realignunwarp.data(i).pmscan = {[vdm_temp(i).folder '\' vdm_temp(i).name]};
end
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.sep = 4;
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.rtm = 1;
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.einterp = 2;
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.ewrap = [0 1 0];
matlabbatch{2}.spm.spatial.realignunwarp.eoptions.weight = '';
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.jm = 0;
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.sot = [];
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.rem = 1;
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.noi = 5;
matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.mask = 1;
matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.prefix = 'u'; 
spm_jobman('run',matlabbatch(2));

% We need to grab the T1 (whith distortion correction)

t1w = dir([mri.ana_dir , '*T1w.nii.gz']);
gunzip([mri.ana_dir t1w.name],[mri.res_dir  'sub-' num2str(mri.ID) '\anat\'])

tmp = dir([mri.res_dir  'sub-' num2str(mri.ID) '\anat\sub*']);
tmp = tmp(arrayfun(@(f) endsWith(f.name, '.nii'), tmp));

anat_file = [mri.res_dir  'sub-' num2str(mri.ID) '\anat\' tmp.name];

mri.ana_dir = [mri.res_dir  'sub-' num2str(mri.ID) '\anat\'];
mean_epi =[]; tmp = dir([mri.res_dir  'sub-' num2str(mri.ID) '\func\mean*']); 

if length(tmp) > 1; error('shuld have one file') ;end
mean_epi = [mri.res_dir  'sub-' num2str(mri.ID) '\func\' tmp.name]; %% should have one file 


% segmentation

matlabbatch{3}.spm.spatial.preproc.channel.vols = {anat_file};
matlabbatch{3}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{3}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{3}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = {'C:\Users\Kenza Kedri\Documents\MATLAB\spm12\tpm\TPM.nii,1'};
matlabbatch{3}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = {'C:\Users\Kenza Kedri\Documents\MATLAB\spm12\tpm\TPM.nii,2'};
matlabbatch{3}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = {'C:\Users\Kenza Kedri\Documents\MATLAB\spm12\tpm\TPM.nii,3'};
matlabbatch{3}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = {'C:\Users\Kenza Kedri\Documents\MATLAB\spm12\tpm\TPM.nii,4'};
matlabbatch{3}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{3}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = {'C:\Users\Kenza Kedri\Documents\MATLAB\spm12\tpm\TPM.nii,5'};
matlabbatch{3}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{3}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {'C:\Users\Kenza Kedri\Documents\MATLAB\spm12\tpm\TPM.nii,6'};
matlabbatch{3}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{3}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{3}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{3}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{3}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{3}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{3}.spm.spatial.preproc.warp.write = [0 1];
matlabbatch{3}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{3}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];
spm_jobman('run',matlabbatch(3)); 

tmp = dir([mri.res_dir  'sub-' num2str(mri.ID) '\func\usub*']); %% temporary
uepi = tmp(arrayfun(@(f) endsWith(f.name, '.nii'), tmp));

aligned_func= [];
for i = 1:length(uepi)
    aligned_func{i} = [mri.res_dir  'sub-' num2str(mri.ID) '\func\' uepi(i).name];
end


% coregister mmeanEPI (ref) & EPIs (others images) to mT1 and write
% try to coregister mT1 with ROI and EPI ...
matlabbatch{4}.spm.spatial.coreg.estimate.source        ={mean_epi};
matlabbatch{4}.spm.spatial.coreg.estimate.ref           ={anat_file};  % the image that move
matlabbatch{4}.spm.spatial.coreg.estimate.other= aligned_func'; %{[mri.anat_dir 'VTASN.nii'];  % ROI 
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
spm_jobman('run',matlabbatch(4));

tmp = dir([mri.res_dir  'sub-' num2str(mri.ID) '\anat\y*']);
deformation_field = [mri.res_dir  'sub-' num2str(mri.ID) '\anat\' tmp.name];


% normalize epis using deformation fields
% tmp = dir([mri.fun_dir 'u*']); 
% 
matlabbatch{5}.spm.util.defs.comp{1}.def = {deformation_field};
matlabbatch{5}.spm.util.defs.out{1}.pull.fnames = aligned_func';
matlabbatch{5}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
matlabbatch{5}.spm.util.defs.out{1}.pull.interp = 4;
matlabbatch{5}.spm.util.defs.out{1}.pull.mask = 1;
matlabbatch{5}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
spm_jobman('run',matlabbatch(5));

% % spatial smoothing of functinal image
wu_epis = [];
    tmp = dir([mri.res_dir  'sub-' num2str(mri.ID) '\func\wu*']);
    for f = 1:length(tmp)
        wu_epis{end+1} = [mri.res_dir  'sub-' num2str(mri.ID) '\func\' tmp(f).name];
    end
matlabbatch{6}.spm.spatial.smooth.data = wu_epis';
matlabbatch{6}.spm.spatial.smooth.fwhm = [mri.epi_params.FWHM mri.epi_params.FWHM mri.epi_params.FWHM];
matlabbatch{6}.spm.spatial.smooth.dtype = 0;
matlabbatch{6}.spm.spatial.smooth.im = 0;
matlabbatch{6}.spm.spatial.smooth.prefix = 's';
spm_jobman('run',matlabbatch(6));



%% save path
mri.epis= {};
tmp = dir([mri.res_dir  'sub-' num2str(mri.ID) '\func\swu*']);
for i = 1:length(tmp)
    mri.epis{i} = [mri.fun_dir tmp.name];
end


mri = mri_set_history(mri,['realign, unwarp, coregister(est and write) (' int2str(mri.epi_params.FWHM) 'mm) EPI data']);