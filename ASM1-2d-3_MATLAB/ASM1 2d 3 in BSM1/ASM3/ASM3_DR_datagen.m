%% ASM3 BENCHMARK MODEL DEMAND RESPONSE DATA GENERATION SCRIPT
% Author: Samuel Botts White
% Date: 2025

%% ===============================================
%% INITIALIZATION AND CONFIGURATION
%% ==============================================

fprintf('\n=== ASM3 BENCHMARK MODEL ===\n');
fprintf('Initializing workspace and model parameters...\n');

% Step 1: Initialize all variables and parameters (per README)
benchmarkinit_ASM3_DR;

% Store critical variables before any workspace operations
ss_model = 'benchmarkss';           % Steady state model
main_model = 'DR_benchmark_LT';     % Dynamic model
simend = 609;                       % Total simulation time [days]
cal_time = 245;                     % Calibration time [days]
pause_time = 14;                    % Segment duration [days]
Qr_DR = Qin * 1.0;                  % Recycle flow rate
iteration = 1;                      % Counter for data writers

% Calculate derived parameters
total_segments = floor((simend - cal_time) / pause_time);

% Initialize flags
ss_done = false;
nominal_cal_done = false;
experimental_cal_done = false;

% Create output directory if needed
if ~exist('ASM3_OutputDB', 'dir')
    mkdir('ASM3_OutputDB');
end

fprintf('Configuration complete:\n');
fprintf('  - Simulation duration: %.1f days\n', simend);
fprintf('  - Calibration period: %.1f days\n', cal_time);
fprintf('  - Segment duration: %.1f days\n', pause_time);
fprintf('  - Total segments: %d\n', total_segments);

% Save initial workspace state
save('workspace_initial_config.mat');

%% ===============================================
%% PHASE 1: STEADY STATE INITIALIZATION
%% ===============================================

fprintf('\n=== PHASE 1b: STEADY STATE INITIALIZATION ===\n');

if ~ss_done
    fprintf('Running steady state model with constant influent...\n');
    
    % Step 2: Run steady state model (per README pattern)
    benchmarkss;  % Opens the Simulink model
    
    % Start steady state simulation
    set_param(ss_model, 'SimulationCommand', 'start');
    
    % Wait for steady state completion
    while ~strcmp(get_param(ss_model, 'SimulationStatus'), 'stopped')
        pause(0.1);
    end
    
    % Step 3: Save steady state values (per README pattern)
    stateset;  % Initialize state variables to steady state values
    
    % Save initial steady state workspace
    save('workspace_steady_state_initial.mat');
    ss_done = true;
    
    fprintf('✓ Steady state initialization completed\n');
    fprintf('  States saved to workspace_steady_state_initial.mat\n');
end


fprintf('\n=== PHASE 1a: EXPERIMENTAL CALIBRATION ===\n');

if ~experimental_cal_done
    fprintf('Creating experimental pseudo-steady state...\n');
    
    % Reload initial steady state
    ss_done = false;
    load('workspace_steady_state_initial.mat');
    
    % Re-run steady state to ensure consistency
    benchmarkss;
    if ~ss_done
        set_param(ss_model, 'SimulationCommand', 'start');
        
        while ~strcmp(get_param(ss_model, 'SimulationStatus'), 'stopped')
            pause(0.1);
        end
        
        stateset;
        ss_done = true;
        fprintf('  Steady state re-initialized\n');
    end
    
    % Load and configure dynamic model
    DR_benchmark_LT;
    
    % Configure for calibration
    set_param(main_model, 'StartTime', '0');
    set_param(main_model, 'StopTime', num2str(cal_time));
    set_param(main_model, 'Solver', 'ode45');
    set_param(main_model, 'SimulationMode', 'normal');
    
    if exist('safe_set_outputtimes', 'file')
        safe_set_outputtimes(main_model);
    end
    
    % Load experimental setpoints
    clear KLa3_Setpoints_ASM3 KLa4_Setpoints_ASM3 KLa5_Setpoints_ASM3 kla3in kla4in kla5in
    load('KLa3_Setpoints_experiment.mat');
    load('KLa4_Setpoints_experiment.mat');
    load('KLa5_Setpoints_experiment.mat');
    fprintf('  Experimental setpoints loaded\n');
    
    % Run calibration
    set_param(main_model, 'SimulationCommand', 'start');
    
    start_time = tic;
    while ~strcmp(get_param(main_model, 'SimulationStatus'), 'stopped')
        pause(0.5);
    end
    elapsed = toc(start_time);
    
    % Save calibrated experimental state
    stateset;
    save('workspace_experimental_calibrated.mat');
    experimental_cal_done = true;
    
    fprintf('✓ Experimental calibration completed in %.1f seconds\n', elapsed);
    
    % Close model
    bdclose(main_model);
    
    % Clear workspace except essential variables
    clearvars -except ss_model main_model simend cal_time pause_time total_segments ...
                     ss_done nominal_cal_done experimental_cal_done Qr_DR;
end

%% ===============================================
%% PHASE 2: MAIN DATA GENERATION LOOP
%% ===============================================

fprintf('\n=== PHASE 2: MAIN DATA GENERATION ===\n');
fprintf('Processing %d segments from t=%.1f to t=%.1f days\n', ...
    total_segments, cal_time, simend);

% Main loop timer
total_start = tic;

% IMPORTANT: Using current_segment as loop variable to avoid conflicts
% with workspace loads that might contain a 'segment' variable
for current_segment = 1:total_segments
    
    % ===================================================================
    % CRITICAL: Create protected variable structure for this iteration
    % This completely isolates loop variables from workspace contamination
    % ===================================================================
    PROTECTED_VARS = struct();
    PROTECTED_VARS.segment_number = current_segment;
    PROTECTED_VARS.start_time = cal_time + (current_segment - 1) * pause_time;
    PROTECTED_VARS.end_time = cal_time + current_segment * pause_time;
    PROTECTED_VARS.total_segments = total_segments;
    PROTECTED_VARS.cal_time = cal_time;
    PROTECTED_VARS.pause_time = pause_time;
    
    fprintf('\n--- Segment %d/%d (t=%.1f to %.1f days) ---\n', ...
        PROTECTED_VARS.segment_number, PROTECTED_VARS.total_segments, ...
        PROTECTED_VARS.start_time, PROTECTED_VARS.end_time);
    
    %% ========== EXPERIMENTAL RUN ==========
    fprintf('  Running experimental phase...\n');
    exp_start = tic;
    
    % Load experimental workspace
    load_system(main_model);
    open(main_model);
    
    % Configure model with protected values BEFORE any workspace operations
    set_param(main_model, 'StartTime', num2str(PROTECTED_VARS.start_time));
    set_param(main_model, 'StopTime', num2str(PROTECTED_VARS.end_time));
    set_param(main_model, 'Solver', 'ode45');
    set_param(main_model, 'SimulationMode', 'normal');
    
    % Load workspace (may contaminate variables)
    load('workspace_experimental_calibrated.mat');
    
    % RESTORE protected variables immediately after workspace load
    segment = PROTECTED_VARS.segment_number;
    seg_start = PROTECTED_VARS.start_time;
    seg_end = PROTECTED_VARS.end_time;
    iteration = PROTECTED_VARS.segment_number;
    
    % Set OutputTimes using protected values
    if exist('safe_set_outputtimes', 'file')
        safe_set_outputtimes(main_model);
    else
        outputtimes = PROTECTED_VARS.start_time:(1/96):PROTECTED_VARS.end_time;
        set_param(main_model, 'OutputOption', 'SpecifiedOutputTimes');
        set_param(main_model, 'OutputTimes', mat2str(outputtimes));
    end
    
    % Load experimental setpoints
    clear KLa3_Setpoints_ASM3 KLa4_Setpoints_ASM3 KLa5_Setpoints_ASM3 kla3in kla4in kla5in
    load('KLa3_Setpoints_experiment.mat');
    load('KLa4_Setpoints_experiment.mat');
    load('KLa5_Setpoints_experiment.mat');
    
    % Run simulation
    set_param(main_model, 'SimulationCommand', 'start');
    
    while ~strcmp(get_param(main_model, 'SimulationStatus'), 'stopped')
        pause(0.2);
    end
    
    % Save experimental data (with error handling)
    try
        if exist('Data_writer_newer', 'file')
            Data_writer_settler;
        end
        if exist('Data_writer_reac', 'file')
            Data_writer_reac;
        end
        if exist('perf_plant_LT_DR', 'file')
            perf_plant_LT_DR;
        end
%         if exist('figure_writer', 'file')
%             figure_writer;
%         end
        fprintf('    ✓ Experimental data saved\n');
    catch ME
        fprintf('    ⚠ Warning: Some data writers failed: %s\n', ME.message);
    end
    
    % Update experimental state for next iteration
    stateset;
    save('workspace_experimental_calibrated.mat');
    
    exp_time = toc(exp_start);
    
    % Close model
    bdclose(main_model);

    % Save progress checkpoint using protected variables
    save('simulation_progress.mat', 'PROTECTED_VARS');
end

%% ===============================================
%% COMPLETION AND SUMMARY
%% ===============================================

total_time = toc(total_start);

fprintf('\n=== MODEL LOOP COMPLETED ===\n');
fprintf('Summary:\n');
fprintf('  Total segments processed: %d\n', total_segments);
fprintf('  Simulation time range: %.1f to %.1f days\n', cal_time, simend);
fprintf('  Total execution time: %.1f minutes\n', total_time/60);

% Save final results
% save('simulation_results_final.mat');

fprintf('\nAll data saved successfully.\n');
fprintf('Check ASM3_OutputDB directory for output files.\n');