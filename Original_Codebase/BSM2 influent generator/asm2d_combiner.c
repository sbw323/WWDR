/*
 * asm2d combiner model block 
 * Copyright: Xavier Flores-Alsina, Ulf Jeppsson, IEA, Lund University, Lund, Sweden
 *            Krist V Gernaey, DTU. Denmark
 */

#define S_FUNCTION_NAME asm2d_combiner

#include "simstruc.h"


/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    ssSetNumInputs(        S, 52);  /* number of inputs  (u[0-25] = ASM2d state variables + TSS +  Q +  T + 3 S dummy states + 2 X dummy states; u[26-51] = ASM2d state variables + TSS +  Q +  T + 3 S dummy states + 2 X dummy states; */
    ssSetNumOutputs(       S, 26);  /* number of outputs (y[0-25] = ASM2d state variables + TSS +  Q +  T + 3 S dummy states + 2 X dummy states  */
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
  y[0]=(u[0]*u[19] + u[26]*u[45])/(u[19]+u[45]);     /* ASM2d-state: SO */
  y[1]=(u[1]*u[19] + u[27]*u[45])/(u[19]+u[45]);     /* ASM2d-state: SA */
  y[2]=(u[2]*u[19] + u[28]*u[45])/(u[19]+u[45]);     /* ASM2d-state: SF */
  y[3]=(u[3]*u[19] + u[29]*u[45])/(u[19]+u[45]);     /* ASM2d-state: SI */
  y[4]=(u[4]*u[19] + u[30]*u[45])/(u[19]+u[45]);     /* ASM2d-state: SNH */
  y[5]=(u[5]*u[19] + u[31]*u[45])/(u[19]+u[45]);     /* ASM2d-state: SN2 */
  y[6]=(u[6]*u[19] + u[32]*u[45])/(u[19]+u[45]);     /* ASM2d-state: SNOX */
  y[7]=(u[7]*u[19] + u[33]*u[45])/(u[19]+u[45]);     /* ASM2d-state: SPO4 */
  y[8]=(u[8]*u[19] + u[34]*u[45])/(u[19]+u[45]);     /* ASM2d-state: SALK */
  y[9]=(u[9]*u[19] + u[35]*u[45])/(u[19]+u[45]);     /* ASM2d-state: XI */
  y[10]=(u[10]*u[19] + u[36]*u[45])/(u[19]+u[45]);   /* ASM2d-state: XS */
  y[11]=(u[11]*u[19] + u[37]*u[45])/(u[19]+u[45]);   /* ASM2d-state: XBH */
  y[12]=(u[12]*u[19] + u[38]*u[45])/(u[19]+u[45]);   /* ASM2d-state: XPAO */
  y[13]=(u[13]*u[19] + u[39]*u[45])/(u[19]+u[45]);   /* ASM2d-state: XPP  */
  y[14]=(u[14]*u[19] + u[40]*u[45])/(u[19]+u[45]);   /* ASM2d-state: XPHA */
  y[15]=(u[15]*u[19] + u[41]*u[45])/(u[19]+u[45]);   /* ASM2d-state: XBA  */
  y[16]=(u[16]*u[19] + u[42]*u[45])/(u[19]+u[45]);   /* ASM2d-state: XMEOH  */
  y[17]=(u[17]*u[19] + u[43]*u[45])/(u[19]+u[45]);   /* ASM2d-state: XMEP  */
  y[18]=(u[18]*u[19] + u[44]*u[45])/(u[19]+u[45]);   /* TSS */
  y[19]=(u[19]+u[45]);   /* Q */
  y[20]=(u[20]*u[19] + u[46]*u[45])/(u[19]+u[45]);   /* t */
  y[21]=(u[21]*u[19] + u[47]*u[45])/(u[19]+u[45]);   /* S Dummy state 1 */
  y[22]=(u[22]*u[19] + u[48]*u[45])/(u[19]+u[45]);   /* S Dummy state 2 */
  y[23]=(u[23]*u[19] + u[49]*u[45])/(u[19]+u[45]);   /* S Dummy state 3 */
  y[24]=(u[24]*u[19] + u[50]*u[45])/(u[19]+u[45]);   /* X Dummy state 4 */
  y[25]=(u[25]*u[19] + u[51]*u[45])/(u[19]+u[45]);   /* X Dummy state 5 */

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
