function Data_writer_reliability(settler, iter, KLa3, KLa4, KLa5, Q, sim_stoptime, output_file)
% DATA_WRITER_RELIABILITY Save steady state reliability data (Simplified)
%
% INPUTS:
%   settler         - Settler output matrix from simulation
%   iter            - Iteration number
%   KLa3            - Aeration coefficient reactor 3 (1/d)
%   KLa4            - Aeration coefficient reactor 4 (1/d)
%   KLa5            - Aeration coefficient reactor 5 (1/d)
%   Q               - Flow rate (m³/d)
%   sim_stoptime    - Simulation stop time (days)
%   output_file     - Path to output CSV file
%
% OUTPUT CSV COLUMNS:
%   iter, KLa3, KLa4, KLa5, Q, sim_stoptime,
%   SNH_eff, SI_eff, SS_eff, XI_eff, XS_eff, XH_eff, XA_eff, XSTO_eff,
%   COD_eff, failure
%
% Author: Samuel Botts White
% Date: 2025

%% Effluent limits
SNH_limit = 4.0;     % mg/L
COD_limit = 100.0;   % mg/L

%% Extract steady state values from settler matrix
% Settler columns (from Data_writer_settler.md):
% 23: SI, 24: SS, 25: SNH, 29: XI, 30: XS, 31: XBH (X_H), 32: XSTO, 33: XBA (X_A)

SNH_eff = settler(end, 25);
SI_eff = settler(end, 23);
SS_eff = settler(end, 24);
XI_eff = settler(end, 29);
XS_eff = settler(end, 30);
XH_eff = settler(end, 31);
XA_eff = settler(end, 33);
XSTO_eff = settler(end, 32);

%% Calculate COD
% COD = SI + SS + XI + XS + X_H + X_A + X_STO
COD_eff = SI_eff + SS_eff + XI_eff + XS_eff + XH_eff + XA_eff + XSTO_eff;

%% Check failure
SNH_violation = (SNH_eff > SNH_limit);
COD_violation = (COD_eff > COD_limit);
failure = double(SNH_violation || COD_violation);

%% Create output row
output_row = [iter, KLa3, KLa4, KLa5, Q, sim_stoptime, ...
              SNH_eff, SI_eff, SS_eff, XI_eff, XS_eff, XH_eff, XA_eff, XSTO_eff, ...
              COD_eff, failure];

%% Write to CSV
if iter == 1
    % First iteration: create file with header
    header = {'iter', 'KLa3', 'KLa4', 'KLa5', 'Q', 'sim_stoptime', ...
              'SNH_eff', 'SI_eff', 'SS_eff', 'XI_eff', 'XS_eff', 'XH_eff', 'XA_eff', 'XSTO_eff', ...
              'COD_eff', 'failure'};
    
    data_table = array2table(output_row, 'VariableNames', header);
    writetable(data_table, output_file);
    fprintf('    ✓ Created output file\n');
else
    % Append data
    dlmwrite(output_file, output_row, '-append', 'delimiter', ',', 'precision', '%.6f');
    fprintf('    ✓ Data appended\n');
end

%% Print results
fprintf('    SNH=%.3f mg/L, COD=%.2f mg/L', SNH_eff, COD_eff);

if failure
    fprintf(' - FAILURE');
    if SNH_violation
        fprintf(' (SNH>%.1f)', SNH_limit);
    end
    if COD_violation
        fprintf(' (COD>%.1f)', COD_limit);
    end
    fprintf('\n');
else
    fprintf(' - PASS\n');
end

end