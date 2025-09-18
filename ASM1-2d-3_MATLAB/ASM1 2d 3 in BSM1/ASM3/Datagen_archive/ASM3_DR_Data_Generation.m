%% SIMPLIFIED ASM3 DR DATA GENERATION SCRIPT
% 
% Simplified version that eliminates redundant nominal dataset generation.
% The nominal dataset is generated once and reused, while only experimental
% datasets are generated for each iteration.
%
% Follows the pattern from benchmarkinit_ASM3_DR_0.md reference script
% Author: Simplified from REFACTORED_ASM3_DR_BENCHMARKING_SCRIPT
% Date: 2025

%% ===============================================
%% INITIALIZATION AND CONFIGURATION
%% ===============================================

% Initialize script and variables (following reference pattern)
benchmarkinit_ASM3_DR;

% Configuration variables (following reference script naming convention)
ss = 'benchmarkss';
model = 'DR_benchmark_LT';
Qr_DR = Qin * 1.5;
simend = 428;                    % Total simulation time [days]
cal_time = 63;                   % Calibration time [days] 
pause_time = 14;                 % Segment duration [days]
iteration = 1;                   % Current iteration
ss_done = false;
experimental_cal_done = false;

% Calculate experimental parameters
total_segments = floor((simend - cal_time) / pause_time);

fprintf('\n=== SIMPLIFIED ASM3 DR DATA GENERATION ===\n');
fprintf('Generating experimental datasets with pre-existing nominal baseline...\n');
fprintf('Total experimental segments: %d\n', total_segments);
fprintf('Experimental period: %.1f to %.1f days\n', cal_time, simend);
fprintf('Assuming nominal datasets already exist\n');

% Create output directory if needed
if ~exist('ASM3_OutputDB', 'dir')
    mkdir('ASM3_OutputDB');
end

%% ===============================================
%% PHASE 1: STEADY STATE SETUP
%% ===============================================

fprintf('\n=== PHASE 1: STEADY STATE SETUP ===\n');

% Setup Steady State (following reference pattern exactly)
benchmarkss;
if ~ss_done
    set_param(ss, 'SimulationCommand', 'start');

    % Wait until simulation is truly stopped
    while ~strcmp(get_param(ss, 'SimulationStatus'), 'stopped')
        pause(0.1);
    end

    % When stopped, update states and mark steady state as complete
    stateset;
    ss_done = true;
    fprintf('✓ Steady state initialization completed\n');
end

%% ===============================================
%% PHASE 2: EXPERIMENTAL CALIBRATION (ONE-TIME)
%% ===============================================

fprintf('\n=== PHASE 2: EXPERIMENTAL CALIBRATION ===\n');

if ~experimental_cal_done
    fprintf('Creating experimental calibrated state...\n');
    
    % Load and configure model (following reference pattern)
    DR_benchmark_LT;
    set_param(model, 'StartTime', '0'); 
    set_param(model, 'StopTime', num2str(cal_time)); 
    set_param(model, 'Solver', 'ode45');
    set_param(model, 'SimulationMode', 'normal');
    
    % Load experimental setpoints for calibration
    clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3' 'kla3in' 'kla4in' 'kla5in'
    load('KLa3_Setpoints_experiment.mat');
    load('KLa4_Setpoints_experiment.mat');
    load('KLa5_Setpoints_experiment.mat');
    fprintf('  Experimental setpoints loaded\n');
    
    % Run experimental calibration
    if ss_done == true
        set_param(model, 'SimulationCommand', 'start');
    end
    
    % Wait for completion
    while ~strcmp(get_param(model, 'SimulationStatus'), 'stopped')
        pause(0.1);
    end
    
    % Save experimental calibrated state
    stateset;
    save('workspace_experimental_calibrated.mat');
    experimental_cal_done = true;
    
    fprintf('✓ Experimental calibration completed\n');
    
    % Close model
    bdclose(model);
end

%% ===============================================
%% PHASE 3: EXPERIMENTAL DATA GENERATION LOOP
%% ===============================================

fprintf('\n=== PHASE 3: EXPERIMENTAL DATA GENERATION ===\n');
fprintf('Processing %d experimental segments...\n', total_segments);
fprintf('Note: Using pre-existing nominal datasets for comparison\n');

% Process each experimental segment
for current_segment = 1:total_segments
    
    % Calculate segment timing
    seg_start = cal_time + (current_segment - 1) * pause_time;
    seg_end = cal_time + current_segment * pause_time;
    
    fprintf('\n--- Experimental Segment %d/%d (t=%.1f to %.1f days) ---\n', ...
        current_segment, total_segments, seg_start, seg_end);
    
    % Set iteration for data writers (critical for original data writers)
    iteration = current_segment;
    
    %% ========== EXPERIMENTAL SIMULATION ==========
    
    % Load and configure model (following reference pattern)
    load_system(model);
    open(model);
    
    % Load experimental calibrated workspace
    load('workspace_experimental_calibrated.mat');
    stateset;
    
    % Configure model for current segment
    set_param(model, 'StartTime', num2str(seg_start));
    set_param(model, 'StopTime', num2str(seg_end));
    set_param(model, 'Solver', 'ode45');
    set_param(model, 'SimulationMode', 'normal');
    
    % Set output times for segment
    if exist('safe_set_outputtimes', 'file')
        safe_set_outputtimes(model);
    end
    
    % Load experimental setpoints (following reference pattern)
    clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3' 'kla3in' 'kla4in' 'kla5in'
    load('KLa3_Setpoints_experiment.mat');
    load('KLa4_Setpoints_experiment.mat');
    load('KLa5_Setpoints_experiment.mat');
    
    % Run experimental simulation
    fprintf('  Running experimental simulation...\n');
    set_param(model, 'SimulationCommand', 'start');
    
    % Wait for completion
    while ~strcmp(get_param(model, 'SimulationStatus'), 'stopped')
        pause(0.2);
    end
    
    %% ========== EXPERIMENTAL DATA EXPORT ==========
    
    fprintf('  Exporting experimental data...\n');
    
    % Export experimental datasets (following reference pattern)
    try
        Data_writer_newer
        Data_writer_reac
        perf_plant_LT_DR
        figure_writer
        fprintf('  ✓ Experimental data exported successfully\n');
    catch ME
        fprintf('  ⚠ Warning: Some experimental data writers failed: %s\n', ME.message);
    end
    
    %% ========== STATE UPDATE ==========
    
    % Update experimental state for next iteration
    stateset;
    save('workspace_experimental_calibrated.mat');
    
    % Close model
    bdclose(model);
    
    % Progress report
    fprintf('  ✓ Segment %d completed successfully\n', current_segment);
    fprintf('  Progress: %.1f%% (%d/%d segments)\n', ...
        100*current_segment/total_segments, current_segment, total_segments);
end

%% ===============================================
%% COMPLETION
%% ===============================================

fprintf('\n=== EXPERIMENTAL DATA GENERATION COMPLETED ===\n');
fprintf('Summary:\n');
fprintf('  - Experimental segments processed: %d\n', total_segments);
fprintf('  - Time range: %.1f to %.1f days\n', cal_time, simend);
fprintf('  - Nominal datasets: Using pre-existing data\n');

% Save final results
save('experimental_results_final.mat');

fprintf('\n✓ All experimental data saved successfully\n');
fprintf('✓ Check ASM3_OutputDB directory for experimental output files\n');
fprintf('✓ Nominal datasets remain unchanged and available for comparison\n');

% Final message (following reference pattern)
disp('Experimental data generation completed finished.');