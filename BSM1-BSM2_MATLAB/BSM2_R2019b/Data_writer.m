[m n] = size(in);

% Assume 't' is a uniformly sampled vector with at least 1345 entries
stopindex = length(t);                     % Last index of t
startindex = stopindex - 14;             % 1344 steps before end

% Safety check (optional)
if startindex < 1
    error('Not enough data points in t to go back 1344 steps.');
end

% Define time window
stoptime = t(stopindex);                   % Last time value
starttime = t(startindex);                 % Time 1344 steps before end

% Evaluation window
time_eval = t(startindex:stopindex);       % Time range for evaluation

% Time resolution and total duration
sampletime = time_eval(2) - time_eval(1);  % Assumes uniform sampling
totalt = time_eval(end) - time_eval(1);    % Total duration

%cut out the parts of the files to be used
inpart=in(startindex:(stopindex-1),:);
effluentpart=effluent(startindex:(stopindex-1),:);
settlerpart=settler(startindex:(stopindex-1),:);
recpart=rec(startindex:(stopindex-1),:);

% Effluent concentrations
% Effluent concentrations
timevector = time_eval(2:end) - time_eval(1:end-1);  % FIXED: now 1344x1

Qevec = effluentpart(:,15).*timevector;
Qinvec=inpart(:,15).*timevector;
SIevec=settlerpart(:,1).*Qevec;
SSevec=settlerpart(:,2).*Qevec;     
XIevec=settlerpart(:,3).*Qevec;
XSevec=settlerpart(:,4).*Qevec;  
XBHevec=settlerpart(:,5).*Qevec;  
XBAevec=settlerpart(:,6).*Qevec;
XPevec=settlerpart(:,7).*Qevec;
SOevec=settlerpart(:,8).*Qevec;
SNOevec=settlerpart(:,9).*Qevec;
SNHevec=settlerpart(:,10).*Qevec;
SNDevec=settlerpart(:,11).*Qevec;
XNDevec=settlerpart(:,12).*Qevec;
SALKevec=settlerpart(:,13).*Qevec;
TSSevec=settlerpart(:,14).*Qevec;
Tempevec =settlerpart(:,15).*Qevec;

% Create a matrix from all the vectors
settler_data = [SIevec, SSevec, XIevec, XSevec, XBHevec, XBAevec, XPevec, SOevec, SNOevec, SNHevec, SNDevec, XNDevec, SALKevec, TSSevec, Tempevec];
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

% Determine iteration number for filename
% Assuming "iteration" variable exists in the workspace and represents the current iteration
filename = sprintf('%ssettler_data_DR_iteration_%d.csv', folder_path, iteration);

% Save to CSV
if exist('writematrix', 'file')  % for MATLAB R2019a or newer
    writematrix(settler_data, filename);
else
    csvwrite(filename, settler_data);
end
