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
    timevector = dt;                   % time vector for energy calculations
else
    sampletime = NaN;
    totalt     = 0;
    timevector = [];
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

S_O2_1 = reac1part(:,1);
S_I_1 = reac1part(:,2);
S_S_1 = reac1part(:,3);
S_NH4_1 = reac1part(:,4);
S_N2_1 = reac1part(:,5);
S_NOX_1 = reac1part(:,6);
S_ALK_1 = reac1part(:,7);
X_I_1 = reac1part(:,8);
X_S_1 = reac1part(:,9);
X_H_1 = reac1part(:,10);
X_STO_1 = reac1part(:,11);
X_A_1 = reac1part(:,12);
X_SS_1 = reac1part(:,13);
Q_1 = reac1part(:,14);
T1 = reac1part(:,15);
S_D1_1 = reac1part(:,16);
S_D2_1 = reac1part(:,17);
S_D3_1 = reac1part(:,18);
X_D4_1 = reac1part(:,19);
X_D5_1 = reac1part(:,20);

S_O2_2 = reac2part(:,1);
S_I_2 = reac2part(:,2);
S_S_2 = reac2part(:,3);
S_NH4_2 = reac2part(:,4);
S_N2_2 = reac2part(:,5);
S_NOX_2 = reac2part(:,6);
S_ALK_2 = reac2part(:,7);
X_I_2 = reac2part(:,8);
X_S_2 = reac2part(:,9);
X_H_2 = reac2part(:,10);
X_STO_2 = reac2part(:,11);
X_A_2 = reac2part(:,12);
X_SS_2 = reac2part(:,13);
Q_2 = reac2part(:,14);
T2 = reac2part(:,15);
S_D1_2 = reac2part(:,16);
S_D2_2 = reac2part(:,17);
S_D3_2 = reac2part(:,18);
X_D4_2 = reac2part(:,19);
X_D5_2 = reac2part(:,20);

S_O2_3 = reac3part(:,1);
S_I_3 = reac3part(:,2);
S_S_3 = reac3part(:,3);
S_NH4_3 = reac3part(:,4);
S_N2_3 = reac3part(:,5);
S_NOX_3 = reac3part(:,6);
S_ALK_3 = reac3part(:,7);
X_I_3 = reac3part(:,8);
X_S_3 = reac3part(:,9);
X_H_3 = reac3part(:,10);
X_STO_3 = reac3part(:,11);
X_A_3 = reac3part(:,12);
X_SS_3 = reac3part(:,13);
Q_3 = reac3part(:,14);
T3 = reac3part(:,15);
S_D1_3 = reac3part(:,16);
S_D2_3 = reac3part(:,17);
S_D3_3 = reac3part(:,18);
X_D4_3 = reac3part(:,19);
X_D5_3 = reac3part(:,20);

S_O2_4 = reac4part(:,1);
S_I_4 = reac4part(:,2);
S_S_4 = reac4part(:,3);
S_NH4_4 = reac4part(:,4);
S_N2_4 = reac4part(:,5);
S_NOX_4 = reac4part(:,6);
S_ALK_4 = reac4part(:,7);
X_I_4 = reac4part(:,8);
X_S_4 = reac4part(:,9);
X_H_4 = reac4part(:,10);
X_STO_4 = reac4part(:,11);
X_A_4 = reac4part(:,12);
X_SS_4 = reac4part(:,13);
Q_4 = reac4part(:,14);
T4 = reac4part(:,15);
S_D1_4 = reac4part(:,16);
S_D2_4 = reac4part(:,17);
S_D3_4 = reac4part(:,18);
X_D4_4 = reac4part(:,19);
X_D5_4 = reac4part(:,20);

S_O2_5 = reac5part(:,1);
S_I_5 = reac5part(:,2);
S_S_5 = reac5part(:,3);
S_NH4_5 = reac5part(:,4);
S_N2_5 = reac5part(:,5);
S_NOX_5 = reac5part(:,6);
S_ALK_5 = reac5part(:,7);
X_I_5 = reac5part(:,8);
X_S_5 = reac5part(:,9);
X_H_5 = reac5part(:,10);
X_STO_5 = reac5part(:,11);
X_A_5 = reac5part(:,12);
X_SS_5 = reac5part(:,13);
Q_5 = reac5part(:,14);
T5 = reac5part(:,15);
S_D1_5 = reac5part(:,16);
S_D2_5 = reac5part(:,17);
S_D3_5 = reac5part(:,18);
X_D4_5 = reac5part(:,19);
X_D5_5 = reac5part(:,20);

%% ========================================================================
%  AERATION AND MIXING ENERGY CALCULATIONS
%  ========================================================================

% Convert kla inputs to vectors if necessary
invecsize = size(t);
kla1in = changeScalarToVector(kla1in, invecsize);
kla2in = changeScalarToVector(kla2in, invecsize);
kla3in = changeScalarToVector(kla3in, invecsize);
kla4in = changeScalarToVector(kla4in, invecsize);
kla5in = changeScalarToVector(kla5in, invecsize);

% Extract kla vectors for the selected window
kla1vec = kla1in(startindex:(stopindex-1), :);
kla2vec = kla2in(startindex:(stopindex-1), :);
kla3vec = kla3in(startindex:(stopindex-1), :);
kla4vec = kla4in(startindex:(stopindex-1), :);
kla5vec = kla5in(startindex:(stopindex-1), :);

% Aeration energy calculation (updated BSM1/BSM2 approach)
SOSAT = 8;
kla1newvec_new = SOSAT * VOL1 * kla1vec;
kla2newvec_new = SOSAT * VOL2 * kla2vec;
kla3newvec_new = SOSAT * VOL3 * kla3vec;
kla4newvec_new = SOSAT * VOL4 * kla4vec;
kla5newvec_new = SOSAT * VOL5 * kla5vec;

airenergyvec_new = (kla1newvec_new + kla2newvec_new + kla3newvec_new + ...
                    kla4newvec_new + kla5newvec_new) / (1.8 * 1000);

% Calculate aeration energy per sample (instantaneous power × time)
if ~isempty(timevector)
    aeration_energy_per_sample = airenergyvec_new .* timevector;
else
    aeration_energy_per_sample = zeros(size(airenergyvec_new));
end

% Mixing energy calculation
mixnumreac1 = length(find(kla1vec < 20));
mixnumreac2 = length(find(kla2vec < 20));
mixnumreac3 = length(find(kla3vec < 20));
mixnumreac4 = length(find(kla4vec < 20));
mixnumreac5 = length(find(kla5vec < 20));

mixenergyunitreac = 0.005; % kW/m3

mixenergyreac1 = mixnumreac1 * mixenergyunitreac * VOL1;
mixenergyreac2 = mixnumreac2 * mixenergyunitreac * VOL2;
mixenergyreac3 = mixnumreac3 * mixenergyunitreac * VOL3;
mixenergyreac4 = mixnumreac4 * mixenergyunitreac * VOL4;
mixenergyreac5 = mixnumreac5 * mixenergyunitreac * VOL5;

% Total mixing energy over the window
if ~isnan(sampletime)
    mixenergy_total = 24 * (mixenergyreac1 + mixenergyreac2 + mixenergyreac3 + ...
                            mixenergyreac4 + mixenergyreac5) * sampletime;
else
    mixenergy_total = 0;
end

% Distribute mixing energy per sample (per reactor)
num_samples = length(kla1vec);
if num_samples > 0
    mixing_energy_reac1 = repmat(mixenergyreac1 * 24 * sampletime / num_samples, num_samples, 1);
    mixing_energy_reac2 = repmat(mixenergyreac2 * 24 * sampletime / num_samples, num_samples, 1);
    mixing_energy_reac3 = repmat(mixenergyreac3 * 24 * sampletime / num_samples, num_samples, 1);
    mixing_energy_reac4 = repmat(mixenergyreac4 * 24 * sampletime / num_samples, num_samples, 1);
    mixing_energy_reac5 = repmat(mixenergyreac5 * 24 * sampletime / num_samples, num_samples, 1);
else
    mixing_energy_reac1 = [];
    mixing_energy_reac2 = [];
    mixing_energy_reac3 = [];
    mixing_energy_reac4 = [];
    mixing_energy_reac5 = [];
end

% Calculate per-reactor aeration energy
aeration_energy_reac1 = kla1newvec_new / (1.8 * 1000);
aeration_energy_reac2 = kla2newvec_new / (1.8 * 1000);
aeration_energy_reac3 = kla3newvec_new / (1.8 * 1000);
aeration_energy_reac4 = kla4newvec_new / (1.8 * 1000);
aeration_energy_reac5 = kla5newvec_new / (1.8 * 1000);

if ~isempty(timevector)
    aeration_energy_reac1 = aeration_energy_reac1 .* timevector;
    aeration_energy_reac2 = aeration_energy_reac2 .* timevector;
    aeration_energy_reac3 = aeration_energy_reac3 .* timevector;
    aeration_energy_reac4 = aeration_energy_reac4 .* timevector;
    aeration_energy_reac5 = aeration_energy_reac5 .* timevector;
end

% Total energy per reactor (aeration + mixing)
total_energy_reac1 = aeration_energy_reac1 + mixing_energy_reac1;
total_energy_reac2 = aeration_energy_reac2 + mixing_energy_reac2;
total_energy_reac3 = aeration_energy_reac3 + mixing_energy_reac3;
total_energy_reac4 = aeration_energy_reac4 + mixing_energy_reac4;
total_energy_reac5 = aeration_energy_reac5 + mixing_energy_reac5;

%% ========================================================================
%  CREATE OUTPUT MATRICES WITH ENERGY COLUMNS
%  ========================================================================

% Create matrices from all the vectors with energy as final column
reac1_data = [S_I_1  S_S_1  X_I_1  X_S_1  X_H_1  X_A_1  X_STO_1  S_O2_1  S_NOX_1  S_NH4_1  S_N2_1  S_ALK_1  X_SS_1  Q_1  total_energy_reac1];
reac2_data = [S_I_2  S_S_2  X_I_2  X_S_2  X_H_2  X_A_2  X_STO_2  S_O2_2  S_NOX_2  S_NH4_2  S_N2_2  S_ALK_2  X_SS_2  Q_2  total_energy_reac2];
reac3_data = [S_I_3  S_S_3  X_I_3  X_S_3  X_H_3  X_A_3  X_STO_3  S_O2_3  S_NOX_3  S_NH4_3  S_N2_3  S_ALK_3  X_SS_3  Q_3  total_energy_reac3];
reac4_data = [S_I_4  S_S_4  X_I_4  X_S_4  X_H_4  X_A_4  X_STO_4  S_O2_4  S_NOX_4  S_NH4_4  S_N2_4  S_ALK_4  X_SS_4  Q_4  total_energy_reac4];
reac5_data = [S_I_5  S_S_5  X_I_5  X_S_5  X_H_5  X_A_5  X_STO_5  S_O2_5  S_NOX_5  S_NH4_5  S_N2_5  S_ALK_5  X_SS_5  Q_5  total_energy_reac5];

%% ========================================================================
%  SAVE OUTPUT FILES
%  ========================================================================

% Define the base output directory
base_output_dir = '/Users/ikai/github/WWDR/ASM1-2d-3_MATLAB/ASM1 2d 3 in BSM1/ASM3/ASM3_OutputDB';

iteration = t(1);

% Define the iteration-specific subfolder name
iteration_folder = sprintf('iter%d', iteration);

% Construct the full output path
folder_path = fullfile(base_output_dir, iteration_folder, '/');

% Create the directory if it doesn't exist
if ~exist(folder_path, 'dir')
    mkdir(folder_path);
end

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

%% ========================================================================
%  HELPER FUNCTION
%  ========================================================================

function vec = changeScalarToVector(input, targetsize)
    % Convert scalar to vector if necessary
    if isscalar(input)
        vec = repmat(input, targetsize);
    else
        vec = input;
    end
end