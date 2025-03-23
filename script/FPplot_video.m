%% Fiber Photometry single trace video generation
% Tianbo Qi, 02/2025
% For generating a video with FP trace 

% Manually load the signal .mat file

% sig_norm = smoothdata(sig_norm,2);

% Output video name
videoFile = "example.mp4";
video = VideoWriter(videoFile, 'MPEG-4');
video.FrameRate = 10;  % Set the fps

open(video);

% Time window to be plotted, in seconds
time_start = 40;
time_end = 100;
signal_fps = 20;

sig_window = sig_norm(time_start*signal_fps:time_end*signal_fps);
time_window = time(time_start*signal_fps:time_end*signal_fps);
numFrames = (time_end - time_start)*video.FrameRate;

% Create plot
figure;  hold on;
xlabel('time (s)');
ylabel('\Delta F/F (%)');

for k = 1:2:numFrames
    
    frame_plot_end = k / video.FrameRate * signal_fps;
    
    sig_plot = sig_window(1:round(frame_plot_end));
    time_plot = time_window(1:round(frame_plot_end));
    
    plot(time_plot, sig_plot * 100, 'k');
    
    xlim([time_start, time_end]);
    ylim([-2 6]);    % manually adjust
    
    frame = getframe(gcf);
    writeVideo(video, frame);
    
    hold off;
    hold on;
end

close(video);
disp('Video created successfully!');