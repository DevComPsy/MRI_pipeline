function mri = mri_get_physio_regressors(mri)

try
    addpath(mri.settings.dir_physio)
catch
    mri = alert(mri, 'Could not add path to "physio" toolbox.');
    return
end

%% Set up options
nslices  = mri.epi_params.nSlicesPerTR;
TR       = mri.epi_params.TR;
ndummies = mri.ndummies;

%% Find realignment parameter files
rp_files = dir(fullfile(mri.fun_dir, 'rp*'));
[~, ind] = sort({rp_files.name});
rp_files = rp_files(ind);

if length(rp_files) ~= mri.nblocks
    mri = alert(mri, sprintf('Expected %d rp files, found %d.', mri.nblocks, length(rp_files)));
    return
end

%% Find raw physio files (exclude already-processed outputs)
physio_files = dir(mri.physio_dir);
physio_files = physio_files(~ismember({physio_files.name}, {'.','..'}));
physio_files = physio_files(~contains({physio_files.name}, ...
    {'pulse','respiration','multiple_regressors','figures'}));

if length(physio_files) < mri.nblocks
    mri = alert(mri, sprintf('Expected %d raw physio files, found %d.', mri.nblocks, length(physio_files)));
    return
end

%% Process each block
for b = 1:mri.nblocks
    try
        %-- Load physio table --%
        physio_raw = readtable(fullfile(physio_files(b).folder, physio_files(b).name));

        %-- Remove trailing NaN rows --%
        while isnan(physio_raw.Var5(end))
            physio_raw(end,:) = [];
        end

        %-- Remove restarted block (keep from last zero onset) --%
        lastZeroIdx = find(physio_raw.Var5 == 0, 1, 'last');
        if lastZeroIdx > 1
            physio_raw = physio_raw(lastZeroIdx:end,:);
        end

        %-- Remove duplicate timestamps --%
        [~, uniqueIdx] = unique(physio_raw.Var5, 'stable');
        if length(uniqueIdx) < height(physio_raw)
            physio_raw = physio_raw(uniqueIdx, :);
        end

        %-- Binarise trigger channel --%
        physio_raw.Var1(physio_raw.Var1 >  0.1) = 1;
        physio_raw.Var1(physio_raw.Var1 <= 0.1) = 0;

        %-- Find trigger onsets and strip dummies --%
        transitions    = diff(physio_raw.Var1');
        trigger_onsets = find(transitions == 1);

        if length(trigger_onsets) < ndummies + 1
            mri = alert(mri, sprintf('Block %d: only %d triggers found, cannot remove %d dummies.', ...
                b, length(trigger_onsets), ndummies));
            continue
        end

        physio_raw(1:trigger_onsets(ndummies + 1), :) = [];

        %-- Resample respiration and pulse to 100 Hz --%
        t           = physio_raw.Var5;
        respiration = physio_raw.Var2;
        pulse       = physio_raw.Var3;

        new_t         = t(1) : 1/100 : t(end);
        respiration_r = interp1(t, respiration, new_t)';
        pulse_r       = interp1(t, pulse,       new_t)';

        %-- Write resampled signals --%
        resp_file  = fullfile(mri.physio_dir, sprintf('sub-%s-block%d-respiration.txt', mri.ID, b));
        pulse_file = fullfile(mri.physio_dir, sprintf('sub-%s-block%d-pulse.txt',       mri.ID, b));

        writematrix(respiration_r, resp_file);
        writematrix(pulse_r,       pulse_file);

        %-- Get nscans from rp file --%
        rp_file_path = fullfile(rp_files(b).folder, rp_files(b).name);
        nscans       = height(readtable(rp_file_path));

        %-- Build SPM TAPAS PhysIO batch --%
        clearvars matlabbatch
        matlabbatch{1}.spm.tools.physio.save_dir                                                = {mri.physio_dir};
        matlabbatch{1}.spm.tools.physio.log_files.vendor                                        = 'Custom';
        matlabbatch{1}.spm.tools.physio.log_files.cardiac                                       = {pulse_file};
        matlabbatch{1}.spm.tools.physio.log_files.respiration                                   = {resp_file};
        matlabbatch{1}.spm.tools.physio.log_files.scan_timing                                   = {''};
        matlabbatch{1}.spm.tools.physio.log_files.sampling_interval                             = 0.01;
        matlabbatch{1}.spm.tools.physio.log_files.relative_start_acquisition                    = 0;
        matlabbatch{1}.spm.tools.physio.log_files.align_scan                                    = 'first';
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nslices                               = nslices;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat                        = [];
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.TR                                    = TR;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Ndummies                              = 0; % already stripped above
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans                                = nscans;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.onset_slice                           = 1;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice                   = [];
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nprep                                 = [];
        matlabbatch{1}.spm.tools.physio.scan_timing.sync.nominal                                = struct([]);
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.modality                                = 'PPU';
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.filter.yes.type                         = 'cheby2';
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.filter.yes.passband                     = [0.3 9];
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.filter.yes.stopband                     = [];
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min  = 0.4;
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.max_heart_rate_bpm = 90;
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off               = struct([]);
        matlabbatch{1}.spm.tools.physio.preproc.respiratory.filter.passband                     = [0.01 2];
        matlabbatch{1}.spm.tools.physio.preproc.respiratory.despike                             = false;
        matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors                        = sprintf('multiple_regressors-run%d.txt', b);
        matlabbatch{1}.spm.tools.physio.model.output_physio                                     = sprintf('multiple_regressors-run%d.mat', b);
        matlabbatch{1}.spm.tools.physio.model.orthogonalise                                     = 'none';
        matlabbatch{1}.spm.tools.physio.model.censor_unreliable_recording_intervals             = false;
        matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.c                             = 3;
        matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.r                             = 4;
        matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.cr                            = 1;
        matlabbatch{1}.spm.tools.physio.model.rvt.no                                            = struct([]);
        matlabbatch{1}.spm.tools.physio.model.hrv.no                                            = struct([]);
        matlabbatch{1}.spm.tools.physio.model.noise_rois.no                                     = struct([]);
        matlabbatch{1}.spm.tools.physio.model.movement.yes.file_realignment_parameters          = {rp_file_path};
        matlabbatch{1}.spm.tools.physio.model.movement.yes.order                                = 6;
        matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_method                     = 'FD';
        matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_threshold                  = 0.5;
        matlabbatch{1}.spm.tools.physio.model.other.no                                          = struct([]);
        matlabbatch{1}.spm.tools.physio.verbose.level                                           = 0;
        matlabbatch{1}.spm.tools.physio.verbose.fig_output_file                                 = sprintf('figures_block%d.jpg', b);
        matlabbatch{1}.spm.tools.physio.verbose.use_tabs                                        = false;

        spm_jobman('run', matlabbatch(1));

        %-- Load output and store in mri struct --%
        mul_reg_path      = fullfile(mri.physio_dir, sprintf('multiple_regressors-run%d.txt', b));
        mri.physio.mul_reg{b} = table2array(readtable(mul_reg_path));

        if mri.verbose
            figure()
            imagesc(mri.physio.mul_reg{b});
            colormap('gray')
            title(sprintf('Multiple regressors - block %d', b))
            ylabel('Scan No.')
            xlabel('Regressor No.')
        end

    catch ME
        mri = alert(mri, sprintf('Block %d failed: %s', b, ME.message));
    end
end

mri = mri_set_history(mri, 'aggregated noise parameters');
end