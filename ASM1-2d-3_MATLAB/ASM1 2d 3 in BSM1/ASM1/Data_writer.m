[m n] = size(in);

starttime = 1;
stoptime = 14;
startindex=max(find(t <= starttime));
stopindex=min(find(t >= stoptime));

time=t(startindex:stopindex);

sampletime = time(2)-time(1);
totalt=time(end)-time(1);

%cut out the parts of the files to be used
inpart=in(startindex:(stopindex-1),:);
settlerpart=settler(startindex:(stopindex-1),:);
recpart=rec(startindex:(stopindex-1),:);

% Effluent concentrations
timevector=time(2:end)-time(1:(end-1));

Qevec=settlerpart(:,201).*timevector;
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

% Determine iteration number for filename
% Assuming "iteration" variable exists in the workspace and represents the current iteration
filename = sprintf('settler_data_iteration_%d.csv', iteration);

% Save to CSV
if exist('writematrix', 'file')  % for MATLAB R2019a or newer
    writematrix(settler_data, filename);
else
    csvwrite(filename, settler_data);
end
