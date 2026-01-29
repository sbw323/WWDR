%% ASM3 RELIABILITY DATA GENERATION - SIMPLIFIED
% Author: Samuel Botts White
% Date: 2025
%
% Simple steady state iteration script for reliability modeling
% Only varies: KLa3, KLa4, KLa5, Q, sim_stoptime
% All other parameters use defaults from benchmarkinit_ASM3_DR
%
% Usage:
% 1. Define test cases in the test_cases matrix below
% 2. Run script
% 3. Results saved to CSV file

%% ===============================================
%% CONFIGURATION
%% ===============================================

fprintf('\n=== ASM3 RELIABILITY DATA GENERATION (SIMPLIFIED) ===\n');

% Output file path
output_file = 'ASM3_OutputDB/reliability_data/reliability_dataset.csv';

% Create output directory if needed
output_dir = fileparts(output_file);
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
    fprintf('Created output directory: %s\n', output_dir);
end

%% ===============================================
%% DEFINE TEST CASES
%% ===============================================

% Each row defines one test case:
% Columns: [KLa3, KLa4, KLa5, Q, sim_stoptime]
%
% KLa3, KLa4, KLa5 = Aeration coefficients for reactors 3, 4, 5 (1/d)
% Q = Influent flow rate (m³/d)
% sim_stoptime = Simulation stop time (days)

test_cases = [
    % KLa3  KLa4  KLa5   Q      stoptime
      240   240   240   18000   200;      % High aeration, baseline
      150   150   150   18000   200;      % Medium-high aeration
      100   100   100   18000   300;      % Medium aeration
       75    75    75   18000   400;      % Medium-low aeration
       50    50    50   18000   600;      % Low aeration
       30    30    30   18000   1000;     % Very low aeration
       20    20    20   18000   1500;     % Extremely low aeration
];

% You can add more test cases or modify the ones above
% Examples:
% - Test different flow rates: [240, 240, 240, 20000, 200]
% - Test asymmetric aeration: [100, 150, 200, 18000, 300]

num_iterations = size(test_cases, 1);

fprintf('Number of test cases: %d\n', num_iterations);
fprintf('Output file: %s\n\n', output_file);

%% ===============================================
%% MODEL NAME
%% ===============================================

ss_model = 'benchmarkss';  % Steady state model name

%% ===============================================
%% MAIN ITERATION LOOP
%% ===============================================

fprintf('Starting iterations...\n');
total_start = tic;

for iter = 1:num_iterations
    
    fprintf('\n--- Iteration %d/%d ---\n', iter, num_iterations);
    iter_start = tic;
    
    try
        %% Extract parameters for this test case
        KLa3_target = test_cases(iter, 1);
        KLa4_target = test_cases(iter, 2);
        KLa5_target = test_cases(iter, 3);
        Q_target = test_cases(iter, 4);
        sim_stoptime = test_cases(iter, 5);
        
        fprintf('  KLa: [%.0f, %.0f, %.0f], Q=%.0f, stoptime=%d\n', ...
                KLa3_target, KLa4_target, KLa5_target, Q_target, sim_stoptime);
        
        %% Save iteration variables before workspace clear
        iter_save = iter;
        test_cases_save = test_cases;
        output_file_save = output_file;
        ss_model_save = ss_model;
        num_iterations_save = num_iterations;
        total_start_save = total_start;
        KLa3_target_save = KLa3_target;
        KLa4_target_save = KLa4_target;
        KLa5_target_save = KLa5_target;
        Q_target_save = Q_target;
        sim_stoptime_save = sim_stoptime;
        
        %% Clear workspace and reinitialize with defaults
        clear all;
        
        % Restore iteration variables
        iter = iter_save;
        test_cases = test_cases_save;
        output_file = output_file_save;
        ss_model = ss_model_save;
        num_iterations = num_iterations_save;
        total_start = total_start_save;
        KLa3_target = KLa3_target_save;
        KLa4_target = KLa4_target_save;
        KLa5_target = KLa5_target_save;
        Q_target = Q_target_save;
        sim_stoptime = sim_stoptime_save;
        
        %% Initialize benchmark with all default parameters
        fprintf('  Initializing benchmark...\n');
        benchmarkinit_ASM3_DR;
        
        %% Override Q
        Q = Q_target;
        
        %% Set KLa values
        % NOTE: The method for setting KLa depends on your model structure
        % Choose one of the following methods:
        
        % Method 1: Direct workspace variables (if model reads these)
        KLa3 = KLa3_target;
        KLa4 = KLa4_target;
        KLa5 = KLa5_target;
        
        % Method 2: If using setpoint arrays (uncomment if needed)
        % KLa3_Setpoints = ones(size(KLa3_Setpoints)) * KLa3_target;
        % KLa4_Setpoints = ones(size(KLa4_Setpoints)) * KLa4_target;
        % KLa5_Setpoints = ones(size(KLa5_Setpoints)) * KLa5_target;
        
        % Method 3: Create constant setpoint files (uncomment if needed)
        % save('KLa3_Setpoints.mat', 'KLa3_Setpoints');
        % save('KLa4_Setpoints.mat', 'KLa4_Setpoints');
        % save('KLa5_Setpoints.mat', 'KLa5_Setpoints');
        
        %% Load and configure steady state model
        fprintf('  Loading steady state model...\n');
        load_system(ss_model);
        
        % Set simulation stop time
        set_param(ss_model, 'StopTime', num2str(sim_stoptime));
        
        % Set solver
        set_param(ss_model, 'Solver', 'ode45');
        set_param(ss_model, 'SimulationMode', 'normal');
        
        %% Run simulation
        fprintf('  Running simulation (stoptime=%d days)...\n', sim_stoptime);
        sim_start = tic;
        
        set_param(ss_model, 'SimulationCommand', 'start');
        
        % Wait for completion
        while ~strcmp(get_param(ss_model, 'SimulationStatus'), 'stopped')
            pause(0.1);
        end
        
        sim_time = toc(sim_start);
        fprintf('  Simulation completed in %.1f sec (%.2f min)\n', sim_time, sim_time/60);
        
        %% Capture steady state
        fprintf('  Capturing steady state...\n');
        stateset;
        
        %% Save data
        fprintf('  Saving data...\n');
        Data_writer_reliability(settler, iter, KLa3, KLa4, KLa5, Q, sim_stoptime, output_file);
        
        %% Cleanup
        bdclose(ss_model);
        
        iter_time = toc(iter_start);
        fprintf('  ✓ Iteration %d complete (%.1f sec)\n', iter, iter_time);
        
        % Estimate remaining time
        if iter < num_iterations
            avg_time = toc(total_start) / iter;
            remaining = avg_time * (num_iterations - iter);
            fprintf('  Estimated time remaining: %.1f min\n', remaining/60);
        end
        
    catch ME
        %% Error handling
        fprintf('  ✗ ERROR: %s\n', ME.message);
        
        % Try to close model
        try
            bdclose(ss_model);
        catch
        end
        
        % Continue to next iteration
        fprintf('  Continuing to next iteration...\n');
    end
    
end

%% ===============================================
%% COMPLETION SUMMARY
%% ===============================================

total_time = toc(total_start);

fprintf('\n=== COMPLETE ===\n');
fprintf('Total iterations: %d\n', num_iterations);
fprintf('Total time: %.1f min (%.2f hours)\n', total_time/60, total_time/3600);
fprintf('Average time per iteration: %.1f sec\n', total_time/num_iterations);
fprintf('\nResults saved to:\n%s\n\n', output_file);