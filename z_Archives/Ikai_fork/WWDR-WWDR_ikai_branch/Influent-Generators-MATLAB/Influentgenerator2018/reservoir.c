/*
 * Reservoir model for flow and pollutant transport with a residence time K
 * Copyright: Ramesh Saagi, IEA, Lund University, Lund, Sweden
 *            
 */

#define S_FUNCTION_NAME reservoir

#include "simstruc.h"
#include <math.h>

#define PAR	ssGetArg(S,0)           /* (PAR contains initial values for the continuous states and residence time K) */
/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 6);   /* number of continuous states                  (CODs,CODp, SNH, TKN,NOx,V)                         */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states                                                        */
    ssSetNumInputs(        S, 6);   /* number of inputs                             (CODs,CODp, SNH, TKN,NOx,Q)       */
    ssSetNumOutputs(       S, 6);   /* number of outputs                            (CODs,CODp, SNH, TKN,NOx,Q)  */
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
int i;
static void mdlInitializeConditions(double *x0, SimStruct *S)
{
   for (i=0;i<6; i++)
   {
    x0[i] = mxGetPr(PAR)[i];     /* Initial pollutant concentration and flowrate */
   }
}
/*
 * mdlOutputs - compute the outputs
 */
static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{
double K, ytemp[6]; int i;
K  = mxGetPr(PAR)[6]; 
  for (i=0;i<6; i++)
   {
    ytemp[i] = (1/K)*x[i];     /* Output pollutant load and flow rate */
   }
   
for (i=0;i<6;i++)
{
    if (ytemp[i]< 0.000001)
            y[i]=0;
    else  y[i]=ytemp[i];
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
double K;int i;
K  = mxGetPr(PAR)[6];   /* Residence time constant (1/T)*/
for (i=0;i<6; i++)
 {
/*   dx[i]=(u[5]/x[5])*(u[i]-x[i]); /* dC/dt = (Qin/V)*(Cin-C)*/
    dx[i] = u[i]-(1/K)*x[i]; /*dM/dt = Qin.Cin -K.M */
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
