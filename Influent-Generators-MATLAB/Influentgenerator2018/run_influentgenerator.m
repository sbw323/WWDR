% Load parameter values from init file
influentgeneratorinit

%% Run simulation
tic;sim('influentgenerator_BSM');toc

%% Data processing

% Create necessary time and date vectors
td_model=datetime([2012,01,01,00,00,00])+days(tout);

% Create individual vectors for flow rate and pollutants
inpart=inflow_WWTP(1:end,:);        % flow rate
CODinvec=(inpart(:,1)+inpart(:,2)); % total COD
SNH4invec=inpart(:,3);              % SNH4 
TKNinvec=inpart(:,4);               % TKN
TPinvec=inpart(:,5);                % TP    
Tempinvec=inpart(:,7);              % Temperature

mean_model=[mean(inflow_WWTP(:,6)); mean(CODinvec); mean(SNH4invec); mean(TKNinvec); mean(TPinvec)];

% Compute monthly, weekly, daily and hourly mean values
[ym,yw,yd,yh]=meanvalues(td_model,inflow_WWTP(:,6));                    % flow rate
[ym_COD,yw_COD,yd_COD,yh_COD]=meanvalues(td_model,CODinvec(:,1));       % total COD
[ym_NH4,yw_NH4,yd_NH4,yh_NH4]=meanvalues(td_model,SNH4invec(:,1));      % NH4-N
[ym_TKN,yw_TKN,yd_TKN,yh_TKN]=meanvalues(td_model,TKNinvec(:,1));       % TKN
[ym_TP,yw_TP,yd_TP,yh_TP]=meanvalues(td_model,TPinvec(:,1));            % TP
[ym_temp,yw_temp,yd_temp,yh_temp]=meanvalues(td_model,Tempinvec(:,1));  % temperature

%% Display and plot results

disp('*****************************************************')
disp('Summary of the influent data ')
disp('*****************************************************')
disp(' ')
disp('Influent characteristics')
disp('---------------------------------------------')
disp(['Daily average flow rate = ',num2str(round(mean_model(1))),' m3/d '])
disp(['Daily average COD load = ',num2str(round(mean_model(2))),' kg/d'])
disp(['Daily average NH4-N load = ',num2str(round(mean_model(3))),' kg/d'])
disp(['Daily average TKN load = ',num2str(round(mean_model(4))),' kg/d'])
disp(['Daily average TP load = ',num2str(round(mean_model(5))),' kg/d'])
disp(['Daily average COD conc = ',num2str(round(mean_model(2)*1000./mean_model(1))),' g/m3'])
disp(['Daily average NH4-N conc = ',num2str(round(mean_model(3)*1000./mean_model(1))),' g/m3'])
disp(['Daily average TKN conc = ',num2str(round(mean_model(4)*1000./mean_model(1))),' g/m3'])
disp(['Daily average TP conc = ',num2str(round(mean_model(5)*1000./mean_model(1))),' g/m3'])
disp(['Population equivalents = ',num2str(round(pe1)),' g/m3'])
disp(' ')

% Figure 1 - flow rate
figure
plot(td_model,inflow_WWTP(:,6))
ylabel ('flow rate m^3/d')
xlim(datetime(2012, [1 12], [01 31]))

%Figure 2 - monthly, weekly and daily average flow rate
figure
subplot(3,1,1)
plot(ym.t,ym.x)
xlabel ('months')
ylabel ('flow rate m^3/d')
xlim(datetime(2012, [1 12], [01 31]))
subplot(3,1,2)
plot(yd.t, yd.x)
xlabel ('days')
ylabel ('flow rate m^3/d')
xlim(datetime(2012, [1 12], [01 31]))
subplot(3,1,3)
plot(yh.t, yh.x)
xlabel ('hours')
ylabel ('flow rate m^3/d')
xlim(datetime(2012, [1 12], [01 31]))

% Figure 3 - COD conc. and load
figure
subplot(2,1,1)
plot(yw_COD.t,1000*yw_COD.x./(yw.x))
ylabel ('COD conc. (g/m^3)')
xlim(datetime(2012, [1 12], [01 31]))
subplot(2,1,2)
plot(yw_COD.t,yw_COD.x)
ylabel ('COD load (kg/d)')
xlim(datetime(2012, [1 12], [01 31]))

% Figure 4 - conc. for NH4, TKN and TP
figure
subplot(3,1,1)
plot(yw_NH4.t,1000*yw_NH4.x./(yw.x))
ylabel ('NH4-N conc. (g/m^3)')
subplot(3,1,2)
plot(yw_TKN.t,1000*yw_TKN.x./(yw.x))
ylabel ('TN conc. (g/m^3)')
subplot(3,1,3)
plot(yw_TP.t,1000*yw_TP.x./(yw.x))
ylabel ('TP conc. (g/m^3)')

% Figure 4 - loads for NH4, TKN and TP
figure
subplot(3,1,1)
plot(yw_NH4.t,yw_NH4.x)
ylabel ('NH4-N load (kg/d')
subplot(3,1,2)
plot(yw_TKN.t,yw_TKN.x)
ylabel ('TN load (kg/d')
subplot(3,1,3)
plot(yw_TP.t,yw_TP.x)
ylabel ('TP load (kg/d')

% Figure 5 - temperature at model sample time and daily average values
figure
subplot(2,1,1)
plot(td_model, temp_wwtp)
ylabel ('Temp (C)')
subplot(2,1,2)
plot(yd_temp.t, yd_temp.x)
ylabel ('Temp (C)')