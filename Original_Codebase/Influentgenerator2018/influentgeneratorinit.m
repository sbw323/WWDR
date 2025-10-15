% This is the inititialization file for the new influent generator model
% used in the conference paper: 
% Ramesh Saagi
% IEA, LTH, Sweden
% October 2018


%% Input data and general parameters for the entire model
% Load dry weather flow profiles
load domestic_day;      % normalized diurnal profile of domestic wastewater flow and pollutants
load domestic_week;     % normalized profile for variation in flow during the week
load industrial_week;   % normalized 4-hourly profile for a week duration of industrial wastewater flow and pollutants
load domestic_year;     % normalized profile for variation in profile during an year for domestic. 
load industrial_year;   % normalized profile for variation in profile during an year for industries
noise_std=0.1;          % noise standard deviation as a fraction of total load 

% Rainfall and temperature data
load rain_data.mat          % rainfall intensity in mm/h
load evaporation_data.mat   % yearly evaporation profile (mm/h)
load temperature_air.mat    % air temperature in C
evaporation_on=1;           % switch to turn ON/OFF evaporation effects. ON=1; OFF=0.

% %Change the default holiday periods with user-defined dates
% startday=datetime(2011,12,31);
% hol1_start=datetime(2012,01,26); % beginning of holiday 1
% hol1_end=datetime(2012,02,16);   % end of holiday 1
% ind_hol1=(days(hol1_start-startday):1:days(hol1_end-startday));
% 
% hol2_start=datetime(2012,07,01); % beginning of holiday 2
% hol2_end=datetime(2012,08,16);   % end of holiday 2
% ind_hol2=(days(hol2_start-startday):1:days(hol2_end-startday));
% 
% ind_temp1 = [ind_hol1';ind_hol2'];% one can add more holiday periods to this vector
% ind_temp2=(1:1:length(domestic_year.signals.values))';
% ind_all=intersect(ind_temp1,ind_temp2);
% domestic_year.signals.values(ind_all,:)=0.75;
% domestic_year.signals.values=domestic_year.signals.values./mean(domestic_year.signals.values); % normalizing the yearly profile so that the mean yearly variation is 1.

% % Use this to produce uniform profiles for wastewater generation during dry weather
% domestic_day.signals.values(:,:)=1;
% domestic_year.signals.values(:,:)=1;
% domestic_week.signals.values(:,:)=1;
% industrial_week.signals.values(:,:)=1;
% industrial_year.signals.values(:,:)=1;
% noise_std=0;

% Event mean concentration during rain events
emc_codsol = 9/1000; % (kg/m3) event mean concentration for CODsol (BOD5 value from table is used) during rain events (from Table 6.3 - Textbook "Urban Drainage by David Butler and John W. Davies)
emc_nh4 = 0.56/1000; % (kg/m3) event mean concentration for NH4-N during rain events

% Seasonal infiltration parameters
amp=0.05;            % amplitude fraction for each sub catchment
freq=2*pi/365;       % frequency   
phase=-3*pi/2;       % phase shift   
XINITSOIL=2.00075;   % inital value for infiltration to sewer model
kinf_tune =20;       % tuning parameter for infiltration to soil - represents flow to sewer pipes
kdown_tune=0.25;     % tuning parameter for infiltration to soil - represents flow to downstream aquifers

% Catchment and sewer storage parameters commonly used for all sub-catchments
ksewer=6/(60*24);                                         % residence time for each sewer reservoir
PAR_RESERVOIR=[2; 10; 0.5; 0; 0.15; ksewer*2000; ksewer]; % initial values for state variables in sewer reservoir
PAR_RESERVOIR_rain=[0; 0; 0; 0; 0; 0; ksewer];            % initial values for rainfall runoff reservoirs
PAR_SNOW=[0;0.25];                                        % initial values for the snow_depth model

%% Temperature model parameters
% Annual variation
TAmp =  4;                                  % sine wave amplitude (deg. C)
TBias = 16;                                 % sine wave bias (deg. C)
TFreq = freq;                               % sine wave frequency (rad/d)
TPhase =-0.4*2*pi;% -phase;                 % sine wave phase shift
% Daily variation
TdAmp = 0.7;                                % sine wave amplitude (deg. C)
TdBias = 0;                                 % sine wave bias (deg. C)
TdFreq = 2*pi;                              % sine wave frequency (rad/d)
TdPhase = 0.25*pi; %pi*1.5;                 % sine wave phase shift
temp_correction=2;

%% ASM1 fractionation parameters
SALK_cst = 7;
SI_cst   = 30.0;                            % SI is not defined as a fraction of soluble COD, but as a constant concentration
                                            % It is assumed that SI is also present in the infiltration water. Only rain can dilute SI
XI_fr    = 0.23;                            % XI as fraction of particulate COD
XS_fr    = 0.62;                            % XS as fraction of particulate COD
XBH_fr   = 0.15;                            % XBH as fraction of particulate COD
XBA_fr   = 0.0;                             % XBA as fraction of particulate COD
XP_fr    = 0.0;                             % XP as fraction of particulate COD
SNO_fr   = 1.0;                             % SNO as fraction of inorganic N (strictly speaking not needed, but opens possibilities 
                                            % for developing influent models considering both nitrate and nitrite)
SNH_fr   = 1.0;                             
SND_fr   = 0.247;                           % BSM2
XND_fr   = 0.753;                           % BSM2

ASM1_FRACTIONS = [SI_cst XI_fr XS_fr XBH_fr XBA_fr XP_fr SNO_fr SNH_fr SND_fr XND_fr];       
%% For each urban sub-catchment - sub-catchment 1
QperPE1=0.15;        % domestic wastewater production per inhabitant per day (m3/PE.day)
Qind_daily1 = 15000; % daily industrial wastewater production (m3/d)
codpart_frac1=0.7;   % particulate fraction of total COD. 
domestic_avg1=[(1-codpart_frac1)*150/1000 codpart_frac1*150/1000  10/1000 15/1000 1.5/1000 QperPE1]; % kg pol/PE.day domestic per capita wastewater generation [CODsolperPE, CODpartperPE SNHperPE NOxperPE QperPE]
industrial_avg1=[2000, 8000, 500, 800, 50, Qind_daily1];                                            % kg /d industrial load [CODsol_daily, CODpart_daily SNH_daily TKN_daily NOx_daily Qind_daily]
pe1=400000;         % population equivalents for domestic wastewater

imp_area1=250;      % impervious area (ha)
perv_area1=1000;     % pervious area (ha)
rrc1 = 1;           % rainfall runoff coefficient

%Accumulation % washoff model
Kacc=5;
Kdecay=0.2;
Kwashoff=0.3;
area1=imp_area1;
PAR_QUALITY1 = [Kacc Kdecay Kwashoff area1];% parameters for the accumulation and washoff model
XINIT_QUALITY1 = 1;                         % initial value for the accumulation and washoff model

% Infiltration to sewer model
gwbias1=95000;          % average yearly infiltration for the whole catchment
XINITSOIL1=XINITSOIL;   % inital value for infiltration to sewer model

HINV=2;                                     % invert level in tank, i.e. water level corresponding to bottom of sewer pipes
HMAX=HINV+0.8;                              % maximum water level in tank
A=perv_area1*2;                              % surface area
K=0.6;                                      % parameter, permeability of soil for water penetration
Kinf=gwbias1*kinf_tune;                     % infiltration gain, can be an indication of the quality of the sewer system pipes
Kdown=gwbias1*kdown_tune;                   % gain to adjust for flow rate to downstream aquifer
Kevap=0.05;                                 % factor to adjust the effect of evaporation of infiltration to sewers
PARS_SOIL1=[HMAX HINV A*10000 K Kinf Kdown Kevap];  % parameter vector, an input to the unisoilmodel.c S-function
clearvars HMAX HINV A*10000 K Kinf Kdown Kevap;

% sewer model
subareas1=7; % no. of sub-divisions of the sewer system. The total inflow is divided into 7(subareas1) and fed into the sewer system at different points. 
             % this is to simulate a more realistic sewer system where inflows enter at diferrent points in the catchment rather than the entire inflow from one point

% First flush model in the sewer system
FFfraction1 = 0.25;                          % fraction of the TSS that is able to settle in the sewers
M_Max = area1*10;                            % kg SS
XINIT_FF = M_Max;                            % initial TSS load in the sewer system   
Q_lim = pe1*QperPE1*8;                        % m3/d
n     = 15;                                  % dimensionless
Ff    = 5000;                                % dimensionless, gain
PAR_FIRSTFLUSH1=[XINIT_FF M_Max Q_lim n Ff]; % parameters for the firstflush model in the sewer syste,
clearvars XINIT_FF M_Max Q_lim n Ff;

