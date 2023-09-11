% This file has been modified by Xavier Flores-Alsina
% July, 2010
% IEA, Lund University, Lund, Sweden

clear all;
clc;

asm2dinit;
settler1dinit_asm2d
reginit;


load dryinfluent;
load storminfluent;
load raininfluent;
load constinfluent;
load DYNINFLUENT_ASM2d



DECAY = [0];        % if DECAY is 1 the decay of heterotrophs, autotrophs and phosphorus accumulating organisms is depending on the electron acceptor present  
                    % if DECAY is 0 the decay do not change
                    
SETTLER = [0];      % if SETTLER is 0 the settling model is non reactive
                    % if SETTLER IS 1 the settling model is reactive
                    
TEMPMODEL = [0];    % if TEMPM0DEL is 0 influent wastewater temperature is just passed through process reactors 
                    % if TEMPMODEL is 1 mass balance for the wastewater temperature is used in process reactors    
                    
ACTIVATE = [0];     % if ACTIVATE is 0 dummy states are 0 
                    % if ACTIVATE is 0 dummy states are activated
                    