/*
 * combiner_asm1.c calculates the output concentrations when adding two flow  
 * streams together. Output temperature always based on 'heat content' of the
 * influent flows, i.e. parameter TEMPMODEL is not used. If all input flow rates are
 * less or equal to zero then all outputs are zero.

 * This file has been modified by Xavier Flores-Alsina
 * July, 2010
 * IEA, Lund University, Lund, Sweden

 */

#define S_FUNCTION_NAME combiner_asm1

#include "simstruc.h"

/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    ssSetNumInputs(        S, 42);  /* number of inputs                      */
    ssSetNumOutputs(       S, 21);  /* number of outputs                     */
    ssSetDirectFeedThrough(S, 1);   /* direct feedthrough flag               */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumSFcnParams(    S, 0);   /* number of input arguments             */
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
}

/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{
    
  if ((u[14] > 0) || (u[35] > 0)) {
    y[0]=(u[0]*u[14] + u[21]*u[35])/(u[14]+u[35]);
    y[1]=(u[1]*u[14] + u[22]*u[35])/(u[14]+u[35]);
    y[2]=(u[2]*u[14] + u[23]*u[35])/(u[14]+u[35]);
    y[3]=(u[3]*u[14] + u[24]*u[35])/(u[14]+u[35]);
    y[4]=(u[4]*u[14] + u[25]*u[35])/(u[14]+u[35]);
    y[5]=(u[5]*u[14] + u[26]*u[35])/(u[14]+u[35]);
    y[6]=(u[6]*u[14] + u[27]*u[35])/(u[14]+u[35]);
    y[7]=(u[7]*u[14] + u[28]*u[35])/(u[14]+u[35]);
    y[8]=(u[8]*u[14] + u[29]*u[35])/(u[14]+u[35]);
    y[9]=(u[9]*u[14] + u[30]*u[35])/(u[14]+u[35]);
    y[10]=(u[10]*u[14] + u[31]*u[35])/(u[14]+u[35]);
    y[11]=(u[11]*u[14] + u[32]*u[35])/(u[14]+u[35]);
    y[12]=(u[12]*u[14] + u[33]*u[35])/(u[14]+u[35]);
    y[13]=(u[13]*u[14] + u[34]*u[35])/(u[14]+u[35]);
    
    y[14]=u[14]+u[35];                               /* Flow rate */
    
    y[15]=(u[15]*u[14] + u[36]*u[35])/(u[14]+u[35]);    /* Temp */
         
    /* Dummy states */
    y[16]=(u[16]*u[14] + u[37]*u[35])/(u[14]+u[35]);
    y[17]=(u[17]*u[14] + u[38]*u[35])/(u[14]+u[35]);
    y[18]=(u[18]*u[14] + u[39]*u[35])/(u[14]+u[35]);
    y[19]=(u[19]*u[14] + u[40]*u[35])/(u[14]+u[35]);
    y[20]=(u[20]*u[14] + u[41]*u[35])/(u[14]+u[35]);

  }
  else {
    y[0]=0;
    y[1]=0;
    y[2]=0;
    y[3]=0;
    y[4]=0;
    y[5]=0;
    y[6]=0;
    y[7]=0;
    y[8]=0;
    y[9]=0;
    y[10]=0;
    y[11]=0;
    y[12]=0;
    y[13]=0;
    y[14]=0;
    y[15]=0;
    y[16]=0;
    y[17]=0;
    y[18]=0;
    y[19]=0;
    y[20]=0;

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

