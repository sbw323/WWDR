/*
 * sewer_asm1 model block 
 * Copyright: Xavier Flores-Alsina, Ulf Jeppsson, IEA, Lund University, Lund, Sweden
 *            Krist V Gernaey, DTU. Denmark
 */

#define S_FUNCTION_NAME sewer_asm2d

#include "simstruc.h"
#include <math.h>

#define ASM2d_SEWERINIT ssGetArg(S,0)
#define ASM2d_PARS ssGetArg(S,1)
#define SPAR ssGetArg(S,2)


/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 24);  /* number of continuous states           (x[0-23] = ASM2d state variables + 3 S dummy states + 2 X dummy states + h */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states              */
    ssSetNumInputs(        S, 27);  /* number of inputs (corresponding to outputs) (u[0-26] = ASM2d state variables + TSS +  Q +  T + 3 S dummy states + 2 X dummy states + h */
    ssSetNumOutputs(       S, 27);  /* number of outputs                           (y[0-26] = ASM2d state variables + TSS +  Q +  T + 3 S dummy states + 2 X dummy states + h */  
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

for (i = 0; i < 24; i++) {
   x0[i] = mxGetPr(ASM2d_SEWERINIT)[i];
}
}

/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{
  double iSS_XI, iSS_XS, iSS_XB, iSS_XPP, iSS_XPHA, iSS_XMe, A, C, Hmin, vol;
  int i;
  
  iSS_XI   =	mxGetPr(ASM2d_PARS)[19];    
  iSS_XS   =	mxGetPr(ASM2d_PARS)[20];    
  iSS_XB   =	mxGetPr(ASM2d_PARS)[21];
  iSS_XPP  =    mxGetPr(ASM2d_PARS)[22];
  iSS_XPHA =    mxGetPr(ASM2d_PARS)[23];
  iSS_XMe  =    mxGetPr(ASM2d_PARS)[24]; 

  A = mxGetPr(SPAR)[0];
  C = mxGetPr(SPAR)[1];
  Hmin = mxGetPr(SPAR)[2];
  
  if (x[23] < Hmin)
    x[23] = Hmin;
  
  vol = A*x[23];

  for (i = 0; i < 18; i++) {
      y[i] = x[i]/vol;               /* ASM2d-states: SO, SA, SF, SNH, SN2, SNOX, SPO4, SALK, XI, XS, XBH, XPAO, XBA, XMEOH, XMEP */
  }

  y[18] = (iSS_XI*x[9]+iSS_XS *x[10]+ iSS_XB*x[11]+ iSS_XB*x[12]+ iSS_XPP*x[13] + iSS_XPHA*x[14]+ iSS_XB*x[15]+ iSS_XMe*x[16]+ iSS_XMe*x[17])/vol;   
                                     /* TSS */
  y[19] = C*pow((x[23] - Hmin),1.5); /* Q_out */
  
  
  y[20] = u[20];                     /* T */
  
  y[21] = x[18]/vol;                 /* Dummy state 1 */  
  y[22] = x[19]/vol;                 /* Dummy state 2 */
  y[23] = x[20]/vol;                 /* Dummy state 3 */
  y[24] = x[21]/vol;                 /* Dummy state 4 */
  y[25] = x[22]/vol;                 /* Dummy state 5 */
  y[26] = x[23];                     /* Level in tank */
  

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

if (x[23] < Hmin)
    x[23] = Hmin; 

qin = u[19];
qout = C*pow((x[23] - Hmin),1.5);
vol = A*x[23];

/* NOTE: the states are expressed in mass (not concentration) */
dx[0] = (qin*u[0]-qout*x[0]/vol);    /* ASM2d-state: S0 */
dx[1] = (qin*u[1]-qout*x[1]/vol);    /* ASM2d-state: SA */
dx[2] = (qin*u[2]-qout*x[2]/vol);    /* ASM2d-state: SF */
dx[3] = (qin*u[3]-qout*x[3]/vol);    /* ASM2d-state: SI */
dx[4] = (qin*u[4]-qout*x[4]/vol);    /* ASM2d-state: SNH */
dx[5] = (qin*u[5]-qout*x[5]/vol);    /* ASM2d-state: SN2 */
dx[6] = (qin*u[6]-qout*x[6]/vol);    /* ASM2d-state: SNOX */
dx[7] = (qin*u[7]-qout*x[7]/vol);    /* ASM2d-state: SPO4 */
dx[8] = (qin*u[8]-qout*x[8]/vol);    /* ASM2d-state: SALK */
dx[9] = (qin*u[9]-qout*x[9]/vol);    /* ASM2d-state: XI */
dx[10] = (qin*u[10]-qout*x[10]/vol); /* ASM2d-state: XS */
dx[11] = (qin*u[11]-qout*x[11]/vol); /* ASM2d-state: XBH */
dx[12] = (qin*u[12]-qout*x[12]/vol); /* ASM2d-state: XPAO */
dx[13] = (qin*u[13]-qout*x[13]/vol); /* ASM2d-state: XPP */
dx[14] = (qin*u[14]-qout*x[14]/vol); /* ASM2d-state: XPHA */
dx[15] = (qin*u[15]-qout*x[15]/vol); /* ASM2d-state: XBA */
dx[16] = (qin*u[16]-qout*x[16]/vol); /* ASM2d-state: XMEOH */
dx[17] = (qin*u[17]-qout*x[17]/vol); /* ASM2d-state: XMEP*/

dx[18] = (qin*u[21]-qout*x[18]/vol); /* S_D1 */
dx[19] = (qin*u[22]-qout*x[19]/vol); /* S_D2 */
dx[20] = (qin*u[23]-qout*x[20]/vol); /* S_D3 */
dx[21] = (qin*u[24]-qout*x[21]/vol); /* X_D1 */
dx[22] = (qin*u[25]-qout*x[22]/vol); /* X_D2 */

dx[23] = 1/A*(qin - qout);           /* h, level in tank */

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
