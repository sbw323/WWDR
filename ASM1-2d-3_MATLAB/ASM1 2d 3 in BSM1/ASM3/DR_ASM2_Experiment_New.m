% === ASM3 Dual Pseudo-Steady-State Simulation Protocol ===

benchmarkinit_ASM3_DR;
ss = 'benchmarkss';
model = 'DR_benchmark_LT';
Qr_DR = Qin * 1.5;
simend = 609;
cal_time = 63;         % Reduced calibration time
pause_time = 14;        % Segment duration
iteration = 1;
ss_done = false;
cal_nom = false;
cal_exp = false;

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

% === Generate initial 63-day nominal steady state ===
if ~cal_nom
    load('KLa3_Setpoints_nominal.mat');
    load('KLa4_Setpoints_nominal.mat');
    load('KLa5_Setpoints_nominal.mat');
    DR_benchmark_LT;
    set_param(model, 'StartTime', '0'); 
    set_param(model, 'SimulationCommand', 'start');
    sim_time = get_param(model, 'SimulationTime');
    if sim_time >= cal_time
        set_param(model, 'SimulationCommand', 'pause');
        stateset;
        save workspace_dynamic_nominal
        bdclose(model);
        cal_nom = true;
        ss_done = false;
        while ~strcmp(get_param(model, 'SimulationStatus'), 'stopped')
            pause(0.1);
        end
    end
end

% === Generate initial 63-day experimental steady state ===
if ~cal_exp
    load('KLa3_Setpoints_experiment.mat');
    load('KLa4_Setpoints_experiment.mat');
    load('KLa5_Setpoints_experiment.mat');
    DR_benchmark_LT;
    set_param(model, 'StartTime', '0');
    set_param(model, 'SimulationCommand', 'start');
    while ~strcmp(get_param(model, 'SimulationStatus'), 'stopped')
        pause(0.1);
    end
    stateset;
    save workspace_dynamic_experimental
    bdclose(model);
    cal_exp = true;
end

% === 3. Begin Alternating Simulation Loop ===
pause_target = cal_time + pause_time * iteration;

while true
    load_system(model);
    DR_benchmark_LT;
    set_param(model, 'StartTime', num2str(cal_time));
    set_param(model, 'StopTime', num2str(simend));
    set_param(model, 'Solver', 'ode45');
    set_param(model, 'SimulationMode', 'normal');

    % Preserve iteration across workspace load
    persistent_iter = iteration;

    is_nominal = mod(iteration, 2) == 0;
    if is_nominal
        load workspace_dynamic_nominal
        load('KLa3_Setpoints_nominal.mat');
        load('KLa4_Setpoints_nominal.mat');
        load('KLa5_Setpoints_nominal.mat');
        disp('Nominal setpoints and state loaded.');
    else
        load workspace_dynamic_experimental
        load('KLa3_Setpoints_experiment.mat');
        load('KLa4_Setpoints_experiment.mat');
        load('KLa5_Setpoints_experiment.mat');
        disp('Experimental setpoints and state loaded.');
    end

    % Restore iteration
    iteration = persistent_iter;

    stateset;
    set_param(model, 'StartTime', num2str(cal_time));
    safe_set_outputtimes(model);
    set_param(model, 'SimulationCommand', 'start');
    while ~strcmp(get_param(model, 'SimulationStatus'), 'running')
        pause(0.2);
    end

    while true
        status = get_param(model, 'SimulationStatus');
        if strcmp(status, 'stopped')
            break;
        end
        sim_time = get_param(model, 'SimulationTime');

        if sim_time >= pause_target
            set_param(model, 'SimulationCommand', 'pause');
            while ~strcmp(get_param(model, 'SimulationStatus'), 'paused')
                pause(0.1);
            end

            if is_nominal
                Data_writer_nominal_reac;
                Data_writer_nominal;
                perf_plant_LT_DR;
                figure_writer_nominal;
                save workspace_dynamic_nominal
            else
                Data_writer_newer;
                Data_writer_reac;
                perf_plant_LT_DR;
                figure_writer;
                save workspace_dynamic_experimental
            end

            iteration = iteration + 1;
            pause_target = cal_time + pause_time * iteration;
            bdclose(model);
            break;
        end
        pause(0.2);
    end

    if sim_time >= simend
        disp('Simulation reached end time.');
        break;
    end
end

% === Simulation End ===
disp('Experiment completed successfully.');
