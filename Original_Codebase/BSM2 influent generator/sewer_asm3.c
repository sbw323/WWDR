/*
 * sewer_asm3 model block 
 * Copyright: Xavier Flores-Alsina, Ulf Jeppsson, IEA, Lund University, Lund, Sweden
 *            Krist V Gernaey, DTU. Denmark
 */

#define S_FUNCTION_NAME sewer_asm3

#include "simstruc.h"
#include <math.h>

#define ASM3_SEWERINIT ssGetArg(S,0)
#define ASM3_PARS ssGetArg(S,1)
#define SPAR ssGetArg(S,2)


/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 18);  /* number of continuous states           (x[0-17] = ASM3 state variables +3 S dummy states + 2 X dummy states + h */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states */            
    ssSetNumInputs(        S, 21);  /* number of inputs (corresponding to outputs) (u[0-20] = ASM3 state variables + TSS +  Q +  T + 3 S dummy states + 2 X dummy states + h */
    ssSetNumOutputs(       S, 21);  /* number of outputs                           (y[0-20] = ASM3 state variables + TSS +  Q +  T + 3 S dummy states + 2 X dummy states + h */  
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

for (i = 0; i < 18; i++) {
   x0[i] = mxGetPr(ASM3_SEWERINIT)[i];
}
}

/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{
  double ISS_XI, ISS_XS, ISS_XB, A, C, Hmin, vol;
  int i;

  ISS_XI = mxGetPr(ASM3_PARS)[33];
  ISS_XS = mxGetPr(ASM3_PARS)[34];
  ISS_XB = mxGetPr(ASM3_PARS)[35];
  
  A = mxGetPr(SPAR)[0];
  C = mxGetPr(SPAR)[1];
  Hmin = mxGetPr(SPAR)[2];
  
  if (x[17] < Hmin)
    x[17] = Hmin;
  
  vol = A*x[17];

  for (i = 0; i < 12; i++) {
      y[i] = x[i]/vol;               /* ASM3-states: SO, SI, SS, SNH, SN2, SNOX, SALK, XI, XS, XBH, XSTO, XA */
  }

  y[12] = (ISS_XI*x[7] + ISS_XS*x[8] + ISS_XB*x[9] + ISS_XB*x[10] + ISS_XB*x[11])/vol;   
                                     /* TSS */
  y[13] = C*pow((x[17] - Hmin),1.5); /* Q_out */
  y[14] = u[14];                     /* T */
  y[15] = x[12]/vol;                 /* Dummy state 1 */  
  y[16] = x[13]/vol;                 /* Dummy state 2 */
  y[17] = x[14]/vol;                 /* Dummy state 3 */
  y[18] = x[15]/vol;                 /* Dummy state 4 */
  y[19] = x[16]/vol;                 /* Dummy state 5 */
  y[20] = x[17];                     /* Level in tank */
  

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

if (x[17] < Hmin)
    x[17] = Hmin; 

qin = u[13];
qout = C*pow((x[17] - Hmin),1.5);
vol = A*x[17];

/* NOTE: the states are expressed in mass (not concentration) */
dx[0] = (qin*u[0]-qout*x[0]/vol);    /* ASM3-state: SO */
dx[1] = (qin*u[1]-qout*x[1]/vol);    /* ASM3-state: SI */
dx[2] = (qin*u[2]-qout*x[2]/vol);    /* ASM3-state: SS */
dx[3] = (qin*u[3]-qout*x[3]/vol);    /* ASM3-state: SNH */
dx[4] = (qin*u[4]-qout*x[4]/vol);    /* ASM3-state: SN2 */
dx[5] = (qin*u[5]-qout*x[5]/vol);    /* ASM3-state: SNOX */
dx[6] = (qin*u[6]-qout*x[6]/vol);    /* ASM3-state: SALK */
dx[7] = (qin*u[7]-qout*x[7]/vol);    /* ASM3-state: XI */
dx[8] = (qin*u[8]-qout*x[8]/vol);    /* ASM3-state: XS */
dx[9] = (qin*u[9]-qout*x[9]/vol);    /* ASM3-state: XBH */
dx[10] = (qin*u[10]-qout*x[10]/vol); /* ASM3-state: XSTO */
dx[11] = (qin*u[11]-qout*x[11]/vol); /* ASM3-state: XA */

dx[12] = (qin*u[15]-qout*x[12]/vol); /* S_D1 */
dx[13] = (qin*u[16]-qout*x[13]/vol); /* S_D2 */
dx[14] = (qin*u[17]-qout*x[14]/vol); /* S_D3 */
dx[15] = (qin*u[18]-qout*x[15]/vol); /* X_D1 */
dx[16] = (qin*u[19]-qout*x[16]/vol); /* X_D2 */

dx[17] = 1/A*(qin - qout);           /* h, level in tank */

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
