/*
 * asm2d fractionation model block 
 * Copyright: Xavier Flores-Alsina, Ulf Jeppsson, IEA, Lund University, Lund, Sweden
 *            Krist V Gernaey, DTU. Denmark
 */

#define S_FUNCTION_NAME asm2d_fractionation

#include "simstruc.h"
#include <math.h>

#define ASM2d_PARS   ssGetArg(S,0)       /* definition of the ASM1 kinetic and stoichiometric coefficients            */
#define ASM2d_FRACTIONS   ssGetArg(S,1)  /* definition of the ASM1 kinetic and stoichiometric coefficients            */

/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 0);   /* number of continuous states                                                      */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states                                                        */
    ssSetNumInputs(        S, 12);  /* number of inputs                            (u[0] = CODsol_HH; u[1] = CODpart_HH, u[2] = SNH_HH; u[3] = NOX_HH; u[4] = PO4_HH; u[5] = CODsol_Ind; u[6] = CODpart_Ind, u[7] = SNH_Ind; u[8] = NOX_Ind; [u9] = PO4_Ind, u[10] = Q_rain; u[11] = Q_total;   )       */
    ssSetNumOutputs(       S, 18);  /* number of outputs                           (y[0] = S0; y[1] = Sa; y[2] = sf; y[3] = si; y[4] = snh; y[5] = sn2; y[6] = snox; y[7] = spo4; y[8] = salk; y[9] = Xi; y [10] = Xs; y[11] = Xbh; y[12] = Xpao, y[13] = Xpp; y [14] = Xpha; y[15] = Xba; y[16] = Xmeoh y[17] = Xmep ) */
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

double So_fr,Sa_fr,Sf_fr, Si_fr, Snh_fr, Sn2_in, Sno_fr, Spo4_fr, Salk_fr, Xi_fr, Xs_fr, Xbh_fr, Xpao_fr, Xpp_fr, Xpha_fr, Xba_fr, Xmeoh_fr, XMep_fr;   
double So_cst,Sa_cst,Sf_cst, Si_cst, Snh_cst, Sn2_cst, Sno_cst, Spo4_cst, Salk_cst, Xi_cst, Xs_cst, Xbh_cst, Xpao_cst, Xpp_cst, Xpha_cst, Xba_cst, Xmeoh_cst, XMep_cst;  
double CODsolflux;
    

/* load the ASM2d component fractions */

Sa_fr   =  mxGetPr(ASM2d_FRACTIONS)[0];                        
Sf_fr   =  mxGetPr(ASM2d_FRACTIONS)[1];                          
Si_cst  =  mxGetPr(ASM2d_FRACTIONS)[2];                       
                                           
Snh_fr  =  mxGetPr(ASM2d_FRACTIONS)[3];                       
Sno_fr  =  mxGetPr(ASM2d_FRACTIONS)[4];
Spo4_fr =  mxGetPr(ASM2d_FRACTIONS)[5];                      

Xi_fr   =  mxGetPr(ASM2d_FRACTIONS)[6];                      
Xs_fr   =  mxGetPr(ASM2d_FRACTIONS)[7];                   
Xbh_fr  =  mxGetPr(ASM2d_FRACTIONS)[8];                


y[0] = 0;                                           /* SO is assumed to be zero */

CODsolflux=u[0]+u[5];

if ((Si_cst*(u[11]-u[10])) <=CODsolflux){          /* SI is constant, direct rain water (u[10]) can dilute SI only */
    y[1] = ((CODsolflux-Si_cst*(u[11]-u[10]))/u[11])*Sa_fr;
    y[2] = ((CODsolflux-Si_cst*(u[11]-u[10]))/u[11])*Sf_fr;
    y[3] = Si_cst*(u[11]-u[10])/u[11];
    }
else if ((Si_cst*(u[11]-u[10])) > CODsolflux){
    y[1] = 0;
    y[2] = 0;
    y[3] = CODsolflux/u[11];
    }
y[4] = Snh_fr*(u[2]+u[7])/u[11];                    /* SNH defined as the result of combining the ammonium N fluxes */
y[5] = 0;                                           /* SN2 is assumed to be zero */
y[6] = Sno_fr*(u[3]+u[8])/u[11];                   /* SNO defined as the result of combining the inorganic  N fluxes */
y[7] = Spo4_fr*(u[4]+u[9])/u[11];                  /* SPO4 defined as the result of combining the phosphate P fluxes */
y[8] = 7.0;                                         /* SALK is assumed to be constant and not limiting for the processes in the WWTP */   

y[9] = Xi_fr*(u[1]+u[6])/u[11];                     /* XI defined as a fraction of the particulate COD */
y[10]= Xs_fr*(u[1]+u[6])/u[11];                     /* XS defined as a fraction of the particulate COD */
y[11]= Xbh_fr*(u[1]+u[6])/u[11];                    /* XBH defined as a fraction of the particulate COD */
y[12] = 0;                                          /* XPAO is assumed to be zero */
y[13] = 0;                                          /* XPP is assumed to be zero */
y[14] = 0;                                          /* XPHA is assumed to be zero */
y[15] = 0;                                          /* XBA is assumed to be zero */
y[16] = 0;                                          /* XMeOH is assumed to be zero */
y[17] = 0;                                          /* XMeP is assumed to be zero */

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
