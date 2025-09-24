% Inputs: t (time vector), in (data), settler (interval data, size ~= numel(t)-1)
% Goal: use up to the last 1344 samples if available; otherwise use all.

[m, n] = size(in);

target_len = 1344;
stopindex  = numel(t);
if stopindex == 0
    error('t is empty.');
end

% Window length in samples (cap at available samples)
window_len = min(target_len, stopindex);
startindex = stopindex - window_len + 1;

% Indices and time window
idx       = startindex:stopindex;
time_eval = t(idx);

% Time resolution and total duration (robust to jitter and short windows)
if numel(time_eval) >= 2
    dt         = diff(time_eval);
    sampletime = median(dt);           % robust to minor jitter
    totalt     = time_eval(end) - time_eval(1);
else
    sampletime = NaN;
    totalt     = 0;
    warning('Not enough points to compute sample time; setting sampletime=NaN.');
end

% If settler has one row per interval (numel(t)-1), align safely
% Intervals covered by the chosen time window are idx(1:end-1)
if size(settler,1) < stopindex-1
    warning('settler has fewer rows than expected; truncating to available rows.');
end
settler_idx = idx(1:end-1);
settler_idx = settler_idx(settler_idx <= size(settler,1));  % clip to bounds
settlerpart = settler(settler_idx, :);

Qevec = settlerpart(:,35);
SOevec = settlerpart(:,22);
SIevec = settlerpart(:,23);
SSevec = settlerpart(:,24); 
SNHevec = settlerpart(:,25);
SN2evec = settlerpart(:,26);
SNOevec = settlerpart(:,27);
SALKevec = settlerpart(:,28);
XIevec = settlerpart(:,29);
XSevec = settlerpart(:,30);  
XBHevec = settlerpart(:,31);  
XSTOevec = settlerpart(:,32);  
XBAevec = settlerpart(:,33);
TSSevec = settlerpart(:,34);

% Create a matrix from all the vectors
settler_data = [SIevec, SSevec, XIevec, XSevec, XBHevec, XBAevec, XSTOevec, SOevec, SNOevec, SNHevec, SN2evec, SALKevec, TSSevec, Qevec];
% Define the base output directory
base_output_dir = '/Users/aya/github/WWDR/ASM1-2d-3_MATLAB/ASM1 2d 3 in BSM1/ASM3/ASM3_OutputDB';

iteration = t(1);

% Define the iteration-specific subfolder name
iteration_folder = sprintf('iter%d', iteration);

% Construct the full output path
folder_path = fullfile(base_output_dir, iteration_folder, '/');

% Create the directory if it doesn't exist
if ~exist(folder_path, 'dir')
    mkdir(folder_path);
end

% Determine iteration number for filename
% Assuming "iteration" variable exists in the workspace and represents the current iteration
filename = sprintf('%ssettler_data_DR_iteration_%d.csv', folder_path, iteration);

% Save to CSV
if exist('writematrix', 'file')  % for MATLAB R2019a or newer
    writematrix(settler_data, filename);
else
    csvwrite(filename, settler_data);
end
