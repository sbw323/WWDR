/*
 * first flush model block 
 * Copyright: Xavier Flores-Alsina, Ulf Jeppsson, IEA, Lund University, Lund, Sweden
 *            Krist V Gernaey, DTU. Denmark
 * Modified by: Ramesh Saagi, IEA, Lund University, Sweden
 */


#define S_FUNCTION_NAME firstflush

#include "simstruc.h"
#include <math.h>

#define PAR ssGetArg(S,0)

/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 1);   /* number of continuous states                      (x[0] = TSS;                            */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states                                                                */
    ssSetNumInputs(        S, 2);  /* number of inputs                                  (u[0] = TSS; u[1] = Q)                  */
    ssSetNumOutputs(       S, 4);  /* number of outputs                                 (y[0] = TSS; y[1]=Q; y[2] = mass of TSS, y[3]=Hill */
    ssSetDirectFeedThrough(S, 1);   /* direct feedthrough flag                                                                  */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                                                                   */
    ssSetNumSFcnParams(    S, 1);   /* number of input arguments                        (PAR)                                   */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements                                                      */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements                                                   */
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements                                                   */
    
  
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
   x0[0] = mxGetPr(PAR)[0];
}

/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{

int i;
double M_Max, Q_lim, n, Ff, Ff_factor_out, Hill;

M_Max = mxGetPr(PAR)[1];
Q_lim = mxGetPr(PAR)[2];
n     = mxGetPr(PAR)[3];
Ff    = mxGetPr(PAR)[4];

if (x[0] < 0.0)
    x[0] = 0.0;

Ff_factor_out=(x[0]/M_Max);
Hill=pow(u[1]/10000,n)/(pow(Q_lim/10000,n)+pow(u[1]/10000,n));

   y[0]=u[0]*Ff_factor_out+Hill*x[0]*Ff; /* TSS Load after first flush (Kg COD/d)                              */
   y[1]=u[1];                            /* Flow rate                                                          */
   y[2]=x[0];                            /* Internal state, mass of sediment (TSS) stored in the sewer (kg COD)*/
   y[3]=Hill;
  
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

double M_Max, Q_lim, n, Ff, Ff_factor, Hill;

M_Max = mxGetPr(PAR)[1];
Q_lim = mxGetPr(PAR)[2];
n     = mxGetPr(PAR)[3];
Ff    = mxGetPr(PAR)[4];

Ff_factor=(1-x[0]/M_Max);
Hill=pow(u[1]/10000,n)/(pow(Q_lim/10000,n)+pow(u[1]/10000,n));

dx[0] = u[0]*Ff_factor-Hill*x[0]*Ff;  /* TSS balance */

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
