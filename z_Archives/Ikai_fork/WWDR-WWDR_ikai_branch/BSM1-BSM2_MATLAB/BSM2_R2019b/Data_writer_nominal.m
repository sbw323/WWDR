[m, n] = size(in);

% Index bounds
stopindex = length(t);

if stopindex < 1344
    startindex = floor(min(t));  % or 1 if you meant index, not time
    warning('Not enough data points in t to go back 1344 steps. Using startindex = min(t).');
else
    startindex = stopindex - 1344 + 1;
end

% Time window and time vector
stoptime = t(stopindex);
starttime = t(startindex);
time_eval = t(startindex:stopindex);

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
SIevec=settlerpart(:,1);
SSevec=settlerpart(:,2);     
XIevec=settlerpart(:,3);
XSevec=settlerpart(:,4);  
XBHevec=settlerpart(:,5);  
XBAevec=settlerpart(:,6);
XPevec=settlerpart(:,7);
SOevec=settlerpart(:,8);
SNOevec=settlerpart(:,9);
SNHevec=settlerpart(:,10);
SNDevec=settlerpart(:,11);
XNDevec=settlerpart(:,12);
SALKevec=settlerpart(:,13);
TSSevec=settlerpart(:,14);
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
filename = sprintf('%ssettler_data_nominal_iteration_%d.csv', folder_path, iteration);

% Save to CSV
if exist('writematrix', 'file')  % for MATLAB R2019a or newer
    writematrix(settler_data, filename);
else
    csvwrite(filename, settler_data);
end
