function mri = mri_create_average_brain(mri)
% Coregister T1 with deformation field

%Temporary T1
T1_temp = dir([mri.res_dir  'sub-' num2str(mri.ID) '\anat\sub*T1w.nii']);
T1 = {[T1_temp.folder,'/',T1_temp.name]};

% T1 = mri.ana_dir;
tmp = dir([mri.res_dir  'sub-' num2str(mri.ID) '\anat\y*']);
deformation_field = [mri.res_dir  'sub-' num2str(mri.ID) '\anat\' tmp.name];


% normalize epis using deformation fields
% tmp = dir([mri.fun_dir 'u*']); 
% 
matlabbatch{1}.spm.util.defs.comp{1}.def = {deformation_field};
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = T1;
matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
spm_jobman('run',matlabbatch(1));


end
