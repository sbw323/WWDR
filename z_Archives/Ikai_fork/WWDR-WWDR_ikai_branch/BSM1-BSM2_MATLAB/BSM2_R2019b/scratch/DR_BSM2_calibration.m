% clear all;
% close all;
% 
% init_bsm2_DR; %Initialize the BSM2
% days = 609;
% bsm2_ss
% outputtimes=[0:(1/96):days]; %Define the simulation time for dynamic influent
% 
% disp(' ')
% disp('Running BSM2 to steady state! Solver = ode15s and Simulink model = benchmark2 ss')
% disp('**************************************************************************')
% disp(' ')
% options = simset('solver','ode15s','Reltol',1e-5,'AbsTol',1e-8,'refine',1); %Define simulation options for constant influent
% sim('bsm2_ss',[0 200],options); %Simulate the BSM2 under constant influent
% 
% disp('Steady state achieved. Initializing all state variables to steady state values.')
% disp(' ')
% stateset_bsm2; %Initialize the states 
% save workspace_steady
% 
% bsm2_ol
% disp('Simulating BSM2 with dynamic influent (i) in open loop (Tempmodel = 1)! Solver = ode45 and Simulink model = benchmark2 open loop')
% disp('*****************************************************************************************************************')
% disp(' ')
% start=clock; 
% disp(['Start time for simulation (hour:min:sec) = ', num2str(round(start(4:6)))]); %Display simulation start time 
% 
% options=simset('solver','ode45','Reltol',1e-5,'AbsTol',1e-8,'outputpoints','specified'); %Define simulation options for dynamic influent 
% sim('bsm2_ol',outputtimes,options); %Simulate the BSM2 under dynamic influent 
% stateset_bsm2
% 
% stop=clock;
% disp('Dynamic open loop BSM2 simulation finished!')
% disp(['End time for simulation (hour:min:sec) = ', num2str(round(stop(4:6)))]); %Display simulation stop time
% disp(' ')
% 
% save workspace_dynamic

clear all;
close all;

init_bsm2_DR; %Initialize the BSM2
days = 609;
bsm2_ss
outputtimes = 0:(1/96):days; %Define the simulation time for dynamic influent

disp(' ')
disp('Running BSM2 to steady state! Solver = ode15s and Simulink model = benchmark2 ss')
disp('**************************************************************************')
disp(' ')
options = simset('solver','ode15s','Reltol',1e-5,'AbsTol',1e-8,'refine',1); %Define simulation options for constant influent
sim('bsm2_ss', [0 200], options); %Simulate the BSM2 under constant influent

disp('Steady state achieved. Initializing all state variables to steady state values.')
disp(' ')
stateset_bsm2; %Initialize the states 
save workspace_steady

% === Open Loop Simulation with Pause at t = 245 ===
DR_bsm2_ol % If this initializes a setup script, keep it
disp('Simulating BSM2 with dynamic influent (i) in open loop (Tempmodel = 1)! Solver = ode45 and Simulink model = benchmark2 open loop')
disp('*****************************************************************************************************************')
disp(' ')
start = clock; 
disp(['Start time for simulation (hour:min:sec) = ', num2str(round(start(4:6)))]); %Display simulation start time 

% Set up Simulink model
model = 'DR_bsm2_ol';
cal_time = 245; % days
pause_time = 14; 
custom_code_run = false;

load_system(model); % Open silently if not already open
set_param(model, 'StopTime', num2str(outputtimes(end))); % End time = full duration
set_param(model, 'Solver', 'ode45'); % Use ode45 as defined
set_param(model, 'SimulationMode', 'normal');

% Start simulation asynchronously
set_param(model, 'SimulationCommand', 'start');

% Wait for simulation to enter 'running' state
while ~strcmp(get_param(model, 'SimulationStatus'), 'running')
    pause(0.2);
end

% Monitor simulation time and pause at specified point
while true
    status = get_param(model, 'SimulationStatus');
    if strcmp(status, 'stopped')
        break;
    end

    sim_time = get_param(model, 'SimulationTime');

    if ~custom_code_run && sim_time >= pause_time
        set_param(model, 'SimulationCommand', 'pause');
        disp(['Simulation paused at t = ', num2str(sim_time), ' days.']);

        % Wait for simulation to fully pause
        while ~strcmp(get_param(model, 'SimulationStatus'), 'paused')
            pause(0.1);
        end

        % Perform custom commands at pause point
        stateset_bsm2;
        save workspace_dynamic

        % Resume simulation
        set_param(model, 'SimulationCommand', 'continue');
        disp('Simulation resumed after custom actions.');

        custom_code_run = true;
    end

    pause(0.2); % prevent tight polling
end

% Wait until simulation ends
while ~strcmp(get_param(model, 'SimulationStatus'), 'stopped')
    pause(0.5);
end

% Finalize
stateset_bsm2
stop = clock;
disp('Dynamic open loop BSM2 simulation finished!')
disp(['End time for simulation (hour:min:sec) = ', num2str(round(stop(4:6)))])
disp(' ')

save workspace_dynamic
