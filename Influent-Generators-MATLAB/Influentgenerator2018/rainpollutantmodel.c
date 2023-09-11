/*
 * Pollutant buildup and washoff model
 * Copyright: Ramesh Saagi, IEA, Lund University, Lund, Sweden
 *           
 */

#define S_FUNCTION_NAME rainpollutantmodel

#include "simstruc.h"
#include <math.h>

#define PAR	  ssGetArg(S,0)           /* definition of the set of parmater values */
#define XINIT ssGetArg(S,1)            /* Initial value for catchment pollutant buidlup and washoff model */

/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 1);   /* number of continuous states                  (x[0] = TSS mass per unit area (Kg/ha))                         */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states                                                        */
    ssSetNumInputs(        S, 1);   /* number of inputs                             (u[0] = i - rain intensity (mm/h)       */
    ssSetNumOutputs(       S, 2);   /* number of outputs                            (y[0] = TSS mass (Kg/ha), y[1]= TSS load (Kg/d))*/
    ssSetDirectFeedThrough(S, 1);   /* direct feedthrough flag                                                          */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                                                           */
    ssSetNumSFcnParams(    S, 2);   /* number of input arguments                    (PAR,XINIT)                        */
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
     x0[0] = mxGetPr(XINIT)[0];     /* Initial Mass of TSS (Kg/ha)*/
}
/*
 * mdlOutputs - compute the outputs
 */
static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{
double Kw,A,rain; int i;
Kw  = mxGetPr(PAR)[2]; 
A   = mxGetPr(PAR)[3];   /* Catchment Surface area (ha)*/

if (u[0]>2.00)
    rain=u[0];
else rain = 0;

    y[0]=x[0]; /*pollutant mass accumulated (Kg/ha)*/
    y[1]=A*Kw*24*rain*x[0];                 /* Load of pollutant (Kg/d)*/
 
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
double Ka,Kd, Kw, A,rain; int i;
Ka  = mxGetPr(PAR)[0];   /* Surface accumulation rate (Kg/ha.d)*/
Kd  = mxGetPr(PAR)[1];   /* Decay rate (/d) */
Kw  = mxGetPr(PAR)[2];   /* Washoff rate constant (/mm)*/
A   = mxGetPr(PAR)[3];   /* Catchment Surface area (ha)*/

if (u[0]>2.00)
    rain=u[0];
else rain = 0;

if(rain>0)
{Ka=0;Kd=0;}
else
{Ka=Ka;Kd=Kd;}


dx[0]=Ka-Kd*x[0]-Kw*24*rain*x[0]; /* dM/dt = Ka.-Kd.M-24.Kw.i.M*/

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
