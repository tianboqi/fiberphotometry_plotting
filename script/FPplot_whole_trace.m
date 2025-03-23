%% Fiber Photometry single trace plotting
% Tianbo Qi, 01/2020, modified 01/2025
% For plotting FP trace with behavior events
% anno_file should be a .txt file output from Caltech behavior annotator
% signal_file should be a .mat file with dF/F as columns in matrix sig_norm

%% Input files and arguments
% clear all; clc;

anno_file = '1.txt';
signal_file = '1_000_processed.mat';

%% Read annotation
tlines = textread(anno_file, '%s', 'delimiter', '\n');

% Extract times and behaviors starting
line1 = find(cellfun(@(x) numel(x) >= 3 && strcmp(x(1:3), '---'), tlines)) + 1;
data = cellfun(@(x) strsplit(strtrim(x)), tlines(line1:end), 'UniformOutput', false);
times = cell2mat(cellfun(@(x) cellfun(@str2double, x(1:2)), data, 'UniformOutput', false));
behaviors = cellfun(@(x) x{3}, data, 'UniformOutput', false);

assert(strcmp(behaviors{1}, 'Start'), 'First event should be "Start"');

times = times(2:end,:) - times(1,2);
behaviors = behaviors(2:end);

clearvars -except signal_file times behaviors framerate

%% Plot
fps_anno = 5;
fps_signal = 20;

load(signal_file)
n_channels = size(sig_norm,1);

% Filter behaviors
behaviors_unique = setdiff(unique(behaviors), {'Other', 'Intro'});  

colors = jet(length(behaviors_unique));
figure;

for i = 1:n_channels
    subplot(n_channels,1,i); hold on;

    hs = gobjects(1, length(behaviors_unique));

    for j = 1:length(behaviors)
        behavior_idx = find(strcmp(behaviors_unique, behaviors{j}), 1);
        
        if ~isempty(behavior_idx)
            t_start = times(j,1) / fps_anno;
            t_end = times(j+1,1) / fps_anno;
            h = fill([t_start t_end t_end t_start], [-5 -5 5 5], colors(behavior_idx,:), ...
                'FaceAlpha', 0.6, 'LineStyle', 'none');
            hs(behavior_idx) = h;
        end
    end

    % Plot
    time_plot = (1:size(sig_norm,2)) / fps_signal;
    plot(time_plot, 100 * sig_norm(i,:), 'k');
    xlim([0 size(sig_norm,2) / fps_signal]);
    legend(hs, behaviors_unique, 'Interpreter', 'none');
    title(['fiber' int2str(i)]);
    xlabel('time (s)');
    ylabel('\Delta F/F_0 (%)');
end
