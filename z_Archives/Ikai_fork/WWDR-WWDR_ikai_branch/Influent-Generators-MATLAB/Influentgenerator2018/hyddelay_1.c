/*
 * hyddelayv3_bsm2 is a C-file S-function for first order reaction of flow and conc.  
 * In this version the loads are first calculated and the first
 * order reaction is used for the load and flow. After this the concentrations are
 * recalculated based on the delayed flow and load. Note that the state
 * vector internally here represents mass. State no 14 (TSS) is a dummy state to 
 * maintain consistence with the normal vector size used in reactors.
 * For temperature T(out) = T(in) independently of parameter TEMPMODEL.
 *  
 * Copyright: Ulf Jeppsson, IEA, Lund University, Lund, Sweden
 *
 *Modified by Ramesh Saagi, IEA, Lund University,Sweden
 *to include only one state (is used to split only flow rate inputs)
 */

#define S_FUNCTION_NAME hyddelay_1

#include "simstruc.h"

#define XINIT       ssGetArg(S,0)
#define T       ssGetArg(S,1)



/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 1);  /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    ssSetNumInputs(        S, 1);  /* number of inputs                      */
    ssSetNumOutputs(       S, 1);  /* number of outputs                     */
    ssSetDirectFeedThrough(S, 0);   /* direct feedthrough flag               */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumSFcnParams(    S, 2);   /* number of input arguments             */
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

   x0[0] = mxGetPr(XINIT)[0];
}

/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{
   y[0] = x[0];
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
double timeconst;

timeconst = mxGetPr(T)[0];
if (timeconst > 0.000001) 
  dx[0] = (u[0]-x[0])/timeconst;
else 
 dx[0]=0;
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

