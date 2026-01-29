%% ASM3 RELIABILITY DATA GENERATION - STEADY STATE ITERATIONS
% Author: Samuel Botts White
% Date: 2025
% Purpose: Generate steady state operating point dataset for reliability modeling
%
% This script performs multiple independent steady state simulations with
% varying operating conditions to build a dataset for fitting constant
% failure rate reliability models. Unlike dynamic simulations, each iteration
% produces a single steady state operating point.
%
% Key Features:
% - Q variable override after benchmarkinit
% - Adaptive simulation stop time based on KLa values
% - Parameter space sampling (grid or random)
% - Failure classification based on effluent limits
%
% Output: Single CSV file with one row per iteration containing:
%   - Operating conditions (Q, Qin, COD_in, TKN_in, KLa3, KLa4, KLa5)
%   - Simulation parameters (iteration, sim_stoptime)
%   - Effluent quality (SNH, COD components, total COD)
%   - Failure flags (SNH_violation, COD_violation, failure)

%% ===============================================
%% CONFIGURATION AND INITIALIZATION
%% ===============================================

fprintf('\n=== ASM3 RELIABILITY DATA GENERATION ===\n');
fprintf('Steady State Operating Point Sampling\n');
fprintf('Date: %s\n', datestr(now));

% Output configuration
base_output_dir = 'ASM3_OutputDB/reliability_data';
output_filename = 'reliability_dataset.csv';
output_filepath = fullfile(base_output_dir, output_filename);

% Create output directory if needed
if ~exist(base_output_dir, 'dir')
    mkdir(base_output_dir);
    fprintf('Created output directory: %s\n', base_output_dir);
end

% Number of iterations (operating points to sample)
num_iterations = 100;  % Adjust as needed for your study

fprintf('\nConfiguration:\n');
fprintf('  Number of iterations: %d\n', num_iterations);
fprintf('  Output file: %s\n', output_filepath);

%% ===============================================
%% PARAMETER SPACE DEFINITION
%% ===============================================

fprintf('\nDefining parameter space...\n');

% Parameter ranges for reliability study
% Adjust these ranges based on your specific study objectives

% Flow rates
Q_min = 15000;          % m³/d - minimum flow rate
Q_max = 25000;          % m³/d - maximum flow rate

Qin_min = 15000;        % m³/d - minimum influent flow (may equal Q)
Qin_max = 25000;        % m³/d - maximum influent flow

% Influent characteristics
COD_in_min = 300;       % mg/L - minimum influent COD
COD_in_max = 600;       % mg/L - maximum influent COD

TKN_in_min = 40;        % mg/L - minimum influent total Kjeldahl nitrogen
TKN_in_max = 80;        % mg/L - maximum influent TKN

% Aeration coefficients (oxygen transfer)
KLa3_min = 20;          % 1/d - minimum KLa for reactor 3
KLa3_max = 240;         % 1/d - maximum KLa for reactor 3

KLa4_min = 20;          % 1/d - minimum KLa for reactor 4
KLa4_max = 240;         % 1/d - maximum KLa for reactor 4

KLa5_min = 20;          % 1/d - minimum KLa for reactor 5
KLa5_max = 240;         % 1/d - maximum KLa for reactor 5

% Additional parameters can be added as needed
% Examples: Temperature, recycle ratio, SRT, etc.

%% ===============================================
%% PARAMETER SAMPLING STRATEGY
%% ===============================================

fprintf('Generating parameter sets...\n');

% Choose sampling strategy:
% Option 1: Random sampling (Latin Hypercube or Monte Carlo)
% Option 2: Grid search (regular intervals)
% Option 3: Custom design of experiments

% For this implementation, using random sampling with uniform distributions
% This provides good coverage of parameter space with fewer iterations

rng(42);  % Set random seed for reproducibility

% Generate random samples
param_sets = zeros(num_iterations, 7);
param_sets(:,1) = Q_min + (Q_max - Q_min) * rand(num_iterations, 1);           % Q
param_sets(:,2) = Qin_min + (Qin_max - Qin_min) * rand(num_iterations, 1);     % Qin
param_sets(:,3) = COD_in_min + (COD_in_max - COD_in_min) * rand(num_iterations, 1);  % COD_in
param_sets(:,4) = TKN_in_min + (TKN_in_max - TKN_in_min) * rand(num_iterations, 1);  % TKN_in
param_sets(:,5) = KLa3_min + (KLa3_max - KLa3_min) * rand(num_iterations, 1);  % KLa3
param_sets(:,6) = KLa4_min + (KLa4_max - KLa4_min) * rand(num_iterations, 1);  % KLa4
param_sets(:,7) = KLa5_min + (KLa5_max - KLa5_min) * rand(num_iterations, 1);  % KLa5

% Alternative: Grid search (uncomment to use)
% n_per_param = round(num_iterations^(1/7));  % Points per parameter
% Q_grid = linspace(Q_min, Q_max, n_per_param);
% ... create meshgrid and flatten to param_sets

fprintf('Parameter sets generated:\n');
fprintf('  Q range: %.0f - %.0f m³/d\n', min(param_sets(:,1)), max(param_sets(:,1)));
fprintf('  Qin range: %.0f - %.0f m³/d\n', min(param_sets(:,2)), max(param_sets(:,2)));
fprintf('  COD_in range: %.0f - %.0f mg/L\n', min(param_sets(:,3)), max(param_sets(:,3)));
fprintf('  TKN_in range: %.0f - %.0f mg/L\n', min(param_sets(:,4)), max(param_sets(:,4)));
fprintf('  KLa3 range: %.0f - %.0f 1/d\n', min(param_sets(:,5)), max(param_sets(:,5)));
fprintf('  KLa4 range: %.0f - %.0f 1/d\n', min(param_sets(:,6)), max(param_sets(:,6)));
fprintf('  KLa5 range: %.0f - %.0f 1/d\n', min(param_sets(:,7)), max(param_sets(:,7)));

%% ===============================================
%% STEADY STATE MODEL NAMES
%% ===============================================

% Model names (should match your Simulink model files)
ss_model = 'benchmarkss';           % Steady state model name

%% ===============================================
%% MAIN ITERATION LOOP
%% ===============================================

fprintf('\n=== STARTING MAIN ITERATION LOOP ===\n');
fprintf('Processing %d steady state operating points...\n', num_iterations);

% Overall timer
total_start_time = tic;

% Track successful completions
successful_iterations = 0;
failed_iterations = 0;

% Main loop - each iteration is independent
for iter = 1:num_iterations
    
    fprintf('\n--- Iteration %d/%d ---\n', iter, num_iterations);
    iter_start_time = tic;
    
    try
        %% Extract parameters for this iteration
        Q_override = param_sets(iter, 1);
        Qin = param_sets(iter, 2);
        COD_in = param_sets(iter, 3);
        TKN_in = param_sets(iter, 4);
        KLa3 = param_sets(iter, 5);
        KLa4 = param_sets(iter, 6);
        KLa5 = param_sets(iter, 7);
        
        fprintf('  Parameters: Q=%.0f, Qin=%.0f, COD_in=%.0f, TKN_in=%.0f\n', ...
                Q_override, Qin, COD_in, TKN_in);
        fprintf('              KLa3=%.0f, KLa4=%.0f, KLa5=%.0f\n', ...
                KLa3, KLa4, KLa5);
        
        %% Determine adaptive simulation stop time
        % Low KLa values require longer simulation for convergence
        min_KLa = min([KLa3, KLa4, KLa5]);
        
        if min_KLa < 30
            sim_stoptime = 2000;  % Very low aeration - extended convergence time
            fprintf('  Low KLa detected (%.1f), using extended stoptime=%d days\n', ...
                    min_KLa, sim_stoptime);
        elseif min_KLa < 50
            sim_stoptime = 1000;  % Low aeration
            fprintf('  Moderate-low KLa (%.1f), using stoptime=%d days\n', ...
                    min_KLa, sim_stoptime);
        elseif min_KLa < 100
            sim_stoptime = 500;   % Moderate aeration
        else
            sim_stoptime = 200;   % Default - normal aeration
        end
        
        %% Fresh workspace initialization
        % CRITICAL: Clear all variables to ensure independence between iterations
        % Save iteration variables before clearing
        iter_save = iter;
        param_sets_save = param_sets;
        output_filepath_save = output_filepath;
        ss_model_save = ss_model;
        num_iterations_save = num_iterations;
        Q_override_save = Q_override;
        Qin_save = Qin;
        COD_in_save = COD_in;
        TKN_in_save = TKN_in;
        KLa3_save = KLa3;
        KLa4_save = KLa4;
        KLa5_save = KLa5;
        sim_stoptime_save = sim_stoptime;
        successful_iterations_save = successful_iterations;
        failed_iterations_save = failed_iterations;
        total_start_time_save = total_start_time;
        
        % Clear workspace
        clear all;
        
        % Restore iteration variables
        iter = iter_save;
        param_sets = param_sets_save;
        output_filepath = output_filepath_save;
        ss_model = ss_model_save;
        num_iterations = num_iterations_save;
        Q_override = Q_override_save;
        Qin = Qin_save;
        COD_in = COD_in_save;
        TKN_in = TKN_in_save;
        KLa3 = KLa3_save;
        KLa4 = KLa4_save;
        KLa5 = KLa5_save;
        sim_stoptime = sim_stoptime_save;
        successful_iterations = successful_iterations_save;
        failed_iterations = failed_iterations_save;
        total_start_time = total_start_time_save;
        
        %% Initialize benchmark model with default parameters
        fprintf('  Initializing benchmark model...\n');
        benchmarkinit_ASM3_DR;
        
        %% CRITICAL: Override Q after benchmarkinit
        % benchmarkinit loads default Q value, we override it here
        Q = Q_override;
        
        % Verify override was successful
        if abs(Q - Q_override) > 1e-6
            warning('Q override may have failed! Q=%.6f, Q_override=%.6f', Q, Q_override);
        end
        
        %% Apply other operating conditions
        % Modify workspace variables as needed for your specific model
        % This section depends on how your benchmarkinit sets up variables
        
        % Example modifications (adjust based on your model structure):
        % Qin = Qin_save;  % If Qin is separate from Q
        % influent_COD = COD_in;
        % influent_TKN = TKN_in;
        % Temperature = T_operating;  % If varying temperature
        
        % Note: KLa values may need to be set differently depending on
        % whether your model uses setpoints or direct KLa values
        % Adjust the following based on your model's requirements:
        
        % Option 1: If model uses KLa setpoint variables directly
        % KLa3_setpoint = KLa3;
        % KLa4_setpoint = KLa4;
        % KLa5_setpoint = KLa5;
        
        % Option 2: If model loads KLa from files, you may need to
        % create temporary setpoint files or modify loaded arrays
        
        %% Load and configure steady state model
        fprintf('  Loading steady state model...\n');
        
        % Load the Simulink model
        load_system(ss_model);
        
        % Configure simulation stop time
        set_param(ss_model, 'StopTime', num2str(sim_stoptime));
        
        % Set solver and simulation mode
        set_param(ss_model, 'Solver', 'ode45');
        set_param(ss_model, 'SimulationMode', 'normal');
        
        %% Run steady state simulation
        fprintf('  Running steady state simulation (stoptime=%d days)...\n', sim_stoptime);
        sim_start = tic;
        
        % Start simulation
        set_param(ss_model, 'SimulationCommand', 'start');
        
        % Wait for completion
        while ~strcmp(get_param(ss_model, 'SimulationStatus'), 'stopped')
            pause(0.1);
        end
        
        sim_elapsed = toc(sim_start);
        fprintf('  Simulation completed in %.1f seconds (%.2f min)\n', ...
                sim_elapsed, sim_elapsed/60);
        
        %% Capture steady state values
        fprintf('  Capturing steady state values...\n');
        stateset;  % Initialize state variables to steady state values
        
        %% CRITICAL: Save data BEFORE workspace operations
        % Call data writer to extract and save steady state results
        fprintf('  Saving data...\n');
        
        % Pass all necessary information to data writer
        Data_writer_reliability(settler, iter, Q, Qin, COD_in, TKN_in, ...
                               KLa3, KLa4, KLa5, sim_stoptime, output_filepath);
        
        fprintf('  ✓ Iteration %d completed successfully\n', iter);
        successful_iterations = successful_iterations + 1;
        
        %% Clean up
        % Close model to free memory
        bdclose(ss_model);
        
        % Report iteration time
        iter_elapsed = toc(iter_start_time);
        fprintf('  Total iteration time: %.1f seconds (%.2f min)\n', ...
                iter_elapsed, iter_elapsed/60);
        
        % Estimate remaining time
        if iter < num_iterations
            avg_time_per_iter = toc(total_start_time) / iter;
            remaining_iters = num_iterations - iter;
            estimated_remaining_time = avg_time_per_iter * remaining_iters;
            fprintf('  Estimated time remaining: %.1f minutes\n', ...
                    estimated_remaining_time/60);
        end
        
    catch ME
        %% Error handling
        fprintf('  ✗ ERROR in iteration %d: %s\n', iter, ME.message);
        fprintf('     Stack trace:\n');
        for k = 1:length(ME.stack)
            fprintf('       %s (line %d)\n', ME.stack(k).name, ME.stack(k).line);
        end
        
        failed_iterations = failed_iterations + 1;
        
        % Try to close model if it's open
        try
            bdclose(ss_model);
        catch
            % Model may not be open, ignore
        end
        
        % Decide whether to continue or abort
        if failed_iterations > num_iterations * 0.1  % If >10% fail
            fprintf('\n!!! Too many failures (%.0f%%), aborting simulation !!!\n', ...
                    100*failed_iterations/iter);
            break;
        else
            fprintf('  Continuing to next iteration...\n');
        end
    end
    
end  % End main iteration loop

%% ===============================================
%% COMPLETION SUMMARY
%% ===============================================

total_elapsed_time = toc(total_start_time);

fprintf('\n=== SIMULATION COMPLETE ===\n');
fprintf('Summary:\n');
fprintf('  Total iterations attempted: %d\n', iter);
fprintf('  Successful: %d (%.1f%%)\n', successful_iterations, ...
        100*successful_iterations/iter);
fprintf('  Failed: %d (%.1f%%)\n', failed_iterations, ...
        100*failed_iterations/iter);
fprintf('  Total execution time: %.1f minutes (%.2f hours)\n', ...
        total_elapsed_time/60, total_elapsed_time/3600);

if successful_iterations > 0
    fprintf('  Average time per iteration: %.1f seconds\n', ...
            total_elapsed_time/successful_iterations);
end

fprintf('\nResults saved to:\n');
fprintf('  %s\n', output_filepath);

if exist(output_filepath, 'file')
    file_info = dir(output_filepath);
    fprintf('  File size: %.2f KB\n', file_info.bytes/1024);
    fprintf('  Expected rows: %d (including header)\n', successful_iterations + 1);
else
    fprintf('  WARNING: Output file not found!\n');
end

fprintf('\nNext steps:\n');
fprintf('  1. Verify output file integrity\n');
fprintf('  2. Perform post-processing analysis\n');
fprintf('  3. Fit reliability models to data\n');
fprintf('  4. Identify safe operating envelope\n');

fprintf('\n=== SCRIPT COMPLETE ===\n\n');