/*
 * hyddelay is a C-file S-function for first order reaction of flow and conc.  
 *
 * Copyright: Ulf Jeppsson, IEA, Lund University, Lund, Sweden
 *
 * This file has been modified by Xavier Flores-Alsina
 * July, 2010
 * IEA, Lund University, Lund, Sweden
 *
 *
 *
 */

#define S_FUNCTION_NAME hyddelay_asm2d

#include "simstruc.h"

#define XINIT   ssGetArg(S,0)
#define PAR     ssGetArg(S,1)
#define T       ssGetArg(S,2)

/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 26); /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    ssSetNumInputs(        S, 26);   /* number of inputs                      */
    ssSetNumOutputs(       S, 26);   /* number of outputs                     */
    ssSetDirectFeedThrough(S, 0);   /* direct feedthrough flag               */
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

for (i = 0; i < 26; i++) {
   x0[i] = mxGetPr(XINIT)[i];
}
}

/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{
  int i;

  for (i = 0; i < 19; i++) {
      y[i] = x[i]/x[19];
  }

  y[19]=x[19];
  
 
  y[20] = x[20]; /* Temp */
  
  /* dummy states */
  y[21] = x[21]/x[19];
  y[22] = x[22]/x[19];
  y[23] = x[23]/x[19];
  y[24] = x[24]/x[19];
  y[25] = x[25]/x[19];


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
int i;
double timeconst;

timeconst = mxGetPr(T)[0];
if (timeconst > 0.000001) {
  dx[0] = (u[0]*u[19]-x[0])/timeconst;
  dx[1] = (u[1]*u[19]-x[1])/timeconst;
  dx[2] = (u[2]*u[19]-x[2])/timeconst;
  dx[3] = (u[3]*u[19]-x[3])/timeconst;
  dx[4] = (u[4]*u[19]-x[4])/timeconst;
  dx[5] = (u[5]*u[19]-x[5])/timeconst;
  dx[6] = (u[6]*u[19]-x[6])/timeconst;
  dx[7] = (u[7]*u[19]-x[7])/timeconst;
  dx[8] = (u[8]*u[19]-x[8])/timeconst;
  dx[9] = (u[9]*u[19]-x[9])/timeconst;
  dx[10] = (u[10]*u[19]-x[10])/timeconst;
  dx[11] = (u[11]*u[19]-x[11])/timeconst;
  dx[12] = (u[12]*u[19]-x[12])/timeconst;
  dx[13] = (u[13]*u[19]-x[13])/timeconst;
  dx[14] = (u[14]*u[19]-x[14])/timeconst;
  dx[15] = (u[15]*u[19]-x[15])/timeconst;
  dx[16] = (u[16]*u[19]-x[16])/timeconst;
  dx[17] = (u[17]*u[19]-x[17])/timeconst;
  dx[18] = (u[18]*u[19]-x[18])/timeconst;
  
  dx[19] = (u[19]-x[19])/timeconst; 
  dx[20] = (u[20]-x[20])/timeconst; 
  
  dx[21] = (u[21]*u[19]-x[21])/timeconst;
  dx[22] = (u[22]*u[19]-x[22])/timeconst;
  dx[23] = (u[23]*u[19]-x[23])/timeconst;
  dx[24] = (u[24]*u[19]-x[24])/timeconst;
  dx[25] = (u[25]*u[19]-x[25])/timeconst;
}
else {
  dx[0] = 0.0;
  dx[1] = 0.0;
  dx[2] = 0.0;
  dx[3] = 0.0;
  dx[4] = 0.0;
  dx[5] = 0.0;
  dx[6] = 0.0;
  dx[7] = 0.0;
  dx[8] = 0.0;
  dx[9] = 0.0;
  dx[10] = 0.0;
  dx[11] = 0.0;
  dx[12] = 0.0;
  dx[13] = 0.0; 
  dx[14] = 0.0; 
  dx[15] = 0.0; 
  dx[16] = 0.0; 
  dx[17] = 0.0;
  dx[18] = 0.0; 
  
  dx[19] = 0.0; 
  dx[20] = 0.0; 
  
  dx[21] = 0.0; 
  dx[22] = 0.0; 
  dx[23] = 0.0; 
  dx[24] = 0.0; 
  dx[25] = 0.0; 
  
  x[0] = u[0]*u[19];
  x[1] = u[1]*u[19];
  x[2] = u[2]*u[19];
  x[3] = u[3]*u[19];
  x[4] = u[4]*u[19];
  x[5] = u[5]*u[19];
  x[6] = u[6]*u[19];
  x[7] = u[7]*u[19];
  x[8] = u[8]*u[19];
  x[9] = u[9]*u[19];
  x[10] = u[10]*u[19];
  x[11] = u[11]*u[19];
  x[12] = u[12]*u[19];
  x[13] = u[13]*u[19];
  x[14] = u[14]*u[19];
  x[15] = u[15]*u[19];
  x[16] = u[16]*u[19];
  x[17] = u[17]*u[19];
  x[18] = u[18]*u[19];
  
  x[19] = u[19];
  x[20] = u[20];
  
  x[21] = u[21]*u[19];
  x[22] = u[22]*u[19];
  x[23] = u[23]*u[19];
  x[24] = u[24]*u[19];
  x[25] = u[25]*u[19];
  
}
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
