%% ASM3 RELIABILITY DATA GENERATION - STEADY STATE
% Purpose: Generate steady state data for constant failure rate reliability modeling.
% Iterates through KLa, Q, and StopTime conditions using the 'benchmarkss' model.
%
% Usage:
% 1. Define test cases in 'test_cases' matrix.
% 2. Run script.
%
% FIX APPLIED: Reloads loop state after 'benchmarkinit' clears the workspace.

%% ===============================================
%% 1. CONFIGURATION & INITIALIZATION
%% ===============================================

fprintf('\n=== ASM3 RELIABILITY DATA GENERATION ===\n');

% Output file definition
output_file = 'ASM3_Output/reliability_data/reliability_ss_dataset.csv';
output_dir = fileparts(output_file);
if ~exist(output_dir, 'dir') && ~isempty(output_dir)
    mkdir(output_dir);
end

% Matrix Columns: [KLa3, KLa4, KLa5, Q, StopTime]
test_cases = [
    % KLa3  KLa4  KLa5   Q      StopTime
      240      240      84   200;
      220.80   220.80   77.28   200;
      203.14   203.14   71.10   400;
      186.89   186.89   65.41   400;
      171.93   171.93   60.18   600;
      158.18   158.18   55.36   800;
      145.53   145.53   50.93   800;
      133.88   133.88   46.86   1000;
      123.17   123.17   43.11   1000;
      113.32   113.32   39.66   2000;
      104.25   104.25   36.49   2000;
];

CONSTINFLUENT(1,15) = 20291;
CONSTINFLUENT(2,15) = 20291;
Q = CONSTINFLUENT(1,15);

ss_model = 'benchmarkss';
num_iterations = size(test_cases, 1);
total_start = tic;

% SAVE CONFIGURATION: Immutable data
save('sim_config.mat', 'test_cases', 'output_file', 'ss_model', 'num_iterations', 'total_start');

% INITIALIZE ITERATOR
iter = 1;
save('sim_state.mat', 'iter');

fprintf('Total Test Cases: %d\n', num_iterations);
fprintf('Output File: %s\n\n', output_file);

%% ===============================================
%% 2. ROBUST ITERATION LOOP
%% ===============================================

while true
    % A. CLEAN SLATE
    clear all;

    % B. RESTORE UNIVERSE (Phase 1)
    if exist('sim_config.mat', 'file')
        load('sim_config.mat');
    else
        error('Config file missing. Script aborted.');
    end
    
    if exist('sim_state.mat', 'file')
        load('sim_state.mat');
    else
        break; % Done or crashed
    end

    % C. CHECK COMPLETION
    if iter > num_iterations
        break;
    end

    try
        fprintf('--- Iteration %d/%d ---\n', iter, num_iterations);

        % D. INITIALIZE MODEL
        % Warning: benchmarkinit likely performs a 'clear all' internally
        fprintf('   Initializing standard benchmark...\n');
        benchmarkinit; 
        
        % E. RESTORE UNIVERSE (Phase 2 - CRITICAL FIX)
        % We must reload our variables because benchmarkinit likely wiped them
        load('sim_config.mat');
        load('sim_state.mat');
        
        % F. EXTRACT PARAMETERS
        KLa3_target = test_cases(iter, 1);
        KLa4_target = test_cases(iter, 2);
        KLa5_target = test_cases(iter, 3);
        Stop_target = test_cases(iter, 4);
        
        fprintf('   Target: KLa=[%d, %d, %d], Time=%d\n', ...
            KLa3_target, KLa4_target, KLa5_target, Stop_target);

        % G. OVERRIDE PARAMETERS
        KLa3 = KLa3_target;
        KLa4 = KLa4_target;
        KLa5 = KLa5_target;

        % H. CONFIGURE & RUN SIMULATION
        if ~bdIsLoaded(ss_model)
            load_system(ss_model);
        end
        
        set_param(ss_model, 'StopTime', num2str(Stop_target));
        set_param(ss_model, 'Solver', 'ode15s');
        set_param(ss_model, 'SimulationMode', 'normal');

        fprintf('   Running simulation...\n');
        sim_start = tic;
        
        set_param(ss_model, 'SimulationCommand', 'start');
        
        while ~strcmp(get_param(ss_model, 'SimulationStatus'), 'stopped')
            pause(0.1);
        end
        
        fprintf('   Simulation finished (%.2f sec)\n', toc(sim_start));
        
        % I. SAVE DATA
        stateset; % Captures 'settler'
        fprintf('   Saving data...\n');
        ssData_writer_reliability(settler, iter, KLa3, KLa4, KLa5, Q, Stop_target, output_file);
        
        % J. INCREMENT & SAVE STATE
        iter = iter + 1;
        save('sim_state.mat', 'iter');
        
    catch ME
        % FIX: Ensure 'iter' exists before using it in error message
        if ~exist('iter', 'var')
            if exist('sim_state.mat', 'file')
                load('sim_state.mat');
            else
                iter = NaN;
            end
        end
        
        fprintf('   ERROR in iteration %d: %s\n', iter, ME.message);
        
        % Try to close model
        try bdclose(ss_model); catch; end
        
        % Increment to avoid infinite loop on error
        iter = iter + 1;
        save('sim_state.mat', 'iter');
    end
end

%% ===============================================
%% 3. CLEANUP
%% ===============================================

total_time = toc(total_start);
fprintf('\n=== COMPLETED in %.2f minutes ===\n', total_time/60);

% Clean up temporary files
if exist('sim_config.mat', 'file'), delete('sim_config.mat'); end
if exist('sim_state.mat', 'file'), delete('sim_state.mat'); end