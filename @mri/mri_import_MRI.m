function mri = mri_import_MRI(mri)

try
    addpath(mri.settings.dir_importTB)
catch
    mri = alert('could not add path to "import archive" toolbox.',mri);
end
try
    addpath(mri.settings.dir_spm)
catch
    mri = alert('could not add path to "SPM" toolbox.',mri);
end

spm fmri

list1 = dir([mri.mri_dir '*_FIL']);
list = dir([mri.mri_dir list1.name '\*.tar']);
for d = 1:length(list); arch{d} = [mri.mri_dir list1.name '\' list(d).name]; end

Import_Archive(arch,[mri.mri_dir 'nii\']);

mri = mri_set_history(mri,'import MRI data');