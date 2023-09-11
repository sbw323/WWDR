/*
 * combinerasm2d.c calculates the concentrations when adding two flow  
 * streams together.
 *  
 * Copyright: Ulf Jeppsson, IEA, Lund University, Lund, Sweden
 *
 * This file has been modified by Xavier Flores-Alsina
 * July, 2010
 * IEA, Lund University, Lund, Sweden
 */

#define S_FUNCTION_NAME combiner_asm2d

#include "simstruc.h"


/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    ssSetNumInputs(        S, 52);   /* number of inputs                      */
    ssSetNumOutputs(       S, 26);   /* number of outputs                     */
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
  if ((u[19] > 0) || (u[45] > 0)) {
    y[0]=(u[0]*u[19] + u[26]*u[45])/(u[19]+u[45]);
    y[1]=(u[1]*u[19] + u[27]*u[45])/(u[19]+u[45]);
    y[2]=(u[2]*u[19] + u[28]*u[45])/(u[19]+u[45]);
    y[3]=(u[3]*u[19] + u[29]*u[45])/(u[19]+u[45]);
    y[4]=(u[4]*u[19] + u[30]*u[45])/(u[19]+u[45]);
    y[5]=(u[5]*u[19] + u[31]*u[45])/(u[19]+u[45]);
    y[6]=(u[6]*u[19] + u[32]*u[45])/(u[19]+u[45]);
    y[7]=(u[7]*u[19] + u[33]*u[45])/(u[19]+u[45]);
    y[8]=(u[8]*u[19] + u[34]*u[45])/(u[19]+u[45]);
    y[9]=(u[9]*u[19] + u[35]*u[45])/(u[19]+u[45]);
    y[10]=(u[10]*u[19] + u[36]*u[45])/(u[19]+u[45]);
    y[11]=(u[11]*u[19] + u[37]*u[45])/(u[19]+u[45]);
    y[12]=(u[12]*u[19] + u[38]*u[45])/(u[19]+u[45]);
    y[13]=(u[13]*u[19] + u[39]*u[45])/(u[19]+u[45]);
    y[14]=(u[14]*u[19] + u[40]*u[45])/(u[19]+u[45]);
    y[15]=(u[15]*u[19] + u[41]*u[45])/(u[19]+u[45]);
    y[16]=(u[16]*u[19] + u[42]*u[45])/(u[19]+u[45]);
    y[17]=(u[17]*u[19] + u[43]*u[45])/(u[19]+u[45]);
    y[18]=(u[18]*u[19] + u[44]*u[45])/(u[19]+u[45]);
    
    y[19]=(u[19]+u[45]);
    
    y[20]=(u[20]*u[19] + u[46]*u[45])/(u[19]+u[45]);
    y[21]=(u[21]*u[19] + u[47]*u[45])/(u[19]+u[45]);
    y[22]=(u[22]*u[19] + u[48]*u[45])/(u[19]+u[45]);
    y[23]=(u[23]*u[19] + u[49]*u[45])/(u[19]+u[45]);
    y[24]=(u[24]*u[19] + u[50]*u[45])/(u[19]+u[45]);
    y[25]=(u[25]*u[19] + u[51]*u[45])/(u[19]+u[45]);
    
    
    
    
    
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
    y[21]=0;
    y[22]=0;
    y[23]=0;
    y[24]=0;
    y[25]=0;
    

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
