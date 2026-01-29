%% ASM3 RELIABILITY DATA GENERATION - STEADY STATE
% Purpose: Generate steady state data for constant failure rate reliability modeling.
% Iterates through KLa, Q, and StopTime conditions using the 'benchmarkss' model.
%
% Usage:
% 1. Define test cases in 'test_cases' matrix.
% 2. Run script.
%
% Note: Uses 'benchmarkinit' for initialization.

%% ===============================================
%% CONFIGURATION
%% ===============================================

fprintf('\n=== ASM3 RELIABILITY DATA GENERATION ===\n');

% Output file definition
output_file = 'ASM3_Output/reliability_data/reliability_ss_dataset.csv';

% Create output directory if it doesn't exist
output_dir = fileparts(output_file);
if ~exist(output_dir, 'dir') && ~isempty(output_dir)
    mkdir(output_dir);
end

%% ===============================================
%% DEFINE TEST CASES
%% ===============================================

% Matrix Columns: [KLa3, KLa4, KLa5, Q, StopTime]
% Units: KLa (1/d), Q (m3/d), StopTime (days)

test_cases = [
    % KLa3  KLa4  KLa5   Q      StopTime
      240   240   240   18446   200;      % Baseline (Q default approx)
      120   120   120   18446   200;      % Medium Aeration
       60    60    60   18446   500;      % Low Aeration (Increased Time)
       40    40    40   18446   1000;     % Very Low Aeration (High Time)
       30    30    30   20000   1500;     % High Load, Low Aeration
       20    20    20   18446   2000;     % Extreme Low Aeration
];

num_iterations = size(test_cases, 1);
ss_model = 'benchmarkss';

fprintf('Total Test Cases: %d\n', num_iterations);
fprintf('Output File: %s\n\n', output_file);

%% ===============================================
%% MAIN ITERATION LOOP
%% ===============================================

total_start = tic;

for iter = 1:num_iterations
    
    fprintf('--- Iteration %d/%d ---\n', iter, num_iterations);
    
    try
        % 1. Extract parameters for current iteration
        KLa3_target = test_cases(iter, 1);
        KLa4_target = test_cases(iter, 2);
        KLa5_target = test_cases(iter, 3);
        Q_target    = test_cases(iter, 4);
        Stop_target = test_cases(iter, 5);
        
        fprintf('   Setting: KLa=[%d, %d, %d], Q=%d, Time=%d\n', ...
            KLa3_target, KLa4_target, KLa5_target, Q_target, Stop_target);

        % 2. SAVE STATE: Preserve loop variables before clearing workspace
        iter_save = iter;
        test_cases_save = test_cases;
        output_file_save = output_file;
        ss_model_save = ss_model;
        num_iterations_save = num_iterations;
        total_start_save = total_start;
        
        % Current Iteration Targets
        KLa3_t = KLa3_target;
        KLa4_t = KLa4_target;
        KLa5_t = KLa5_target;
        Q_t    = Q_target;
        Stop_t = Stop_target;

        % 3. CLEAR WORKSPACE: Ensure clean simulation environment
        clear all; 
        
        % 4. RESTORE STATE: Reload loop variables
        iter = iter_save;
        test_cases = test_cases_save;
        output_file = output_file_save;
        ss_model = ss_model_save;
        num_iterations = num_iterations_save;
        total_start = total_start_save;
        
        % Restore targets
        KLa3_target = KLa3_t;
        KLa4_target = KLa4_t;
        KLa5_target = KLa5_t;
        Q_target    = Q_t;
        sim_stoptime = Stop_t;

        % 5. INITIALIZE MODEL
        % Using standard benchmarkinit as requested
        fprintf('   Initializing standard benchmark...\n');
        benchmarkinit; 
        
        % 6. OVERRIDE PARAMETERS
        % Override Flow Rate (Q)
        Q = Q_target;
        
        % Override Aeration (KLa)
        KLa3 = KLa3_target;
        KLa4 = KLa4_target;
        KLa5 = KLa5_target;

        % 7. CONFIGURE & RUN SIMULATION
        if ~bdIsLoaded(ss_model)
            load_system(ss_model);
        end
        
        % Set Simulation Stop Time
        set_param(ss_model, 'StopTime', num2str(sim_stoptime));
        set_param(ss_model, 'Solver', 'ode45');
        set_param(ss_model, 'SimulationMode', 'normal');

        fprintf('   Running simulation...\n');
        sim_start = tic;
        
        % Start Simulation
        set_param(ss_model, 'SimulationCommand', 'start');
        
        % Wait for simulation to finish
        while ~strcmp(get_param(ss_model, 'SimulationStatus'), 'stopped')
            pause(0.1);
        end
        
        fprintf('   Simulation finished (%.2f sec)\n', toc(sim_start));
        
        % 8. CAPTURE & SAVE DATA
        % 'stateset' captures steady state values into 'settler' matrix
        stateset; 
        
        fprintf('   Saving data...\n');
        ssData_writer_reliability(settler, iter, KLa3, KLa4, KLa5, Q, sim_stoptime, output_file);
        
    catch ME
        fprintf('   ERROR in iteration %d: %s\n', iter, ME.message);
        % Attempt cleanup
        try bdclose(ss_model); catch; end
    end
end

total_time = toc(total_start);
fprintf('\n=== COMPLETED in %.2f minutes ===\n', total_time/60);