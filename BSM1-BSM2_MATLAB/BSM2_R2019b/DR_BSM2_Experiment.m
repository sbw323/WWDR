init_bsm2_DR;
ss = 'bsm2_ss';
model = 'DR_bsm2_ol';
simend = 609;
cal_time = 25;       % Absolute first pause point [days]
pause_time = 14;      % Segment duration [days]
iteration = 1;        % Current iteration (manually set or loaded)
ss_done = false;
cal_pause_done = false;
DR_pause_done = false;
recal_segment_pause_done = false;

% === Setup Steady State === 
bsm2_ss;
if ~ss_done
    set_param(ss, 'SimulationCommand', 'start');

    % Wait until simulation is truly stopped
    while ~strcmp(get_param(ss, 'SimulationStatus'), 'stopped')
        pause(0.1);
    end

    % When stopped, update states and mark steady state as complete
    stateset_bsm2;
    ss_done = true;
end

% === Calculate first iteration-based pause time ===
pause_target = cal_time + pause_time * iteration;

% === Load and configure model ===
DR_bsm2_ol;
%load_system(model);
set_param(model, 'StopTime', num2str(simend)); % simulate far enough
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

disp(['Simulation started. Will pause first at cal_time = ', num2str(cal_time), ' days.']);

% === Main simulation monitoring loop ===
while true
    status = get_param(model, 'SimulationStatus');
    if strcmp(status, 'stopped')
        break;
    end

    sim_time = get_param(model, 'SimulationTime');

    % === STEP 1: Priority pause at cal_time ===
    if ~cal_pause_done && sim_time >= cal_time
        set_param(model, 'SimulationCommand', 'pause');
        disp(['Simulation paused at cal_time = ', num2str(sim_time), ' days.']);

        while ~strcmp(get_param(model, 'SimulationStatus'), 'paused')
            pause(0.1);
        end

        % Save steady state or checkpoint
        stateset_bsm2;
        save workspace_dynamic
        % Close model
        bdclose(model);
        % Clear workspace
        clearvars -except model simend pause_time iteration cal_time ss_done cal_pause_done segment_pause_done recal_segment_pause_done stepback_target
        % Open model
        load_system(model);
        open(model);
        % Load workspace at previous segment pause
        load workspace_dynamic
        stateset_bsm2;
        % Set model time appropriately
        set_param(model, 'StartTime', num2str(cal_time));
        output_expr = sprintf('[%g:1/96:%g]', cal_time, simend);
        set_param(model, 'outputtimes', output_expr);  
        % === STEP 1-A: Load experimental input while paused ===
        clear 'KLa3_Setpoints_BSM2' 'KLa4_Setpoints_BSM2' 'KLa5_Setpoints_BSM2' 'kla3in' 'kla4in' 'kla5in'
        load('KLa3_Setpoints_BSM2_experiment.mat');
        load('KLa4_Setpoints_BSM2_experiment.mat');
        load('KLa5_Setpoints_BSM2_experiment.mat');
        disp('Experimental DR setpoints loaded into workspace.');

        % Resume simulation
        set_param(model, 'SimulationCommand', 'start');
        disp('Simulation resumed after cal_time pause.');

        cal_pause_done = true;
    end

    % === STEP 2: Pause at iteration-based target ===
    if cal_pause_done && ~DR_pause_done && sim_time >= pause_target
        set_param(model, 'SimulationCommand', 'pause');
        disp(['Simulation paused at pause_target = ', num2str(sim_time), ' days. DR experiment no ',num2str(iteration), ' completed.']);

        while ~strcmp(get_param(model, 'SimulationStatus'), 'paused')
            pause(0.1);
        end
        
        Data_writer
        Data_writer_reac
        perf_plant_DRbsm2
        figure_writer

        % Prepare the recalibration
        stepback_target = sim_time - pause_time;

        % Close model
        bdclose(model);
        % Clear workspace
        clearvars -except model simend pause_time iteration cal_time ss_done cal_pause_done segment_pause_done recal_segment_pause_done stepback_target
        % Open model
        load_system(model);
        open(model);
        % Load workspace at previous segment pause
        load workspace_dynamic
        stateset_bsm2;
        % Set model time appropriately
        set_param(model, 'StartTime', num2str(stepback_target));
        output_expr = sprintf('[%g:1/96:%g]', stepback_target, simend);
        set_param(model, 'outputtimes', output_expr);  
        
        % === STEP 2-A: Load nominal input while paused ===
        clear 'KLa3_Setpoints_BSM2' 'KLa4_Setpoints_BSM2' 'KLa5_Setpoints_BSM2' 'kla3in' 'kla4in' 'kla5in'
        load('KLa3_Setpoints_BSM2_nominal.mat');
        load('KLa4_Setpoints_BSM2_nominal.mat');
        load('KLa5_Setpoints_BSM2_nominal.mat');
        disp('Nominal DR setpoints loaded into workspace. Preparing for next DR simulation.');

        set_param(model, 'SimulationCommand', 'start');
        disp(['Simulation resumed. Next pause scheduled at t = ', num2str(pause_target), ' days.']);

        DR_pause_done = true;
        recal_segment_pause_done = false;
    end

    if cal_pause_done && DR_pause_done && ~recal_segment_pause_done && sim_time >= pause_target
        set_param(model, 'SimulationCommand', 'pause');
        disp(['Simulation paused at pause_target = ', num2str(sim_time), ' days. Beginning DR experiment no ', num2str(iteration+1)]);

        while ~strcmp(get_param(model, 'SimulationStatus'), 'paused')
            pause(0.1);
        end

        % Prepare next iteration
        iteration = iteration + 1;
        pause_target = cal_time + pause_time * iteration;

        % Save steady state or checkpoint
        stateset_bsm2;
        save workspace_dynamic
        % Close model
        bdclose(model);
        % Clear workspace
        clearvars -except model simend pause_time iteration cal_time ss_done cal_pause_done segment_pause_done recal_segment_pause_done stepback_target
        % Open model
        load_system(model);
        open(model);
        % Load workspace at previous segment pause
        load workspace_dynamic
        stateset_bsm2;
        % Set model time appropriately
        set_param(model, 'StartTime', num2str(sim_time));
        output_expr = sprintf('[%g:1/96:%g]', sim_time, simend);
        set_param(model, 'outputtimes', output_expr);  

        % === STEP 3-A: Load experimental input while paused ===
        clear 'KLa3_Setpoints_BSM2' 'KLa4_Setpoints_BSM2' 'KLa5_Setpoints_BSM2' 'kla3in' 'kla4in' 'kla5in'
        load('KLa3_Setpoints_BSM2_experiment.mat');
        load('KLa4_Setpoints_BSM2_experiment.mat');
        load('KLa5_Setpoints_BSM2_experiment.mat');
        disp('Experimental DR setpoints loaded into workspace.');

        set_param(model, 'SimulationCommand', 'start');
        disp(['Simulation resumed. Next pause scheduled at t = ', num2str(pause_target), ' days.']);

        DR_pause_done = false;
        recal_segment_pause_done = true;
    end

    pause(0.2);
end

% === Simulation Finished ===
disp('Simulation finished.');