benchmarkinit_ASM3_DR;
ss = 'benchmarkss';
model = 'DR_benchmark_LT';
Qr_DR = Qin * 1.5;
simend = 428;         % Reduced simulation end time [days]
cal_time = 63;        % Reduced calibration time [days]
pause_time = 14;      % Segment duration [days]
iteration = 1;        % Current iteration (manually set or loaded)
save workspace_dynamic_ss;

% Initialize flags
ss_done = false;
nominal_cal_done = false;
experimental_cal_done = false;
DR_pause_done = false;
nominal_pause_done = false;

% === PHASE 1: Create Nominal Pseudo-Steady State === 
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
    disp('Phase 1 steady state completed.');
end

disp('=== Starting Nominal Calibration Phase ===');

% Load and configure model for nominal calibration
DR_benchmark_LT;
set_param(model, 'StartTime', '0'); 
set_param(model, 'StopTime', num2str(cal_time)); 
set_param(model, 'Solver', 'ode45');
set_param(model, 'SimulationMode', 'normal');
safe_set_outputtimes(model);

% Load nominal setpoints before starting
clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3' 'kla3in' 'kla4in' 'kla5in'
load('KLa3_Setpoints_nominal.mat');
load('KLa4_Setpoints_nominal.mat');
load('KLa5_Setpoints_nominal.mat');
disp('Nominal DR setpoints loaded for calibration.');

% Start nominal calibration simulation
set_param(model, 'SimulationCommand', 'start');

% Wait for completion
while ~strcmp(get_param(model, 'SimulationStatus'), 'stopped')
    pause(0.2);
end

% Save nominal pseudo-steady state
stateset;
save workspace_dynamic_nominal;
nominal_cal_done = true;
disp('Nominal pseudo-steady state created and saved to workspace_dynamic_nominal.');

% Close model and clear workspace
bdclose(model);
clearvars -except ss model simend cal_time pause_time iteration ss_done nominal_cal_done experimental_cal_done Qr_DR;

% === PHASE 2: Reset and Create Experimental Pseudo-Steady State ===
disp('=== Starting Experimental Calibration Phase ===');

% Reload initial steady state
ss_done = false;
load workspace_dynamic_ss;
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
    disp('Phase 3 steady state completed.');
end

% Load and configure model for experimental calibration
DR_benchmark_LT;
set_param(model, 'StartTime', '0'); 
set_param(model, 'StopTime', num2str(cal_time)); 
set_param(model, 'Solver', 'ode45');
set_param(model, 'SimulationMode', 'normal');
safe_set_outputtimes(model);

% Load experimental setpoints before starting
clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3' 'kla3in' 'kla4in' 'kla5in'
load('KLa3_Setpoints_experiment.mat');
load('KLa4_Setpoints_experiment.mat');
load('KLa5_Setpoints_experiment.mat');
disp('Experimental DR setpoints loaded for calibration.');

% Start experimental calibration simulation
set_param(model, 'SimulationCommand', 'start');

% Wait for completion
while ~strcmp(get_param(model, 'SimulationStatus'), 'stopped')
    pause(0.2);
end

% Save experimental pseudo-steady state
stateset;
save workspace_dynamic_experimental;
experimental_cal_done = true;
disp('Experimental pseudo-steady state created and saved to workspace_dynamic_experimental.');

% Close model and clear workspace
bdclose(model);
clearvars -except ss model simend cal_time pause_time iteration ss_done nominal_cal_done experimental_cal_done Qr_DR;

% === PHASE 4: Main Data Generation Loop ===
disp('=== Starting Main Data Generation Loop ===');

% Calculate total number of segments
total_segments = floor((simend - cal_time) / pause_time);
disp(['Total segments to process: ', num2str(total_segments)]);

for seg_idx = 1:total_segments
    % Calculate timing values for display (these will be overwritten by workspace load)
    current_start_time = cal_time + (seg_idx - 1) * pause_time;
    current_end_time = cal_time + seg_idx * pause_time;
    
    disp(['=== Processing Segment ', num2str(seg_idx), ' (t = ', num2str(current_start_time), ' to ', num2str(current_end_time), ' days) ===']);
    
    % --- EXPERIMENTAL RUN ---
    disp('--- Running Experimental Segment ---');
    
    % Load experimental workspace and configure model
    load_system(model);
    open(model);
    load workspace_dynamic_experimental;
    stateset;
    
    % Set timing parameters directly using calculated values (immune to workspace load)
    set_param(model, 'StartTime', num2str(cal_time + (seg_idx - 1) * pause_time));
    set_param(model, 'StopTime', num2str(cal_time + seg_idx * pause_time));
    safe_set_outputtimes(model);
    
    % Load experimental setpoints
    clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3' 'kla3in' 'kla4in' 'kla5in'
    load('KLa3_Setpoints_experiment.mat');
    load('KLa4_Setpoints_experiment.mat');
    load('KLa5_Setpoints_experiment.mat');
    
    % Run experimental simulation
    set_param(model, 'SimulationCommand', 'start');
    
    % Wait for completion
    while ~strcmp(get_param(model, 'SimulationStatus'), 'stopped')
        pause(0.2);
    end
    
    % Save experimental data
    Data_writer_newer;
    Data_writer_reac;
    perf_plant_LT_DR;
    figure_writer;
    
    disp(['Experimental data saved for segment ', num2str(seg_idx)]);
    
    % Update experimental workspace for next iteration
    stateset;
    save workspace_dynamic_experimental;
    
    % Close model
    bdclose(model);
    
    % --- NOMINAL RUN ---
    disp('--- Running Nominal Segment ---');
    
    % Load nominal workspace and configure model
    load_system(model);
    open(model);
    load workspace_dynamic_nominal;
    stateset;
    
    % Set timing parameters directly using calculated values (immune to workspace load)
    set_param(model, 'StartTime', num2str(cal_time + (seg_idx - 1) * pause_time));
    set_param(model, 'StopTime', num2str(cal_time + seg_idx * pause_time));
    safe_set_outputtimes(model);
    
    % Load nominal setpoints
    clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3' 'kla3in' 'kla4in' 'kla5in'
    load('KLa3_Setpoints_nominal.mat');
    load('KLa4_Setpoints_nominal.mat');
    load('KLa5_Setpoints_nominal.mat');
    
    % Run nominal simulation
    set_param(model, 'SimulationCommand', 'start');
    
    % Wait for completion
    while ~strcmp(get_param(model, 'SimulationStatus'), 'stopped')
        pause(0.2);
    end
    
    % Save nominal data
    Data_writer_nominal;
    Data_writer_nominal_reac;
    perf_plant_LT_DR;
    figure_writer_nominal;
    
    disp(['Nominal data saved for segment ', num2str(seg_idx)]);
    
    % Update nominal workspace for next iteration
    stateset;
    save workspace_dynamic_nominal;
    
    % Close model
    bdclose(model);
    
    disp(['Segment ', num2str(seg_idx), ' completed successfully.']);
end

% === Experiment Completed ===
disp('=== All Data Generation Completed Successfully ===');
disp(['Total segments processed: ', num2str(total_segments)]);
disp(['Simulation time range: ', num2str(cal_time), ' to ', num2str(simend), ' days']);