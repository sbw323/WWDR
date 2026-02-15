clear
clc

load sensornoise;
asm1init;
settler1dinit_asm1;

load('iteration.mat');
load dryinfluent;
load storminfluent;
load raininfluent;
load constinfluent;
load DYNINFLUENT_ASM1;
load KLa3_Setpoints_14Day;
load KLa4_Setpoints_14Day;
load KLa5_Setpoints_14Day

DECAY = [0];        % if DECAY is 1 the decay of heterotrophs and autotrophs is depending on the electron acceptor present  
                    % if DECAY is 0 the decay do not change
SETTLER = [0];      % if SETTLER is 0 the settling model is non reactive
                    % if SETTLER IS 1 the settling model is reactive
ACTIVATE = [0];     % if ACTIVATE is 0 dummy states are 0 
                    % if ACTIVATE is 1 dummy states are activated
TEMPMODEL =[0];     % if TEMPM0DEL is 0 influent wastewater temperature is just passed through process reactors 
                    % if TEMPMODEL is 1 mass balance for the wastewater
                    % temperature is used in process reactors  