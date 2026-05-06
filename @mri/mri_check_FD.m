function mri = mri_check_FD(mri)

%% Find realignment parameter files
rp_files = dir(fullfile(mri.fun_dir, 'rp*'));
[~, ind] = sort({rp_files.name});
rp_files = rp_files(ind);

if length(rp_files) ~= mri.nblocks
    mri = alert(mri, sprintf('mri_check_FD: expected %d rp files, found %d.', mri.nblocks, length(rp_files)));
    return
end

%% FD parameters
head_radius = 50; % mm
fd_threshold = 0.5; % mm

%% Process each block
for b = 1:mri.nblocks
    rp_params = load(fullfile(rp_files(b).folder, rp_files(b).name));

    % Calculate FD
    trans     = rp_params(:, 1:3);
    rot_mm    = rp_params(:, 4:6) * head_radius;
    trans_diff = [zeros(1,3); diff(trans)];
    rot_diff   = [zeros(1,3); diff(rot_mm)];
    fd         = sum(abs(trans_diff), 2) + sum(abs(rot_diff), 2);

    % Statistics
    mean_fd       = mean(fd);
    max_fd        = max(fd);
    pct95_fd      = prctile(fd, 95);
    n_exceeding   = sum(fd > fd_threshold);
    pct_exceeding = 100 * n_exceeding / length(fd);

    % Store in mri struct
    mri.physio.FD{b}.fd            = fd;
    mri.physio.FD{b}.mean          = mean_fd;
    mri.physio.FD{b}.max           = max_fd;
    mri.physio.FD{b}.pct95         = pct95_fd;
    mri.physio.FD{b}.n_exceeding   = n_exceeding;
    mri.physio.FD{b}.pct_exceeding = pct_exceeding;

    % Flag if mean FD exceeds threshold
    if mean_fd > fd_threshold
        mri = alert(mri, sprintf('Block %d: mean FD (%.3f mm) exceeds threshold (%.1f mm).', ...
            b, mean_fd, fd_threshold));
    end

    % Flag if >20% of volumes exceed threshold
    if pct_exceeding > 20
        mri = alert(mri, sprintf('Block %d: %.1f%% of volumes exceed FD threshold (%.1f mm).', ...
            b, pct_exceeding, fd_threshold));
    end

    % Plot
    if mri.verbose
        figure('Position', [100, 100, 1000, 600]);

        subplot(2,1,1);
        plot(fd, 'LineWidth', 2, 'Color', [0.1 0.4 0.7]);
        hold on;
        yline(fd_threshold, 'r--', 'LineWidth', 2,   'Label', sprintf('Threshold (%.1f mm)', fd_threshold));
        yline(mean_fd,      'g--', 'LineWidth', 1.5,  'Label', sprintf('Mean (%.3f mm)', mean_fd));
        xlabel('Volume Number');
        ylabel('FD (mm)');
        title(sprintf('Framewise Displacement - block %d', b));
        box off;

        subplot(2,1,2);
        histogram(fd, 'BinWidth', 0.01, 'FaceColor', [0.2 0.6 0.8]);
        xlabel('FD (mm)');
        ylabel('Frequency');
        title('Distribution of FD values');
        box off;

        text(0.7, 0.9, sprintf('Mean: %.3f mm\nMax: %.3f mm\n95th: %.3f mm\n>threshold: %.1f%%', ...
            mean_fd, max_fd, pct95_fd, pct_exceeding), ...
            'Units', 'normalized', 'FontSize', 10, ...
            'BackgroundColor', 'white', 'EdgeColor', 'black');

        saveas(gcf, fullfile(mri.physio_dir, sprintf('FD_block%d.svg', b)));
    end
end

mri = mri_set_history(mri, 'checked framewise displacement');
end