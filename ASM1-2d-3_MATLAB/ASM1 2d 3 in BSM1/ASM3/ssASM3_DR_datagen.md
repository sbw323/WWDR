%% ASM3 RELIABILITY DATA GENERATION - STEADY STATE
% Purpose: Generate steady state data for constant failure rate reliability modeling.
% Iterates through KLa and StopTime conditions using the 'benchmarkss' model.
% Updates CONSTINFLUENT directly for Flow Rate (Q).
%
% Usage:
% 1. Define test cases in 'test_cases' matrix.
% 2. Run script.

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

% Matrix Columns: [KLa3, KLa4, KLa5, StopTime]
test_cases = [
    % KLa3    KLa4     KLa5    StopTime
      240     240      84      200;
      220.80  220.80   77.28   200;
      203.14  203.14   71.10   400;
      186.89  186.89   65.41   400;
      171.93  171.93   60.18   600;
      158.18  158.18   55.36   800;
      145.53  145.53   50.93   800;
      133.88  133.88   46.86   1000;
      123.17  123.17   43.11   1000;
      113.32  113.32   39.66   2000;
      104.25  104.25   36.49   2000;
];

% Global target Q (Flow Rate) to apply to all cases
target_Q = 20291; 

ss_model = 'benchmarkss';
num_iterations = size(test_cases, 1);
total_start = tic;

% SAVE CONFIGURATION
% We include target_Q here so it persists across clears
save('sim_config.mat', 'test_cases', 'output_file', 'ss_model', 'num_iterations', 'total_start', 'target_Q');

% INITIALIZE ITERATOR
iter = 1;
save('sim_state.mat', 'iter');

fprintf('Total Test Cases: %d\n', num_iterations);
fprintf('Target Q: %d m3/d\n', target_Q);
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
        break; 
    end

    % C. CHECK COMPLETION
    if iter > num_iterations
        break;
    end

    try
        fprintf('--- Iteration %d/%d ---\n', iter, num_iterations);

        % D. INITIALIZE MODEL
        fprintf('   Initializing standard benchmark...\n');
        benchmarkinit; 
        
        % E. RESTORE UNIVERSE (Phase 2 - Post-Init)
        load('sim_config.mat');
        load('sim_state.mat');
        
        % F. EXTRACT PARAMETERS
        KLa3_target = test_cases(iter, 1);
        KLa4_target = test_cases(iter, 2);
        KLa5_target = test_cases(iter, 3);
        Stop_target = test_cases(iter, 4);
        
        fprintf('   Target: KLa=[%.2f, %.2f, %.2f], Q=%d, Time=%d\n', ...
            KLa3_target, KLa4_target, KLa5_target, target_Q, Stop_target);

        % G. OVERRIDE PARAMETERS
        % 1. Update Aeration
        KLa3 = KLa3_target;
        KLa4 = KLa4_target;
        KLa5 = KLa5_target;
        
        % 2. Update Flow Rate (Q) in CONSTINFLUENT matrix
        % Column 15 is Flow Rate
        CONSTINFLUENT(1,15) = target_Q; 
        CONSTINFLUENT(2,15) = target_Q;
        
        % Assign Q variable for the writer to use later
        Q = target_Q;

        % H. CONFIGURE & RUN SIMULATION
        if ~bdIsLoaded(ss_model)
            open_system(ss_model); % Window visible
        end
        
        set_param(ss_model, 'StopTime', num2str(Stop_target));
        set_param(ss_model, 'Solver', 'ode15s'); % Stiff solver
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
        
        % Pass variables to writer
        ssData_writer_reliability(settler, iter, KLa3, KLa4, KLa5, Q, Stop_target, output_file);
        
        % J. INCREMENT & SAVE STATE
        iter = iter + 1;
        save('sim_state.mat', 'iter');
        
    catch ME
        % Error Handling
        if ~exist('iter', 'var')
            if exist('sim_state.mat', 'file')
                load('sim_state.mat');
            else
                iter = NaN;
            end
        end
        
        fprintf('   ERROR in iteration %d: %s\n', iter, ME.message);
        try bdclose(ss_model); catch; end
        
        iter = iter + 1;
        save('sim_state.mat', 'iter');
    end
end

%% ===============================================
%% 3. CLEANUP
%% ===============================================

total_time = toc(total_start);
fprintf('\n=== COMPLETED in %.2f minutes ===\n', total_time/60);

if exist('sim_config.mat', 'file'), delete('sim_config.mat'); end
if exist('sim_state.mat', 'file'), delete('sim_state.mat'); end