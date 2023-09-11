/*
 * sewer_asm1 model block 
 * Copyright: Xavier Flores-Alsina, Ulf Jeppsson, IEA, Lund University, Lund, Sweden
 *            Krist V Gernaey, DTU. Denmark
 */

#define S_FUNCTION_NAME sewer_asm1

#include "simstruc.h"
#include <math.h>

#define ASM1_SEWERINIT ssGetArg(S,0)
#define ASM1_PARS ssGetArg(S,1)
#define SPAR ssGetArg(S,2)


/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 19);  /* number of continuous states           (x[0-18] = ASM1 state variables +3 S dummy states + 2 X dummy states + h */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states */            
    ssSetNumInputs(        S, 22);  /* number of inputs (corresponding to outputs) (u[0-20] = ASM1 state variables + TSS +  Q +  T + 3 S dummy states + 2 X dummy states + h */
    ssSetNumOutputs(       S, 22);  /* number of outputs                           (y[0-20] = ASM1 state variables + TSS +  Q +  T + 3 S dummy states + 2 X dummy states + h */  
    ssSetDirectFeedThrough(S, 1);   /* direct feedthrough flag               */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumSFcnParams(    S, 3);   /* number of input arguments             */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
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

for (i = 0; i < 19; i++) {
   x0[i] = mxGetPr(ASM1_SEWERINIT)[i];
}
}

/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{
  double X_I2TSS, X_S2TSS, X_BH2TSS, X_BA2TSS, X_P2TSS, A, C, Hmin, vol;
  int i;

  X_I2TSS = mxGetPr(ASM1_PARS)[19];
  X_S2TSS = mxGetPr(ASM1_PARS)[20];
  X_BH2TSS = mxGetPr(ASM1_PARS)[21];
  X_BA2TSS = mxGetPr(ASM1_PARS)[22];
  X_P2TSS = mxGetPr(ASM1_PARS)[23];
  A = mxGetPr(SPAR)[0];
  C = mxGetPr(SPAR)[1];
  Hmin = mxGetPr(SPAR)[2];
  
  if (x[18] < Hmin)
    x[18] = Hmin;
  
  vol = A*x[18];

  for (i = 0; i < 13; i++) {
      y[i] = x[i]/vol;               /* ASM1-states: SI, SS, XI, XS, XBH, XBA, XP, SO, SNO, SNH, SND, XND, SALK */
  }

  y[13] = (X_I2TSS*x[2]+X_S2TSS*x[3]+X_BH2TSS*x[4]+X_BA2TSS*x[5]+X_P2TSS*x[6])/vol;   
                                     /* TSS */
  y[14] = C*pow((x[18] - Hmin),1.5); /* Q_out */
  y[15] = u[15];                     /* T */
  y[16] = x[13]/vol;                 /* Dummy state 1 */  
  y[17] = x[14]/vol;                 /* Dummy state 2 */
  y[18] = x[15]/vol;                 /* Dummy state 3 */
  y[19] = x[16]/vol;                 /* Dummy state 4 */
  y[20] = x[17]/vol;                 /* Dummy state 5 */
  y[21] = x[18];                     /* Level in tank */
  

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

double vol, A, C, Hmin, qin, qout;

A = mxGetPr(SPAR)[0];
C = mxGetPr(SPAR)[1];
Hmin = mxGetPr(SPAR)[2];

if (x[18] < Hmin)
    x[18] = Hmin; 

qin = u[14];
qout = C*pow((x[18] - Hmin),1.5);
vol = A*x[18];

/* NOTE: the states are expressed in mass (not concentration) */
dx[0] = (qin*u[0]-qout*x[0]/vol);    /* ASM1-state: SI */
dx[1] = (qin*u[1]-qout*x[1]/vol);    /* ASM1-state: SS */
dx[2] = (qin*u[2]-qout*x[2]/vol);    /* ASM1-state: XI */
dx[3] = (qin*u[3]-qout*x[3]/vol);    /* ASM1-state: XS */
dx[4] = (qin*u[4]-qout*x[4]/vol);    /* ASM1-state: XBH */
dx[5] = (qin*u[5]-qout*x[5]/vol);    /* ASM1-state: XBA */
dx[6] = (qin*u[6]-qout*x[6]/vol);    /* ASM1-state: XP */
dx[7] = (qin*u[7]-qout*x[7]/vol);    /* ASM1-state: SO */
dx[8] = (qin*u[8]-qout*x[8]/vol);    /* ASM1-state: SNO */
dx[9] = (qin*u[9]-qout*x[9]/vol);    /* ASM1-state: SNH */
dx[10] = (qin*u[10]-qout*x[10]/vol); /* ASM1-state: SND */
dx[11] = (qin*u[11]-qout*x[11]/vol); /* ASM1-state: XND */
dx[12] = (qin*u[12]-qout*x[12]/vol); /* ASM1-state: SALK */

dx[13] = (qin*u[16]-qout*x[13]/vol); /* S_D1 */
dx[14] = (qin*u[17]-qout*x[14]/vol); /* S_D2 */
dx[15] = (qin*u[18]-qout*x[15]/vol); /* S_D3 */
dx[16] = (qin*u[19]-qout*x[16]/vol); /* X_D1 */
dx[17] = (qin*u[20]-qout*x[17]/vol); /* X_D2 */

dx[18] = 1/A*(qin - qout);           /* h, level in tank */

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
