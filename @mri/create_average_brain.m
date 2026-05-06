function create_average_brain(list, param)

%% Warp each subject's T1 to MNI and collect paths
T1_warped = {};

for i = 1:length(list)
    ID = list(i).name(5:end);

    % Skip excluded subjects by ID
    if ismember(str2double(ID), param.exclude)
        fprintf('Sub-%s: excluded, skipping.\n', ID);
        continue
    end

    try
        % Load subject mri object
        data_dir = [param.mri_path 'derivatives\sub-' ID '\'];
        load([data_dir ID '.mat'], 'mri');

        %-- Find deformation field --%
        y_file = dir(fullfile(mri.res_dir, ['sub-' ID], 'anat', 'y*'));
        if isempty(y_file)
            warning('Sub-%s: no deformation field found, skipping.', ID);
            continue
        end
        deformation_field = fullfile(y_file.folder, y_file.name);

        %-- Find T1 --%
        T1_temp = dir(fullfile(mri.res_dir, ['sub-' ID], 'anat', 'sub*T1w.nii'));
        if isempty(T1_temp)
            warning('Sub-%s: no T1 found, skipping.', ID);
            continue
        end
        T1 = {fullfile(T1_temp.folder, T1_temp.name)};

        %-- Apply deformation field --%
        clearvars matlabbatch
        matlabbatch{1}.spm.util.defs.comp{1}.def        = {deformation_field};
        matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = T1;
        matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
        matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
        matlabbatch{1}.spm.util.defs.out{1}.pull.mask   = 1;
        matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm   = [0 0 0];
        spm_jobman('run', matlabbatch(1));

        %-- Find warped T1 --%
        wT1_temp = dir(fullfile(T1_temp.folder, 'wsub*T1w.nii'));
        if isempty(wT1_temp)
            warning('Sub-%s: warped T1 not found after normalisation, skipping.', ID);
            continue
        end
        T1_warped{end+1} = fullfile(wT1_temp.folder, wT1_temp.name);
        fprintf('Sub-%s: warped T1 added.\n', ID);

    catch ME
        warning('Sub-%s: warping failed — %s', ID, ME.message);
    end
end

%% Check we have something to average
if isempty(T1_warped)
    error('No warped T1s available for averaging.')
end

fprintf('\n%d subjects included in average.\n', length(T1_warped));

%% Average across subjects
nT1       = length(T1_warped);
exprParts = arrayfun(@(i) sprintf('i%d', i), 1:nT1, 'UniformOutput', false);
expr      = ['(' strjoin(exprParts, '+') ') / ' num2str(nT1)];

clearvars matlabbatch
matlabbatch{1}.spm.util.imcalc.input       = T1_warped';
matlabbatch{1}.spm.util.imcalc.output      = 'avg_T1.nii';
matlabbatch{1}.spm.util.imcalc.outdir      = {param.mri_path};
matlabbatch{1}.spm.util.imcalc.expression  = expr;
matlabbatch{1}.spm.util.imcalc.options.dmtx   = 0;
matlabbatch{1}.spm.util.imcalc.options.mask   = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype  = 16;
spm_jobman('run', matlabbatch(1));

fprintf('Average brain saved to %s\n', param.mri_path);
end