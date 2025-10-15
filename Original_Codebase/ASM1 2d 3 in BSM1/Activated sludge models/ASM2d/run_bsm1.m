% This script will first run the BSM1 plant to steady state, followed by
% a simulation for dynamic influent conditions in closed loop. Finally, evaluation
% criteria are calculated and printed on the screen.

% This file has been created by Xavier Flores-Alsina
% July, 2010
% IEA, Lund University, Lund, Sweden

clear all;
close all;

benchmarkinit; %Initialize the BSM2
benchmarkss
outputtimes=[0:(1/96):14]; %Define the simulation time for dynamic influent



disp(' ')
disp('Running BSM1 to steady state! Solver = ode15s and Simulink model = benchmarkss')
disp('**************************************************************************')
disp(' ')
options = simset('solver','ode15s','Reltol',1e-5,'AbsTol',1e-8,'refine',1); %Define simulation options for constant influent
sim('benchmarkss',[0 200],options); %Simulate the BSM2 under constant influent

disp('Steady state achieved. Initializing all state variables to steady state values.')
disp(' ')
stateset; %Initialize the states 
save workspace_steady


benchmark
disp('Simulating BSM1 with dynamic influent (i) in closed loop (Tempmodel = 1)! Solver = ode45 and Simulink model = benchmark')
disp('*****************************************************************************************************************')
disp(' ')
start=clock; 
disp(['Start time for simulation (hour:min:sec) = ', num2str(round(start(4:6)))]); %Display simulation start time 

options=simset('solver','ode45','Reltol',1e-5,'AbsTol',1e-8,'outputpoints','specified'); %Define simulation options for dynamic influent 
sim('benchmark',outputtimes,options); %Simulate the BSM2 under dynamic influent 
stateset

disp('Simulating BSM1 with dynamic influent (ii) in closed loop (Tempmodel = 1)! Solver = ode45 and Simulink model = benchmark')
disp('*****************************************************************************************************************')
disp(' ')
start=clock; 
disp(['Start time for simulation (hour:min:sec) = ', num2str(round(start(4:6)))]); %Display simulation start time 

options=simset('solver','ode45','Reltol',1e-5,'AbsTol',1e-8,'outputpoints','specified'); %Define simulation options for dynamic influent 
sim('benchmark',outputtimes,options); %Simulate the BSM2 under dynamic influent 


stop=clock;
disp('Dynamic closed loop BSM1 simulation finished!')
disp(['End time for simulation (hour:min:sec) = ', num2str(round(stop(4:6)))]); %Display simulation stop time
disp(' ')

save workspace_dynamic