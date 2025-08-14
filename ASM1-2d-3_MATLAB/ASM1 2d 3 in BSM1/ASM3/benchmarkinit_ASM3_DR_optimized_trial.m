function benchmarkinit_ASM3_DR_optimized_trial()
%% OPTIMIZED SIMULATION SCRIPT FOR ASM3 DR BENCHMARKING
% Follows original working script pattern with efficiency improvements

%% ===============================================
%% INITIALIZATION AND CONFIGURATION
%% ===============================================

% Initialize script and paths
benchmarkinit_ASM3_DR;

% Core configuration parameters (protected from workspace loads)
PROTECTED_CONFIG = struct();
PROTECTED_CONFIG.ss_model = 'benchmarkss';
PROTECTED_CONFIG.main_model = 'DR_benchmark_LT';
PROTECTED_CONFIG.simend = 428;         % Total simulation time [days]
PROTECTED_CONFIG.cal_time = 63;        % Calibration time [days] 
PROTECTED_CONFIG.pause_time = 14;      % Segment duration [days]
PROTECTED_CONFIG.Qr_DR = Qin * 1.5;    % Flow rate parameter

% Calculate derived parameters
PROTECTED_CONFIG.total_segments = floor((PROTECTED_CONFIG.simend - PROTECTED_CONFIG.cal_time) / PROTECTED_CONFIG.pause_time);

% Initialize completion flags
ss_done = false;
nominal_cal_done = false;
experimental_cal_done = false;

fprintf('=== OPTIMIZED ASM3 DR SIMULATION INITIALIZED ===\n');
fprintf('Total segments to process: %d\n', PROTECTED_CONFIG.total_segments);
fprintf('Simulation range: %.1f to %.1f days\n', PROTECTED_CONFIG.cal_time, PROTECTED_CONFIG.simend);

%% ===============================================
%% PHASE 1: STEADY STATE INITIALIZATION
%% ===============================================

fprintf('\n=== PHASE 1: STEADY STATE SETUP ===\n');

if ~ss_done
    % Initialize steady state exactly like original
    benchmarkss;
    set_param(PROTECTED_CONFIG.ss_model, 'SimulationCommand', 'start');
    
    % Wait until simulation is truly stopped
    while ~strcmp(get_param(PROTECTED_CONFIG.ss_model, 'SimulationStatus'), 'stopped')
        pause(0.1);
    end
    
    % When stopped, update states and mark steady state as complete
    stateset;
    save('workspace_dynamic_ss.mat');
    ss_done = true;
    fprintf('✓ Steady state initialization completed\n');
end

%% ===============================================
%% PHASE 2: NOMINAL CALIBRATION PHASE
%% ===============================================

fprintf('\n=== PHASE 2: NOMINAL CALIBRATION ===\n');

if ~nominal_cal_done
    % Load and configure model for nominal calibration
    eval(PROTECTED_CONFIG.main_model);
    set_param(PROTECTED_CONFIG.main_model, 'StartTime', '0');
    set_param(PROTECTED_CONFIG.main_model, 'StopTime', num2str(PROTECTED_CONFIG.cal_time));
    set_param(PROTECTED_CONFIG.main_model, 'Solver', 'ode45');
    set_param(PROTECTED_CONFIG.main_model, 'SimulationMode', 'normal');
    safe_set_outputtimes(PROTECTED_CONFIG.main_model);
    
    % Load nominal setpoints before starting
    clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3'
    load('KLa3_Setpoints_nominal.mat');
    load('KLa4_Setpoints_nominal.mat');
    load('KLa5_Setpoints_nominal.mat');
    fprintf('Nominal setpoints loaded for calibration\n');
    
    % Start nominal calibration simulation
    set_param(PROTECTED_CONFIG.main_model, 'SimulationCommand', 'start');
    
    % Wait for completion
    while ~strcmp(get_param(PROTECTED_CONFIG.main_model, 'SimulationStatus'), 'stopped')
        pause(0.2);
    end
    
    % Save nominal pseudo-steady state
    stateset;
    save('workspace_dynamic_nominal.mat');
    nominal_cal_done = true;
    fprintf('✓ Nominal pseudo-steady state created\n');
    
    % Close model and clear workspace like original
    bdclose(PROTECTED_CONFIG.main_model);
    clearvars -except PROTECTED_CONFIG ss_done nominal_cal_done experimental_cal_done;
end

%% ===============================================
%% PHASE 3: EXPERIMENTAL CALIBRATION PHASE
%% ===============================================

fprintf('\n=== PHASE 3: EXPERIMENTAL CALIBRATION ===\n');

if ~experimental_cal_done
    % Reload initial steady state like original
    ss_done = false;
    load('workspace_dynamic_ss.mat');
    benchmarkss;
    if ~ss_done
        set_param(PROTECTED_CONFIG.ss_model, 'SimulationCommand', 'start');
        
        % Wait until simulation is truly stopped
        while ~strcmp(get_param(PROTECTED_CONFIG.ss_model, 'SimulationStatus'), 'stopped')
            pause(0.1);
        end
        
        % When stopped, update states
        stateset;
        ss_done = true;
        fprintf('Steady state reloaded for experimental calibration\n');
    end
    
    % Load and configure model for experimental calibration
    eval(PROTECTED_CONFIG.main_model);
    set_param(PROTECTED_CONFIG.main_model, 'StartTime', '0');
    set_param(PROTECTED_CONFIG.main_model, 'StopTime', num2str(PROTECTED_CONFIG.cal_time));
    set_param(PROTECTED_CONFIG.main_model, 'Solver', 'ode45');
    set_param(PROTECTED_CONFIG.main_model, 'SimulationMode', 'normal');
    safe_set_outputtimes(PROTECTED_CONFIG.main_model);
    
    % Load experimental setpoints before starting
    clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3'
    load('KLa3_Setpoints_experiment.mat');
    load('KLa4_Setpoints_experiment.mat');
    load('KLa5_Setpoints_experiment.mat');
    fprintf('Experimental setpoints loaded for calibration\n');
    
    % Start experimental calibration simulation
    set_param(PROTECTED_CONFIG.main_model, 'SimulationCommand', 'start');
    
    % Wait for completion
    while ~strcmp(get_param(PROTECTED_CONFIG.main_model, 'SimulationStatus'), 'stopped')
        pause(0.2);
    end
    
    % Save experimental pseudo-steady state
    stateset;
    save('workspace_dynamic_experimental.mat');
    experimental_cal_done = true;
    fprintf('✓ Experimental pseudo-steady state created\n');
    
    % Close model and clear workspace like original
    bdclose(PROTECTED_CONFIG.main_model);
    clearvars -except PROTECTED_CONFIG ss_done nominal_cal_done experimental_cal_done;
end

%% ===============================================
%% PHASE 4: MAIN DATA GENERATION LOOP
%% ===============================================

fprintf('\n=== PHASE 4: MAIN DATA GENERATION ===\n');
fprintf('Processing %d segments...\n', PROTECTED_CONFIG.total_segments);

% Progress tracking
progress_timer = tic;

for segment_idx = 1:PROTECTED_CONFIG.total_segments
    segment_timer = tic;
    
    % Calculate timing for current segment (using protected config)
    current_start_time = PROTECTED_CONFIG.cal_time + (segment_idx - 1) * PROTECTED_CONFIG.pause_time;
    current_end_time = PROTECTED_CONFIG.cal_time + segment_idx * PROTECTED_CONFIG.pause_time;
    
    fprintf('\n--- Segment %d/%d (t=%.1f to %.1f days) ---\n', ...
        segment_idx, PROTECTED_CONFIG.total_segments, current_start_time, current_end_time);
    
    %% ============ EXPERIMENTAL RUN ============
    fprintf('  Running experimental phase...\n');
    
    % Load experimental workspace and configure model (exactly like original)
    load_system(PROTECTED_CONFIG.main_model);
    open(PROTECTED_CONFIG.main_model);
    load('workspace_dynamic_experimental.mat');
    stateset;
    
    % Set timing parameters using the calculated values
    set_param(PROTECTED_CONFIG.main_model, 'StartTime', num2str(current_start_time));
    set_param(PROTECTED_CONFIG.main_model, 'StopTime', num2str(current_end_time));
    safe_set_outputtimes(PROTECTED_CONFIG.main_model);
    
    % Load experimental setpoints
    clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3'
    load('KLa3_Setpoints_experiment.mat');
    load('KLa4_Setpoints_experiment.mat');
    load('KLa5_Setpoints_experiment.mat');
    
    % Run experimental simulation
    set_param(PROTECTED_CONFIG.main_model, 'SimulationCommand', 'start');
    
    % Wait for completion
    while ~strcmp(get_param(PROTECTED_CONFIG.main_model, 'SimulationStatus'), 'stopped')
        pause(0.2);
    end
    
    % Save experimental data
    try
        Data_writer_newer;
        Data_writer_reac;
        perf_plant_LT_DR;
        figure_writer;
        fprintf('  ✓ Experimental data saved for segment %d\n', segment_idx);
    catch ME
        fprintf('  Warning: Failed to save experimental data for segment %d: %s\n', segment_idx, ME.message);
    end
    
    % Update experimental workspace for next iteration
    stateset;
    save('workspace_dynamic_experimental.mat');
    
    % Close model
    bdclose(PROTECTED_CONFIG.main_model);
    
    %% ============ NOMINAL RUN ============
    fprintf('  Running nominal phase...\n');
    
    % Load nominal workspace and configure model (exactly like original)
    load_system(PROTECTED_CONFIG.main_model);
    open(PROTECTED_CONFIG.main_model);
    load('workspace_dynamic_nominal.mat');
    stateset;
    
    % Set timing parameters using the calculated values
    set_param(PROTECTED_CONFIG.main_model, 'StartTime', num2str(current_start_time));
    set_param(PROTECTED_CONFIG.main_model, 'StopTime', num2str(current_end_time));
    safe_set_outputtimes(PROTECTED_CONFIG.main_model);
    
    % Load nominal setpoints
    clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3'
    load('KLa3_Setpoints_nominal.mat');
    load('KLa4_Setpoints_nominal.mat');
    load('KLa5_Setpoints_nominal.mat');
    
    % Run nominal simulation
    set_param(PROTECTED_CONFIG.main_model, 'SimulationCommand', 'start');
    
    % Wait for completion
    while ~strcmp(get_param(PROTECTED_CONFIG.main_model, 'SimulationStatus'), 'stopped')
        pause(0.2);
    end
    
    % Save nominal data
    try
        Data_writer_nominal;
        Data_writer_nominal_reac;
        perf_plant_LT_DR;
        figure_writer_nominal;
        fprintf('  ✓ Nominal data saved for segment %d\n', segment_idx);
    catch ME
        fprintf('  Warning: Failed to save nominal data for segment %d: %s\n', segment_idx, ME.message);
    end
    
    % Update nominal workspace for next iteration
    stateset;
    save('workspace_dynamic_nominal.mat');
    
    % Close model
    bdclose(PROTECTED_CONFIG.main_model);
    
    % Progress reporting and time estimation
    segment_time = toc(segment_timer);
    if segment_idx == 1
        estimated_total_time = segment_time * PROTECTED_CONFIG.total_segments;
        fprintf('  Estimated total time: %.1f minutes\n', estimated_total_time/60);
    end
    
    elapsed_time = toc(progress_timer);
    remaining_segments = PROTECTED_CONFIG.total_segments - segment_idx;
    avg_time_per_segment = elapsed_time / segment_idx;
    estimated_remaining = remaining_segments * avg_time_per_segment;
    
    fprintf('  Progress: %.1f%% | Elapsed: %.1f min | Estimated remaining: %.1f min\n', ...
        100*segment_idx/PROTECTED_CONFIG.total_segments, elapsed_time/60, estimated_remaining/60);
    
    fprintf('  ✓ Segment %d completed successfully\n', segment_idx);
end

%% ===============================================
%% COMPLETION SUMMARY
%% ===============================================

total_time = toc(progress_timer);
fprintf('\n=== SIMULATION COMPLETED SUCCESSFULLY ===\n');
fprintf('Total segments processed: %d\n', PROTECTED_CONFIG.total_segments);
fprintf('Simulation time range: %.1f to %.1f days\n', PROTECTED_CONFIG.cal_time, PROTECTED_CONFIG.simend);
fprintf('Total execution time: %.2f minutes\n', total_time/60);
fprintf('Average time per segment: %.2f seconds\n', total_time/PROTECTED_CONFIG.total_segments);

end