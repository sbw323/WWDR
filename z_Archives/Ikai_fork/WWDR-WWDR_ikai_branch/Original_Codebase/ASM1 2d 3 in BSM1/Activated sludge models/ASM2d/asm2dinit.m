% initialization files for all the asm2d state variables + T +  dummy states

% This file has been created by Xavier Flores-Alsina
% July, 2010
% IEA, Lund University, Lund, Sweden

Qin0 = 18446;
Qintr = 3*Qin0;
Qw= 385;

S_O2_1 = 0;
S_F_1 = 2;
S_A_1 = 5;
S_I_1 = 30;
S_NH4_1 = 22;
S_N2_1 = 21;
S_NOX_1 = 0.001;
S_PO4_1 = 11;
S_ALK_1 = 6;
X_I_1 = 1800;
X_S_1 = 150;
X_H_1 = 1900;
X_PAO_1 = 250;
X_PP_1 = 70;
X_PHA_1 = 7;
X_A_1 = 125;
X_TSS_1 = 3700;
X_MeOH_1 = 0;
X_MeP_1 = 0;
Q1 = Qin0*2;
T1 = 15;
S_D1_1 = 0;
S_D2_1 = 0;
S_D3_1 = 0;
X_D4_1 = 0;
X_D5_1 = 0;

S_O2_2 = 0;
S_F_2 = 1;
S_A_2 = 15;
S_I_2 = 30;
S_NH4_2 = 22;
S_N2_2 = 21;
S_NOX_2 = 0.001;
S_PO4_2 = 16;
S_ALK_2 = 6;
X_I_2 = 1800;
X_S_2 = 140;
X_H_2 = 1900;
X_PAO_2 = 250;
X_PHA_2 = 18;
X_PP_2 = 70;
X_A_2 = 125;
X_TSS_2 = 3700;
X_MeOH_2 = 0;
X_MeP_2 = 0;
Q2 = Qin0*2;
T2 = 15;
S_D1_2 = 0;
S_D2_2 = 0;
S_D3_2 = 0;
X_D4_2 = 0;
X_D5_2 = 0;


S_O2_3 = 0;
S_F_3 = 0.5;
S_A_3 = 1;
S_I_3 = 30;
S_NH4_3 = 10;
S_N2_3 = 30;
S_NOX_3 = 6;
S_PO4_3 = 10;
S_ALK_3 = 5;
X_I_3 = 1800;
X_S_3 = 80;
X_H_3 = 1900;
X_PAO_3 = 250;
X_PP_3 = 70;
X_PHA_3 = 6;
X_A_3 = 125;
X_TSS_3 = 3700;
X_MeOH_3 = 0;
X_MeP_3 = 0;
Q3 = Qin0*2+Qintr;
T3 = 14.8581;
S_D1_3 = 0;
S_D2_3 = 0;
S_D3_3 = 0;
X_D4_3 = 0;
X_D5_3 = 0;

S_O2_ASin  = S_O2_3*Q3 ;
S_F_ASin   = S_F_3*Q3 ;
S_A_ASin   = S_A_3*Q3;
S_I_ASin   = S_I_3*Q3 ;
S_NH4_ASin = S_NH4_3*Q3 ;
S_N2_ASin  = S_N2_3*Q3;
S_NOX_ASin = S_NOX_3*Q3 ;
S_PO4_ASin = S_PO4_3*Q3;
S_ALK_ASin = S_ALK_3*Q3;
X_I_ASin   = X_I_3*Q3;
X_S_ASin   = X_S_3*Q3 ;
X_H_ASin   = X_H_3*Q3 ;
X_PAO_ASin = X_PAO_3*Q3;
X_PP_ASin  = X_PP_3*Q3;
X_PHA_ASin = X_PHA_3*Q3 ;
X_A_ASin   = X_A_3*Q3;
X_TSS_ASin = X_TSS_3*Q3 ;
X_MeOH_ASin= X_MeOH_3*Q3;
X_MeP_ASin = X_MeP_3*Q3;
Q_ASin     = Q3;
T_ASin = 14.8581;
S_D1_ASin = 0;
S_D2_ASin = 0;
S_D3_ASin = 0;
X_D4_ASin = 0;
X_D5_ASin = 0;

S_O2_4 = 0;
S_F_4 = 0.5;
S_A_4 = 1;
S_I_4 = 30;
S_NH4_4 = 10;
S_N2_4 = 30;
S_NOX_4 = 4;
S_PO4_4 = 9;
S_ALK_4 = 5;
X_I_4 = 1800;
X_S_4 = 80;
X_H_4 = 1900;
X_PAO_4 = 250;
X_PP_4 = 70;
X_PHA_4 = 5;
X_A_4 = 125;
X_TSS_4 = 3700;
X_MeOH_4 = 0;
X_MeP_4 = 0;
Q4 = Qin0*2+Qintr;
T4 = 15;
S_D1_4 = 0;
S_D2_4 = 0;
S_D3_4 = 0;
X_D4_4 = 0;
X_D5_4 = 0;


S_O2_5 = 2;
S_F_5 = 0.5;
S_A_5 = 0.1;
S_I_5 = 30;
S_NH4_5 = 10;
S_N2_5 = 30;
S_NOX_5 = 6;
S_PO4_5 = 7;
S_ALK_5 = 4;
X_I_5 = 1800;
X_S_5 = 70;
X_H_5 = 1900;
X_PAO_5 = 250;
X_PP_5 = 70;
X_PHA_5 = 2;
X_A_5 = 125;
X_TSS_5 = 3700;
X_MeOH_5 = 0;
X_MeP_5 = 0;
Q5 = Qin0*2+Qintr;
T5 = 14.8581;
S_D1_5 = 0;
S_D2_5 = 0;
S_D3_5 = 0;
X_D4_5 = 0;
X_D5_5 = 0;


S_O2_6 = 2;
S_F_6 = 0.5;
S_A_6 = 0.1;
S_I_6 = 30;
S_NH4_6 = 5;
S_N2_6 = 30;
S_NOX_6 =9;
S_PO4_6 = 7;
S_ALK_6 = 4;
X_I_6 = 1800;
X_S_6 = 60;
X_H_6 = 1900;
X_PAO_6 = 250;
X_PP_6 = 70;
X_PHA_6 = 6;
X_A_6 = 125;
X_TSS_6 = 3700;
X_MeOH_6 = 0;
X_MeP_6 = 0;
Q6 = Qin0*2+Qintr;
T6 = 15;
S_D1_6 = 0;
S_D2_6 = 0;
S_D3_6 = 0;
X_D4_6 = 0;
X_D5_6 = 0;


S_O2_7 = 2;
S_F_7 = 0.5;
S_A_7 = 0.1;
S_I_7 = 30;
S_NH4_7 = 2;
S_N2_7 = 30;
S_NOX_7 = 10;
S_PO4_7 = 6;
S_ALK_7 = 4;
X_I_7 = 1800;
X_S_7 = 50;
X_H_7 = 1900;
X_PAO_7 = 250;
X_PP_7 = 70;
X_PHA_7 = 1;
X_A_7 = 125;
X_TSS_7 = 3700;
X_MeOH_7 = 0;
X_MeP_7 = 0;
Q7 = Qin0*2+Qintr;
T7 = 15;
S_D1_7 = 0;
S_D2_7 = 0;
S_D3_7 = 0;
X_D4_7 = 0;
X_D5_7 = 0;


XINITDELAY = [S_O2_ASin S_F_ASin S_A_ASin S_I_ASin S_NH4_ASin S_N2_ASin S_NOX_ASin S_PO4_ASin S_ALK_ASin X_I_ASin X_S_ASin X_H_ASin X_PAO_ASin X_PP_ASin X_PHA_ASin X_A_ASin X_TSS_ASin X_MeOH_ASin X_MeP_ASin Q_ASin  T_ASin S_D1_ASin S_D2_ASin S_D3_ASin X_D4_ASin X_D5_ASin];
XINIT1 = [ S_O2_1  S_F_1  S_A_1  S_I_1  S_NH4_1  S_N2_1  S_NOX_1  S_PO4_1  S_ALK_1  X_I_1  X_S_1  X_H_1  X_PAO_1  X_PP_1  X_PHA_1  X_A_1  X_TSS_1  X_MeOH_1  X_MeP_1  Q1  T1 S_D1_1 S_D2_1 S_D3_1 X_D4_1 X_D5_1];
XINIT2 = [ S_O2_2  S_F_2  S_A_2  S_I_2  S_NH4_2  S_N2_2  S_NOX_2  S_PO4_2  S_ALK_2  X_I_2  X_S_2  X_H_2  X_PAO_2  X_PP_2  X_PHA_2  X_A_2  X_TSS_2  X_MeOH_2  X_MeP_2  Q2  T2 S_D1_2 S_D2_2 S_D3_2 X_D4_2 X_D5_2];
XINIT3 = [ S_O2_3  S_F_3  S_A_3  S_I_3  S_NH4_3  S_N2_3  S_NOX_3  S_PO4_3  S_ALK_3  X_I_3  X_S_3  X_H_3  X_PAO_3  X_PP_3  X_PHA_3  X_A_3  X_TSS_3  X_MeOH_3  X_MeP_3  Q3  T3 S_D1_3 S_D2_3 S_D3_3 X_D4_3 X_D5_3];
XINIT4 = [ S_O2_4  S_F_4  S_A_4  S_I_4  S_NH4_4  S_N2_4  S_NOX_4  S_PO4_4  S_ALK_4  X_I_4  X_S_4  X_H_4  X_PAO_4  X_PP_4  X_PHA_4  X_A_4  X_TSS_4  X_MeOH_4  X_MeP_4  Q4  T4 S_D1_4 S_D2_4 S_D3_4 X_D4_4 X_D5_4];
XINIT5 = [ S_O2_5  S_F_5  S_A_5  S_I_5  S_NH4_5  S_N2_5  S_NOX_5  S_PO4_5  S_ALK_5  X_I_5  X_S_5  X_H_5  X_PAO_5  X_PP_5  X_PHA_5  X_A_5  X_TSS_5  X_MeOH_5  X_MeP_5  Q5  T5 S_D1_5 S_D2_5 S_D3_5 X_D4_5 X_D5_5];
XINIT6 = [ S_O2_6  S_F_6  S_A_6  S_I_6  S_NH4_6  S_N2_6  S_NOX_6  S_PO4_6  S_ALK_6  X_I_6  X_S_6  X_H_6  X_PAO_6  X_PP_6  X_PHA_6  X_A_6  X_TSS_6  X_MeOH_6  X_MeP_6  Q6  T6 S_D1_6 S_D2_6 S_D3_6 X_D4_6 X_D5_6];
XINIT7 = [ S_O2_7  S_F_7  S_A_7  S_I_7  S_NH4_7  S_N2_7  S_NOX_7  S_PO4_7  S_ALK_7  X_I_7  X_S_7  X_H_7  X_PAO_7  X_PP_7  X_PHA_7  X_A_7  X_TSS_7  X_MeOH_7  X_MeP_7  Q7  T7 S_D1_7 S_D2_7 S_D3_7 X_D4_7 X_D5_7];


%%% ASM2d-CEP model parameters
% Parameter values for 15 deg. C, obtained from olasm2dinit.m
% Reference values for kinetic parameters as comments (first value = 10 deg. C; 2nd value = 20 deg. C)

f_SI     = 	0.00;    % Fraction of SI from hydrolysis 
Y_H      = 	0.625;   % Yield of heterotrophic biomass (XH)
Y_PAO    =	0.625;   % Yield coefficient (biomass/PHA)
Y_PO4    =	0.40;    % PP requirement (PO4 release) per PHA stored
Y_PHA    =	0.20;    % PHA requirement for PP storage
Y_A      =	0.24;    % Yield of autotrophic biomass (XA)
f_XIH    =	0.10;    % Fraction of inert COD from lysis
f_XIP    =	0.10;    % Fraction of inert COD from lysis
f_XIA    =	0.10;    % Fraction of inert COD from lysis
iN_SI    =	0.01;    % N content of inert soluble COD, SI
iN_SF    =	0.03;    % N content of soluble COD, SF
iN_XI    =	0.02;    % N content of inert particulate COD, XI
iN_XS    =	0.04;    % N content of particulate COD, XS
iN_BM    =	0.07;    % N content of biomass (XH, XPAO, XA)
iP_SI    =	0.00;    % P content of inert soluble COD, SI
iP_SF    =	0.01;    % P content of soluble COD, SF
iP_XI    =	0.01;    % P content of inert particulate COD, XI
iP_XS    =	0.01;    % P content of particulate COD, XS
iP_BM    =	0.02;    % P content of biomass (XH, XPAO, XA)
iSS_XI   =	0.75;    % TSS to COD ratio for XI
iSS_XS   =	0.75;    % TSS to COD ratio for XS
iSS_BM   =	0.90;    % TSS to COD ratio for biomass (XH, XPAO, XA)
k_H      =  2.46;    % Hydrolysis rate constant (2.00; 3.00)
hL_NO3   =	0.60;    % Anoxic hydrolysis reduction factor
hL_fe    =	0.40;    % Anaerobic hydrolysis reduction factor
KL_O2    =	0.20;    % Saturaton/inhibition coefficient for oxygen
KL_NO3   =	0.50;    % Saturaton/inhibition coefficient for nitrate
KL_X     =	0.10;    % Saturaton coefficient for particulate COD
Mu_H     =  4.23;    % Maximal growth rate on substrate (3.00; 6.00)
q_fe     =  2.11;    % Maximal fermentation rate (1.50; 3.00)
hH_NO3   =	0.80;    % Reduction factor for denitrification
b_H      =  0.28;    % Lysis rate constant	(0.20; 0.40)
hH_NO3_end   =  0.50;    % Anoxic reduction factor for endogenous respiration
KH_O2    =  0.20;    % Saturation/inhibition coefficient for oxygen
K_F      =	4.00;    % Saturation coefficient for growth on SF
K_fe     =  4.00;    % Saturation coefficient for fermentation on SF
KH_A     =  4.00;    % Saturation coefficient for acetate
KH_NO3   =	0.50;    % Saturation/inhibition coefficient for nitrate
KH_NH4   =	0.05;    % Saturation coefficient for SNH4 as nutrient
KH_PO4   =	0.01;    % Saturation coefficient for SPO4 as nutrient
KH_ALK   =	0.10;    % Saturation coefficient for alkalinity
q_PHA    =	2.46;    % Rate constant for storage of XPHA (2.00; 3.00)
q_PP     =	1.23;    % Rate constant for storage of XPP (1.00; 1.50)
Mu_PAO   =	0.82;    % Maximum growth rate of XPAO (0.67; 1.00)
hP_NO3   =	0.60;    % Reduction factor under anoxic conditions
b_PAO    =	0.14;    % Rate for lysis of XPAO (0.10; 0.20)
hP_NO3_end   =  0.33;    % Anoxic reduction factor for decay of PAOs
b_PP     =	0.14;    % Rate for lysis of XPP (0.10; 0.20)
hPP_NO3_end  =	0.33;    % Anoxic reduction factor for decay of PP
b_PHA    =	0.14;    % Rate for lysis of XPHA (0.10; 0.20)
hPHA_NO3_end =	0.33;    % Anoxic reduction factor for decay of PHA
KP_O2    =	0.20;    % Saturation coefficient for oxygen
KP_NO3   =	0.50;    % Saturation coefficient for nitrate
KP_A     =	4.00;    % Saturation coefficient for acetate
KP_NH4   =	0.05;    % Saturation coefficient for ammonium	
KP_P     =	0.20;    % Saturation coefficient for phosphate for XPP formation	
KP_PO4   =	0.01;    % Saturation coefficient for phosphate for growth
KP_ALK   =	0.10;    % Saturation coefficient for alkalinity
KP_PP    =	0.01;    % Saturation coefficient for polyphosphate
K_MAX    =	0.34;    % Maximum ratio of XPP/XPAO
KI_PP    =	0.02;    % Inhibition coefficient for polyphosphate storage
KP_PHA   =	0.01;    % Saturation coefficient for PHA	
Mu_A     =	0.61;    % Maximal growth rate of autotrophic biomass	(0.35; 1.00)
b_A      =	0.09;    % Decay rate if autotrophic biomass	(0.05; 0.15)
hA_NO3_end	 =  0.33;    % Anoxic reduction factor for decay of autotrophs
KA_O2    =	0.50;    % Saturation/inhibition coefficient for oxygen
KA_NH4   =	1.00;    % Saturation coefficient for SNH4
KA_ALK   =	0.50;    % Saturation coefficient for alkalinity
KA_PO4   =	0.01;    % Saturation coefficient for SPO4
KA_NO3	     =  0.50;    % Saturation constant for SNOX	
k_PRE    =	1.00;    % Rate constant for P precipitation
k_RED    =	0.60;    % Rate constant for redissolution
KPr_ALK  =	0.50;    % Saturation coefficient for alkalinity

PAR1 = [f_SI Y_H Y_PAO Y_PO4 Y_PHA Y_A f_XIH f_XIP f_XIA iN_SI iN_SF iN_XI iN_XS iN_BM iP_SI iP_SF iP_XI iP_XS iP_BM iSS_XI iSS_XS iSS_BM k_H hL_NO3 hL_fe KL_O2 KL_NO3 KL_X Mu_H q_fe hH_NO3 b_H hH_NO3_end KH_O2 K_F K_fe KH_A KH_NO3 KH_NH4 KH_PO4 KH_ALK q_PHA q_PP Mu_PAO hP_NO3 b_PAO hP_NO3_end b_PP hPP_NO3_end b_PHA hPHA_NO3_end KP_O2 KP_NO3 KP_A KP_NH4 KP_P KP_PO4 KP_ALK KP_PP K_MAX KI_PP KP_PHA Mu_A b_A hA_NO3_end KA_O2 KA_NH4 KA_ALK KA_PO4 KA_NO3 k_PRE k_RED KPr_ALK];
PAR2 = PAR1;
PAR3 = PAR1;
PAR4 = PAR1;
PAR5 = PAR1;
PAR6 = PAR1;
PAR7 = PAR1;

VOL1 = 1000;
VOL2 = 1000;
VOL3 = 1000;
VOL4 = VOL3;
VOL5 = 1333;
VOL6 = VOL5;
VOL7 = VOL5;

SOSAT1 = 8;
SOSAT2 = SOSAT1;
SOSAT3 = SOSAT1;
SOSAT4 = SOSAT1;
SOSAT5 = SOSAT1;
SOSAT6 = SOSAT1;
SOSAT7 = SOSAT1;

KLa1 = 0;
KLa2 = 0;
KLa3 = 0;
KLa4 = 0;
KLa5 = 240;
KLa6 = 240;
KLa7 = 240;

carb1 = 0; % external carbon flow rate to reactor 1
carb2 = 0; % external carbon flow rate to reactor 2
carb3 = 0; % external carbon flow rate to reactor 3
carb4 = 0; % external carbon flow rate to reactor 4
carb5 = 0; % external carbon flow rate to reactor 5
carb6 = 0; % external carbon flow rate to reactor 1
carb7 = 0; % external carbon flow rate to reactor 2

CARBONSOURCECONC = 400000; % external carbon source concentration = 400000 mg COD/l

metal1 = 0; % external metal flow rate to reactor 1
metal2 = 0; % external metal flow rate to reactor 2
metal3 = 0; % external metal flow rate to reactor 3
metal4 = 0; % external metal flow rate to reactor 4
metal5 = 0; % external metal flow rate to reactor 5
metal6 = 0; % external metal flow rate to reactor 1
metal7 = 0; % external metal flow rate to reactor 2

METALSOURCECONC = 1000000; % external metal source concentration = 1000000 mg MeOH/l

T = 0.0001;
