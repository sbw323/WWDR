/*
 * asm1 fractionation model block 
 * Copyright: Xavier Flores-Alsina, Ulf Jeppsson, IEA, Lund University, Lund, Sweden
 *            Krist V Gernaey, DTU. Denmark
 * Modified by: Ramesh Saagi, IEA, Lund University, Sweden
 */ 

#define S_FUNCTION_NAME asm1_fractionation

#include "simstruc.h"
#include <math.h>


#define ASM1_FRACTIONS   ssGetArg(S,0)  /*  ASM1 fractions   */

/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 0);   /* number of continuous states                                                      */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states                                                        */
    ssSetNumInputs(        S, 7);  /* number of inputs                            (u[0] = CODsol; u[1] = CODpart, u[2] = SNH; u[3] = NOX; u[4] = PO4;u[5] = Q;)       */
    ssSetNumOutputs(       S, 26);  /* number of outputs                           (y[0] = SI; y[1] = SS; y[2] = XI; y[3] = XS; y[4] = XBH; y[5] = XBA; y[6] = XP; y[7] = SO; y[8] = SNO; y[9] = SNH; y [10] = SND; y[11] = XND; y[12] = SALK, y[13] = VSS; y [14] = Q; y[15] = Temp; y[16] onwards N variables and dummies*/
    ssSetDirectFeedThrough(S, 1);   /* direct feedthrough flag                                                          */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                                                           */
    ssSetNumSFcnParams(    S, 1);   /* number of input arguments                    (ASM1_FRACTIONS)         */
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

double SI_cst, XI_fr, XS_fr, XBH_fr, XBA_fr, XP_fr, SNO_fr, SNH_fr, SND_fr, XND_fr, Norg_rem, iXB, iXI;
double CODsolflux;
int i;

/* load the ASM1 component fractions */

SI_cst  =  mxGetPr(ASM1_FRACTIONS)[0];  
XI_fr   =  mxGetPr(ASM1_FRACTIONS)[1];                      
XS_fr   =  mxGetPr(ASM1_FRACTIONS)[2];                   
XBH_fr  =  mxGetPr(ASM1_FRACTIONS)[3]; 
XBA_fr  =  mxGetPr(ASM1_FRACTIONS)[4]; 
XP_fr  =  mxGetPr(ASM1_FRACTIONS)[5]; 
SNO_fr   = mxGetPr(ASM1_FRACTIONS)[6];                              /* SNO as fraction of inorganic N (strictly speaking not needed, but opens possibilities 
                                                                    for developing influent models considering both nitrate and nitrite) */
SNH_fr  =  mxGetPr(ASM1_FRACTIONS)[7]; 
SND_fr  =  mxGetPr(ASM1_FRACTIONS)[8]; 
XND_fr  =  mxGetPr(ASM1_FRACTIONS)[9]; 

iXB=0.0860; 
iXI=0.0600;
                
if (u[5]< 0.1){
    for(i=0;i<26;i++){
        y[i]=0;}
    y[15] = u[6];                                   /* Temperature */
}

else {

CODsolflux=u[0];
if (SI_cst*u[5] <=CODsolflux){          /* SI is constant*/
    y[0] = SI_cst;
    y[1] = ((CODsolflux-SI_cst*u[5])/u[5]);
    }
else if (SI_cst*u[5]>CODsolflux){
    y[0] = CODsolflux/u[5];
    y[1] = 0;
    }
y[2]= XI_fr*u[1]/u[5];                     /* XI defined as a fraction of the particulate COD */
y[3]= XS_fr*u[1]/u[5];                     /* XS defined as a fraction of the particulate COD */
y[4]= XBH_fr*u[1]/u[5];                    /* XBH defined as a fraction of the particulate COD */
y[5]= XBA_fr*u[1]/u[5];                    /* XBA defined as a fraction of the particulate COD */
y[6]= XP_fr*u[1]/u[5];                    /* XP defined as a fraction of the particulate COD */
y[7]=0;                                     /* SO is assumed to be zero */
y[8]=0;                                     /* SNO is assumed to be zero */
y[9] = SNH_fr*u[2]/u[5];                    /* SNH defined as the result of combining the ammonium N fluxes */
Norg_rem = u[3]-u[2]-((iXB*(XBH_fr+XBA_fr)+iXI*(XI_fr+XP_fr))*u[1]); /* Remaining organic nitrogen: TKN-NH4-Ncontent in XBH,XBa, XI, XP */
if (Norg_rem <= 0) {
        y[10]=0;
        y[11]=0;}
else {
y[10] = SND_fr*Norg_rem/u[5];                   /* SND as a fraction of organic nitrogen (TKN-NH4). Nitrogen component in XBH, XBA, XI and XP is also removed */
y[11] = XND_fr*Norg_rem/u[5];                  /* XND as a fraction of organic nitrogen (TKN-NH4). Nitrogen component in XBH, XBA, XI and XP is also removed */
}
y[12] = 7.0;                                       /* SALK is assumed to be constant and not limiting for the processes in the WWTP */   
y[13]=  (0.625*(XI_fr+XS_fr+XP_fr)+0.625*(XBH_fr+XBA_fr))*u[1]/u[5];                                       /* VSS */
y[14]=u[5];                                     /* flow rate */
y[15] = u[6];                                   /* Temperature */
y[16]=0;                                        /* SNO2 */
y[17]=0;                                        /* SNO */
y[18]=0;                                        /* SN20 */
y[19]=0;                                        /* SN2 */
y[20]=0;                                        /* XBA2 */
y[21]=0;                                        /* Dummy 1 */
y[22]=0;                                        /* Dummy 2 */
y[23]=0;                                        /* Dummy 3 */
y[24]=0;                                        /* Dummy 4 */
y[25]=(0.625*(XI_fr+XS_fr+XP_fr)+0.625*(XBH_fr+XBA_fr))*u[1]*0.124/u[5];                                      /* ISS. */
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
