function run_dartel(list, param)

spm('defaults', 'fmri')
spm_jobman('initcfg')

dartel_dir = fullfile(param.mri_path, 'derivatives', 'dartel');
if ~exist(dartel_dir, 'dir'); mkdir(dartel_dir); end

dartel_template = fullfile(dartel_dir, 'Template_6.nii');

%% Step 1 — Segmentation (for Dartel: native + Dartel imported tissue classes)
if param.dartel.segm
    fprintf('Running Dartel segmentation...\n')
    for i = 1:length(list)
        ID = list(i).name(5:end);
        if ismember(str2double(ID), param.exclude)
            fprintf('Sub-%s: excluded, skipping.\n', ID); continue
        end
        try
            anat_file = get_anat(list(i));

            clearvars matlabbatch
            matlabbatch{1}.spm.spatial.preproc.channel.vols     = {anat_file};
            matlabbatch{1}.spm.spatial.preproc.channel.biasreg  = 1;
            matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
            matlabbatch{1}.spm.spatial.preproc.channel.write    = [1 1];
            for t = 1:6
                matlabbatch{1}.spm.spatial.preproc.tissue(t).tpm = ...
                    {sprintf('C:\\Users\\Kenza Kedri\\Documents\\MATLAB\\spm12\\tpm\\TPM.nii,%d', t)};
                matlabbatch{1}.spm.spatial.preproc.tissue(t).ngaus  = [1 1 2 3 4 2];
                matlabbatch{1}.spm.spatial.preproc.tissue(t).native = [1 1]; % native + Dartel
                matlabbatch{1}.spm.spatial.preproc.tissue(t).warped = [t<=3, 0];
            end
            matlabbatch{1}.spm.spatial.preproc.warp.mrf    = 1;
            matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
            matlabbatch{1}.spm.spatial.preproc.warp.reg    = [0 0.001 0.5 0.05 0.2];
            matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
            matlabbatch{1}.spm.spatial.preproc.warp.fwhm   = 0;
            matlabbatch{1}.spm.spatial.preproc.warp.samp   = 3;
            matlabbatch{1}.spm.spatial.preproc.warp.write  = [1 1];
            spm_jobman('run', matlabbatch);
            fprintf('Sub-%s: segmentation done.\n', ID)
        catch ME
            warning('Sub-%s: segmentation failed — %s', ID, ME.message)
        end
    end
    fprintf('Segmentation done.\n')
end

%% Step 2 — Create Dartel template
if param.dartel.template
    fprintf('Creating Dartel template...\n')
    rc1dir = {}; rc2dir = {};

    for i = 1:length(list)
        ID = list(i).name(5:end);
        if ismember(str2double(ID), param.exclude)
            fprintf('Sub-%s: excluded, skipping.\n', ID); continue
        end
        try
            anat_file    = get_anat(list(i));
            [anat_folder, ~, ~] = fileparts(anat_file);
            rc1 = dir(fullfile(anat_folder, 'rc1*'));
            rc2 = dir(fullfile(anat_folder, 'rc2*'));
            if isempty(rc1) || isempty(rc2)
                warning('Sub-%s: rc1/rc2 not found, skipping.', ID); continue
            end
            rc1dir{end+1} = fullfile(rc1.folder, rc1.name);
            rc2dir{end+1} = fullfile(rc2.folder, rc2.name);
        catch ME
            warning('Sub-%s: could not get tissue classes — %s', ID, ME.message)
        end
    end

    if length(rc1dir) < 2
        error('Not enough subjects for template creation.')
    end

    clearvars matlabbatch
    matlabbatch{1}.spm.tools.dartel.warp.images = [{rc1dir'} {rc2dir'}];
    matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
    matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its    = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K      = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam   = 16;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its    = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K      = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam   = 8;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its    = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K      = 1;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam   = 4;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its    = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K      = 2;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam   = 2;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its    = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K      = 4;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam   = 1;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its    = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K      = 6;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam   = 0.5;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc   = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its   = 3;
    spm_jobman('run', matlabbatch);

    % Move template to dartel_dir
    anat_file       = get_anat(list(1));
    [anat_folder,~,~] = fileparts(anat_file);
    tmp = dir(fullfile(anat_folder, 'Template_6.nii'));
    if ~isempty(tmp)
        movefile(fullfile(tmp.folder, tmp.name), dartel_dir);
        fprintf('Template moved to %s\n', dartel_dir)
    else
        warning('Template_6.nii not found — may need to move manually.')
    end
    fprintf('Template creation done.\n')
end

%% Step 3 — Normalise structural to MNI
if param.dartel.norm_struct
    fprintf('Normalising structural images...\n')
    if ~exist(dartel_template, 'file')
        error('Dartel template not found at %s', dartel_template)
    end

    flowfields = {}; anat_files = {};
    for i = 1:length(list)
        ID = list(i).name(5:end);
        if ismember(str2double(ID), param.exclude)
            fprintf('Sub-%s: excluded, skipping.\n', ID); continue
        end
        try
            anat_file = get_anat(list(i));
            [anat_folder,~,~] = fileparts(anat_file);
            ff = dir(fullfile(anat_folder, 'u_rc1*'));
            if isempty(ff)
                warning('Sub-%s: flow field not found, skipping.', ID); continue
            end
            flowfields{end+1} = fullfile(ff.folder, ff.name);
            anat_files{end+1} = anat_file;
        catch ME
            warning('Sub-%s: failed — %s', ID, ME.message)
        end
    end

    clearvars matlabbatch
    matlabbatch{1}.spm.tools.dartel.mni_norm.template                    = {dartel_template};
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields       = flowfields';
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images           = {anat_files'};
    matlabbatch{1}.spm.tools.dartel.mni_norm.vox                         = [NaN NaN NaN];
    matlabbatch{1}.spm.tools.dartel.mni_norm.bb                          = [NaN NaN NaN; NaN NaN NaN];
    matlabbatch{1}.spm.tools.dartel.mni_norm.preserve                    = 0;
    matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm                        = [0 0 0];
    spm_jobman('run', matlabbatch);
    fprintf('Structural normalisation done.\n')
end

%% Step 4 — Average brain
if param.dartel.avg_brain
    fprintf('Computing average brain...\n')
    anat_norm = {};

    for i = 1:length(list)
        ID = list(i).name(5:end);
        if ismember(str2double(ID), param.exclude)
            fprintf('Sub-%s: excluded, skipping.\n', ID); continue
        end
        try
            anat_file = get_anat(list(i));
            [anat_folder,~,~] = fileparts(anat_file);
            [~, anat_name, anat_ext] = fileparts(anat_file);
            w_file = dir(fullfile(anat_folder, ['w' anat_name anat_ext]));
            if isempty(w_file)
                warning('Sub-%s: normalised structural not found, skipping.', ID); continue
            end
            anat_norm{end+1} = fullfile(w_file.folder, w_file.name);
        catch ME
            warning('Sub-%s: failed — %s', ID, ME.message)
        end
    end

    if isempty(anat_norm)
        error('No normalised structural images found.')
    end

    nSub      = length(anat_norm);
    exprParts = arrayfun(@(i) sprintf('i%d', i), 1:nSub, 'UniformOutput', false);
    expr      = ['(' strjoin(exprParts, '+') ') / ' num2str(nSub)];

    clearvars matlabbatch
    matlabbatch{1}.spm.util.imcalc.input             = anat_norm';
    matlabbatch{1}.spm.util.imcalc.output            = 'avg_brain.nii';
    matlabbatch{1}.spm.util.imcalc.outdir            = {dartel_dir};
    matlabbatch{1}.spm.util.imcalc.expression        = expr;
    matlabbatch{1}.spm.util.imcalc.options.dmtx      = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask       = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp    = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype     = 16;
    spm_jobman('run', matlabbatch);
    fprintf('Average brain saved to %s\n', dartel_dir)
end

%% Step 5 — Normalise EPIs
if param.dartel.norm_epi
    fprintf('Normalising EPIs...\n')
    if ~exist(dartel_template, 'file')
        error('Dartel template not found at %s', dartel_template)
    end

    flowfields = {}; epi_files = {};
    for i = 1:length(list)
        ID = list(i).name(5:end);
        if ismember(str2double(ID), param.exclude)
            fprintf('Sub-%s: excluded, skipping.\n', ID); continue
        end
        try
            data_dir = fullfile(param.mri_path, 'derivatives', ['sub-' ID]);
            load(fullfile(data_dir, [ID '.mat']), 'mri');

            % Flow field from Dartel segmentation
            anat_file = get_anat(list(i));
            [anat_folder,~,~] = fileparts(anat_file);
            ff = dir(fullfile(anat_folder, 'u_rc1*'));
            if isempty(ff)
                warning('Sub-%s: flow field not found, skipping.', ID); continue
            end
            flowfields{end+1} = fullfile(ff.folder, ff.name);

            % wu* EPIs from func dir (unwarped, not yet normalised)
            epi_sub = {};
            for b = 1:mri.nblocks
                wu = dir(fullfile(mri.res_dir, ['sub-' ID], 'func', ...
                    sprintf('usub-%s_run-%d*bold.nii', ID, b)));
                if isempty(wu)
                    warning('Sub-%s block %d: wu EPI not found.', ID, b); continue
                end
                epi_sub{end+1} = fullfile(wu.folder, wu.name);
            end
            epi_files{end+1} = epi_sub';

        catch ME
            warning('Sub-%s: failed — %s', ID, ME.message)
        end
    end

    % Output dir per subject
    for i = 1:length(flowfields)
        out_dir = fullfile(dartel_dir, ['sub-' list(i).name(5:end)], 'func');
        if ~exist(out_dir, 'dir'); mkdir(out_dir); end
    end

    clearvars matlabbatch
    matlabbatch{1}.spm.tools.dartel.mni_norm.template              = {dartel_template};
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = flowfields';
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images     = epi_files';
    matlabbatch{1}.spm.tools.dartel.mni_norm.vox                   = [NaN NaN NaN];
    matlabbatch{1}.spm.tools.dartel.mni_norm.bb                    = [NaN NaN NaN; NaN NaN NaN];
    matlabbatch{1}.spm.tools.dartel.mni_norm.preserve              = 0;
    matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm                  = [2 2 2];
    spm_jobman('run', matlabbatch);
    fprintf('EPI normalisation done.\n')
end

end

%% Helper: find anatomical image (MTw preferred, fallback to T1)
function anat_file = get_anat(sub_entry)
    % Try MTw first
    tmp = dir(fullfile(sub_entry.folder, sub_entry.name, ...
        'anat', 'MPM', 'Results', 'Supplementary', 'sub*MTw.nii'));
    if ~isempty(tmp)
        anat_file = fullfile(tmp.folder, tmp.name);
        return
    end
    % Fallback to T1
    tmp = dir(fullfile(sub_entry.folder, sub_entry.name, 'anat', 'sub*T1w.nii'));
    if ~isempty(tmp)
        anat_file = fullfile(tmp.folder, tmp.name);
        return
    end
    error('No anatomical image found for %s', sub_entry.name)
end