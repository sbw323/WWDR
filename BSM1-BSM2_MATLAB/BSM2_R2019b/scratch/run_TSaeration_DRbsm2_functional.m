% This script will first run the BSM2 plant to steady state, followed by
% a simulation for dynamic influent conditions in closed loop. Finally, evaluation
% criteria are calculated and printed on the screen.

clear all;
close all;

init_bsm2_DR; %Initialize the BSM2
days = 245+iteration*14;
DR_bsm2_ss
outputtimes=[0:(1/96):days*96]; %Define the simulation time for dynamic influent

disp(['Current iteration value is: ', num2str(iteration)]);


disp(' ')
disp('Running BSM2 to steady state! Solver = ode15s and Simulink model = benchmarkss')
disp('**************************************************************************')
disp(' ')
options = simset('solver','ode15s','Reltol',1e-5,'AbsTol',1e-8,'refine',1); %Define simulation options for constant influent
sim('DR_bsm2_ss',[0 200],options); %Simulate the BSM2 under constant influent

disp('Steady state achieved. Initializing all state variables to steady state values.')
disp(' ')
stateset_bsm2; %Initialize the states 
save workspace_steady


DR_bsm2_ol
disp('Simulating BSM2 with dynamic influent (i) in open loop (Tempmodel = 1)! Solver = ode45 and Simulink model = benchmark')
disp('*****************************************************************************************************************')
disp(' ')
start=clock; 
disp(['Start time for simulation (hour:min:sec) = ', num2str(round(start(4:6)))]); %Display simulation start time 

options=simset('solver','ode45','Reltol',1e-5,'AbsTol',1e-8,'outputpoints','specified'); %Define simulation options for dynamic influent 
sim('DR_bsm2_ol',outputtimes,options); %Simulate the BSM2 under dynamic influent 
stateset_bsm2

stop=clock;
disp('Dynamic open loop BSM2 simulation finished!')
disp(['End time for simulation (hour:min:sec) = ', num2str(round(stop(4:6)))]); %Display simulation stop time
disp(' ')

save workspace_dynamic

Data_writer
Data_writer_reac
perf_plant_DRbsm2
figure_writer

% Code to close the Simulink model
close_system('DR_bsm2_ss', 'force');
close_system('DR_bsm2_ol', 'force');