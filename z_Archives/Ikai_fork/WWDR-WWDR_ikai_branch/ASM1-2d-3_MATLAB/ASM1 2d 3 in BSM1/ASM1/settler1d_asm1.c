/*
 * settler1d_reac is a C-file S-function for defining a reactive 10 layer sedimentation tank model
 * Compatibility: ASM1 model
 * The model is developed based on the settler1dv4.c model of Ulf Jeppsson (IEA, LTH, Sweden)
 *
 * 25 October 2003
 * Krist V. Gernaey, CAPEC, Dept. of Chemical Engineering, DTU, Denmark
 *
 * This file has been modified by Xavier Flores-Alsina
 * July, 2010
 * IEA, Lund University, Lund, Sweden

 */

#define S_FUNCTION_NAME settler1d_asm1

#include "simstruc.h"
#include <math.h>



#define XINIT   ssGetArg(S,0)   /* initial values                    */
#define SEDPAR	 ssGetArg(S,1)  /* parameters sedimentation model    */
#define DIM	    ssGetArg(S,2)   /* dimensions clarifier              */
#define LAYER   ssGetArg(S,3)   /* Number of layers                  */
#define ASMPAR	 ssGetArg(S,4)  /* parameters activated sludge model */
#define TEMPMODEL  ssGetArg(S,5)
#define DECAY  ssGetArg(S,6)    /* e- dependency decays */
#define SETTLER  ssGetArg(S,7)  /* reactive settler*/


/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(  S, 200);   /* number of continuous states */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    ssSetNumInputs(       S, 23);   /* number of inputs */
    ssSetNumOutputs(     S, 203);   /* number of outputs: 140 states (13 ASM1 components + TSS for each layer) + effluent flow rate + return sludge flow rate + waste sludge flow rate */
    ssSetDirectFeedThrough(S, 1);   /* direct feedthrough flag               */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumSFcnParams(    S, 8);   /* number of input arguments             */
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
int i;

for (i = 0; i < 200; i++) {
   x0[i] = mxGetPr(XINIT)[i];
}

}

/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{
double tempmodel;
int i,j,k;

tempmodel  = mxGetPr(TEMPMODEL)[0];


/* Clarifier state variables */
// 	for (i=0;i<10;i++){
// 		for (j=0;j<20;j++){
// 		y[(i*20)+j]=x[i+j*10];
// 		}
// 	}

    /* Clarifier state variables */
	for (i=0;i<10;i++){
		for (j=0;j<15;j++){
		y[(i*20)+j]=x[i+j*10];
		}
	    if (tempmodel < 0.5) {  
        y[(i*20)+15]=u[14];
        }
        else {
        y[(i*20)+15]=x[i+14*10];
        }
        for (k=15;k<20;k++){
		y[(i*20)+k]=x[i+k*10];
		}
    }


    /* Flow rates out of the clarifier */
   y[200]=u[14]-u[21]-u[22];     /* Q_e  */
   y[201]=u[21];                 /* Q_r  */
   y[202]=u[22];                 /* Q_w  */
  
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

double v0_max, v0, r_h, r_p, f_ns, X_t, area, h, feedlayer, volume;
double Q_f, Q_e, Q_u, v_up, v_dn, v_in, eps;
int i;

double vs[10];
double Js[11];
double Jstemp[10];
double Jflow[11];

double mu_H, K_S, K_OH, K_NO, b_H, mu_A, K_NH, K_OA, b_A, ny_g, k_a, k_h, K_X, ny_h;
double Y_H, Y_A, f_P, i_XB, i_XP, X_I2TSS, X_S2TSS, X_BH2TSS, X_BA2TSS, X_P2TSS ;
double hH_NO3_end, hA_NO3_end;


double proc1[10], proc2[10], proc3[10], proc4[10], proc5[10], proc6[10], proc7[10], proc8[10];
double reac1[10], reac2[10], reac3[10], reac4[10], reac5[10], reac6[10], reac7[10], reac8[10];
double reac9[10], reac10[10], reac11[10], reac12[10], reac13[10], reac14[10];
double reac16[10], reac17[10], reac18[10], reac19[10], reac20[10];
double mu_H_T[10], b_H_T [10], mu_A_T[10], b_A_T [10], k_h_T [10], k_a_T [10];

double xtemp[200];

double decay_switch;
double reactive_settler;
double tempmodel;

v0_max = mxGetPr(SEDPAR)[0];
v0 = mxGetPr(SEDPAR)[1];
r_h = mxGetPr(SEDPAR)[2];
r_p = mxGetPr(SEDPAR)[3];
f_ns = mxGetPr(SEDPAR)[4];
X_t = mxGetPr(SEDPAR)[5];
area = mxGetPr(DIM)[0];
h = mxGetPr(DIM)[1]/mxGetPr(LAYER)[1];
feedlayer = mxGetPr(LAYER)[0];
volume = area*mxGetPr(DIM)[1];

/* ASM1: Stoichiometric parameters */
mu_H = mxGetPr(ASMPAR)[0];
K_S = mxGetPr(ASMPAR)[1];
K_OH = mxGetPr(ASMPAR)[2];
K_NO = mxGetPr(ASMPAR)[3];
b_H = mxGetPr(ASMPAR)[4];
mu_A = mxGetPr(ASMPAR)[5];
K_NH = mxGetPr(ASMPAR)[6];
K_OA = mxGetPr(ASMPAR)[7];
b_A = mxGetPr(ASMPAR)[8];
ny_g = mxGetPr(ASMPAR)[9];
k_a = mxGetPr(ASMPAR)[10];
k_h = mxGetPr(ASMPAR)[11];
K_X = mxGetPr(ASMPAR)[12];
ny_h = mxGetPr(ASMPAR)[13];

Y_H = mxGetPr(ASMPAR)[14];
Y_A = mxGetPr(ASMPAR)[15];
f_P = mxGetPr(ASMPAR)[16];
i_XB = mxGetPr(ASMPAR)[17];
i_XP = mxGetPr(ASMPAR)[18];
X_I2TSS = mxGetPr(ASMPAR)[19];
X_S2TSS = mxGetPr(ASMPAR)[20];
X_BH2TSS = mxGetPr(ASMPAR)[21];
X_BA2TSS = mxGetPr(ASMPAR)[22];
X_P2TSS = mxGetPr(ASMPAR)[23];

hH_NO3_end = mxGetPr(ASMPAR)[24];
hA_NO3_end = mxGetPr(ASMPAR)[25];

decay_switch = mxGetPr(DECAY)[0];
reactive_settler = mxGetPr(SETTLER)[0];
tempmodel  = mxGetPr(TEMPMODEL)[0];

eps = 0.01;
v_in = u[14]/area;
Q_f = u[14];
Q_u = u[21] + u[22];
Q_e = u[14] - Q_u;
v_up = Q_e/area;
v_dn = Q_u/area;

for (i = 0; i < 200; i++) {
   if (x[i] < 0.0)
     xtemp[i] = 0.0;
   else
     xtemp[i] = x[i];
}

/* calculation of the sedimentation velocity for each of the layers */
for (i = 0; i < 10; i++) {
   vs[i] = v0*(exp(-r_h*(xtemp[i+130]-f_ns*u[13]))-exp(-r_p*(xtemp[i+130]-f_ns*u[13])));      /* u[13] = influent SS concentration */
   if (vs[i] > v0_max)     
      vs[i] = v0_max;
   else if (vs[i] < 0.0)
      vs[i] = 0.0;
}

/* calculation of the sludge flux due to sedimentation for each layer (not taking into account X limit) */
for (i = 0; i < 10; i++) {
   Jstemp[i] = vs[i]*xtemp[i+130];
}

/* calculation of the sludge flux due to the liquid flow (upflow or downflow, depending on layer) */
for (i = 0; i < 11; i++) {
   if (i < (feedlayer-eps))     
      Jflow[i] = v_up*xtemp[i+130];
   else
      Jflow[i] = v_dn*xtemp[i-1+130];
}

/* calculation of the sludge flux due to sedimentation for each layer */
Js[0] = 0.0;
Js[10] = 0.0;
for (i = 0; i < 9; i++) {
   if ((i < (feedlayer-1-eps)) && (xtemp[i+1+130] <= X_t))
      Js[i+1] = Jstemp[i];
   else if (Jstemp[i] < Jstemp[i+1])     
      Js[i+1] = Jstemp[i];
   else
      Js[i+1] = Jstemp[i+1];
}

/* Reaction rates ASM1 model */

for (i = 0; i < 10; i++) {
    
if (tempmodel < 0.5) {                            
   
mu_H_T[i]= mu_H*exp((log(mu_H/3.0)/5.0)*(u[15]-15.0)); /* Compensation from the temperature at the influent of the reactor */
b_H_T [i] = b_H*exp((log(b_H/0.2)/5.0)*(u[15]-15.0));
mu_A_T[i]= mu_A*exp((log(mu_A/0.3)/5.0)*(u[15]-15.0));
b_A_T [i]= b_A*exp((log(b_A/0.03)/5.0)*(u[15]-15.0));
k_h_T [i]= k_h*exp((log(k_h/2.5)/5.0)*(u[15]-15.0));
k_a_T [i]= k_a*exp((log(k_a/0.04)/5.0)*(u[15]-15.0));

}
else {
   
mu_H_T[i] = mu_H*exp((log(mu_H/3.0)/5.0)*(x[i+150]-15.0)); /* Compensation from the current temperature in the reactor */
b_H_T [i] = b_H*exp((log(b_H/0.2)/5.0)*(x[i+150]-15.0));
mu_A_T[i] = mu_A*exp((log(mu_A/0.3)/5.0)*(x[i+150]-15.0));
b_A_T [i] = b_A*exp((log(b_A/0.03)/5.0)*(x[i+150]-15.0));
k_h_T [i]= k_h*exp((log(k_h/2.5)/5.0)*(x[i+150]-15.0));
k_a_T [i]= k_a*exp((log(k_a/0.04)/5.0)*(x[i+150]-15.0));

}

if (decay_switch > 0.5) {
    
proc1[i] = mu_H_T[i]*(xtemp[i+10]/(K_S+xtemp[i+10]))*(xtemp[i+70]/(K_OH+xtemp[i+70]))*xtemp[i+40];
proc2[i] = mu_H_T[i]*(xtemp[i+10]/(K_S+xtemp[i+10]))*(K_OH/(K_OH+xtemp[i+70]))*(xtemp[i+80]/(K_NO+xtemp[i+80]))*ny_g*xtemp[i+40];
proc3[i] = mu_A_T[i]*(xtemp[i+90]/(K_NH+xtemp[i+90]))*(xtemp[i+70]/(K_OA+xtemp[i+70]))*xtemp[i+50];
proc4[i] = b_H_T [i]*(xtemp[i+70]/(K_OH+xtemp[i+70])+hH_NO3_end*K_OH/(K_OH+xtemp[i+70])*xtemp[i+80]/(K_NO+xtemp[i+80]))*xtemp[i+40];
proc5[i] = b_A_T [i]*(xtemp[i+70]/(K_OH+xtemp[i+70])+hH_NO3_end*K_OH/(K_OH+xtemp[i+70])*xtemp[i+80]/(K_NO+xtemp[i+80]))*xtemp[i+50];
proc6[i] = k_a_T[i]*xtemp[i+100]*xtemp[i+40];
proc7[i] = k_h_T[i]*((xtemp[i+30]/xtemp[i+40])/(K_X+(xtemp[i+30]/xtemp[i+40])))*((xtemp[i+70]/(K_OH+xtemp[i+70]))+ny_h*(K_OH/(K_OH+xtemp[i+70]))*(xtemp[i+80]/(K_NO+xtemp[i+80])))*xtemp[i+40];
proc8[i] = proc7[i]*xtemp[i+110]/xtemp[i+30];
}
else if (decay_switch  < 0.5) {

proc1[i] = mu_H_T[i]*(xtemp[i+10]/(K_S+xtemp[i+10]))*(xtemp[i+70]/(K_OH+xtemp[i+70]))*xtemp[i+40];
proc2[i] = mu_H_T[i]*(xtemp[i+10]/(K_S+xtemp[i+10]))*(K_OH/(K_OH+xtemp[i+70]))*(xtemp[i+80]/(K_NO+xtemp[i+80]))*ny_g*xtemp[i+40];
proc3[i] = mu_A_T[i]*(xtemp[i+90]/(K_NH+xtemp[i+90]))*(xtemp[i+70]/(K_OA+xtemp[i+70]))*xtemp[i+50];
proc4[i] = b_H_T [i]*xtemp[i+40];
proc5[i] = b_A_T [i]*xtemp[i+50];
proc6[i] = k_a_T[i]*xtemp[i+100]*xtemp[i+40];
proc7[i] = k_h_T[i]*((xtemp[i+30]/xtemp[i+40])/(K_X+(xtemp[i+30]/xtemp[i+40])))*((xtemp[i+70]/(K_OH+xtemp[i+70]))+ny_h*(K_OH/(K_OH+xtemp[i+70]))*(xtemp[i+80]/(K_NO+xtemp[i+80])))*xtemp[i+40];
proc8[i] = proc7[i]*xtemp[i+110]/xtemp[i+30];

}
    

if (reactive_settler > 0.5) {
reac1[i] = 0.0;
reac2[i] = (-proc1[i]-proc2[i])/Y_H+proc7[i];
reac3[i] = 0.0;
reac4[i] = (1.0-f_P)*(proc4[i]+proc5[i])-proc7[i];
reac5[i] = proc1[i]+proc2[i]-proc4[i];
reac6[i] = proc3[i]-proc5[i];
reac7[i] = f_P*(proc4[i]+proc5[i]);
reac8[i] = -((1.0-Y_H)/Y_H)*proc1[i]-((4.57-Y_A)/Y_A)*proc3[i];
reac9[i] = -((1.0-Y_H)/(2.86*Y_H))*proc2[i]+proc3[i]/Y_A;
reac10[i] = -i_XB*(proc1[i]+proc2[i])-(i_XB+(1.0/Y_A))*proc3[i]+proc6[i];
reac11[i] = -proc6[i]+proc8[i];
reac12[i] = (i_XB-f_P*i_XP)*(proc4[i]+proc5[i])-proc8[i];
reac13[i] = -i_XB/14.0*proc1[i]+((1.0-Y_H)/(14.0*2.86*Y_H)-(i_XB/14.0))*proc2[i]-((i_XB/14.0)+1.0/(7.0*Y_A))*proc3[i]+proc6[i]/14.0;
reac14[i] = X_I2TSS*reac3[i]+X_S2TSS*reac4[i]+X_BH2TSS*reac5[i]+X_BA2TSS*reac6[i]+X_P2TSS*reac7[i];

reac16[i] = 0.0;
reac17[i] = 0.0;
reac18[i] = 0.0;
reac19[i] = 0.0;
reac20[i] = 0.0;

}
else if (reactive_settler  < 0.5) {

reac1[i] = 0.0;
reac2[i] = 0.0;
reac3[i] = 0.0;
reac4[i] = 0.0;
reac5[i] = 0.0;
reac6[i] = 0.0;
reac7[i] = 0.0;
reac8[i] = 0.0;
reac9[i] = 0.0;
reac10[i] = 0.0;
reac11[i] = 0.0;
reac12[i] = 0.0;
reac13[i] = 0.0;
reac14[i] = 0.0;

reac16[i] = 0.0;
reac17[i] = 0.0;
reac18[i] = 0.0;
reac19[i] = 0.0;
reac20[i] = 0.0;

}
}

/* ASM1 model component balances over the layers */
/* ASM1: [Si Ss Xi Xs Xbh Xba Xp So Sno Snh Snd Xnd Salk TSS Q_in]   */

/* soluble component S_I */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i]  = (-v_up*xtemp[i] +v_up*xtemp[i+1])/h+reac1[i];                              
   else if (i > (feedlayer-eps)) 
      dx[i]  = (v_dn*xtemp[i-1] -v_dn*xtemp[i])/h+reac1[i];
   else
      dx[i]  = (v_in*u[0] -v_up*xtemp[i] -v_dn*xtemp[i])/h+reac1[i];
}

/* soluble component S_S */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps))
      dx[i+10]  = (-v_up*xtemp[i+10] +v_up*xtemp[i+1+10])/h +reac2[i];
   else if (i > (feedlayer-eps)) 
      dx[i+10]  = (v_dn*xtemp[i-1+10] -v_dn*xtemp[i+10])/h +reac2[i];
   else
      dx[i+10]  = (v_in*u[1] -v_up*xtemp[i+10] -v_dn*xtemp[i+10])/h +reac2[i];
}

/* particulate component X_I */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+20] = ((xtemp[i+20]/xtemp[i+130])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+20]/xtemp[i-1+130])*Js[i]+(xtemp[i+1+20]/xtemp[i+1+130])*Jflow[i+1])/h +reac3[i];
   else if (i > (feedlayer-eps)) 
      dx[i+20] = ((xtemp[i+20]/xtemp[i+130])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+20]/xtemp[i-1+130])*(Jflow[i]+Js[i]))/h +reac3[i];
   else
      dx[i+20] = ((xtemp[i+20]/xtemp[i+130])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+20]/xtemp[i-1+130])*Js[i]+v_in*u[2])/h +reac3[i];
}

/* particulate component X_S */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
       dx[i+30] = ((xtemp[i+30]/xtemp[i+130])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+30]/xtemp[i-1+130])*Js[i]+(xtemp[i+1+30]/xtemp[i+1+130])*Jflow[i+1])/h +reac4[i];
   else if (i > (feedlayer-eps)) 
       dx[i+30] = ((xtemp[i+30]/xtemp[i+130])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+30]/xtemp[i-1+130])*(Jflow[i]+Js[i]))/h +reac4[i];
   else
       dx[i+30] = ((xtemp[i+30]/xtemp[i+130])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+30]/xtemp[i-1+130])*Js[i]+v_in*u[3])/h +reac4[i];
}

/* particulate component X_BH */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
       dx[i+40] = ((xtemp[i+40]/xtemp[i+130])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+40]/xtemp[i-1+130])*Js[i]+(xtemp[i+1+40]/xtemp[i+1+130])*Jflow[i+1])/h +reac5[i];
   else if (i > (feedlayer-eps)) 
       dx[i+40] = ((xtemp[i+40]/xtemp[i+130])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+40]/xtemp[i-1+130])*(Jflow[i]+Js[i]))/h +reac5[i];
   else
       dx[i+40] = ((xtemp[i+40]/xtemp[i+130])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+40]/xtemp[i-1+130])*Js[i]+v_in*u[4])/h +reac5[i];
}

/* particulate component X_BA */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
       dx[i+50] = ((xtemp[i+50]/xtemp[i+130])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+50]/xtemp[i-1+130])*Js[i]+(xtemp[i+1+50]/xtemp[i+1+130])*Jflow[i+1])/h +reac6[i];
   else if (i > (feedlayer-eps)) 
       dx[i+50] = ((xtemp[i+50]/xtemp[i+130])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+50]/xtemp[i-1+130])*(Jflow[i]+Js[i]))/h +reac6[i];
   else
       dx[i+50] = ((xtemp[i+50]/xtemp[i+130])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+50]/xtemp[i-1+130])*Js[i]+v_in*u[5])/h +reac6[i];
}

/* particulate component X_P */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
       dx[i+60] = ((xtemp[i+60]/xtemp[i+130])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+60]/xtemp[i-1+130])*Js[i]+(xtemp[i+1+60]/xtemp[i+1+130])*Jflow[i+1])/h +reac7[i];
   else if (i > (feedlayer-eps)) 
       dx[i+60] = ((xtemp[i+60]/xtemp[i+130])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+60]/xtemp[i-1+130])*(Jflow[i]+Js[i]))/h +reac7[i];
   else
       dx[i+60] = ((xtemp[i+60]/xtemp[i+130])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+60]/xtemp[i-1+130])*Js[i]+v_in*u[6])/h +reac7[i];
}

/* soluble component S_O */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps))
      dx[i+70]  = (-v_up*xtemp[i+70] +v_up*xtemp[i+1+70])/h +reac8[i];
   else if (i > (feedlayer-eps)) 
      dx[i+70]  = (v_dn*xtemp[i-1+70] -v_dn*xtemp[i+70])/h +reac8[i];
   else
      dx[i+70]  = (v_in*u[7] -v_up*xtemp[i+70] -v_dn*xtemp[i+70])/h +reac8[i];
}

/* soluble component S_NO */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps))
      dx[i+80]  = (-v_up*xtemp[i+80] +v_up*xtemp[i+1+80])/h +reac9[i];
   else if (i > (feedlayer-eps)) 
      dx[i+80]  = (v_dn*xtemp[i-1+80] -v_dn*xtemp[i+80])/h +reac9[i];
   else
      dx[i+80]  = (v_in*u[8] -v_up*xtemp[i+80] -v_dn*xtemp[i+80])/h +reac9[i];
}

/* soluble component S_NH */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps))
      dx[i+90]  = (-v_up*xtemp[i+90] +v_up*xtemp[i+1+90])/h +reac10[i];
   else if (i > (feedlayer-eps)) 
      dx[i+90]  = (v_dn*xtemp[i-1+90] -v_dn*xtemp[i+90])/h +reac10[i];
   else
      dx[i+90]  = (v_in*u[9] -v_up*xtemp[i+90] -v_dn*xtemp[i+90])/h +reac10[i];
}

/* soluble component S_ND */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps))
      dx[i+100]  = (-v_up*xtemp[i+100] +v_up*xtemp[i+1+100])/h +reac11[i];
   else if (i > (feedlayer-eps)) 
      dx[i+100]  = (v_dn*xtemp[i-1+100] -v_dn*xtemp[i+100])/h +reac11[i];
   else
      dx[i+100]  = (v_in*u[10] -v_up*xtemp[i+100] -v_dn*xtemp[i+100])/h +reac11[i];
}

/* particulate component X_ND */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+110] = ((xtemp[i+110]/xtemp[i+130])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+110]/xtemp[i-1+130])*Js[i]+(xtemp[i+1+110]/xtemp[i+1+130])*Jflow[i+1])/h +reac12[i];
   else if (i > (feedlayer-eps)) 
      dx[i+110] = ((xtemp[i+110]/xtemp[i+130])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+110]/xtemp[i-1+130])*(Jflow[i]+Js[i]))/h +reac12[i];
   else
      dx[i+110] = ((xtemp[i+110]/xtemp[i+130])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+110]/xtemp[i-1+130])*Js[i]+v_in*u[11])/h +reac12[i];
}

/* soluble component S_ALK */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps))
      dx[i+120]  = (-v_up*xtemp[i+120] +v_up*xtemp[i+1+120])/h +reac13[i];
   else if (i > (feedlayer-eps)) 
      dx[i+120]  = (v_dn*xtemp[i-1+120] -v_dn*xtemp[i+120])/h +reac13[i];
   else
      dx[i+120]  = (v_in*u[12] -v_up*xtemp[i+120] -v_dn*xtemp[i+120])/h +reac13[i];
}

/* particulate component X_TSS */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+130] = ((-Jflow[i]-Js[i+1])+Js[i]+Jflow[i+1])/h +reac14[i];
   else if (i > (feedlayer-eps)) 
      dx[i+130] = ((-Jflow[i+1]-Js[i+1])+(Jflow[i]+Js[i]))/h +reac14[i];
   else
      dx[i+130] = ((-Jflow[i]-Jflow[i+1]-Js[i+1])+Js[i]+v_in*u[13])/h +reac14[i];
}

/* Sol. comp. T     ; ASM1 */

for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps))
      dx[i+140]  = (-v_up*xtemp[i+140] +v_up*xtemp[i+1+140])/h ;
   else if (i > (feedlayer-eps)) 
      dx[i+140]  = (v_dn*xtemp[i-1+140] -v_dn*xtemp[i+140])/h ;
   else
      dx[i+140]  = (v_in*u[15] -v_up*xtemp[i+140] -v_dn*xtemp[i+140])/h ;
}


/* Sol. comp. D1     ; ASM1 */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps))
      dx[i+150]  = (-v_up*xtemp[i+150] +v_up*xtemp[i+1+150])/h +reac16[i];
   else if (i > (feedlayer-eps)) 
      dx[i+150]  = (v_dn*xtemp[i-1+150] -v_dn*xtemp[i+150])/h +reac16[i];
   else
      dx[i+150]  = (v_in*u[16] -v_up*xtemp[i+150] -v_dn*xtemp[i+150])/h +reac16[i];
}

/* Sol. comp. D2     ; ASM1 */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps))
      dx[i+160]  = (-v_up*xtemp[i+160] +v_up*xtemp[i+1+160])/h +reac17[i];
   else if (i > (feedlayer-eps)) 
      dx[i+160]  = (v_dn*xtemp[i-1+160] -v_dn*xtemp[i+160])/h +reac17[i];
   else
      dx[i+160]  = (v_in*u[17] -v_up*xtemp[i+160] -v_dn*xtemp[i+160])/h +reac17[i];
}
   
/* Sol. comp. D3     ; ASM1 */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps))
      dx[i+170]  = (-v_up*xtemp[i+170] +v_up*xtemp[i+1+170])/h +reac18[i];
   else if (i > (feedlayer-eps)) 
      dx[i+170]  = (v_dn*xtemp[i-1+170] -v_dn*xtemp[i+170])/h +reac18[i];
   else
      dx[i+170]  = (v_in*u[18] -v_up*xtemp[i+170] -v_dn*xtemp[i+170])/h +reac18[i];
}   

/* Part. comp. D4    ; ASM1 */
      dx[180] = ((x[180]/x[130])*(-Jflow[0]-Js[1])+(x[181]/x[131])*Jflow[1])/h +reac19[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+180] = ((xtemp[i+180]/xtemp[i+130])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+180]/xtemp[i-1+130])*Js[i]+(xtemp[i+1+180]/xtemp[i+1+130])*Jflow[i+1])/h +reac19[i];
   else if (i > (feedlayer-eps)) 
      dx[i+180] = ((xtemp[i+180]/xtemp[i+130])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+180]/xtemp[i-1+130])*(Jflow[i]+Js[i]))/h +reac19[i];
   else
      dx[i+180] = ((xtemp[i+180]/xtemp[i+130])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+180]/xtemp[i-1+130])*Js[i]+v_in*u[19])/h +reac19[i];
}  

 /* Part. comp. D5    ; ASM1 */
      dx[190] = ((x[190]/x[130])*(-Jflow[0]-Js[1])+(x[191]/x[131])*Jflow[1])/h +reac20[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+190] = ((xtemp[i+190]/xtemp[i+130])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+190]/xtemp[i-1+130])*Js[i]+(xtemp[i+1+190]/xtemp[i+1+130])*Jflow[i+1])/h +reac20[i];
   else if (i > (feedlayer-eps)) 
      dx[i+190] = ((xtemp[i+190]/xtemp[i+130])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+190]/xtemp[i-1+130])*(Jflow[i]+Js[i]))/h +reac20[i];
   else
      dx[i+190] = ((xtemp[i+190]/xtemp[i+130])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+190]/xtemp[i-1+130])*Js[i]+v_in*u[20])/h +reac20[i]; 
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
