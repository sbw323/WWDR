load iteration
load DRflag

if DRflag == 1
    startsim = 0;
    simlen = iteration*14;
    outputtimes=[startsim:(1/96):simlen]; %Define the simulation time for dynamic influent
    
    disp(['Current iteration value is: ', num2str(iteration)]);

    DR_bsm2_ol
    load workspace_dynamic
    disp('Simulating DR Experiment BSM2 with dynamic influent (i) in open loop (Tempmodel = 1)! Solver = ode45 and Simulink model = benchmark2 open loop')
    disp('*****************************************************************************************************************')
    disp(' ')
    start=clock; 
    disp(['Start time for simulation (hour:min:sec) = ', num2str(round(start(4:6)))]); %Display simulation start time 
    
    options=simset('solver','ode45','Reltol',1e-5,'AbsTol',1e-8,'outputpoints','specified'); %Define simulation options for dynamic influent 
    sim('DR_bsm2_ol',outputtimes,options); %Simulate the BSM2 under dynamic influent 
    
    stop=clock;
    disp('Dynamic open loop BSM2 simulation finished!')
    disp(['End time for simulation (hour:min:sec) = ', num2str(round(stop(4:6)))]); %Display simulation stop time
    disp(' ')
    
    Data_writer
    Data_writer_reac
    perf_plant_DRbsm2
    figure_writer
end

if DRflag == 0
    startsim = 0;
    simlen = iteration*14;
    outputtimes=[startsim:(1/96):simlen]; %Define the simulation time for dynamic influent
    
    disp(['Current iteration value is: ', num2str(iteration)]);

    bsm2_ol
    load workspace_dynamic
    disp('Simulating DR Experiment BSM2 with dynamic influent (i) in open loop (Tempmodel = 1)! Solver = ode45 and Simulink model = benchmark2 open loop')
    disp('*****************************************************************************************************************')
    disp(' ')
    start=clock; 
    disp(['Start time for simulation (hour:min:sec) = ', num2str(round(start(4:6)))]); %Display simulation start time 
    
    options=simset('solver','ode45','Reltol',1e-5,'AbsTol',1e-8,'outputpoints','specified'); %Define simulation options for dynamic influent 
    sim('bsm2_ol',outputtimes,options); %Simulate the BSM2 under dynamic influent 
    
    stop=clock;
    disp('Dynamic open loop BSM2 simulation finished!')
    disp(['End time for simulation (hour:min:sec) = ', num2str(round(stop(4:6)))]); %Display simulation stop time
    disp(' ')

    save workspace_dynamic
end
% Code to close the Simulink model
close_system('bsm2_ss', 'force');
close_system('bsm2_ol', 'force');