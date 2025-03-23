# Fiber photometry plotting
MATLAB scripts for plotting fiber photometry data

## Scripts
The repository contains the following scripts:
- `FPplot_whole_trace.m`: This script plots the entire recording trace and uses color blocks to indicate different behaviors.

![Example whole FP trace](https://github.com/tianboqi/fiberphotometry_plotting/blob/main/img/example_whole_trace.bmp)

- `FPplot_PSTH.m`: This script plots the signal corresponding to a specific behavior. It offers three different options for visualizing the data.

![Example PSTH](https://github.com/tianboqi/fiberphotometry_plotting/blob/main/img/example_psth.bmp)

- `FPplot_video.m`: This script generates an mp4 video like the following.

<p align="center">
  <img src="https://github.com/tianboqi/fiberphotometry_plotting/blob/main/img/example_video.gif" alt="animated" width="500">
</p>

## Input format
- The input signal file should be a `.mat` file with an array `sig_norm`, each row representing the signal for each brain region recorded.
- The annotation file should be a `.txt` file output from the behavior annotator ([Piotr's MATLAB toolbox](https://github.com/pdollar/toolbox) or [the Python version by Xingjian Zhang](https://github.com/hsingchien/Bannotator)). 

