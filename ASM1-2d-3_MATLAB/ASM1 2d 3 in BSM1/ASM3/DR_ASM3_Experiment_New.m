benchmarkinit_ASM3_DR;
ss = 'benchmarkss';
model = 'DR_benchmark_LT';
Qr_DR = Qin * 1.5;
simend = 609;
cal_time = 63;       % Absolute first pause point [days]
pause_time = 14;      % Segment duration [days]
iteration = 1;        % Current iteration (manually set or loaded)
ss_done = false;
cal_pause_done = false;
cal_pause_exp_done = false;
Exp_iter_flag = false;
Nominal_iter_flag = false;

% === Setup Steady State === 
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
    disp(['Simulation started. Will pause first at cal_time = ', num2str(cal_time), ' days.']);
end

% === Calculate first iteration-based pause time ===
pause_target = cal_time + pause_time * iteration;

% === Load and configure model ===
DR_benchmark_LT;
set_param(model, 'StartTime', '0'); 
set_param(model, 'StopTime', num2str(simend)); 
set_param(model, 'Solver', 'ode45');
set_param(model, 'SimulationMode', 'normal');

% === Start simulation asynchronously ===
if ss_done == true
    set_param(model, 'SimulationCommand', 'start');
end

% === Wait for simulation to begin ===
while ~strcmp(get_param(model, 'SimulationStatus'), 'running')
    pause(0.2);
end


% === Main simulation monitoring loop ===
while true
    status = get_param(model, 'SimulationStatus');
    if strcmp(status, 'stopped')
        break;
    end

    sim_time = get_param(model, 'SimulationTime');
    % === Check for end of simulation ===
    if sim_time >= simend
        set_param(model, 'SimulationCommand', 'stop');
        disp(['Simulation reached end time at t = ', num2str(sim_time), ' days. Ending loop.']);
        break;
    end

    % === STEP 1: Calibrate model to puesdo-steady state ===
    if ~cal_pause_done && ~cal_pause_exp_done && sim_time >= cal_time
        set_param(model, 'SimulationCommand', 'pause');
        disp(['Simulation paused at cal_time = ', num2str(sim_time), ' days.']);

        while ~strcmp(get_param(model, 'SimulationStatus'), 'paused')
            pause(0.1);
        end

        % Save steady state or checkpoint
        stateset;
        save workspace_dynamic_nominal
        cal_pause_done = true;
        disp('Nominal model calibration completed.');
        % Close model
        bdclose(model);
        % Clear workspace
        clearvars -except ss model simend pause_time iteration cal_time ss_done segment_pause_done Nominal_iter_flag stepback_target sim_time cal_pause_done cal_pause_exp_done
        % Begin calibrating experimental model
        benchmarkinit_ASM3_DR;
        load_system(ss);
        open(ss);
        set_param(ss, 'SimulationCommand', 'start');
        stateset;
        load_system(model);
        open(model);
        % === STEP 1-A: Load experimental input ===
        clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3' 'kla3in' 'kla4in' 'kla5in'
        load('KLa3_Setpoints_experiment.mat');
        load('KLa4_Setpoints_experiment.mat');
        load('KLa5_Setpoints_experiment.mat');
        disp('Experimental DR setpoints loaded into workspace.');
        set_param(model, 'StartTime', '0'); 
        set_param(model, 'StopTime', num2str(simend)); 
        set_param(model, 'Solver', 'ode45');
        set_param(model, 'SimulationMode', 'normal');
        % Resume simulation
        set_param(model, 'SimulationCommand', 'start');
        disp('Simulation resumed after cal_time pause.');
        stateset;
        save workspace_dynamic_experimental
        cal_pause_exp_done = true;

    end

    % === STEP 2: Pause at iteration-based target ===
    if cal_pause_done && cal_pause_exp_done && ~Exp_iter_flag && sim_time >= pause_target 
        set_param(model, 'SimulationCommand', 'pause');
        disp(['Simulation paused at pause_target = ', num2str(sim_time), ' days. DR experiment no ',num2str(iteration), ' completed.']);

        while ~strcmp(get_param(model, 'SimulationStatus'), 'paused')
            pause(0.1);
        end
        
        Data_writer_newer
        Data_writer_reac
        perf_plant_LT_DR
        figure_writer

        % Prepare the recalibration
        stepback_target = floor(sim_time) - pause_time;
        save workspace_dynamic_experimental
        % Close model
        bdclose(model);
        % Clear workspace
        clearvars -except model simend pause_time iteration cal_time ss_done segment_pause_done Nominal_iter_flag stepback_target sim_time cal_pause_done cal_pause_exp_done
        % Open model
        load_system(model);
        open(model);
        % Load workspace at previous segment pause
        load workspace_dynamic_nominal 

        stateset;
        % Set model time appropriately
        set_param(model, 'StartTime', num2str(stepback_target));
        safe_set_outputtimes(model);
        % === STEP 2-A: Load nominal input while paused ===
        clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3' 'kla3in' 'kla4in' 'kla5in'
        load('KLa3_Setpoints_nominal.mat');
        load('KLa4_Setpoints_nominal.mat');
        load('KLa5_Setpoints_nominal.mat');
        disp('Nominal DR setpoints loaded into workspace. Preparing for next DR simulation.');

        set_param(model, 'SimulationCommand', 'start');
        disp(['Simulation resumed. Next pause scheduled at t = ', num2str(pause_target), ' days.']);

        Exp_iter_flag = true;
        Nominal_iter_flag = false;
    end

    if cal_pause_done && cal_pause_exp_done && Exp_iter_flag && ~Nominal_iter_flag && sim_time >= pause_target
        set_param(model, 'SimulationCommand', 'pause');
        disp(['Simulation paused at pause_target = ', num2str(sim_time), ' days. Beginning DR experiment no ', num2str(iteration+1)]);

        while ~strcmp(get_param(model, 'SimulationStatus'), 'paused')
            pause(0.1);
        end
        Data_writer_nominal_reac
        Data_writer_nominal
        perf_plant_LT_DR
        figure_writer_nominal

        % Prepare next iteration
        iteration = iteration + 1;
        pause_target = cal_time + pause_time * iteration;
        disp(['Preparing DR experiment no ', num2str(iteration), ', next pause_target = ', num2str(pause_target)]);

        % Save steady state or checkpoint
        stepback_target = floor(sim_time) - pause_time;
        stateset;
        save workspace_dynamic_nominal
        % Close model
        bdclose(model);
        % Clear workspace
        clearvars -except model simend pause_time iteration cal_time ss_done segment_pause_done Nominal_iter_flag stepback_target sim_time cal_pause_done cal_pause_exp_done
        % Open model
        load_system(model);
        open(model);
        % Load workspace at previous segment pause
        load workspace_dynamic_experimental
        stateset;
        % Set model time appropriately
        set_param(model, 'StartTime', num2str(floor(sim_time)));
        safe_set_outputtimes(model);
        % === STEP 3-A: Load experimental input while paused ===
        clear 'KLa3_Setpoints_ASM3' 'KLa4_Setpoints_ASM3' 'KLa5_Setpoints_ASM3' 'kla3in' 'kla4in' 'kla5in'
        load('KLa3_Setpoints_experiment.mat');
        load('KLa4_Setpoints_experiment.mat');
        load('KLa5_Setpoints_experiment.mat');
        disp('Experimental DR setpoints loaded into workspace.');

        set_param(model, 'SimulationCommand', 'start');
        disp(['Simulation resumed. Next pause scheduled at t = ', num2str(pause_target), ' days.']);

        Exp_iter_flag = false;
        Nominal_iter_flag = true;
    end

    pause(0.2);
end

% === Simulation Finished ===
disp('Experiment completed finished.');