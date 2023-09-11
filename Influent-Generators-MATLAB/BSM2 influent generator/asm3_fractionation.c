/*
 * asm3 fractionation model block 
 * Copyright: Xavier Flores-Alsina, Ulf Jeppsson, IEA, Lund University, Lund, Sweden
 *            Krist V Gernaey, DTU. Denmark
 */

#define S_FUNCTION_NAME asm3_fractionation

#include "simstruc.h"
#include <math.h>

#define ASM3_PARS   ssGetArg(S,0)       /* definition of the ASM1 kinetic and stoichiometric coefficients            */
#define ASM3_FRACTIONS   ssGetArg(S,1)  /* definition of the ASM1 kinetic and stoichiometric coefficients            */

/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 0);   /* number of continuous states                                                      */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states                                                        */
    ssSetNumInputs(        S, 12);  /* number of inputs                            (u[0] = CODsol_HH; u[1] = CODpart_HH, u[2] = SNH_HH; u[3] = TKN_HH; u[4] = NOX_HH;  u[5] = CODsol_Ind; u[6] = CODpart_Ind, u[7] = SNH_Ind; u[8] = TKN_Ind; u[9] = NOX_Ind;  u[10] = Q_rain; u[11] = Q_total;   )       */
    ssSetNumOutputs(       S, 12);  /* number of outputs                           (y[0] = SO; y[1] = SI; y[2] = SS; y[3] = SNH4; y[4] = SN2; y[5] = SNOX; y[6] = SALK; y[7] = XI; y[8] = XS; y[9] = XBH; y [10] = XSTO; y[11] = XA */
    ssSetDirectFeedThrough(S, 1);   /* direct feedthrough flag                                                          */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                                                           */
    ssSetNumSFcnParams(    S, 2);   /* number of input arguments                    (ASM1_PARS, ASM1_FRACTIONS)         */
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
}

/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{

double SI_cst, XI_fr, XS_fr, XBH_fr, XBA_fr, XSTO_fr, SNO_fr, SNH_fr;
double CODsolflux, Norg;
   

/* load the ASM1 component fractions */
SI_cst  =  mxGetPr(ASM3_FRACTIONS)[0];
XI_fr   =  mxGetPr(ASM3_FRACTIONS)[1];
XS_fr   =  mxGetPr(ASM3_FRACTIONS)[2];
XBH_fr  =  mxGetPr(ASM3_FRACTIONS)[3];
XBA_fr  =  mxGetPr(ASM3_FRACTIONS)[4];
XSTO_fr  = mxGetPr(ASM3_FRACTIONS)[5];
SNH_fr  =  mxGetPr(ASM3_FRACTIONS)[6];
SNO_fr  =  mxGetPr(ASM3_FRACTIONS)[7];

y[0] = 0;                                           /* SO is assumed to be zero */

CODsolflux=u[0]+u[5];
if ((SI_cst*(u[11]-u[10])) <=CODsolflux){          /* SI is constant, direct rain water (u[10]) can dilute SI only */
    y[1] = SI_cst*(u[11]-u[10])/u[11];
    y[2] = (CODsolflux-SI_cst*(u[11]-u[10]))/u[11];
    }
else if ((SI_cst*(u[11]-u[10])) > CODsolflux){
    y[1] = CODsolflux/u[11];
    y[2] = 0.0;
    }
y[3] = (u[2]+u[7])/u[11];                           /* SNH defined as the result of combining the ammonium N fluxes */
y[4] = 0;                                           /* SN2 is assumed to be zero */
y[5] =(u[4]+u[9])/u[11];                           /* SNO defined as the result of combining the inorganic N fluxes */
y[6] = 7.0;                                         /* SALK is assumed to be constant and not limiting for the processes in the WWTP */   
y[7] = XI_fr*(u[1]+u[6])/u[11];                     /* XI defined as a fraction of the particulate COD */
y[8] = XS_fr*(u[1]+u[6])/u[11];                     /* XS defined as a fraction of the particulate COD */
y[9] = XBH_fr*(u[1]+u[6])/u[11];                    /* XBH defined as a fraction of the particulate COD */
y[10] = XSTO_fr*(u[1]+u[6])/u[11];                  /* XSTO defined as a fraction of the particulate COD */
y[11] = XBA_fr*(u[1]+u[6])/u[11];                   /* XBA defined as a fraction of the particulate COD */

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
