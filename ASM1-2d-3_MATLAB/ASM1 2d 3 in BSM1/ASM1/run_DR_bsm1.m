% This script will first run the BSM1 plant to steady state, followed by
% a simulation for dynamic influent conditions in closed loop. Finally, evaluation
% criteria are calculated and printed on the screen.

clear all;
close all;

benchmarkinit; %Initialize the BSM2
benchmarkss
preoutputtimes=[0:(1/96):6]; %Define the simulation time for pre aeration DR of dynamic influent
DRoutputtimes=[0:(1/96):1] %Define the simulation time for Aeration Demand Curtailment
outputtimes=[0:(1/96):7]; %Define the simulation time for post aeration DR of dynamic influent

disp(' ')
disp('Running BSM1 to steady state! Solver = ode15s and Simulink model = benchmarkss')
disp('**************************************************************************')
disp(' ')
options = simset('solver','ode15s','Reltol',1e-5,'AbsTol',1e-8,'refine',1); %Define simulation options for constant influent
sim('benchmarkss',[0 86],options); %Simulate the BSM2 under constant influent
stateset

asm1_DR_init
sim('benchmarkss',[0 14],options); %Simulate the BSM2 under constant influent
stateset

asm1_nomAer_init
sim('benchmarkss',[0 100],options); %Simulate the BSM2 under constant influent
disp('Demand Response Steady state achieved. Initializing all state variables to steady state values.')
disp(' ')
stateset; %Initialize the states 
save workspace_steady


benchmark
disp('Simulating BSM1 with nominal aeration & dynamic influent (i) in closed loop (Tempmodel = 1)! Solver = ode45 and Simulink model = benchmark')
disp('*****************************************************************************************************************')
disp(' ')
start=clock; 
disp(['Start time for simulation (hour:min:sec) = ', num2str(round(start(4:6)))]); %Display simulation start time 

options=simset('solver','ode45','Reltol',1e-5,'AbsTol',1e-8,'outputpoints','specified'); %Define simulation options for dynamic influent 
sim('benchmark',preoutputtimes,options); %Simulate the BSM2 under dynamic influent with nominal aeration
stateset

disp('Simulating BSM1 with aeration curtailment (DR) in closed loop (Tempmodel = 1)! Solver = ode45 and Simulink model = benchmark')
disp('*****************************************************************************************************************')
disp(' ')
asm1_DR_init
start=clock; 
disp(['Start time for DR simulation (hour:min:sec) = ', num2str(round(start(4:6)))]); %Display DR simulation start time 

options=simset('solver','ode45','Reltol',1e-5,'AbsTol',1e-8,'outputpoints','specified'); %Define simulation options for dynamic influent 
sim('benchmark',DRoutputtimes,options); %Simulate the BSM2 under dynamic influent with aeration curtailment
stateset


disp('Simulating BSM1 with nominal aeration & dynamic influent (ii) in closed loop (Tempmodel = 1)! Solver = ode45 and Simulink model = benchmark')
disp('*****************************************************************************************************************')
disp(' ')
asm1_nomAer_init
start=clock; 
disp(['Start time for nominal aeration simulation (hour:min:sec) = ', num2str(round(start(4:6)))]); %Display simulation start time 

options=simset('solver','ode45','Reltol',1e-5,'AbsTol',1e-8,'outputpoints','specified'); %Define simulation options for dynamic influent 
sim('benchmark',outputtimes,options); %Simulate the BSM2 under dynamic influent 


stop=clock;
disp('Dynamic closed loop BSM1 simulation finished!')
disp(['End time for simulation (hour:min:sec) = ', num2str(round(stop(4:6)))]); %Display simulation stop time
disp(' ')

save workspace_dynamic