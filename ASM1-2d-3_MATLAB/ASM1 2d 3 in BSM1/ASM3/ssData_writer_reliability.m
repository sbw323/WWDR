function ssData_writer_reliability(settler, iter, KLa3, KLa4, KLa5, Q, sim_stoptime, output_file)
% ssDATA_WRITER_RELIABILITY 
% Saves steady state output for reliability analysis.
%
% INPUTS:
%   settler: Output matrix from benchmarkss (requires specific columns)
%   iter, KLa3...: Simulation parameters for logging
%
% OUTPUT: Appends row to CSV file.

    %% 1. Effluent Limits (Used for Failure Flag)
    SNH_limit = 4.0;     % mg/L
    COD_limit = 100.0;   % mg/L

    %% 2. Extract Steady State Values (Last Row)
    % Column mapping based on BSM1/ASM3 standard:
    % 23: S_I, 24: S_S, 25: S_NH, 29: X_I, 30: X_S, 31: X_H, 32: X_STO, 33: X_A
    
    SNH_eff  = settler(end, 25);
    
    % COD Components
    SI_eff   = settler(end, 23);
    SS_eff   = settler(end, 24);
    XI_eff   = settler(end, 29);
    XS_eff   = settler(end, 30);
    XH_eff   = settler(end, 31);
    XSTO_eff = settler(end, 32); % Included for accurate ASM3 COD calc
    XA_eff   = settler(end, 33);

    %% 3. Calculate COD
    % COD = Sum of all organic components
    COD_eff = SI_eff + SS_eff + XI_eff + XS_eff + XH_eff + XA_eff + XSTO_eff;

    %% 4. Determine Failure (Boolean)
    % Returns 1 if either limit is violated, 0 otherwise
    is_fail = (SNH_eff > SNH_limit) || (COD_eff > COD_limit);
    failure = double(is_fail);

    %% 5. Construct Output Row
    output_data = [iter, KLa3, KLa4, KLa5, Q, sim_stoptime, ...
                   SNH_eff, SI_eff, SS_eff, XI_eff, XS_eff, ...
                   XH_eff, XA_eff, XSTO_eff, COD_eff, failure];

    %% 6. Write to CSV
    if iter == 1
        % Create new file with Header
        header = {'Iter', 'KLa3', 'KLa4', 'KLa5', 'Q', 'StopTime', ...
                  'SNH', 'S_I', 'S_S', 'X_I', 'X_S', ...
                  'X_H', 'X_A', 'X_STO', 'COD', 'Failure'};
        
        % Write header using Table for simplicity
        T = array2table(output_data, 'VariableNames', header);
        writetable(T, output_file);
        fprintf('      -> Created file: %s\n', output_file);
    else
        % Append data row
        dlmwrite(output_file, output_data, '-append', 'delimiter', ',', 'precision', 6);
        fprintf('      -> Data appended.\n');
    end

end