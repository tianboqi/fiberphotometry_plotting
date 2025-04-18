%% Fiber Photometry PSTH plotting
% Tianbo Qi, 01/2020, modified 01/2025
% For plotting calcium signal during a single behavior
% anno_file should be a .txt file output from Caltech behavior annotator
% signal_file should be a .mat file with dF/F as columns in matrix sig_norm

%% Input files and arguments
% clear all; clc;

anno_file = '1_ds.txt';
signal_file = '1_000_processed.mat';
n_channel = 1;
behavior = 'Feed';
behavior_type = 'start';

% If the interval between two same behavioral events is small than
% time_filter, then the later event is deleted. time_filter = 0 means no
% filter.
time_filter = 0;

% Time to plot before and after behavior starting point.
t_pre = -10;
t_post = 10;

% Smooth or not
smoothing = true;

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

% clearvars -except signal_file times behaviors behavior n_channel...
%     t_pre t_post time_filter smoothing behavior_type

%% Extract peristim signal
fps_anno = 10;
fps_signal = 20;
fps_ratio = fps_signal / fps_anno;

load(signal_file)
assert(n_channel <= size(sig_norm,2), 'Channel number exceeds total number')

time_plot = t_pre : 1/fps_signal : t_post;
peristim_signal = [];

signal_beh_end_old = -Inf;
for i = 1:length(behaviors)-1
    if strcmpi(behaviors{i+1},behavior)
        if strcmpi(behavior_type, 'start')
            signal_zeropoint_new = times(i+1,1)*fps_ratio;
        elseif strcmpi(behavior_type, 'end')
            signal_zeropoint_new = times(i+2,1)*fps_ratio;
            signal_beh_end_old = times(i+1,1)*fps_ratio;
        else
            error('behavior_type has to be "start" or "end"')
        end
        signal_frame_start_new = signal_zeropoint_new + t_pre*fps_signal;
        signal_frame_end_new = signal_zeropoint_new + t_post*fps_signal;
        
        if ~time_filter || (signal_zeropoint_new - signal_beh_end_old > time_filter*fps_signal)
            try
                signal = sig_norm(n_channel, signal_frame_start_new:signal_frame_end_new)';
            catch
                continue
            end
            signal = signal - mean(sig_norm(n_channel, signal_frame_start_new:signal_zeropoint_new));
            if smoothing
                signal = smooth(signal);
            end
            peristim_signal = [peristim_signal signal];
        end
        signal_beh_end_old = times(i+1,2)*fps_ratio;
    end
end

% clearvars -except peristim_signal time_plot

%% Plot
% Options: (1) Signal of each trial overlaid with average signal
%          (2) Average signal with error bar
%          (3) Heatmap

option = 1;

if option == 1
    figure; hold on
    for i = 1:size(peristim_signal,2)
        plot(time_plot, 100*peristim_signal(:,i), 'Color', [.8 .8 .8])
    end
    mean_signal = mean(peristim_signal')';
    plot(time_plot, 100*mean_signal, 'Color', 'b', 'LineWidth', 3);
    xline(0, 'k--');
    xlabel('time (s)'); ylabel('\DeltaF/F_0 (%)')
    box off
    
elseif option == 2    
    figure; hold on
    x = time_plot';
    y = 100*mean(peristim_signal')';
    sem = 100*std(peristim_signal')'./sqrt(size(peristim_signal,2));
    errbar = fill([x;flipud(x)],[y-sem;flipud(y+sem)],...
        [.7 .7 .7], 'LineStyle','none', 'FaceAlpha',0.5);
    line(x, y, 'LineWidth',2, 'Color','b')
    xline(0, 'k--');
    xlabel('time (s)'); ylabel('\DeltaF/F_0 (%)')
    box off

elseif option == 3
    figure; hold on
    colormap jet
    imagesc(time_plot, 1:size(peristim_signal,2), 100*peristim_signal');
    colorbar();
    xline(0, 'k--');
    xlim([time_plot(1) time_plot(end)]); ylim([0.5 size(peristim_signal,2)+0.5])
    xlabel('time (s)'); ylabel('trial');
    axis ij
    ax = gca;
    ax.YTick = unique( round(ax.YTick) );
    
else
    error('Plotting option does not exist')
end

%% Save data

% save([signal_file(1:end-13) 'channel' int2str(n_channel) '_' behavior '_' behavior_type '.mat'], 'time_plot', 'peristim_signal');
