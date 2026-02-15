[m, n] = size(in);

% Index bounds
stopindex = length(t);

if stopindex < 1344
    startindex = floor(min(t));  % or 1 if you meant index, not time
    warning('Not enough data points in t to go back 1344 steps. Using startindex = min(t).');
else
    startindex = stopindex - 1344 + 1;
end

% Evaluation window
time_eval = t(startindex:stopindex);       % Time range for evaluation

% Time resolution and total duration
sampletime = time_eval(2) - time_eval(1);  % Assumes uniform sampling
totalt = time_eval(end) - time_eval(1);    % Total duration

%cut out the parts of the files to be used
reac1part=reac1(startindex:(stopindex-1),:);
reac2part=reac2(startindex:(stopindex-1),:);
reac3part=reac3(startindex:(stopindex-1),:);
reac4part=reac4(startindex:(stopindex-1),:);
reac5part=reac5(startindex:(stopindex-1),:);

S_I1=reac1part(:,1);
S_S1=reac1part(:,2);
X_I1=reac1part(:,3);
X_S1=reac1part(:,4);
X_BH1=reac1part(:,5);
X_BA1=reac1part(:,6);
X_P1=reac1part(:,7);
S_O1=reac1part(:,8);
S_NO1=reac1part(:,9);
S_NH1=reac1part(:,10);
S_ND1=reac1part(:,11);
X_ND1=reac1part(:,12);
S_ALK1=reac1part(:,13);
TSS1=reac1part(:,14);
Q1=reac1part(:,15);

S_I2=reac2part(:,1);
S_S2=reac2part(:,2);
X_I2=reac2part(:,3);
X_S2=reac2part(:,4);
X_BH2=reac2part(:,5);
X_BA2=reac2part(:,6);
X_P2=reac2part(:,7);
S_O2=reac2part(:,8);
S_NO2=reac2part(:,9);
S_NH2=reac2part(:,10);
S_ND2=reac2part(:,11);
X_ND2=reac2part(:,12);
S_ALK2=reac2part(:,13);
TSS2=reac2part(:,14);
Q2=reac2part(:,15);
 
S_I3=reac3part(:,1);
S_S3=reac3part(:,2);
X_I3=reac3part(:,3);
X_S3=reac3part(:,4);
X_BH3=reac3part(:,5);
X_BA3=reac3part(:,6);
X_P3=reac3part(:,7);
S_O3=reac3part(:,8);
S_NO3=reac3part(:,9);
S_NH3=reac3part(:,10);
S_ND3=reac3part(:,11);
X_ND3=reac3part(:,12);
S_ALK3=reac3part(:,13);
TSS3=reac3part(:,14);
Q3=reac3part(:,15);
 
S_I4=reac4part(:,1);
S_S4=reac4part(:,2);
X_I4=reac4part(:,3);
X_S4=reac4part(:,4);
X_BH4=reac4part(:,5);
X_BA4=reac4part(:,6);
X_P4=reac4part(:,7);
S_O4=reac4part(:,8);
S_NO4=reac4part(:,9);
S_NH4=reac4part(:,10);
S_ND4=reac4part(:,11);
X_ND4=reac4part(:,12);
S_ALK4=reac4part(:,13);
TSS4=reac4part(:,14);
Q4=reac4part(:,15);
 
S_I5=reac5part(:,1);
S_S5=reac5part(:,2);
X_I5=reac5part(:,3);
X_S5=reac5part(:,4);
X_BH5=reac5part(:,5);
X_BA5=reac5part(:,6);
X_P5=reac5part(:,7);
S_O5=reac5part(:,8);
S_NO5=reac5part(:,9);
S_NH5=reac5part(:,10);
S_ND5=reac5part(:,11);
X_ND5=reac5part(:,12);
S_ALK5=reac5part(:,13);
TSS5=reac5part(:,14);
Q5=reac5part(:,15);

% Create matricies from all the vectors
reac1_data = [ S_I1  S_S1  X_I1  X_S1  X_BH1  X_BA1  X_P1  S_O1  S_NO1  S_NH1  S_ND1  X_ND1  S_ALK1 TSS1 Q1 ];
reac2_data = [ S_I2  S_S2  X_I2  X_S2  X_BH2  X_BA2  X_P2  S_O2  S_NO2  S_NH2  S_ND2  X_ND2  S_ALK2 TSS2 Q2 ];
reac3_data = [ S_I3  S_S3  X_I3  X_S3  X_BH3  X_BA3  X_P3  S_O3  S_NO3  S_NH3  S_ND3  X_ND3  S_ALK3 TSS3 Q3 ];
reac4_data = [ S_I4  S_S4  X_I4  X_S4  X_BH4  X_BA4  X_P4  S_O4  S_NO4  S_NH4  S_ND4  X_ND4  S_ALK4 TSS4 Q4 ];
reac5_data = [ S_I5  S_S5  X_I5  X_S5  X_BH5  X_BA5  X_P5  S_O5  S_NO5  S_NH5  S_ND5  X_ND5  S_ALK5 TSS5 Q5 ];

% Define the base output directory
base_output_dir = '/Users/aya/github/WWDR/BSM1-BSM2_MATLAB/BSM2_R2019b/BSM2_OutputDB/';

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

