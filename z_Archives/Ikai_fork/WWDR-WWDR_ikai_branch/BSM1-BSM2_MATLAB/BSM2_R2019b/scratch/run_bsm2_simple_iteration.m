% Slimmed-Down BSM2 Workflow Script
% Implements a simplified and tractable simulation loop

function run_bsm2_simple_iteration(t0_days, Rt, iteration)
    % Rt: duration of each experimental phase in days
    % iteration: current iteration index (starting from 1)

    clearvars -except Rt iteration;
    close all;

    fprintf('\n=== Starting Slimmed BSM2 Workflow ===\n');
    fprintf('Experimental timestep duration Rt = %.2f days, Iteration = %d\n', Rt, iteration);

    %% Step 1: Initialize and run steady-state simulation
    fprintf('\n--- Steady State Initialization ---\n');
    evalin('base', 'init_bsm2_DR');
    DR_bsm2_ss
    options_ss = simset('solver','ode15s','Reltol',1e-5,'AbsTol',1e-8,'refine',1);
    sim('DR_bsm2_ss', [0 200], options_ss);
    stateset_bsm2;

    %% Step 2: Run initial open-loop phase
    fprintf('\n--- Initial Open-Loop Simulation ---\n');
    DR_bsm2_ol
    t_start = 0;
    t_stop = t0_days;
    outputtimes = t_start:(1/96):t_stop;
    options_ol = simset('solver','ode45','Reltol',1e-5,'AbsTol',1e-8,'outputpoints','specified');
    sim('DR_bsm2_ol', outputtimes, options_ol);
    stateset_bsm2;

    % Save current workspace state (referred to as stateset(N))
    save('SavedStates/states_bsm2.mat');

    %% Step 3: Experimental phase 1
    fprintf('\n--- Experimental Phase 1 ---\n');
    outputtimes = t_stop:(1/96):(t_stop + Rt);
    sim('DR_bsm2_ol', outputtimes, options_ol);

    % Postprocess outputs
    Data_writer
    Data_writer_reac
    perf_plant_DRbsm2
    figure_writer

    %% Step 4: Recovery phase from saved state
    fprintf('\n--- Recovery Phase (load statesetN) ---\n');
    load('SavedStates/states_bsm2.mat');
    stateset_bsm2;

    % Run open-loop again for extended period (N + iteration*Rt)
    t_start = 0;
    t_stop = N + iteration * Rt;
    outputtimes = t_start:(1/96):t_stop;
    sim('DR_bsm2_ol', outputtimes, options_ol);

    %% Step 5: Experimental phase n (after extended open-loop)
    fprintf('\n--- Experimental Phase %d ---\n', iteration);
    outputtimes = t_stop:(1/96):(t_stop + Rt);
    sim('DR_bsm2_ol', outputtimes, options_ol);

    % Postprocess again
    Data_writer
    Data_writer_reac
    perf_plant_DRbsm2
    figure_writer

    fprintf('=== Slimmed Workflow Complete ===\n');
end
