function benchmarkinit_ASM3_DR_refactored()
%% REFACTORED ASM3 DR BENCHMARKING SCRIPT
% Maintains the original ASM3 initialization pattern from readme while
% incorporating efficiency improvements from the optimized version
%
% Pattern from README:
% 1. Run benchmarkinit to initialize variables/parameters
% 2. Run benchmarkss for steady state with constant influent
% 3. Use stateset to save final values
% 4. Run dynamic model with appropriate configurations
%
% Author: Refactored version combining original pattern with optimizations
% Date: 2025

%% ===============================================
%% INITIALIZATION AND CONFIGURATION
%% ===============================================

fprintf('\n=== ASM3 DR BENCHMARKING - REFACTORED VERSION ===\n');
fprintf('Initializing workspace and model parameters...\n');

% Step 1: Initialize all variables and parameters (per README)
benchmarkinit_ASM3_DR;

% Protected configuration to prevent workspace corruption
CONFIG = struct();
CONFIG.ss_model = 'benchmarkss';           % Steady state model
CONFIG.main_model = 'DR_benchmark_LT';     % Dynamic model
CONFIG.simend = 428;                       % Total simulation time [days]
CONFIG.cal_time = 63;                      % Calibration time [days]
CONFIG.pause_time = 14;                    % Segment duration [days]
CONFIG.solver = 'ode45';                   % Dynamic solver (ode15s for SS)

% Store critical variables that might get cleared
CONFIG.Qr_DR = Qin * 1.5;                  % Recycle flow rate
CONFIG.Qin0 = Qin0;                        % Store influent flow

% Calculate derived parameters
CONFIG.total_segments = floor((CONFIG.simend - CONFIG.cal_time) / CONFIG.pause_time);

% Flags for tracking completion status
flags = struct();
flags.ss_done = false;
flags.nominal_cal_done = false;
flags.experimental_cal_done = false;

% Create output directory if needed
if ~exist('ASM3_OutputDB', 'dir')
    mkdir('ASM3_OutputDB');
end

fprintf('Configuration complete:\n');
fprintf('  - Simulation duration: %.1f days\n', CONFIG.simend);
fprintf('  - Calibration period: %.1f days\n', CONFIG.cal_time);
fprintf('  - Segment duration: %.1f days\n', CONFIG.pause_time);
fprintf('  - Total segments: %d\n', CONFIG.total_segments);

%% ===============================================
%% PHASE 1: STEADY STATE INITIALIZATION
%% ===============================================

fprintf('\n=== PHASE 1: STEADY STATE INITIALIZATION ===\n');

if ~flags.ss_done
    fprintf('Running steady state model with constant influent...\n');
    
    % Step 2: Run steady state model (per README pattern)
    eval(CONFIG.ss_model);  % Opens the Simulink model
    
    % Configure for steady state (uses ode15s as per README)
    set_param(CONFIG.ss_model, 'Solver', 'ode15s');
    set_param(CONFIG.ss_model, 'RelTol', '1e-5');
    set_param(CONFIG.ss_model, 'AbsTol', '1e-8');
    set_param(CONFIG.ss_model, 'SimulationCommand', 'start');
    
    % Wait for steady state completion
    while ~strcmp(get_param(CONFIG.ss_model, 'SimulationStatus'), 'stopped')
        pause(0.1);
    end
    
    % Step 3: Save steady state values (per README pattern)
    stateset;  % Initialize state variables to steady state values
    
    % Save initial steady state workspace
    save('workspace_steady_state_initial.mat');
    flags.ss_done = true;
    
    fprintf('✓ Steady state initialization completed\n');
    fprintf('  States saved to workspace_steady_state_initial.mat\n');
end

%% ===============================================
%% PHASE 2: CREATE NOMINAL PSEUDO-STEADY STATE
%% ===============================================

fprintf('\n=== PHASE 2: NOMINAL CALIBRATION ===\n');

if ~flags.nominal_cal_done
    fprintf('Creating nominal pseudo-steady state...\n');
    
    % Load and configure dynamic model
    eval(CONFIG.main_model);
    
    % Configure model for calibration period
    set_param(CONFIG.main_model, 'StartTime', '0');
    set_param(CONFIG.main_model, 'StopTime', num2str(CONFIG.cal_time));
    set_param(CONFIG.main_model, 'Solver', CONFIG.solver);
    set_param(CONFIG.main_model, 'SimulationMode', 'normal');
    set_param(CONFIG.main_model, 'RelTol', '1e-5');
    set_param(CONFIG.main_model, 'AbsTol', '1e-8');
    
    % Set output times if function exists
    if exist('safe_set_outputtimes', 'file')
        safe_set_outputtimes(CONFIG.main_model);
    else
        outputtimes = 0:(1/96):CONFIG.cal_time;
        set_param(CONFIG.main_model, 'OutputOption', 'SpecifiedOutputTimes');
        set_param(CONFIG.main_model, 'OutputTimes', mat2str(outputtimes));
    end
    
    % Clear previous setpoints and load nominal setpoints
    clear_setpoints();
    load('KLa3_Setpoints_nominal.mat');
    load('KLa4_Setpoints_nominal.mat');
    load('KLa5_Setpoints_nominal.mat');
    fprintf('  Nominal setpoints loaded\n');
    
    % Run calibration simulation
    set_param(CONFIG.main_model, 'SimulationCommand', 'start');
    
    % Monitor progress
    start_time = tic;
    while ~strcmp(get_param(CONFIG.main_model, 'SimulationStatus'), 'stopped')
        pause(0.5);
    end
    elapsed = toc(start_time);
    
    % Save calibrated nominal state
    stateset;
    save('workspace_nominal_calibrated.mat');
    flags.nominal_cal_done = true;
    
    fprintf('✓ Nominal calibration completed in %.1f seconds\n', elapsed);
    
    % Close model to free memory
    bdclose(CONFIG.main_model);
    
    % Clear workspace except essential variables
    clearvars -except CONFIG flags;
end

%% ===============================================
%% PHASE 3: CREATE EXPERIMENTAL PSEUDO-STEADY STATE
%% ===============================================

fprintf('\n=== PHASE 3: EXPERIMENTAL CALIBRATION ===\n');

if ~flags.experimental_cal_done
    fprintf('Creating experimental pseudo-steady state...\n');
    
    % Reload initial steady state
    load('workspace_steady_state_initial.mat');
    
    % Re-run steady state to ensure consistency
    eval(CONFIG.ss_model);
    set_param(CONFIG.ss_model, 'SimulationCommand', 'start');
    
    while ~strcmp(get_param(CONFIG.ss_model, 'SimulationStatus'), 'stopped')
        pause(0.1);
    end
    
    stateset;
    fprintf('  Steady state re-initialized\n');
    
    % Load and configure dynamic model
    eval(CONFIG.main_model);
    
    % Configure for calibration
    set_param(CONFIG.main_model, 'StartTime', '0');
    set_param(CONFIG.main_model, 'StopTime', num2str(CONFIG.cal_time));
    set_param(CONFIG.main_model, 'Solver', CONFIG.solver);
    set_param(CONFIG.main_model, 'SimulationMode', 'normal');
    
    if exist('safe_set_outputtimes', 'file')
        safe_set_outputtimes(CONFIG.main_model);
    else
        outputtimes = 0:(1/96):CONFIG.cal_time;
        set_param(CONFIG.main_model, 'OutputOption', 'SpecifiedOutputTimes');
        set_param(CONFIG.main_model, 'OutputTimes', mat2str(outputtimes));
    end
    
    % Load experimental setpoints
    clear_setpoints();
    load('KLa3_Setpoints_experiment.mat');
    load('KLa4_Setpoints_experiment.mat');
    load('KLa5_Setpoints_experiment.mat');
    fprintf('  Experimental setpoints loaded\n');
    
    % Run calibration
    set_param(CONFIG.main_model, 'SimulationCommand', 'start');
    
    start_time = tic;
    while ~strcmp(get_param(CONFIG.main_model, 'SimulationStatus'), 'stopped')
        pause(0.5);
    end
    elapsed = toc(start_time);
    
    % Save calibrated experimental state
    stateset;
    save('workspace_experimental_calibrated.mat');
    flags.experimental_cal_done = true;
    
    fprintf('✓ Experimental calibration completed in %.1f seconds\n', elapsed);
    
    % Close model
    bdclose(CONFIG.main_model);
    
    % Clear workspace except essential variables
    clearvars -except CONFIG flags;
end

%% ===============================================
%% PHASE 4: MAIN DATA GENERATION LOOP
%% ===============================================

fprintf('\n=== PHASE 4: MAIN DATA GENERATION ===\n');
fprintf('Processing %d segments from t=%.1f to t=%.1f days\n', ...
    CONFIG.total_segments, CONFIG.cal_time, CONFIG.simend);

% Initialize data storage
results = struct();
results.segments = [];
results.experimental_times = [];
results.nominal_times = [];

% Main loop timer
total_start = tic;

for segment = 1:CONFIG.total_segments
    
    % Calculate segment timing
    seg_start = CONFIG.cal_time + (segment - 1) * CONFIG.pause_time;
    seg_end = CONFIG.cal_time + segment * CONFIG.pause_time;
    
    fprintf('\n--- Segment %d/%d (t=%.1f to %.1f days) ---\n', ...
        segment, CONFIG.total_segments, seg_start, seg_end);
    
    %% ========== EXPERIMENTAL RUN ==========
    fprintf('  Running experimental phase...\n');
    exp_start = tic;
    
    % Load experimental workspace
    load_system(CONFIG.main_model);
    open_system(CONFIG.main_model);
    load('workspace_experimental_calibrated.mat');
    stateset;
    
    % Configure for segment
    set_param(CONFIG.main_model, 'StartTime', num2str(seg_start));
    set_param(CONFIG.main_model, 'StopTime', num2str(seg_end));
    set_param(CONFIG.main_model, 'Solver', CONFIG.solver);
    
    if exist('safe_set_outputtimes', 'file')
        safe_set_outputtimes(CONFIG.main_model);
    else
        outputtimes = seg_start:(1/96):seg_end;
        set_param(CONFIG.main_model, 'OutputOption', 'SpecifiedOutputTimes');
        set_param(CONFIG.main_model, 'OutputTimes', mat2str(outputtimes));
    end
    
    % Load experimental setpoints
    clear_setpoints();
    load('KLa3_Setpoints_experiment.mat');
    load('KLa4_Setpoints_experiment.mat');
    load('KLa5_Setpoints_experiment.mat');
    
    % Store iteration number for data writers
    iteration = segment;
    
    % Run simulation
    set_param(CONFIG.main_model, 'SimulationCommand', 'start');
    
    while ~strcmp(get_param(CONFIG.main_model, 'SimulationStatus'), 'stopped')
        pause(0.2);
    end
    
    % Save experimental data (with error handling)
    try
        if exist('Data_writer_newer', 'file')
            Data_writer_newer;
        end
        if exist('Data_writer_reac', 'file')
            Data_writer_reac;
        end
        if exist('perf_plant_LT_DR', 'file')
            perf_plant_LT_DR;
        end
        if exist('figure_writer', 'file')
            figure_writer;
        end
        fprintf('    ✓ Experimental data saved\n');
    catch ME
        fprintf('    ⚠ Warning: Some data writers failed: %s\n', ME.message);
    end
    
    % Update experimental state for next iteration
    stateset;
    save('workspace_experimental_calibrated.mat');
    
    exp_time = toc(exp_start);
    results.experimental_times(segment) = exp_time;
    
    % Close model
    bdclose(CONFIG.main_model);
    
    %% ========== NOMINAL RUN ==========
    fprintf('  Running nominal phase...\n');
    nom_start = tic;
    
    % Load nominal workspace
    load_system(CONFIG.main_model);
    open_system(CONFIG.main_model);
    load('workspace_nominal_calibrated.mat');
    stateset;
    
    % Configure for segment
    set_param(CONFIG.main_model, 'StartTime', num2str(seg_start));
    set_param(CONFIG.main_model, 'StopTime', num2str(seg_end));
    set_param(CONFIG.main_model, 'Solver', CONFIG.solver);
    
    if exist('safe_set_outputtimes', 'file')
        safe_set_outputtimes(CONFIG.main_model);
    else
        outputtimes = seg_start:(1/96):seg_end;
        set_param(CONFIG.main_model, 'OutputOption', 'SpecifiedOutputTimes');
        set_param(CONFIG.main_model, 'OutputTimes', mat2str(outputtimes));
    end
    
    % Load nominal setpoints
    clear_setpoints();
    load('KLa3_Setpoints_nominal.mat');
    load('KLa4_Setpoints_nominal.mat');
    load('KLa5_Setpoints_nominal.mat');
    
    % Run simulation
    set_param(CONFIG.main_model, 'SimulationCommand', 'start');
    
    while ~strcmp(get_param(CONFIG.main_model, 'SimulationStatus'), 'stopped')
        pause(0.2);
    end
    
    % Save nominal data
    try
        if exist('Data_writer_nominal', 'file')
            Data_writer_nominal;
        end
        if exist('Data_writer_nominal_reac', 'file')
            Data_writer_nominal_reac;
        end
        if exist('perf_plant_LT_DR', 'file')
            perf_plant_LT_DR;
        end
        if exist('figure_writer_nominal', 'file')
            figure_writer_nominal;
        end
        fprintf('    ✓ Nominal data saved\n');
    catch ME
        fprintf('    ⚠ Warning: Some data writers failed: %s\n', ME.message);
    end
    
    % Update nominal state for next iteration
    stateset;
    save('workspace_nominal_calibrated.mat');
    
    nom_time = toc(nom_start);
    results.nominal_times(segment) = nom_time;
    
    % Close model
    bdclose(CONFIG.main_model);
    
    % Progress report
    fprintf('  Segment %d completed (Exp: %.1fs, Nom: %.1fs)\n', ...
        segment, exp_time, nom_time);
    
    % Save progress checkpoint
    results.segments(segment) = segment;
    save('simulation_progress.mat', 'results', 'CONFIG', 'segment');
end

%% ===============================================
%% COMPLETION AND SUMMARY
%% ===============================================

total_time = toc(total_start);

fprintf('\n=== SIMULATION COMPLETED SUCCESSFULLY ===\n');
fprintf('Summary:\n');
fprintf('  Total segments processed: %d\n', CONFIG.total_segments);
fprintf('  Simulation time range: %.1f to %.1f days\n', CONFIG.cal_time, CONFIG.simend);
fprintf('  Total execution time: %.1f minutes\n', total_time/60);
fprintf('  Average time per segment:\n');
fprintf('    - Experimental: %.1f seconds\n', mean(results.experimental_times));
fprintf('    - Nominal: %.1f seconds\n', mean(results.nominal_times));

% Save final results
save('simulation_results_final.mat', 'results', 'CONFIG');

fprintf('\nAll data saved successfully.\n');
fprintf('Check ASM3_OutputDB directory for output files.\n');

end

%% ===============================================
%% HELPER FUNCTION: Clear Setpoints
%% ===============================================

function clear_setpoints()
    % Clear any existing setpoint variables to prevent conflicts
    clear_vars = {'KLa3_Setpoints_ASM3', 'KLa4_Setpoints_ASM3', ...
                  'KLa5_Setpoints_ASM3', 'kla3in', 'kla4in', 'kla5in'};
    for i = 1:length(clear_vars)
        if evalin('base', sprintf('exist(''%s'', ''var'')', clear_vars{i}))
            evalin('base', sprintf('clear %s', clear_vars{i}));
        end
    end
end