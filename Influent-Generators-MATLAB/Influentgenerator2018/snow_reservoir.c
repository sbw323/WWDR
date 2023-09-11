/*
 * Reservoir model for storing snowfalland releasing as precipitation with residence time K when temperature is above zero celsius
 * Copyright: Ramesh Saagi, IEA, Lund University, Lund, Sweden
 *            
 */

#define S_FUNCTION_NAME snow_reservoir

#include "simstruc.h"
#include <math.h>

#define PAR	ssGetArg(S,0)           /* (PAR contains initial values for the continuous states and residence time K) */
/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 1);   /* number of continuous states                  (CODs,CODp, SNH, TKN,NOx,V)                         */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states                                                        */
    ssSetNumInputs(        S, 2);   /* number of inputs                             (CODs,CODp, SNH, TKN,NOx,Q)       */
    ssSetNumOutputs(       S, 2);   /* number of outputs                            (CODs,CODp, SNH, TKN,NOx,Q)  */
    ssSetDirectFeedThrough(S, 1);   /* direct feedthrough flag                                                          */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                                                           */
    ssSetNumSFcnParams(    S, 1);   /* number of input arguments                    (PAR contains initial values for the continuous states and residence time K)                        */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements                                              */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements                                           */
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements                                           */
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
    x0[0] = mxGetPr(PAR)[0];     /* Initial volume of snow */
   
}
/*
 * mdlOutputs - compute the outputs
 */
static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{
double K, ytemp[1];
K  = mxGetPr(PAR)[1]; 
 
    if (u[1]>=0){
        y[0] = (1/K)*(u[1]/10)*x[0]/24; }
    else {
        y[0] = 0;}     /* Output precipitation */
y[1]=x[0];
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
double K,utemp;
K  = mxGetPr(PAR)[1];   /* Residence time constant (1/T)*/
    if (u[1]<0)
        utemp=u[0]*24;
    else utemp=0;
if (u[1]>=0)
dx[0]=utemp-(1/K)*x[0]*u[1]/10;
else
dx[0]=utemp;
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
