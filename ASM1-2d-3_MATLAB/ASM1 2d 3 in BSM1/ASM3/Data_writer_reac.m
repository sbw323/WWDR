% Inputs: t (time vector), in (data), reac (interval data, size ~= numel(t)-1)
% Goal: use up to the last 1344 samples if available; otherwise use all.

target_len = 1344;
stopindex  = numel(t);
if stopindex == 0
    error('t is empty.');
end

% Window length in samples (cap at available samples)
window_len = min(target_len, stopindex);
startindex = stopindex - window_len;

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

% If reac has one row per interval (numel(t)-1), align safely
% Intervals covered by the chosen time window are idx(1:end-1)
if size(reac1,1) < stopindex-1
    warning('reac has fewer rows than expected; truncating to available rows.');
end
reac_idx = idx(1:end-1);
reac_idx = reac_idx(reac_idx <= size(reac1,1));  % clip to bounds
reac1part = reac1(reac_idx, :);
reac2part = reac2(reac_idx, :);
reac3part = reac3(reac_idx, :);
reac4part = reac4(reac_idx, :);
reac5part = reac5(reac_idx, :);

S_O2_1 = reac1part(window_len,1);
S_I_1 = reac1part(window_len,2);
S_S_1 = reac1part(window_len,3);
S_NH4_1 = reac1part(window_len,4);
S_N2_1 = reac1part(window_len,5);
S_NOX_1 = reac1part(window_len,6);
S_ALK_1 = reac1part(window_len,7);
X_I_1 = reac1part(window_len,8);
X_S_1 = reac1part(window_len,9);
X_H_1 = reac1part(window_len,10);
X_STO_1 = reac1part(window_len,11);
X_A_1 = reac1part(window_len,12);
X_SS_1 = reac1part(window_len,13);
Q_1 =reac1part(window_len,14);
T1 = reac1part(window_len,15);
S_D1_1 = reac1part(window_len,16);
S_D2_1 = reac1part(window_len,17);
S_D3_1 = reac1part(window_len,18);
X_D4_1 = reac1part(window_len,19);
X_D5_1 = reac1part(window_len,20);

S_O2_2= reac2part(window_len,1);
S_I_2= reac2part(window_len,2);
S_S_2= reac2part(window_len,3);
S_NH4_2= reac2part(window_len,4);
S_N2_2= reac2part(window_len,5);
S_NOX_2= reac2part(window_len,6);
S_ALK_2= reac2part(window_len,7);
X_I_2= reac2part(window_len,8);
X_S_2= reac2part(window_len,9);
X_H_2= reac2part(window_len,10);
X_STO_2= reac2part(window_len,11);
X_A_2= reac2part(window_len,12);
X_SS_2= reac2part(window_len,13);
Q_2=reac2part(window_len,14);
T2 = reac2part(window_len,15);
S_D1_2 = reac2part(window_len,16);
S_D2_2 = reac2part(window_len,17);
S_D3_2 = reac2part(window_len,18);
X_D4_2 = reac2part(window_len,19);
X_D5_2 = reac2part(window_len,20);

S_O2_3= reac3part(window_len,1);
S_I_3= reac3part(window_len,2);
S_S_3= reac3part(window_len,3);
S_NH4_3= reac3part(window_len,4);
S_N2_3= reac3part(window_len,5);
S_NOX_3= reac3part(window_len,6);
S_ALK_3= reac3part(window_len,7);
X_I_3= reac3part(window_len,8);
X_S_3= reac3part(window_len,9);
X_H_3= reac3part(window_len,10);
X_STO_3= reac3part(window_len,11);
X_A_3= reac3part(window_len,12);
X_SS_3= reac3part(window_len,13);
Q_3=reac3part(window_len,14);
T3 = reac3part(window_len,15);
S_D1_3 = reac3part(window_len,16);
S_D2_3 = reac3part(window_len,17);
S_D3_3 = reac3part(window_len,18);
X_D4_3 = reac3part(window_len,19);
X_D5_3 = reac3part(window_len,20);

S_O2_4= reac4part(window_len,1);
S_I_4= reac4part(window_len,2);
S_S_4= reac4part(window_len,3);
S_NH4_4= reac4part(window_len,4);
S_N2_4= reac4part(window_len,5);
S_NOX_4= reac4part(window_len,6);
S_ALK_4= reac4part(window_len,7);
X_I_4= reac4part(window_len,8);
X_S_4= reac4part(window_len,9);
X_H_4= reac4part(window_len,10);
X_STO_4= reac4part(window_len,11);
X_A_4= reac4part(window_len,12);
X_SS_4= reac4part(window_len,13);
Q_4=reac4part(window_len,14);
T4 = reac4part(window_len,15);
S_D1_4 = reac4part(window_len,16);
S_D2_4 = reac4part(window_len,17);
S_D3_4 = reac4part(window_len,18);
X_D4_4 = reac4part(window_len,19);
X_D5_4 = reac4part(window_len,20);

S_O2_5= reac5part(window_len,1);
S_I_5= reac5part(window_len,2);
S_S_5= reac5part(window_len,3);
S_NH4_5= reac5part(window_len,4);
S_N2_5= reac5part(window_len,5);
S_NOX_5= reac5part(window_len,6);
S_ALK_5= reac5part(window_len,7);
X_I_5= reac5part(window_len,8);
X_S_5= reac5part(window_len,9);
X_H_5= reac5part(window_len,10);
X_STO_5= reac5part(window_len,11);
X_A_5= reac5part(window_len,12);
X_SS_5= reac5part(window_len,13);
Q_5=reac5part(window_len,14);
T5 = reac5part(window_len,15);
S_D1_5 = reac5part(window_len,16);
S_D2_5 = reac5part(window_len,17);
S_D3_5 = reac5part(window_len,18);
X_D4_5 = reac5part(window_len,19);
X_D5_5 = reac5part(window_len,20);

% Create matricies from all the vectors
reac1_data = [ S_I_1  S_S_1  X_I_1  X_S_1  X_H_1  X_A_1  X_STO_1  S_O2_1  S_NOX_1  S_NH4_1  S_N2_1  S_ALK_1  X_SS_1  Q_1 ];
reac2_data = [ S_I_2  S_S_2  X_I_2  X_S_2  X_H_2  X_A_2  X_STO_2  S_O2_2  S_NOX_2  S_NH4_2  S_N2_2  S_ALK_2  X_SS_2  Q_2 ];
reac3_data = [ S_I_3  S_S_3  X_I_3  X_S_3  X_H_3  X_A_3  X_STO_3  S_O2_3  S_NOX_3  S_NH4_3  S_N2_3  S_ALK_3  X_SS_3  Q_3 ];
reac4_data = [ S_I_4  S_S_4  X_I_4  X_S_4  X_H_4  X_A_4  X_STO_4  S_O2_4  S_NOX_4  S_NH4_4  S_N2_4  S_ALK_4  X_SS_4  Q_4 ];
reac5_data = [ S_I_5  S_S_5  X_I_5  X_S_5  X_H_5  X_A_5  X_STO_5  S_O2_5  S_NOX_5  S_NH4_5  S_N2_5  S_ALK_5  X_SS_5  Q_5 ];

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
% Determine full folder path

% Determine iteration number for filename with full path
filename1 = sprintf('%sreactor1_data_iteration_%d.csv', folder_path, iteration);
filename2 = sprintf('%sreactor2_data_iteration_%d.csv', folder_path, iteration);
filename3 = sprintf('%sreactor3_data_iteration_%d.csv', folder_path, iteration);
filename4 = sprintf('%sreactor4_data_iteration_%d.csv', folder_path, iteration);
filename5 = sprintf('%sreactor5_data_iteration_%d.csv', folder_path, iteration);

% Save to CSV
if exist('writematrix', 'file')  % for MATLAB R2019a or newer
    writematrix(reac1_data, filename1);
    writematrix(reac2_data, filename2);
    writematrix(reac3_data, filename3);
    writematrix(reac4_data, filename4);
    writematrix(reac5_data, filename5);
else
    csvwrite(filename1, reac1_data);
    csvwrite(filename2, reac2_data);
    csvwrite(filename3, reac3_data);
    csvwrite(filename4, reac4_data);
    csvwrite(filename5, reac5_data);
end

