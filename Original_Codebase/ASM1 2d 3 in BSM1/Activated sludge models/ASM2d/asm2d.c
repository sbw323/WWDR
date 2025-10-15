/*
 * asm2d.c is a C-file S-function for IWA Activated Sludge Model No 2d.  
 * The asm2d.c file was created based on the asm1.c file of Ulf Jeppsson, and the asm3.c file
 * Compatibility: ASM2d2 model
 * (40.0/14.0) is used in this model instead of 2.86 (denitrification stoichiometry)
 * (64.0/14.0) is used in this model instead of 4.57 (nitrification stoichiometry)
 *
 * 20 February 2004
 * Krist V. Gernaey, CAPEC, Dept. of Chemical Engineering, DTU, Denmark
 *
 * This file has been modified by Xavier Flores-Alsina
 * July, 2010
 * IEA, Lund University, Lund, Sweden
 *
 *
 */

#define S_FUNCTION_NAME asm2d

#include "simstruc.h"
#include <math.h>

#define XINIT   ssGetArg(S,0)
#define PAR	    ssGetArg(S,1)
#define V	    ssGetArg(S,2)
#define SOSAT   ssGetArg(S,3)
#define DECAY   ssGetArg(S,4)
#define TEMPMODEL  ssGetArg(S,5)
#define ACTIVATE  ssGetArg(S,6)


/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 26);  /* 19, number of continuous states        */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states              */
    ssSetNumInputs(        S, 27);  /* number of inputs,                      */
    ssSetNumOutputs(       S, 26);  /* number of outputs, 19 components + flow rate */
    ssSetDirectFeedThrough(S, 1);   /* direct feedthrough flag                */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                 */
    ssSetNumSFcnParams(    S, 7);   /* number of input arguments              */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements    */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements */
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements */
}

/*
 * mdlInitializeSampleTimes - initialize the sample times array
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


/*
 * mdlInitializeConditions - initialize the states
 */
static void mdlInitializeConditions(double *x0, SimStruct *S)
{
int i;

for (i = 0; i < 26; i++) {
   x0[i] = mxGetPr(XINIT)[i];
}
}

/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{
   
    double tempmodel, activate;
    int i;
    
    tempmodel = mxGetPr(TEMPMODEL)[0];
    activate = mxGetPr(ACTIVATE)[0];
    
  for (i = 0; i < 19; i++) {
      y[i] = x[i];
  }

  y[19]= u[19];  /* x[19], flow rate */
  
  if (tempmodel < 0.5)                            /* Temp */ 
     y[20] = u[20];                                  
  else 
     y[20] = x[20]; 
 
  /* dummy states, only give outputs if ACTIVATE = 1 */
  if (activate > 0.5) {
      y[21] = x[21];
      y[22] = x[22];
      y[23] = x[23];
      y[24] = x[24];
      y[25] = x[25];
      }
  else if (activate < 0.5) {
      y[21] = tempmodel;
      y[22] = 0.0;
      y[23] = 0.0;
      y[24] = 0.0;
      y[25] = 0.0;
      }


}

/*
 * mdlUpdate - perform action at major integration time step
 */

static void mdlUpdate(double *x, double *u, SimStruct *S, int tid)
{
}

/*
 * mdlDerivatives - compute the derivatives
 */
static void mdlDerivatives(double *dx, double *x, double *u, SimStruct *S, int tid)
{

double f_SI, Y_H, Y_PAO, Y_PO4, Y_PHA, Y_A, f_XIH, f_XIP, f_XIA, iN_SI, iN_SF, iN_XI;
double iN_XS, iN_BM, iP_SI, iP_SF, iP_XI, iP_XS, iP_BM, iSS_XI, iSS_XS, iSS_BM;
double k_H, hL_NO3, hL_fe, KL_O2, KL_NO3, KL_X;
double Mu_H, q_fe, hH_NO3, b_H, hH_NO3_end, KH_O2, K_F, K_fe, KH_A, KH_NO3, KH_NH4, KH_PO4, KH_ALK;
double q_PHA, q_PP, Mu_PAO, hP_NO3, b_PAO, hP_NO3_end, b_PP, hPP_NO3_end, b_PHA, hPHA_NO3_end, KP_O2, KP_NO3, KP_A;
double KP_NH4, KP_P, KP_PO4, KP_ALK, KP_PP, K_MAX, KI_PP, KP_PHA;
double Mu_A, b_A, hA_NO3_end, KA_O2, KA_NH4, KA_ALK, KA_PO4, KA_NO3, k_PRE, k_RED, KPr_ALK;
double proc1, proc2, proc3, proc4, proc5, proc6, proc7, proc8, proc9, proc10, proc11;
double proc12, proc13, proc14, proc15, proc16, proc17, proc18, proc19, proc20, proc21;
double reac1, reac2, reac3, reac4, reac5, reac6, reac7, reac8, reac9, reac9_1, reac9_2, reac9_3;
double reac10, reac11, reac12, reac13, reac14, reac15, reac16, reac17, reac18, reac19;
double reac20, reac21, reac22, reac23, reac24;
double vol, SO_sat;  /* T */
double xtemp[26];
double decay_switch;
double tempmodel, activate;
double SO_sat_temp, KLa_temp;


int i;

/* Stoichiometric parameters */

f_SI         = mxGetPr(PAR)[0];
Y_H          = mxGetPr(PAR)[1];
Y_PAO        = mxGetPr(PAR)[2];
Y_PO4        = mxGetPr(PAR)[3];
Y_PHA        = mxGetPr(PAR)[4];
Y_A          = mxGetPr(PAR)[5];
f_XIH        = mxGetPr(PAR)[6];
f_XIP        = mxGetPr(PAR)[7];
f_XIA        = mxGetPr(PAR)[8];
iN_SI        = mxGetPr(PAR)[9];
iN_SF        = mxGetPr(PAR)[10];
iN_XI        = mxGetPr(PAR)[11];
iN_XS        = mxGetPr(PAR)[12];
iN_BM        = mxGetPr(PAR)[13];
iP_SI        = mxGetPr(PAR)[14];
iP_SF        = mxGetPr(PAR)[15];
iP_XI        = mxGetPr(PAR)[16];
iP_XS        = mxGetPr(PAR)[17];
iP_BM        = mxGetPr(PAR)[18];
iSS_XI       = mxGetPr(PAR)[19];
iSS_XS       = mxGetPr(PAR)[20];
iSS_BM       = mxGetPr(PAR)[21];

/* Hydrolysis of particulate substrate, X_S */

k_H          = mxGetPr(PAR)[22];
hL_NO3       = mxGetPr(PAR)[23];
hL_fe        = mxGetPr(PAR)[24];
KL_O2        = mxGetPr(PAR)[25];
KL_NO3       = mxGetPr(PAR)[26];
KL_X         = mxGetPr(PAR)[27];

/* Heterotrophic organisms, X_H */

Mu_H         = mxGetPr(PAR)[28];
q_fe         = mxGetPr(PAR)[29];
hH_NO3       = mxGetPr(PAR)[30];
b_H          = mxGetPr(PAR)[31];
hH_NO3_end   = mxGetPr(PAR)[32];
KH_O2        = mxGetPr(PAR)[33];
K_F          = mxGetPr(PAR)[34];
K_fe         = mxGetPr(PAR)[35];
KH_A         = mxGetPr(PAR)[36];
KH_NO3       = mxGetPr(PAR)[37];
KH_NH4       = mxGetPr(PAR)[38];
KH_PO4       = mxGetPr(PAR)[39];
KH_ALK       = mxGetPr(PAR)[40];

/* Phosphorus accumulating organisms, X_PAO */

q_PHA        = mxGetPr(PAR)[41];
q_PP         = mxGetPr(PAR)[42];
Mu_PAO       = mxGetPr(PAR)[43];
hP_NO3       = mxGetPr(PAR)[44];
b_PAO        = mxGetPr(PAR)[45];
hP_NO3_end   = mxGetPr(PAR)[46];
b_PP         = mxGetPr(PAR)[47];
hPP_NO3_end  = mxGetPr(PAR)[48];
b_PHA        = mxGetPr(PAR)[49];
hPHA_NO3_end = mxGetPr(PAR)[50];
KP_O2        = mxGetPr(PAR)[51];
KP_NO3       = mxGetPr(PAR)[52];
KP_A         = mxGetPr(PAR)[53];
KP_NH4       = mxGetPr(PAR)[54];
KP_P         = mxGetPr(PAR)[55];
KP_PO4       = mxGetPr(PAR)[56];
KP_ALK       = mxGetPr(PAR)[57];
KP_PP        = mxGetPr(PAR)[58];
K_MAX        = mxGetPr(PAR)[59];
KI_PP        = mxGetPr(PAR)[60];
KP_PHA       = mxGetPr(PAR)[61];

/* Autotrophic organisms X_A, nitrifying activity */

Mu_A         = mxGetPr(PAR)[62];
b_A          = mxGetPr(PAR)[63];
hA_NO3_end   = mxGetPr(PAR)[64];
KA_O2        = mxGetPr(PAR)[65];
KA_NH4       = mxGetPr(PAR)[66];
KA_ALK       = mxGetPr(PAR)[67];
KA_PO4       = mxGetPr(PAR)[68];
KA_NO3       = mxGetPr(PAR)[69];

/* Precipitation */

k_PRE        = mxGetPr(PAR)[70];
k_RED        = mxGetPr(PAR)[71];
KPr_ALK      = mxGetPr(PAR)[72];

/* Reactor specific parameters */

vol      = mxGetPr(V)[0];
SO_sat   = mxGetPr(SOSAT)[0];

/* switching function */

decay_switch = mxGetPr(DECAY)[0];
tempmodel = mxGetPr(TEMPMODEL)[0];
activate = mxGetPr(ACTIVATE)[0];


/* temperature compensation */
if (tempmodel < 0.5) {    
   /* Compensation from the temperature at the influent of the reactor */
      k_H =   k_H*exp((log(k_H/2.0)/5.0)*(u[20]-15.0)); /* Compensation from the temperature at the influent of the reactor */ 
      Mu_H =  Mu_H*exp((log(Mu_H/3.0)/5.0)*(u[20]-15.0));
      q_fe =  q_fe*exp((log(q_fe/1.5)/5.0)*(u[20]-15.0));
      b_H =   b_H*exp((log(b_H/0.2)/5.0)*(u[20]-15.0));
      q_PHA = q_PHA*exp((log(q_PHA/2.0)/5.0)*(u[20]-15.0));
      q_PP =  q_PP*exp((log(q_PP/1.00)/5.0)*(u[20]-15.0));
      Mu_PAO =Mu_PAO*exp((log(Mu_PAO/0.67)/5.0)*(u[20]-15.0));
      b_PAO = b_PAO*exp((log(b_PAO/0.1)/5.0)*(u[20]-15.0));
      b_PP =  b_PP*exp((log(b_PP/0.1)/5.0)*(u[20]-15.0));
      b_PHA = b_PHA*exp((log(b_PHA/0.1)/5.0)*(u[20]-15.0));
      Mu_A =  Mu_A*exp((log(Mu_A/0.35)/5.0)*(u[20]-15.0));
      b_A =   b_A*exp((log(b_A/0.05)/5.0)*(u[20]-15.0));
    
      SO_sat_temp = 0.9997743214*8.0/10.5*(56.12*6791.5*exp(-66.7354 + 87.4755/((u[20]+273.15)/100.0) + 24.4526*log((u[20]+273.15)/100.0))); /* van't Hoff equation */
      KLa_temp = u[26]*pow(1.024, (u[20]-15.0));
}
else {
   /* Compensation from the current temperature in the reactor */
      k_H =   k_H*exp((log(k_H/2.0)/5.0)*(x[20]-15.0)); /* Compensation from the temperature at the influent of the reactor */ 
      Mu_H =  Mu_H*exp((log(Mu_H/3.0)/5.0)*(x[20]-15.0));
      q_fe =  q_fe*exp((log(q_fe/1.5)/5.0)*(x[20]-15.0));
      b_H =   b_H*exp((log(b_H/0.2)/5.0)*(x[20]-15.0));
      q_PHA = q_PHA*exp((log(q_PHA/2.0)/5.0)*(x[20]-15.0));
      q_PP =  q_PP*exp((log(q_PP/1.00)/5.0)*(x[20]-15.0));
      Mu_PAO =Mu_PAO*exp((log(Mu_PAO/0.67)/5.0)*(x[20]-15.0));
      b_PAO = b_PAO*exp((log(b_PAO/0.1)/5.0)*(x[20]-15.0));
      b_PP =  b_PP*exp((log(b_PP/0.1)/5.0)*(x[20]-15.0));
      b_PHA = b_PHA*exp((log(b_PHA/0.1)/5.0)*(x[20]-15.0));
      Mu_A =  Mu_A*exp((log(Mu_A/0.35)/5.0)*(x[20]-15.0));
      b_A =   b_A*exp((log(b_A/0.05)/5.0)*(x[20]-15.0));
      
     SO_sat_temp = 0.9997743214*8.0/10.5*(56.12*6791.5*exp(-66.7354 + 87.4755/((x[20]+273.15)/100.0) + 24.4526*log((x[20]+273.15)/100.0))); /* van't Hoff equation */
     KLa_temp = u[26]*pow(1.024, (x[20]-15.0));
} 




for (i = 0; i < 26; i++) {
   if (x[i] < 0.0)
     xtemp[i] = 0.0;
   else
     xtemp[i] = x[i];
}

if (u[26] < 0.0)
      x[0] = fabs(u[26]);		/*u[26] is the KLa value */


if (decay_switch > 0.5) {
proc1  = k_H*xtemp[0]/(KL_O2+xtemp[0])*((xtemp[10]/xtemp[11])/(KL_X+xtemp[10]/xtemp[11]))*xtemp[11];
proc2  = k_H*hL_NO3*KL_O2/(KL_O2+xtemp[0])*xtemp[6]/(KL_NO3+xtemp[6])*((xtemp[10]/xtemp[11])/(KL_X+xtemp[10]/xtemp[11]))*xtemp[11];
proc3  = k_H*hL_fe*KL_O2/(KL_O2+xtemp[0])*KL_NO3/(KL_NO3+xtemp[6])*((xtemp[10]/xtemp[11])/(KL_X+xtemp[10]/xtemp[11]))*xtemp[11];
proc4  = Mu_H*xtemp[0]/(KH_O2+xtemp[0])*xtemp[1]/(K_F+xtemp[1])*xtemp[1]/(xtemp[2]+xtemp[1])*xtemp[4]/(KH_NH4+xtemp[4])*xtemp[7]/(KH_PO4+xtemp[7])*xtemp[8]/(KH_ALK+xtemp[8])*xtemp[11];
proc5  = Mu_H*xtemp[0]/(KH_O2+xtemp[0])*xtemp[2]/(KH_A+xtemp[2])*xtemp[2]/(xtemp[2]+xtemp[1])*xtemp[4]/(KH_NH4+xtemp[4])*xtemp[7]/(KH_PO4+xtemp[7])*xtemp[8]/(KH_ALK+xtemp[8])*xtemp[11];
proc6  = Mu_H*hH_NO3*KH_O2/(KH_O2+xtemp[0])*xtemp[1]/(K_F+xtemp[1])*xtemp[1]/(xtemp[2]+xtemp[1])*xtemp[6]/(KH_NO3+xtemp[6])*xtemp[4]/(KH_NH4+xtemp[4])*xtemp[7]/(KH_PO4+xtemp[7])*xtemp[8]/(KH_ALK+xtemp[8])*xtemp[11];
proc7  = Mu_H*hH_NO3*KH_O2/(KH_O2+xtemp[0])*xtemp[2]/(KH_A+xtemp[2])*xtemp[2]/(xtemp[2]+xtemp[1])*xtemp[6]/(KH_NO3+xtemp[6])*xtemp[4]/(KH_NH4+xtemp[4])*xtemp[7]/(KH_PO4+xtemp[7])*xtemp[8]/(KH_ALK+xtemp[8])*xtemp[11];
proc8  = q_fe*KH_O2/(KH_O2+xtemp[0])*KH_NO3/(KH_NO3+xtemp[6])*xtemp[1]/(K_fe+xtemp[1])*xtemp[8]/(KH_ALK+xtemp[8])*xtemp[11];
proc9  = b_H*(xtemp[0]/(KH_O2+xtemp[0])+hH_NO3_end*KH_O2/(KH_O2+xtemp[0])*xtemp[6]/(KH_NO3+xtemp[6]))*xtemp[11];
proc10 = q_PHA*xtemp[2]/(KP_A+xtemp[2])*xtemp[8]/(KP_ALK+xtemp[8])*((xtemp[13]/xtemp[12])/(KP_PP+xtemp[13]/xtemp[12]))*xtemp[12];
proc11 = q_PP*xtemp[0]/(KP_O2+xtemp[0])*xtemp[7]/(KP_P+xtemp[7])*xtemp[8]/(KP_ALK+xtemp[8])*((xtemp[14]/xtemp[12])/(KP_PHA+xtemp[14]/xtemp[12]))*((K_MAX-xtemp[13]/xtemp[12])/(KI_PP+K_MAX-xtemp[13]/xtemp[12]))*xtemp[12];
proc12 = q_PP*hP_NO3*KP_O2/(KP_O2+xtemp[0])*xtemp[6]/(KP_NO3+xtemp[6])*xtemp[7]/(KP_P+xtemp[7])*xtemp[8]/(KP_ALK+xtemp[8])*((xtemp[14]/xtemp[12])/(KP_PHA+xtemp[14]/xtemp[12]))*((K_MAX-xtemp[13]/xtemp[12])/(KI_PP+K_MAX-xtemp[13]/xtemp[12]))*xtemp[12];
proc13 = Mu_PAO*xtemp[0]/(KP_O2+xtemp[0])*xtemp[4]/(KP_NH4+xtemp[4])*xtemp[7]/(KP_PO4+xtemp[7])*xtemp[8]/(KP_ALK+xtemp[8])*((xtemp[14]/xtemp[12])/(KP_PHA+xtemp[14]/xtemp[12]))*xtemp[12];
proc14 = Mu_PAO*hP_NO3*KP_O2/(KP_O2+xtemp[0])*xtemp[6]/(KP_NO3+xtemp[6])*xtemp[4]/(KP_NH4+xtemp[4])*xtemp[7]/(KP_PO4+xtemp[7])*xtemp[8]/(KP_ALK+xtemp[8])*((xtemp[14]/xtemp[12])/(KP_PHA+xtemp[14]/xtemp[12]))*xtemp[12];
proc15 = b_PAO*xtemp[8]/(KP_ALK+xtemp[8])*(xtemp[0]/(KP_O2+xtemp[0])+hP_NO3_end*KP_O2/(KP_O2+xtemp[0])*xtemp[6]/(KP_NO3+xtemp[6]))*xtemp[12];
proc16 = b_PP*xtemp[8]/(KP_ALK+xtemp[8])*(xtemp[0]/(KP_O2+xtemp[0])+hPP_NO3_end*KP_O2/(KP_O2+xtemp[0])*xtemp[6]/(KP_NO3+xtemp[6]))*xtemp[13];
proc17 = b_PHA*xtemp[8]/(KP_ALK+xtemp[8])*(xtemp[0]/(KP_O2+xtemp[0])+hPHA_NO3_end*KP_O2/(KP_O2+xtemp[0])*xtemp[6]/(KP_NO3+xtemp[6]))*xtemp[14];
proc18 = Mu_A*xtemp[0]/(KA_O2+xtemp[0])*xtemp[4]/(KA_NH4+xtemp[4])*xtemp[7]/(KA_PO4+xtemp[7])*xtemp[8]/(KA_ALK+xtemp[8])*xtemp[15];
proc19 = b_A*(xtemp[0]/(KA_O2+xtemp[0])+hA_NO3_end*KA_O2/(KA_O2+xtemp[0])*xtemp[6]/(KA_NO3+xtemp[6]))*xtemp[15];
proc20 = k_PRE*xtemp[7]*xtemp[17];
proc21 = k_RED*xtemp[18]*xtemp[8]/(KPr_ALK+xtemp[8]);

}

else if (decay_switch  < 0.5) {
proc1  = k_H*xtemp[0]/(KL_O2+xtemp[0])*((xtemp[10]/xtemp[11])/(KL_X+xtemp[10]/xtemp[11]))*xtemp[11];
proc2  = k_H*hL_NO3*KL_O2/(KL_O2+xtemp[0])*xtemp[6]/(KL_NO3+xtemp[6])*((xtemp[10]/xtemp[11])/(KL_X+xtemp[10]/xtemp[11]))*xtemp[11];
proc3  = k_H*hL_fe*KL_O2/(KL_O2+xtemp[0])*KL_NO3/(KL_NO3+xtemp[6])*((xtemp[10]/xtemp[11])/(KL_X+xtemp[10]/xtemp[11]))*xtemp[11];
proc4  = Mu_H*xtemp[0]/(KH_O2+xtemp[0])*xtemp[1]/(K_F+xtemp[1])*xtemp[1]/(xtemp[2]+xtemp[1])*xtemp[4]/(KH_NH4+xtemp[4])*xtemp[7]/(KH_PO4+xtemp[7])*xtemp[8]/(KH_ALK+xtemp[8])*xtemp[11];
proc5  = Mu_H*xtemp[0]/(KH_O2+xtemp[0])*xtemp[2]/(KH_A+xtemp[2])*xtemp[2]/(xtemp[2]+xtemp[1])*xtemp[4]/(KH_NH4+xtemp[4])*xtemp[7]/(KH_PO4+xtemp[7])*xtemp[8]/(KH_ALK+xtemp[8])*xtemp[11];
proc6  = Mu_H*hH_NO3*KH_O2/(KH_O2+xtemp[0])*xtemp[1]/(K_F+xtemp[1])*xtemp[1]/(xtemp[2]+xtemp[1])*xtemp[6]/(KH_NO3+xtemp[6])*xtemp[4]/(KH_NH4+xtemp[4])*xtemp[7]/(KH_PO4+xtemp[7])*xtemp[8]/(KH_ALK+xtemp[8])*xtemp[11];
proc7  = Mu_H*hH_NO3*KH_O2/(KH_O2+xtemp[0])*xtemp[2]/(KH_A+xtemp[2])*xtemp[2]/(xtemp[2]+xtemp[1])*xtemp[6]/(KH_NO3+xtemp[6])*xtemp[4]/(KH_NH4+xtemp[4])*xtemp[7]/(KH_PO4+xtemp[7])*xtemp[8]/(KH_ALK+xtemp[8])*xtemp[11];
proc8  = q_fe*KH_O2/(KH_O2+xtemp[0])*KH_NO3/(KH_NO3+xtemp[6])*xtemp[1]/(K_fe+xtemp[1])*xtemp[8]/(KH_ALK+xtemp[8])*xtemp[11];
proc9  = b_H*xtemp[11];
proc10 = q_PHA*xtemp[2]/(KP_A+xtemp[2])*xtemp[8]/(KP_ALK+xtemp[8])*((xtemp[13]/xtemp[12])/(KP_PP+xtemp[13]/xtemp[12]))*xtemp[12];
proc11 = q_PP*xtemp[0]/(KP_O2+xtemp[0])*xtemp[7]/(KP_P+xtemp[7])*xtemp[8]/(KP_ALK+xtemp[8])*((xtemp[14]/xtemp[12])/(KP_PHA+xtemp[14]/xtemp[12]))*((K_MAX-xtemp[13]/xtemp[12])/(KI_PP+K_MAX-xtemp[13]/xtemp[12]))*xtemp[12];
proc12 = q_PP*hP_NO3*KP_O2/(KP_O2+xtemp[0])*xtemp[6]/(KP_NO3+xtemp[6])*xtemp[7]/(KP_P+xtemp[7])*xtemp[8]/(KP_ALK+xtemp[8])*((xtemp[14]/xtemp[12])/(KP_PHA+xtemp[14]/xtemp[12]))*((K_MAX-xtemp[13]/xtemp[12])/(KI_PP+K_MAX-xtemp[13]/xtemp[12]))*xtemp[12];
proc13 = Mu_PAO*xtemp[0]/(KP_O2+xtemp[0])*xtemp[4]/(KP_NH4+xtemp[4])*xtemp[7]/(KP_PO4+xtemp[7])*xtemp[8]/(KP_ALK+xtemp[8])*((xtemp[14]/xtemp[12])/(KP_PHA+xtemp[14]/xtemp[12]))*xtemp[12];
proc14 = Mu_PAO*hP_NO3*KP_O2/(KP_O2+xtemp[0])*xtemp[6]/(KP_NO3+xtemp[6])*xtemp[4]/(KP_NH4+xtemp[4])*xtemp[7]/(KP_PO4+xtemp[7])*xtemp[8]/(KP_ALK+xtemp[8])*((xtemp[14]/xtemp[12])/(KP_PHA+xtemp[14]/xtemp[12]))*xtemp[12];
proc15 = b_PAO*xtemp[12]*xtemp[8]/(KP_ALK+xtemp[8]);
proc16 = b_PP*xtemp[13]*xtemp[8]/(KP_ALK+xtemp[8]);
proc17 = b_PHA*xtemp[14]*xtemp[8]/(KP_ALK+xtemp[8]);
proc18 = Mu_A*xtemp[0]/(KA_O2+xtemp[0])*xtemp[4]/(KA_NH4+xtemp[4])*xtemp[7]/(KA_PO4+xtemp[7])*xtemp[8]/(KA_ALK+xtemp[8])*xtemp[15];
proc19 = b_A*xtemp[15];
proc20 = k_PRE*xtemp[7]*xtemp[17];
proc21 = k_RED*xtemp[18]*xtemp[8]/(KPr_ALK+xtemp[8]);


}


reac1   = (-(1.0-Y_H)/Y_H)*(proc4+proc5)-Y_PHA*proc11+(-(1.0-Y_PAO)/Y_PAO)*proc13+(-((64.0/14.0)-Y_A)/Y_A)*proc18;
reac2   = (1.0-f_SI)*(proc1+proc2+proc3)+(-1.0/Y_H)*(proc4+proc6)-proc8;
reac3   = (-1.0/Y_H)*(proc5+proc7)+proc8-proc10+proc17;
reac4   = f_SI*(proc1+proc2+proc3);
reac5   = (iN_XS-iN_SI*f_SI-iN_SF*(1.0-f_SI))*(proc1+proc2+proc3)+(iN_SF/Y_H-iN_BM)*(proc4+proc6)-iN_BM*(proc5+proc7+proc13+proc14)+iN_SF*proc8+(iN_BM-iN_XI*f_XIH-iN_XS*(1.0-f_XIH))*proc9+(iN_BM-iN_XI*f_XIP-iN_XS*(1.0-f_XIP))*proc15+(-iN_BM-1.0/Y_A)*proc18+(iN_BM-iN_XI*f_XIA-iN_XS*(1.0-f_XIA))*proc19;
reac6   = ((1.0-Y_H)/((40.0/14.0)*Y_H))*(proc6+proc7)+(Y_PHA/(40.0/14.0))*proc12+((1.0-Y_PAO)/((40.0/14.0)*Y_PAO))*proc14;
reac7   = (-(1.0-Y_H)/((40.0/14.0)*Y_H))*(proc6+proc7)+(-Y_PHA/(40.0/14.0))*proc12+(-(1.0-Y_PAO)/((40.0/14.0)*Y_PAO))*proc14+(1.0/Y_A)*proc18;
reac8   = (iP_XS-iP_SI*f_SI-iP_SF*(1.0-f_SI))*(proc1+proc2+proc3)+(iP_SF/Y_H-iP_BM)*(proc4+proc6)-iP_BM*(proc5+proc7+proc13+proc14+proc18)+iP_SF*proc8+(iP_BM-iP_XI*f_XIH-iP_XS*(1.0-f_XIH))*proc9+Y_PO4*proc10-proc11-proc12+(iP_BM-iP_XI*f_XIP-iP_XS*(1.0-f_XIP))*proc15+proc16+(iP_BM-iP_XI*f_XIA-iP_XS*(1.0-f_XIA))*proc19-proc20+proc21;
reac9_1 = ((iN_XS-iN_SI*f_SI-iN_SF*(1.0-f_SI))/14.0-(iP_XS-iP_SI*f_SI-iP_SF*(1.0-f_SI))*(1.5/31.0))*(proc1+proc2+proc3)+((iN_SF/Y_H-iN_BM)/14.0-(iP_SF/Y_H-iP_BM)*(1.5/31.0))*(proc4+proc6)+(-iN_BM/14.0-(-iP_BM)*(1.5/31.0)+1.0/(64.0*Y_H))*(proc5+proc7)+((1.0-Y_H)/(14.0*(40.0/14.0)*Y_H))*(proc6+proc7)+(iN_SF/14.0-iP_SF*(1.5/31.0)-1.0/64.0)*proc8;
reac9_2 = ((iN_BM-iN_XI*f_XIH-iN_XS*(1.0-f_XIH))/14.0-(iP_BM-iP_XI*f_XIH-iP_XS*(1.0-f_XIH))*(1.5/31.0))*proc9+(-Y_PO4*((1.5-1.0)/31.0)+1.0/64.0)*proc10+((1.5-1.0)/31.0)*proc11+((1.5-1.0)/31.0+Y_PHA/(14.0*(40.0/14.0)))*proc12+(-iN_BM/14.0-(-iP_BM)*(1.5/31.0))*proc13+(-iN_BM/14.0-(-iP_BM)*(1.5/31.0)+(1.0-Y_PAO)/(14.0*(40.0/14.0)*Y_PAO))*proc14;
reac9_3 = ((iN_BM-iN_XI*f_XIP-iN_XS*(1.0-f_XIP))/14.0-(iP_BM-iP_XI*f_XIP-iP_XS*(1.0-f_XIP))*(1.5/31.0))*proc15+((1.0-1.5)/31.0)*proc16+(-1.0/64.0)*proc17+((-iN_BM-1.0/Y_A)/14.0-(-iP_BM)*(1.5/31.0)-1.0/(14.0*Y_A))*proc18+((iN_BM-iN_XI*f_XIA-iN_XS*(1.0-f_XIA))/14.0-(iP_BM-iP_XI*f_XIA-iP_XS*(1.0-f_XIA))*(1.5/31.0))*proc19+(1.5/31.0)*(proc20-proc21);
reac9   = reac9_1+reac9_2+reac9_3;
reac10  = f_XIH*proc9+f_XIP*proc15+f_XIA*proc19;
reac11  = -proc1-proc2-proc3+(1.0-f_XIH)*proc9+(1.0-f_XIP)*proc15+(1.0-f_XIA)*proc19;
reac12  = proc4+proc5+proc6+proc7-proc9;
reac13  = proc13+proc14-proc15;
reac14  = -Y_PO4*proc10+proc11+proc12-proc16;
reac15  = proc10+(-Y_PHA)*(proc11+proc12)+(-1.0/Y_PAO)*(proc13+proc14)-proc17;
reac16  = proc18-proc19;
reac17  = -iSS_XS*(proc1+proc2+proc3)+iSS_BM*(proc4+proc5+proc6+proc7+proc18)+(iSS_XI*f_XIH+iSS_XS*(1.0-f_XIH)-iSS_BM)*proc9+(-3.23*Y_PO4+0.6)*proc10+(3.23-0.6*Y_PHA)*(proc11+proc12)+(iSS_BM-0.6/Y_PAO)*(proc13+proc14)+(iSS_XI*f_XIP+iSS_XS*(1.0-f_XIP)-iSS_BM)*proc15-3.23*proc16-0.6*proc17+(iSS_XI*f_XIA+iSS_XS*(1.0-f_XIA)-iSS_BM)*proc19+1.42*(proc20-proc21);
reac18  = -3.45*proc20+3.45*proc21;
reac19  = 4.87*proc20-4.87*proc21;




reac20 = 0.0;
reac21 = 0.0;
reac22 = 0.0;
reac23 = 0.0;
reac24 = 0.0;


if (u[26] < 0.0)
      dx[0] = 0.0;
   else
      dx[0] = 1.0/vol*(u[19]*(u[0]-x[0]))+reac1+KLa_temp*(SO_sat_temp-x[0]);
dx[1] = 1.0/vol*(u[19]*(u[1]-x[1]))+reac2;
dx[2] = 1.0/vol*(u[19]*(u[2]-x[2]))+reac3;
dx[3] = 1.0/vol*(u[19]*(u[3]-x[3]))+reac4;
dx[4] = 1.0/vol*(u[19]*(u[4]-x[4]))+reac5;
dx[5] = 1.0/vol*(u[19]*(u[5]-x[5]))+reac6;
dx[6] = 1.0/vol*(u[19]*(u[6]-x[6]))+reac7;
dx[7] = 1.0/vol*(u[19]*(u[7]-x[7]))+reac8;
dx[8] = 1.0/vol*(u[19]*(u[8]-x[8]))+reac9;
dx[9] = 1.0/vol*(u[19]*(u[9]-x[9]))+reac10;
dx[10] = 1.0/vol*(u[19]*(u[10]-x[10]))+reac11;
dx[11] = 1.0/vol*(u[19]*(u[11]-x[11]))+reac12;
dx[12] = 1.0/vol*(u[19]*(u[12]-x[12]))+reac13;
dx[13] = 1.0/vol*(u[19]*(u[13]-x[13]))+reac14;
dx[14] = 1.0/vol*(u[19]*(u[14]-x[14]))+reac15;
dx[15] = 1.0/vol*(u[19]*(u[15]-x[15]))+reac16;
dx[16] = 1.0/vol*(u[19]*(u[16]-x[16]))+reac17;
dx[17] = 1.0/vol*(u[19]*(u[17]-x[17]))+reac18;
dx[18] = 1.0/vol*(u[19]*(u[18]-x[18]))+reac19;

dx[19] = 0.0; 

if (tempmodel < 0.5)                
    dx[20] = 0.0;                                 
else 
    dx[20] = 1.0/vol*(u[19]*(u[20]-x[20]));  

dx[21] = 1.0/vol*(u[19]*(u[21]-x[21]))+reac20;
dx[22] = 1.0/vol*(u[19]*(u[22]-x[22]))+reac21;
dx[23] = 1.0/vol*(u[19]*(u[23]-x[23]))+reac22;
dx[24] = 1.0/vol*(u[19]*(u[24]-x[24]))+reac23;
dx[25] = 1.0/vol*(u[19]*(u[25]-x[25]))+reac24;

}


/*
 * mdlTerminate - called when the simulation is terminated.
 */
static void mdlTerminate(SimStruct *S)
{
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
