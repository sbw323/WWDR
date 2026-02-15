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
inpart=in(startindex:(stopindex-1),:);
% effluentpart=effluent(startindex:(stopindex-1),:);
settlerpart=settler(startindex:(stopindex-1),:);
recpart=rec(startindex:(stopindex-1),:);

% Effluent concentrations
% Effluent concentrations
timevector=time_eval(2:end)-time_eval(1:(end-1));

Qevec = settlerpart(:,35).*timevector;
Qinvec=inpart(:,14).*timevector;
SOevec = settlerpart(:,22).*Qevec;
SIevec = settlerpart(:,23).*Qevec;
SSevec = settlerpart(:,24).*Qevec; 
SNHevec = settlerpart(:,25).*Qevec;
SN2evec = settlerpart(:,26).*Qevec;
SNOevec = settlerpart(:,27).*Qevec;
SALKevec = settlerpart(:,28).*Qevec;
XIevec = settlerpart(:,29).*Qevec;
XSevec = settlerpart(:,30).*Qevec;  
XBHevec = settlerpart(:,31).*Qevec;  
XSTOevec = settlerpart(:,32).*Qevec;  
XBAevec = settlerpart(:,33).*Qevec;
TSSevec = settlerpart(:,34).*Qevec;

BSS=2;
BCOD=1;
BNKj=20; % original BSM1
BNO=20; % original BSM1
BBOD5=2;
BNKj_new = 30; % updated BSM TG meeting no 8
BNO_new = 10; % updated BSM TG meeting no 8

SSe=       settlerpart(:,34);
CODe=      settlerpart(:,23)+ settlerpart(:,24)+ settlerpart(:,29)+settlerpart(:,30)+settlerpart(:,31)+settlerpart(:,32) + settlerpart(:,33);
SNKje=     settlerpart(:,25)+ i_NSI*(settlerpart(:,23)) + i_NSS*(settlerpart(:,24)) + i_NXI*(settlerpart(:,29)) + i_NXS*(settlerpart(:,30)) + i_NBM*( settlerpart(:,31) + settlerpart(:,33));
SNOe=      settlerpart(:,29);
BOD5e=     0.65*(settlerpart(:,24)+settlerpart(:,30)+(1-f_P)*(settlerpart(:,31)+settlerpart(:,32)+ settlerpart(:,33) ));

EQvecinst=(BSS*SSe+BCOD*CODe+BNKj*SNKje+BNO*SNOe+BBOD5*BOD5e).*settlerpart(:,35);
EQvecinst_new=(BSS*SSe+BCOD*CODe+BNKj_new*SNKje+BNO_new*SNOe+BBOD5*BOD5e).*settlerpart(:,35); %updated BSM TG meeting no 8

EQvec=(BSS*SSe+BCOD*CODe+BNKj*SNKje+BNO*SNOe+BBOD5*BOD5e).*Qevec;
EQvec_new=(BSS*SSe+BCOD*CODe+BNKj_new*SNKje+BNO_new*SNOe+BBOD5*BOD5e).*Qevec; %updated BSM TG meeting no 8


% Create a matrix from all the vectors
settler_data = [SIevec, SSevec, XIevec, XSevec, XBHevec, XBAevec, SOevec, SNOevec, SNHevec, SALKevec, TSSevec, EQvecinst_new, EQvec_new];
% Define the base output directory
base_output_dir = '/Users/aya/github/WWDR/ASM1-2d-3_MATLAB/ASM1 2d 3 in BSM1/ASM3/ASM3_OutputDB';

iteration = t(1)

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
