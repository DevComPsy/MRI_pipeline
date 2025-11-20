% =========================================================================
% SIMPLIFIED EXAMPLE: Motion Analysis for Your Data
% =========================================================================
% This is a simplified version specifically for your data structure
% Use this if you only want to analyze Subject 3, Run 02
% =========================================================================

clear; close all; clc;

%% SIMPLE CONFIGURATION
% -------------------------------------------------------------------------
% Single file analysis specify the motion parameter file to evaluate the FD
rp_file = 'D:\Neuroflux\LC_MR\preprocessed\sub-9992\func\rp_sub-9992_run-04_bold.txt';
%% 
save_dir = 'D:\Neuroflux\LC_MR\preprocessed\sub-9992\func\';
% Check if file exists
if ~exist(rp_file, 'file')
    error('File not found: %s', rp_file);
end

%% LOAD DATA
% -------------------------------------------------------------------------
% Load realignment parameters
% Columns: [x(mm), y(mm), z(mm), pitch(rad), roll(rad), yaw(rad)]
rp_params = load(rp_file);

% Limit to first 100 volumes
n_vols = min(size(rp_params, 1), 100);
rp_params = rp_params(1:n_vols, :);

fprintf('Loaded %d volumes from: %s\n\n', n_vols, rp_file);

%% CALCULATE FD
% -------------------------------------------------------------------------
head_radius = 50; % mm

% Extract parameters
trans = rp_params(:, 1:3);     % Translation (mm)
rot_rad = rp_params(:, 4:6);   % Rotation (rad)

% Convert rotation to mm
rot_mm = rot_rad * head_radius;

% Calculate differences between consecutive volumes
trans_diff = [zeros(1, 3); diff(trans)];
rot_diff = [zeros(1, 3); diff(rot_mm)];

% FD = sum of absolute differences
fd = sum(abs(trans_diff), 2) + sum(abs(rot_diff), 2);

%% STATISTICS
% -------------------------------------------------------------------------
mean_fd = mean(fd);
max_fd = max(fd);
percentile_95 = prctile(fd, 95);

fprintf('=== MOTION STATISTICS ===\n');
fprintf('Mean FD:          %.4f mm\n', mean_fd);
fprintf('Max FD:           %.4f mm\n', max_fd);
fprintf('95th Percentile:  %.4f mm\n', percentile_95);
fprintf('=========================\n\n');

%% VISUALIZATION
% -------------------------------------------------------------------------
figure('Position', [100, 100, 1000, 600]);

% Plot 1: FD time series
subplot(2, 1, 1);
plot(fd, 'LineWidth', 2, 'Color', [0.1 0.4 0.7]);
hold on;
yline(0.5, 'r--', 'LineWidth', 2, 'Label', 'QC Threshold (0.5mm)');
yline(mean_fd, 'g--', 'LineWidth', 1.5, 'Label', sprintf('Mean (%.3f mm)', mean_fd));
xlabel('Volume Number', 'FontSize', 12);
ylabel('FD (mm)', 'FontSize', 12);
title('Framewise Displacement Time Series', 'FontSize', 14, 'FontWeight', 'bold');
box off;

% Plot 2: Histogram of FD values
subplot(2, 1, 2);
histogram(fd,'BinWidth',0.01,'FaceColor', [0.2 0.6 0.8]);
xlabel('FD (mm)', 'FontSize', 12);
ylabel('Frequency', 'FontSize', 12);
xlim([-0.1 0.6])
title('Distribution of FD Values', 'FontSize', 14, 'FontWeight', 'bold');
box off;

% Add statistics text
text_str = sprintf('Mean: %.3f mm\nMax: %.3f mm\n95th: %.3f mm', ...
    mean_fd, max_fd, percentile_95);
text(0.7, 0.9, text_str, 'Units', 'normalized', ...
    'FontSize', 11, 'BackgroundColor', 'white', ...
    'EdgeColor', 'black');

saveas(gcf,[save_dir,'FD.svg'])