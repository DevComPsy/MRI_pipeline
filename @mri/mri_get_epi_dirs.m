function mri = mri_get_epi_dirs(mri,manual)

if nargin < 2
    manual = 0;
end
addpath(mri.settings.dir_spm)

list = dir([mri.fun_dir '*nii.gz']);
list = list(~ismember({list(:).name},{'.','..'}));

fprintf('Retrieving EPI directories.\n')
mri.epi_dirs = [];
if manual
    e_dir = 'tmp';
    while ~isempty(e_dir)
        e_dir = spm_select(1,'dir',['select ' int2str(length(mri.epi_dirs)+1) 'th EPI directory.']);
        if ~isempty(e_dir)
            mri.epi_dirs{end+1} = e_dir;
        end
    end
else
    for d = 1:length(list)
        if length(niftiinfo([mri.fun_dir list(d).name]).ImageSize) > 3 %if func image (pb with nii2bids
            if   niftiinfo([mri.fun_dir list(d).name]).ImageSize(4) > 100  % at least 100 functional scans
                mri.epi_dirs{end+1} = [mri.mri_dir list(d).name];
            end
        end
    end
end

mri = mri_set_history(mri,'get epi dirs');