/*
 * settler1d_reac is a C-file S-function for defining a 10 layer sedimentation tank model
 * Compatibility: ASM2d model
 *
 * 12 February 2004
 * Krist V. Gernaey, CAPEC, Dept. of Chemical Engineering, DTU, Denmark
 *
 */

#define S_FUNCTION_NAME settler1_asm2d

#include "simstruc.h"
#include <math.h>

#define XINIT     ssGetArg(S,0)   /* initial values                */
#define SEDPAR	  ssGetArg(S,1)   /* parameters sedimentation model */
#define DIM	      ssGetArg(S,2)   /*  */
#define LAYER	  ssGetArg(S,3)   /*  */
#define ASMPAR	  ssGetArg(S,4)   /* parameters activated sludge model */
#define DECAY	  ssGetArg(S,5)   /* decay e- dependent */
#define SETTLER	  ssGetArg(S,6)   /* reactive settler */
#define TEMPMODEL  ssGetArg(S,7)  /* temperature propagation */

/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 250);  /* number of continuous states, 19 ASM2d components for each settler layer + T + 5 dummy states */
    ssSetNumDiscStates(    S, 0);    /* number of discrete states              */
    ssSetNumInputs(        S, 28);   /* number of inputs, 19 components + flow rate + T +  5 dummy states + return sludge flow rate + waste sludge flow rate */
    ssSetNumOutputs(       S, 316);  /* number of outputs                      */
    ssSetDirectFeedThrough(S, 1);    /* direct feedthrough flag                */
    ssSetNumSampleTimes(   S, 1);    /* number of sample times                 */
    ssSetNumSFcnParams(    S, 8);    /* number of input arguments              */
    ssSetNumRWork(         S, 0);    /* number of real work vector elements    */
    ssSetNumIWork(         S, 0);    /* number of integer work vector elements */
    ssSetNumPWork(         S, 0);    /* number of pointer work vector elements */
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

for (i = 0; i < 250; i++) {
   x0[i] = mxGetPr(XINIT)[i];
}
}

/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(double *y, double *x, double *u, SimStruct *S, int tid)
{
  double gamma, gamma_eff;
  double tempmodel;
  int i;

  gamma = x[169]/u[16];        /* factor describing underflow vs. inflow TSS concentration ratio */
  gamma_eff = x[160]/u[16];    /* factor describing effluent vs. inflow TSS concentration ratio  */
  
  tempmodel = mxGetPr(TEMPMODEL)[0];

     /* layers as separate mixed tanks for soluble components */

     /* underflow; concentrations in underflow equal concentrations in bottom layer settler */
     y[0]=x[9];          /* S_O2    ; ASM2d */
     y[1]=x[19];         /* S_F     ; ASM2d */
     y[2]=x[29];         /* S_A     ; ASM2d */
     y[3]=x[39];         /* S_I     ; ASM2d */
     y[4]=x[49];         /* S_NH4   ; ASM2d */
     y[5]=x[59];         /* S_N2    ; ASM2d */
     y[6]=x[69];         /* S_NOX   ; ASM2d */
     y[7]=x[79];         /* S_PO4   ; ASM2d */
     y[8]=x[89];         /* S_ALK   ; ASM2d */
     y[9]=x[99];         /* X_I     ; ASM2d */
     y[10]=x[109];       /* X_S     ; ASM2d */
     y[11]=x[119];       /* X_H     ; ASM2d */
     y[12]=x[129];       /* X_PAO   ; ASM2d */
     y[13]=x[139];       /* X_PP    ; ASM2d */
     y[14]=x[149];       /* X_PHA   ; ASM2d */
     y[15]=x[159];       /* X_A     ; ASM2d */
     y[16]=x[169];       /* X_TSS   ; ASM2d */
     y[17]=x[179];       /* X_MeOH  ; ASM2d */
     y[18]=x[189];       /* X_MeP   ; ASM2d */
     y[19]=u[26];        /* Q_r, return sludge flow rate */
     
     if (tempmodel < 0.5)                     /* Temp */    
        y[20]=u[20];  
     else 
        y[20]=x[199];
     
     /* Dummy states */
     y[21]=x[209];       /* D1 */
     y[22]=x[219];       /* D2 */
     y[23]=x[229];       /* D3 */
     y[24]=x[239];       /* D4 */
     y[25]=x[249];       /* D5 */
     
     y[26]=u[27];        /* Q_w, waste sludge flow rate  */
  
     /* effluent; concentrations in effluent equal concentrations in top layer settler */
     y[27]=x[0];         /* S_O2    ; ASM2d */
     y[28]=x[10];        /* S_F     ; ASM2d */
     y[29]=x[20];        /* S_A     ; ASM2d */
     y[30]=x[30];        /* S_I     ; ASM2d */
     y[31]=x[40];        /* S_NH4   ; ASM2d */
     y[32]=x[50];        /* S_N2    ; ASM2d */
     y[33]=x[60];        /* S_NOX   ; ASM2d */
     y[34]=x[70];        /* S_PO4   ; ASM2d */
     y[35]=x[80];        /* S_ALK   ; ASM2d */
     y[36]=x[90];        /* X_I     ; ASM2d */
     y[37]=x[100];       /* X_S     ; ASM2d */
     y[38]=x[110];       /* X_H     ; ASM2d */
     y[39]=x[120];       /* X_PAO   ; ASM2d */
     y[40]=x[130];       /* X_PP    ; ASM2d */
     y[41]=x[140];       /* X_PHA   ; ASM2d */
     y[42]=x[150];       /* X_A     ; ASM2d */
     y[43]=x[160];       /* X_TSS   ; ASM2d */
     y[44]=x[170];       /* X_MeOH  ; ASM2d */
     y[45]=x[180];       /* X_MeP   ; ASM2d */
     y[46]=u[19]-u[26]-u[27];  /* Q_e, effluent flow rate */
     
      if (tempmodel < 0.5)                     /* Temp */    
        y[47]=u[20];                                  
      else 
         y[48]=x[190];
     
     /* Dummy states */
     y[49]=x[200];       /* D1 */
     y[50]=x[210];       /* D2 */
     y[51]=x[220];       /* D3 */
     y[52]=x[230];       /* D4 */
     y[53]=x[240];       /* D5 */
     
     
     /* internal TSS states */
     y[54]=x[160];    /* top layer */
     y[55]=x[161];
     y[56]=x[162];
     y[57]=x[163];
     y[58]=x[164];
     y[59]=x[165];
     y[60]=x[166];
     y[61]=x[167];
     y[62]=x[168];
     y[63]=x[169];   /* bottom layer */

     y[64]=gamma;
     y[65]=gamma_eff;

     /* states for each layer of the secondary clarifier */
     
     /* S_O2   ; ASM2d */   y[66]  = x[0];   /* layer 1  */
     /* S_F    ; ASM2d */   y[67]  = x[10];
     /* S_A    ; ASM2d */   y[68]  = x[20];
     /* S_I    ; ASM2d */   y[69]  = x[30];
     /* S_NH4  ; ASM2d */   y[70]  = x[40];
     /* S_N2   ; ASM2d */   y[71]  = x[50];
     /* S_NOX  ; ASM2d */   y[72]  = x[60];
     /* S_PO4  ; ASM2d */   y[73]  = x[70];
     /* S_ALK  ; ASM2d */   y[74]  = x[80];
     /* XI     ; ASM2d */   y[75]  = x[90];
     /* XS     ; ASM2d */   y[76]  = x[100];
     /* XH     ; ASM2d */   y[77]  = x[110];
     /* XPAO   ; ASM2d */   y[78]  = x[120];
     /* XPP    ; ASM2d */   y[79]  = x[130];
     /* XPHA   ; ASM2d */   y[80]  = x[140];
     /* XA     ; ASM2d */   y[81]  = x[150];
     /* XTSS   ; ASM2d */   y[82]  = x[160];
     /* MeOH   ; ASM2d */   y[83]  = x[170];
     /* MeP    ; ASM2d */   y[84]  = x[180];
     
     if (tempmodel < 0.5)                     /* Temp */    
        y[85]=u[20];                                  
      else 
        y[85]=x[190];
     
     /* D1   ; ASM2d */    y[86]  = x[200];
     /* D2   ; ASM2d */    y[87]  = x[210];
     /* D3   ; ASM2d */    y[88]  = x[220];
     /* D4   ; ASM2d */    y[89]  = x[230];
     /* D5   ; ASM2d */    y[90]  = x[240];
     
     //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
     
     /* S_O2   ; ASM2d */   y[91]  = x[1];   /* layer 2  */
     /* S_F    ; ASM2d */   y[92]  = x[11];
     /* S_A    ; ASM2d */   y[93]  = x[21];
     /* S_I    ; ASM2d */   y[94]  = x[31];
     /* S_NH4  ; ASM2d */   y[95]  = x[41];
     /* S_N2   ; ASM2d */   y[96]  = x[51];
     /* S_NOX  ; ASM2d */   y[97]  = x[61];
     /* S_PO4  ; ASM2d */   y[98]  = x[71];
     /* S_ALK  ; ASM2d */   y[99]  = x[81];
     /* XI     ; ASM2d */   y[100]  = x[91];
     /* XS     ; ASM2d */   y[101]  = x[101];
     /* XH     ; ASM2d */   y[102]  = x[111];
     /* XPAO   ; ASM2d */   y[103]  = x[121];
     /* XPP    ; ASM2d */   y[104]  = x[131];
     /* XPHA   ; ASM2d */   y[105]  = x[141];
     /* XA     ; ASM2d */   y[106]  = x[151];
     /* XTSS   ; ASM2d */   y[107]  = x[161];
     /* MeOH   ; ASM2d */   y[108]  = x[171];
     /* MeP    ; ASM2d */   y[109]  = x[181];
     
     if (tempmodel < 0.5)                     /* Temp */    
        y[110]=u[20];                                  
      else 
        y[110]=x[191];
     
     /* D1   ; ASM2d */    y[111]  = x[201];
     /* D2   ; ASM2d */    y[112]  = x[211];
     /* D3   ; ASM2d */    y[113]  = x[221];
     /* D4   ; ASM2d */    y[114]  = x[231];
     /* D5   ; ASM2d */    y[115]  = x[241];
     
     //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
     
     /* S_O2   ; ASM2d */   y[116]  = x[2];   /* layer 3  */
     /* S_F    ; ASM2d */   y[117]  = x[12];
     /* S_A    ; ASM2d */   y[118]  = x[22];
     /* S_I    ; ASM2d */   y[119]  = x[32];
     /* S_NH4  ; ASM2d */   y[120]  = x[42];
     /* S_N2   ; ASM2d */   y[121]  = x[52];
     /* S_NOX  ; ASM2d */   y[122]  = x[62];
     /* S_PO4  ; ASM2d */   y[123]  = x[72];
     /* S_ALK  ; ASM2d */   y[124]  = x[82];
     /* XI     ; ASM2d */   y[125]  = x[92];
     /* XS     ; ASM2d */   y[126]  = x[102];
     /* XH     ; ASM2d */   y[127]  = x[112];
     /* XPAO   ; ASM2d */   y[128]  = x[122];
     /* XPP    ; ASM2d */   y[129]  = x[132];
     /* XPHA   ; ASM2d */   y[130]  = x[142];
     /* XA     ; ASM2d */   y[131]  = x[152];
     /* XTSS   ; ASM2d */   y[132]  = x[162];
     /* MeOH   ; ASM2d */   y[133]  = x[172];
     /* MeP    ; ASM2d */   y[134]  = x[182];
     
     if (tempmodel < 0.5)                     /* Temp */    
        y[135]=u[20];                                  
      else 
        y[135]=x[192];
     
     /* D1   ; ASM2d */    y[136]  = x[202];
     /* D2   ; ASM2d */    y[137]  = x[212];
     /* D3   ; ASM2d */    y[138]  = x[222];
     /* D4   ; ASM2d */    y[139]  = x[232];
     /* D5   ; ASM2d */    y[140]  = x[242];
     
     //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
     
     /* S_O2   ; ASM2d */   y[141]  = x[3];   /* layer 4  */
     /* S_F    ; ASM2d */   y[142]  = x[13];
     /* S_A    ; ASM2d */   y[143]  = x[23];
     /* S_I    ; ASM2d */   y[144]  = x[33];
     /* S_NH4  ; ASM2d */   y[145]  = x[43];
     /* S_N2   ; ASM2d */   y[146]  = x[53];
     /* S_NOX  ; ASM2d */   y[147]  = x[63];
     /* S_PO4  ; ASM2d */   y[148]  = x[73];
     /* S_ALK  ; ASM2d */   y[149]  = x[83];
     /* XI     ; ASM2d */   y[150]  = x[93];
     /* XS     ; ASM2d */   y[151]  = x[103];
     /* XH     ; ASM2d */   y[152]  = x[113];
     /* XPAO   ; ASM2d */   y[153]  = x[123];
     /* XPP    ; ASM2d */   y[154]  = x[133];
     /* XPHA   ; ASM2d */   y[155]  = x[143];
     /* XA     ; ASM2d */   y[156]  = x[153];
     /* XTSS   ; ASM2d */   y[157]  = x[163];
     /* MeOH   ; ASM2d */   y[158]  = x[173];
     /* MeP    ; ASM2d */   y[159]  = x[183];
     
     if (tempmodel < 0.5)                     /* Temp */    
        y[160]=u[20];                                  
      else 
        y[160]=x[193];
     
     /* D1   ; ASM2d */    y[161]  = x[203];
     /* D2   ; ASM2d */    y[162]  = x[213];
     /* D3   ; ASM2d */    y[163]  = x[223];
     /* D4   ; ASM2d */    y[164]  = x[233];
     /* D5   ; ASM2d */    y[165]  = x[243];
    
     //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
     
     
     /* S_O2   ; ASM2d */   y[166]  = x[4];   /* layer 5  */
     /* S_F    ; ASM2d */   y[167]  = x[14];
     /* S_A    ; ASM2d */   y[168]  = x[24];
     /* S_I    ; ASM2d */   y[169]  = x[34];
     /* S_NH4  ; ASM2d */   y[170]  = x[44];
     /* S_N2   ; ASM2d */   y[171]  = x[54];
     /* S_NOX  ; ASM2d */   y[172]  = x[64];
     /* S_PO4  ; ASM2d */   y[173]  = x[74];
     /* S_ALK  ; ASM2d */   y[174]  = x[84];
     /* XI     ; ASM2d */   y[175]  = x[94];
     /* XS     ; ASM2d */   y[176]  = x[104];
     /* XH     ; ASM2d */   y[177]  = x[114];
     /* XPAO   ; ASM2d */   y[178]  = x[124];
     /* XPP    ; ASM2d */   y[179]  = x[134];
     /* XPHA   ; ASM2d */   y[180]  = x[144];
     /* XA     ; ASM2d */   y[181]  = x[154];
     /* XTSS   ; ASM2d */   y[182]  = x[164];
     /* MeOH   ; ASM2d */   y[183]  = x[174];
     /* MeP    ; ASM2d */   y[184]  = x[184];
     
     if (tempmodel < 0.5)                     /* Temp */    
        y[185]=u[20];                                  
      else 
       y[185]=x[194];
     
     /* D1   ; ASM2d */    y[186]  = x[204];
     /* D2   ; ASM2d */    y[187]  = x[214];
     /* D3   ; ASM2d */    y[188]  = x[224];
     /* D4   ; ASM2d */    y[189]  = x[234];
     /* D5   ; ASM2d */    y[190]  = x[244];
     
     //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
     
     /* S_O2   ; ASM2d */   y[191]  = x[5];   /* layer 6  */
     /* S_F    ; ASM2d */   y[192]  = x[15];
     /* S_A    ; ASM2d */   y[193]  = x[25];
     /* S_I    ; ASM2d */   y[194]  = x[35];
     /* S_NH4  ; ASM2d */   y[195]  = x[45];
     /* S_N2   ; ASM2d */   y[196]  = x[55];
     /* S_NOX  ; ASM2d */   y[197]  = x[65];
     /* S_PO4  ; ASM2d */   y[198]  = x[75];
     /* S_ALK  ; ASM2d */   y[199]  = x[85];
     /* XI     ; ASM2d */   y[200]  = x[95];
     /* XS     ; ASM2d */   y[201]  = x[105];
     /* XH     ; ASM2d */   y[202]  = x[115];
     /* XPAO   ; ASM2d */   y[203]  = x[125];
     /* XPP    ; ASM2d */   y[204]  = x[135];
     /* XPHA   ; ASM2d */   y[205]  = x[145];
     /* XA     ; ASM2d */   y[206]  = x[155];
     /* XTSS   ; ASM2d */   y[207]  = x[165];
     /* MeOH   ; ASM2d */   y[208]  = x[175];
     /* MeP    ; ASM2d */   y[209]  = x[185];
     
     if (tempmodel < 0.5)                     /* Temp */    
        y[210]=u[20];                                  
      else 
        y[210]=u[20];
     
     /* D1   ; ASM2d */    y[211]  = x[205];
     /* D2   ; ASM2d */    y[212]  = x[215];
     /* D3   ; ASM2d */    y[213]  = x[225];
     /* D4   ; ASM2d */    y[214]  = x[235];
     /* D5   ; ASM2d */    y[215]  = x[245];
     
     //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
     
     /* S_O2   ; ASM2d */   y[216]  = x[6];   /* layer 7  */
     /* S_F    ; ASM2d */   y[217]  = x[16];
     /* S_A    ; ASM2d */   y[218]  = x[26];
     /* S_I    ; ASM2d */   y[219]  = x[36];
     /* S_NH4  ; ASM2d */   y[220]  = x[46];
     /* S_N2   ; ASM2d */   y[221]  = x[56];
     /* S_NOX  ; ASM2d */   y[222]  = x[66];
     /* S_PO4  ; ASM2d */   y[223]  = x[76];
     /* S_ALK  ; ASM2d */   y[224]  = x[86];
     /* XI     ; ASM2d */   y[225]  = x[96];
     /* XS     ; ASM2d */   y[226]  = x[106];
     /* XH     ; ASM2d */   y[227]  = x[116];
     /* XPAO   ; ASM2d */   y[228]  = x[126];
     /* XPP    ; ASM2d */   y[229]  = x[136];
     /* XPHA   ; ASM2d */   y[230]  = x[146];
     /* XA     ; ASM2d */   y[231]  = x[156];
     /* XTSS   ; ASM2d */   y[232]  = x[166];
     /* MeOH   ; ASM2d */   y[233]  = x[176];
     /* MeP    ; ASM2d */   y[234]  = x[186];
     
     if (tempmodel < 0.5)                     /* Temp */    
        y[235]=u[20];                                  
      else 
        y[235]=x[196];
     
     /* D1   ; ASM2d */    y[236]  = x[206];
     /* D2   ; ASM2d */    y[237]  = x[216];
     /* D3   ; ASM2d */    y[238]  = x[226];
     /* D4   ; ASM2d */    y[239]  = x[236];
     /* D5   ; ASM2d */    y[240]  = x[246];
     
     //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
     
     /* S_O2   ; ASM2d */   y[241]  = x[7];  /* layer 8  */
     /* S_F    ; ASM2d */   y[242]  = x[17];
     /* S_A    ; ASM2d */   y[243]  = x[27];
     /* S_I    ; ASM2d */   y[244]  = x[37];
     /* S_NH4  ; ASM2d */   y[245]  = x[47];
     /* S_N2   ; ASM2d */   y[246]  = x[57];
     /* S_NOX  ; ASM2d */   y[247]  = x[67];
     /* S_PO4  ; ASM2d */   y[248]  = x[77];
     /* S_ALK  ; ASM2d */   y[249]  = x[87];
     /* XI     ; ASM2d */   y[250]  = x[97];
     /* XS     ; ASM2d */   y[251]  = x[107];
     /* XH     ; ASM2d */   y[252]  = x[117];
     /* XPAO   ; ASM2d */   y[253]  = x[127];
     /* XPP    ; ASM2d */   y[254]  = x[137];
     /* XPHA   ; ASM2d */   y[255]  = x[147];
     /* XA     ; ASM2d */   y[256]  = x[157];
     /* XTSS   ; ASM2d */   y[257]  = x[167];
     /* MeOH   ; ASM2d */   y[258]  = x[177];
     /* MeP    ; ASM2d */   y[259]  = x[187];
     
     if (tempmodel < 0.5)                     /* Temp */    
        y[260]=u[20];                                  
      else 
        y[260]=x[197];
     
     /* D1   ; ASM2d */    y[261]  = x[207];
     /* D2   ; ASM2d */    y[262]  = x[217];
     /* D3   ; ASM2d */    y[263]  = x[227];
     /* D4   ; ASM2d */    y[264]  = x[237];
     /* D5   ; ASM2d */    y[265]  = x[247];
     
     //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
     
     /* S_O2   ; ASM2d */   y[266]  = x[8];  /* layer 9  */
     /* S_F    ; ASM2d */   y[267]  = x[18];
     /* S_A    ; ASM2d */   y[268]  = x[28];
     /* S_I    ; ASM2d */   y[269]  = x[38];
     /* S_NH4  ; ASM2d */   y[270]  = x[48];
     /* S_N2   ; ASM2d */   y[271]  = x[58];
     /* S_NOX  ; ASM2d */   y[272]  = x[68];
     /* S_PO4  ; ASM2d */   y[273]  = x[78];
     /* S_ALK  ; ASM2d */   y[274]  = x[88];
     /* XI     ; ASM2d */   y[275]  = x[98];
     /* XS     ; ASM2d */   y[276]  = x[108];
     /* XH     ; ASM2d */   y[277]  = x[118];
     /* XPAO   ; ASM2d */   y[278]  = x[128];
     /* XPP    ; ASM2d */   y[279]  = x[138];
     /* XPHA   ; ASM2d */   y[280]  = x[148];
     /* XA     ; ASM2d */   y[281]  = x[158];
     /* XTSS   ; ASM2d */   y[282]  = x[168];
     /* MeOH   ; ASM2d */   y[283]  = x[178];
     /* MeP    ; ASM2d */   y[284]  = x[188];
     
     if (tempmodel < 0.5)                     /* Temp */    
        y[285]=u[20];                                  
      else 
       y[285]=x[198];
     
    /* D1   ; ASM2d */    y[286]  = x[208];
     /* D2   ; ASM2d */   y[287]  = x[218];
     /* D3   ; ASM2d */   y[288]  = x[228];
     /* D4   ; ASM2d */   y[289]  = x[238];
     /* D5   ; ASM2d */   y[290]  = x[248];
     
     //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
     
     /* S_O2   ; ASM2d */   y[291]  = x[9];  /* layer 10  */
     /* S_F    ; ASM2d */   y[292]  = x[19];
     /* S_A    ; ASM2d */   y[293]  = x[29];
     /* S_I    ; ASM2d */   y[294]  = x[39];
     /* S_NH4  ; ASM2d */   y[295]  = x[49];
     /* S_N2   ; ASM2d */   y[296]  = x[59];
     /* S_NOX  ; ASM2d */   y[297]  = x[69];
     /* S_PO4  ; ASM2d */   y[298]  = x[79];
     /* S_ALK  ; ASM2d */   y[299]  = x[89];
     /* XI     ; ASM2d */   y[300]  = x[99];
     /* XS     ; ASM2d */   y[301]  = x[109];
     /* XH     ; ASM2d */   y[302]  = x[119];
     /* XPAO   ; ASM2d */   y[303]  = x[129];
     /* XPP    ; ASM2d */   y[304]  = x[139];
     /* XPHA   ; ASM2d */   y[305]  = x[149];
     /* XA     ; ASM2d */   y[306]  = x[159];
     /* XTSS   ; ASM2d */   y[307]  = x[169];
     /* MeOH   ; ASM2d */   y[308]  = x[179];
     /* MeP    ; ASM2d */   y[309]  = x[189];
     
     if (tempmodel < 0.5)                     /* Temp */    
        y[310]=u[20];                                  
      else 
        y[310]=x[199];
     
     /* D1   ; ASM2d */    y[311]  = x[209];
     /* D2   ; ASM2d */    y[312]  = x[219];
     /* D3   ; ASM2d */    y[313]  = x[229];
     /* D4   ; ASM2d */    y[314]  = x[239];
     /* D5   ; ASM2d */    y[315]  = x[249];
}

/*
 * mdlUpdate - perform action at major integration time step
 */

static void mdlUpdate(double *x, double *u, SimStruct *S, int tid)
{
}

/* Sedimentation velocity: no need to update this part because similar for ASM1, ASM3 and ASM2d */

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

double f_SI, Y_H, Y_PAO, Y_PO4, Y_PHA, Y_A, f_XIH, f_XIP, f_XIA, iN_SI, iN_SF, iN_XI;
double iN_XS, iN_BM, iP_SI, iP_SF, iP_XI, iP_XS, iP_BM, iSS_XI, iSS_XS, iSS_BM;
double k_H, hL_NO3, hL_fe, KL_O2, KL_NO3, KL_X;
double Mu_H, q_fe, hH_NO3, b_H, hH_NO3_end, KH_O2, K_F, K_fe, KH_A, KH_NO3, KH_NH4, KH_PO4, KH_ALK;
double q_PHA, q_PP, Mu_PAO, hP_NO3, b_PAO, hP_NO3_end, b_PP, hPP_NO3_end, b_PHA, hPHA_NO3_end, KP_O2, KP_NO3, KP_A;
double KP_NH4, KP_P, KP_PO4, KP_ALK, KP_PP, K_MAX, KI_PP, KP_PHA;
double Mu_A, b_A, hA_NO3_end, KA_O2, KA_NH4, KA_ALK, KA_PO4, KA_NO3, k_PRE, k_RED, KPr_ALK;

double proc1[10], proc2[10], proc3[10], proc4[10], proc5[10], proc6[10], proc7[10], proc8[10], proc9[10], proc10[10];
double proc11[10], proc12[10], proc13[10], proc14[10], proc15[10], proc16[10], proc17[10], proc18[10], proc19[10];
double proc20[10], proc21[10];
double reac1[10], reac2[10], reac3[10], reac4[10], reac5[10], reac6[10], reac7[10], reac8[10], reac9[10], reac9_1[10];
double reac9_2[10], reac9_3[10], reac10[10], reac11[10], reac12[10], reac13[10], reac14[10], reac15[10], reac16[10];
double reac17[10], reac18[10], reac19[10];
double reac20[10], reac21[10], reac22[10],reac23[10], reac24[10];
double k_H_T[10],Mu_H_T[10],q_fe_T[10],b_H_T[10],q_PHA_T[10],q_PP_T[10], Mu_PAO_T[10],b_PAO_T[10],b_PP_T[10],b_PHA_T[10],Mu_A_T[10], b_A_T[10]; 


double xtemp[250];

double decay_switch;
double reactive_settler;
double tempmodel;

v0_max = mxGetPr(SEDPAR)[0];               /* Takacs parameter */
v0 = mxGetPr(SEDPAR)[1];                   /* Takacs parameter */
r_h = mxGetPr(SEDPAR)[2];                  /* Takacs parameter */
r_p = mxGetPr(SEDPAR)[3];                  /* Takacs parameter */
f_ns = mxGetPr(SEDPAR)[4];                 /* Takacs parameter */
X_t = mxGetPr(SEDPAR)[5];                  /* Takacs parameter */
area = mxGetPr(DIM)[0];                 /* settler area */
h = mxGetPr(DIM)[1]/mxGetPr(LAYER)[1];  /* height of a layer in the settler = height settler/number of layers */
feedlayer = mxGetPr(LAYER)[0];          /* indicate which layer is feed layer */
volume = area*mxGetPr(DIM)[1];          /* settler volume */

/* ASM2d_CEP: Stoichiometric parameters */

/* Stoichiometric parameters */

f_SI         = mxGetPr(ASMPAR)[0];
Y_H          = mxGetPr(ASMPAR)[1];
Y_PAO        = mxGetPr(ASMPAR)[2];
Y_PO4        = mxGetPr(ASMPAR)[3];
Y_PHA        = mxGetPr(ASMPAR)[4];
Y_A          = mxGetPr(ASMPAR)[5];
f_XIH        = mxGetPr(ASMPAR)[6];
f_XIP        = mxGetPr(ASMPAR)[7];
f_XIA        = mxGetPr(ASMPAR)[8];
iN_SI        = mxGetPr(ASMPAR)[9];
iN_SF        = mxGetPr(ASMPAR)[10];
iN_XI        = mxGetPr(ASMPAR)[11];
iN_XS        = mxGetPr(ASMPAR)[12];
iN_BM        = mxGetPr(ASMPAR)[13];
iP_SI        = mxGetPr(ASMPAR)[14];
iP_SF        = mxGetPr(ASMPAR)[15];
iP_XI        = mxGetPr(ASMPAR)[16];
iP_XS        = mxGetPr(ASMPAR)[17];
iP_BM        = mxGetPr(ASMPAR)[18];
iSS_XI       = mxGetPr(ASMPAR)[19];
iSS_XS       = mxGetPr(ASMPAR)[20];
iSS_BM       = mxGetPr(ASMPAR)[21];

/* Hydrolysis of ASMPARticulate substrate, X_S */

k_H          = mxGetPr(ASMPAR)[22];
hL_NO3       = mxGetPr(ASMPAR)[23];
hL_fe        = mxGetPr(ASMPAR)[24];
KL_O2        = mxGetPr(ASMPAR)[25];
KL_NO3       = mxGetPr(ASMPAR)[26];
KL_X         = mxGetPr(ASMPAR)[27];

/* Heterotrophic organisms, X_H */

Mu_H         = mxGetPr(ASMPAR)[28];
q_fe         = mxGetPr(ASMPAR)[29];
hH_NO3       = mxGetPr(ASMPAR)[30];
b_H          = mxGetPr(ASMPAR)[31];
hH_NO3_end   = mxGetPr(ASMPAR)[32];
KH_O2        = mxGetPr(ASMPAR)[33];
K_F          = mxGetPr(ASMPAR)[34];
K_fe         = mxGetPr(ASMPAR)[35];
KH_A         = mxGetPr(ASMPAR)[36];
KH_NO3       = mxGetPr(ASMPAR)[37];
KH_NH4       = mxGetPr(ASMPAR)[38];
KH_PO4       = mxGetPr(ASMPAR)[39];
KH_ALK       = mxGetPr(ASMPAR)[40];

/* Phosphorus accumulating organisms, X_PAO */

q_PHA        = mxGetPr(ASMPAR)[41];
q_PP         = mxGetPr(ASMPAR)[42];
Mu_PAO       = mxGetPr(ASMPAR)[43];
hP_NO3       = mxGetPr(ASMPAR)[44];
b_PAO        = mxGetPr(ASMPAR)[45];
hP_NO3_end   = mxGetPr(ASMPAR)[46];
b_PP         = mxGetPr(ASMPAR)[47];
hPP_NO3_end  = mxGetPr(ASMPAR)[48];
b_PHA        = mxGetPr(ASMPAR)[49];
hPHA_NO3_end = mxGetPr(ASMPAR)[50];
KP_O2        = mxGetPr(ASMPAR)[51];
KP_NO3       = mxGetPr(ASMPAR)[52];
KP_A         = mxGetPr(ASMPAR)[53];
KP_NH4       = mxGetPr(ASMPAR)[54];
KP_P         = mxGetPr(ASMPAR)[55];
KP_PO4       = mxGetPr(ASMPAR)[56];
KP_ALK       = mxGetPr(ASMPAR)[57];
KP_PP        = mxGetPr(ASMPAR)[58];
K_MAX        = mxGetPr(ASMPAR)[59];
KI_PP        = mxGetPr(ASMPAR)[60];
KP_PHA       = mxGetPr(ASMPAR)[61];

/* Autotrophic organisms X_A, nitrifying activity */

Mu_A         = mxGetPr(ASMPAR)[62];
b_A          = mxGetPr(ASMPAR)[63];
hA_NO3_end   = mxGetPr(ASMPAR)[64];
KA_O2        = mxGetPr(ASMPAR)[65];
KA_NH4       = mxGetPr(ASMPAR)[66];
KA_ALK       = mxGetPr(ASMPAR)[67];
KA_PO4       = mxGetPr(ASMPAR)[68];
KA_NO3       = mxGetPr(ASMPAR)[69];

/* Precipitation */

k_PRE        = mxGetPr(ASMPAR)[70];
k_RED        = mxGetPr(ASMPAR)[71];
KPr_ALK      = mxGetPr(ASMPAR)[72];

/* switching function */

decay_switch = mxGetPr(DECAY)[0];
reactive_settler = mxGetPr(SETTLER)[0];
tempmodel = mxGetPr(TEMPMODEL)[0]; 

eps = 0.01;
v_in = u[19]/area;
Q_f = u[19];          /* influent flow rate */
Q_u = u[26] + u[27];  /* underflow flow rate */
Q_e = u[19] - Q_u;    /* effluent flow rate */
v_up = Q_e/area;      /* upstream flow velocity */
v_dn = Q_u/area;      /* downstream flow velocity */


for (i = 0; i < 250; i++) {
   if (x[i] < 0.0)
     xtemp[i] = 0.0;
   else
     xtemp[i] = x[i];
}



/* calculation of the sedimentation velocity for each of the layers */

for (i = 0; i < 10; i++) {
   vs[i] = v0*(exp(-r_h*(xtemp[160+i]-f_ns*u[16]))-exp(-r_p*(xtemp[160+i]-f_ns*u[16])));   /* u[16] = influent SS concentration */
   if (vs[i] > v0_max)     
      vs[i] = v0_max;
   else if (vs[i] < 0.0)
      vs[i] = 0.0;
}

/* calculation of the sludge flux due to sedimentation for each layer */

for (i = 0; i < 10; i++) {
   Jstemp[i] = vs[i]*xtemp[160+i];
}

/* calculation of the sludge flux due to the liquid flow (upflow or downflow, depending on layer) */

for (i = 0; i < 11; i++) {
   if (i < (feedlayer-eps))     
      Jflow[i] = v_up*xtemp[160+i];
   else
      Jflow[i] = v_dn*xtemp[160+i-1];
}

Js[0] = 0.0;
Js[10] = 0.0;
for (i = 0; i < 9; i++) {
   if ((i < (feedlayer-1-eps)) && (xtemp[160+i+1] <= X_t))
      Js[i+1] = Jstemp[i];
   else if (Jstemp[i] < Jstemp[i+1])     
      Js[i+1] = Jstemp[i];
   else
      Js[i+1] = Jstemp[i+1];
}

/* Reaction rates ASM2d_CEP model */

for (i = 0; i < 10; i++) {
    
if (tempmodel < 0.5) {  
     /* Compensation from the current temperature in the settler*/
      k_H_T[i] =   k_H*exp((log(k_H/2.0)/5.0)*(u[20]-15.0)); /* Compensation from the temperature at the influent of the settler */ 
      Mu_H_T[i] =  Mu_H*exp((log(Mu_H/3.0)/5.0)*(u[20]-15.0));
      q_fe_T[i] =  q_fe*exp((log(q_fe/1.5)/5.0)*(u[20]-15.0));
      b_H_T[i] =   b_H*exp((log(b_H/0.2)/5.0)*(u[20]-15.0));
      q_PHA_T[i] = q_PHA*exp((log(q_PHA/2.0)/5.0)*(u[20]-15.0));
      q_PP_T[i] =  q_PP*exp((log(q_PP/1.00)/5.0)*(u[20]-15.0));
      Mu_PAO_T[i] =Mu_PAO*exp((log(Mu_PAO/0.67)/5.0)*(u[20]-15.0));
      b_PAO_T[i] = b_PAO*exp((log(b_PAO/0.1)/5.0)*(u[20]-15.0));
      b_PP_T[i] =  b_PP*exp((log(b_PP/0.1)/5.0)*(u[20]-15.0));
      b_PHA_T[i] = b_PHA*exp((log(b_PHA/0.1)/5.0)*(u[20]-15.0));
      Mu_A_T[i] =  Mu_A*exp((log(Mu_A/0.35)/5.0)*(u[20]-15.0));
      b_A_T[i] =   b_A*exp((log(b_A/0.05)/5.0)*(u[20]-15.0));

}
else {
   /* Compensation from the current temperature in the settler */
      k_H_T[i] =   k_H*exp((log(k_H/2.0)/5.0)*(x[i+190]-15.0)); /* Compensation from the temperature at each layer */ 
      Mu_H_T[i] =  Mu_H*exp((log(Mu_H/3.0)/5.0)*(x[i+190]-15.0));
      q_fe_T[i] =  q_fe*exp((log(q_fe/1.5)/5.0)*(x[i+190]-15.0));
      b_H_T[i] =   b_H*exp((log(b_H/0.2)/5.0)*(x[i+190]-15.0));
      q_PHA_T[i] = q_PHA*exp((log(q_PHA/2.0)/5.0)*(x[i+190]-15.0));
      q_PP_T[i] =  q_PP*exp((log(q_PP/1.00)/5.0)*(x[i+190]-15.0));
      Mu_PAO_T[i] =Mu_PAO*exp((log(Mu_PAO/0.67)/5.0)*(x[i+190]-15.0));
      b_PAO_T[i] = b_PAO*exp((log(b_PAO/0.1)/5.0)*(x[i+190]-15.0));
      b_PP_T[i] =  b_PP*exp((log(b_PP/0.1)/5.0)*(x[i+190]-15.0));
      b_PHA_T[i] = b_PHA*exp((log(b_PHA/0.1)/5.0)*(x[i+190]-15.0));
      Mu_A_T[i] =  Mu_A*exp((log(Mu_A/0.35)/5.0)*(x[i+190]-15.0));
      b_A_T[i] =   b_A*exp((log(b_A/0.05)/5.0)*(x[i+190]-15.0));
} 
    

if (decay_switch > 0.5) {
proc1[i]  = k_H_T[i]*xtemp[i]/(KL_O2+xtemp[i])*((xtemp[i+100]/xtemp[i+110])/(KL_X+xtemp[i+100]/xtemp[i+110]))*xtemp[i+110];
proc2[i]  = k_H_T[i]*hL_NO3*KL_O2/(KL_O2+xtemp[i])*xtemp[i+60]/(KL_NO3+xtemp[i+60])*((xtemp[i+100]/xtemp[i+110])/(KL_X+xtemp[i+100]/xtemp[i+110]))*xtemp[i+110];
proc3[i]  = k_H_T[i]*hL_fe*KL_O2/(KL_O2+xtemp[i])*KL_NO3/(KL_NO3+xtemp[i+60])*((xtemp[i+100]/xtemp[i+110])/(KL_X+xtemp[i+100]/xtemp[i+110]))*xtemp[i+110];
proc4[i]  = Mu_H_T[i]*xtemp[i]/(KH_O2+xtemp[i])*xtemp[i+10]/(K_F+xtemp[i+10])*xtemp[i+10]/(xtemp[i+20]+xtemp[i+10])*xtemp[i+40]/(KH_NH4+xtemp[i+40])*xtemp[i+70]/(KH_PO4+xtemp[i+70])*xtemp[i+80]/(KH_ALK+xtemp[i+80])*xtemp[i+110];
proc5[i]  = Mu_H_T[i]*xtemp[i]/(KH_O2+xtemp[i])*xtemp[i+20]/(KH_A+xtemp[i+20])*xtemp[i+20]/(xtemp[i+20]+xtemp[i+10])*xtemp[i+40]/(KH_NH4+xtemp[i+40])*xtemp[i+70]/(KH_PO4+xtemp[i+70])*xtemp[i+80]/(KH_ALK+xtemp[i+80])*xtemp[i+110];
proc6[i]  = Mu_H_T[i]*hH_NO3*KH_O2/(KH_O2+xtemp[i])*xtemp[i+10]/(K_F+xtemp[i+10])*xtemp[i+10]/(xtemp[i+20]+xtemp[i+10])*xtemp[i+60]/(KH_NO3+xtemp[i+60])*xtemp[i+40]/(KH_NH4+xtemp[i+40])*xtemp[i+70]/(KH_PO4+xtemp[i+70])*xtemp[i+80]/(KH_ALK+xtemp[i+80])*xtemp[i+110];
proc7[i]  = Mu_H_T[i]*hH_NO3*KH_O2/(KH_O2+xtemp[i])*xtemp[i+20]/(KH_A+xtemp[i+20])*xtemp[i+20]/(xtemp[i+20]+xtemp[i+10])*xtemp[i+60]/(KH_NO3+xtemp[i+60])*xtemp[i+40]/(KH_NH4+xtemp[i+40])*xtemp[i+70]/(KH_PO4+xtemp[i+70])*xtemp[i+80]/(KH_ALK+xtemp[i+80])*xtemp[i+110];
proc8[i]  = q_fe_T[i]*KH_O2/(KH_O2+xtemp[i])*KH_NO3/(KH_NO3+xtemp[i+60])*xtemp[i+10]/(K_fe+xtemp[i+10])*xtemp[i+80]/(KH_ALK+xtemp[i+80])*xtemp[i+110];
proc9[i]  = b_H_T[i]*(xtemp[i]/(KH_O2+xtemp[i])+hH_NO3_end*KH_O2/(KH_O2+xtemp[i])*xtemp[i+60]/(KH_NO3+xtemp[i+60]))*xtemp[i+110];
proc10[i] = q_PHA_T[i]*xtemp[i+20]/(KP_A+xtemp[i+20])*xtemp[i+80]/(KP_ALK+xtemp[i+80])*((xtemp[i+130]/xtemp[i+120])/(KP_PP+xtemp[i+130]/xtemp[i+120]))*xtemp[i+120];
proc11[i] = q_PP_T[i]*xtemp[i]/(KP_O2+xtemp[i])*xtemp[i+70]/(KP_P+xtemp[i+70])*xtemp[i+80]/(KP_ALK+xtemp[i+80])*((xtemp[i+140]/xtemp[i+120])/(KP_PHA+xtemp[i+140]/xtemp[i+120]))*((K_MAX-xtemp[i+130]/xtemp[i+120])/(KI_PP+K_MAX-xtemp[i+130]/xtemp[i+120]))*xtemp[i+120];
proc12[i] = q_PP_T[i]*hP_NO3*KP_O2/(KP_O2+xtemp[i])*xtemp[i+60]/(KP_NO3+xtemp[i+60])*xtemp[i+70]/(KP_P+xtemp[i+70])*xtemp[i+80]/(KP_ALK+xtemp[i+80])*((xtemp[i+140]/xtemp[i+120])/(KP_PHA+xtemp[i+140]/xtemp[i+120]))*((K_MAX-xtemp[i+130]/xtemp[i+120])/(KI_PP+K_MAX-xtemp[i+130]/xtemp[i+120]))*xtemp[i+120];
proc13[i] = Mu_PAO_T[i]*xtemp[i]/(KP_O2+xtemp[i])*xtemp[i+40]/(KP_NH4+xtemp[i+40])*xtemp[i+70]/(KP_PO4+xtemp[i+70])*xtemp[i+80]/(KP_ALK+xtemp[i+80])*((xtemp[i+140]/xtemp[i+120])/(KP_PHA+xtemp[i+140]/xtemp[i+120]))*xtemp[i+120];
proc14[i] = Mu_PAO_T[i]*hP_NO3*KP_O2/(KP_O2+xtemp[i])*xtemp[i+60]/(KP_NO3+xtemp[i+60])*xtemp[i+40]/(KP_NH4+xtemp[i+40])*xtemp[i+70]/(KP_PO4+xtemp[i+70])*xtemp[i+80]/(KP_ALK+xtemp[i+80])*((xtemp[i+140]/xtemp[i+120])/(KP_PHA+xtemp[i+140]/xtemp[i+120]))*xtemp[i+120];
proc15[i] = b_PAO_T[i]*xtemp[i+80]/(KP_ALK+xtemp[i+80])*(xtemp[i]/(KP_O2+xtemp[i])+hP_NO3_end*KP_O2/(KP_O2+xtemp[i])*xtemp[i+60]/(KP_NO3+xtemp[i+60]))*xtemp[i+120];
proc16[i] = b_PP_T[i]*xtemp[i+80]/(KP_ALK+xtemp[i+80])*(xtemp[i]/(KP_O2+xtemp[i])+hPP_NO3_end*KP_O2/(KP_O2+xtemp[i])*xtemp[i+60]/(KP_NO3+xtemp[i+60]))*xtemp[i+130];
proc17[i] = b_PHA_T[i]*xtemp[i+80]/(KP_ALK+xtemp[i+80])*(xtemp[i]/(KP_O2+xtemp[i])+hPHA_NO3_end*KP_O2/(KP_O2+xtemp[i])*xtemp[i+60]/(KP_NO3+xtemp[i+60]))*xtemp[i+140];
proc18[i] = Mu_A_T[i]*xtemp[i]/(KA_O2+xtemp[i])*xtemp[i+40]/(KA_NH4+xtemp[i+40])*xtemp[i+70]/(KA_PO4+xtemp[i+70])*xtemp[i+80]/(KA_ALK+xtemp[i+80])*xtemp[i+150];
proc19[i] = b_A_T[i]*(xtemp[i]/(KA_O2+xtemp[i])+hA_NO3_end*KA_O2/(KA_O2+xtemp[i])*xtemp[i+60]/(KA_NO3+xtemp[i+60]))*xtemp[i+150];
proc20[i] = k_PRE*xtemp[i+70]*xtemp[i+170];
proc21[i] = k_RED*xtemp[i+180]*xtemp[i+80]/(KPr_ALK+xtemp[i+80]); 



}
else if (decay_switch  < 0.5) {
proc1[i]  = k_H_T[i]*xtemp[i]/(KL_O2+xtemp[i])*((xtemp[i+100]/xtemp[i+110])/(KL_X+xtemp[i+100]/xtemp[i+110]))*xtemp[i+110];
proc2[i]  = k_H_T[i]*hL_NO3*KL_O2/(KL_O2+xtemp[i])*xtemp[i+60]/(KL_NO3+xtemp[i+60])*((xtemp[i+100]/xtemp[i+110])/(KL_X+xtemp[i+100]/xtemp[i+110]))*xtemp[i+110];
proc3[i]  = k_H_T[i]*hL_fe*KL_O2/(KL_O2+xtemp[i])*KL_NO3/(KL_NO3+xtemp[i+60])*((xtemp[i+100]/xtemp[i+110])/(KL_X+xtemp[i+100]/xtemp[i+110]))*xtemp[i+110];
proc4[i]  = Mu_H_T[i]*xtemp[i]/(KH_O2+xtemp[i])*xtemp[i+10]/(K_F+xtemp[i+10])*xtemp[i+10]/(xtemp[i+20]+xtemp[i+10])*xtemp[i+40]/(KH_NH4+xtemp[i+40])*xtemp[i+70]/(KH_PO4+xtemp[i+70])*xtemp[i+80]/(KH_ALK+xtemp[i+80])*xtemp[i+110];
proc5[i]  = Mu_H_T[i]*xtemp[i]/(KH_O2+xtemp[i])*xtemp[i+20]/(KH_A+xtemp[i+20])*xtemp[i+20]/(xtemp[i+20]+xtemp[i+10])*xtemp[i+40]/(KH_NH4+xtemp[i+40])*xtemp[i+70]/(KH_PO4+xtemp[i+70])*xtemp[i+80]/(KH_ALK+xtemp[i+80])*xtemp[i+110];
proc6[i]  = Mu_H_T[i]*hH_NO3*KH_O2/(KH_O2+xtemp[i])*xtemp[i+10]/(K_F+xtemp[i+10])*xtemp[i+10]/(xtemp[i+20]+xtemp[i+10])*xtemp[i+60]/(KH_NO3+xtemp[i+60])*xtemp[i+40]/(KH_NH4+xtemp[i+40])*xtemp[i+70]/(KH_PO4+xtemp[i+70])*xtemp[i+80]/(KH_ALK+xtemp[i+80])*xtemp[i+110];
proc7[i]  = Mu_H_T[i]*hH_NO3*KH_O2/(KH_O2+xtemp[i])*xtemp[i+20]/(KH_A+xtemp[i+20])*xtemp[i+20]/(xtemp[i+20]+xtemp[i+10])*xtemp[i+60]/(KH_NO3+xtemp[i+60])*xtemp[i+40]/(KH_NH4+xtemp[i+40])*xtemp[i+70]/(KH_PO4+xtemp[i+70])*xtemp[i+80]/(KH_ALK+xtemp[i+80])*xtemp[i+110];
proc8[i]  = q_fe_T[i]*KH_O2/(KH_O2+xtemp[i])*KH_NO3/(KH_NO3+xtemp[i+60])*xtemp[i+10]/(K_fe+xtemp[i+10])*xtemp[i+80]/(KH_ALK+xtemp[i+80])*xtemp[i+110];
proc9[i]  = b_H_T[i]*xtemp[i+110];
proc10[i] = q_PHA_T[i]*xtemp[i+20]/(KP_A+xtemp[i+20])*xtemp[i+80]/(KP_ALK+xtemp[i+80])*((xtemp[i+130]/xtemp[i+120])/(KP_PP+xtemp[i+130]/xtemp[i+120]))*xtemp[i+120];
proc11[i] = q_PP_T[i]*xtemp[i]/(KP_O2+xtemp[i])*xtemp[i+70]/(KP_P+xtemp[i+70])*xtemp[i+80]/(KP_ALK+xtemp[i+80])*((xtemp[i+140]/xtemp[i+120])/(KP_PHA+xtemp[i+140]/xtemp[i+120]))*((K_MAX-xtemp[i+130]/xtemp[i+120])/(KI_PP+K_MAX-xtemp[i+130]/xtemp[i+120]))*xtemp[i+120];
proc12[i] = q_PP_T[i]*hP_NO3*KP_O2/(KP_O2+xtemp[i])*xtemp[i+60]/(KP_NO3+xtemp[i+60])*xtemp[i+70]/(KP_P+xtemp[i+70])*xtemp[i+80]/(KP_ALK+xtemp[i+80])*((xtemp[i+140]/xtemp[i+120])/(KP_PHA+xtemp[i+140]/xtemp[i+120]))*((K_MAX-xtemp[i+130]/xtemp[i+120])/(KI_PP+K_MAX-xtemp[i+130]/xtemp[i+120]))*xtemp[i+120];
proc13[i] = Mu_PAO_T[i]*xtemp[i]/(KP_O2+xtemp[i])*xtemp[i+40]/(KP_NH4+xtemp[i+40])*xtemp[i+70]/(KP_PO4+xtemp[i+70])*xtemp[i+80]/(KP_ALK+xtemp[i+80])*((xtemp[i+140]/xtemp[i+120])/(KP_PHA+xtemp[i+140]/xtemp[i+120]))*xtemp[i+120];
proc14[i] = Mu_PAO_T[i]*hP_NO3*KP_O2/(KP_O2+xtemp[i])*xtemp[i+60]/(KP_NO3+xtemp[i+60])*xtemp[i+40]/(KP_NH4+xtemp[i+40])*xtemp[i+70]/(KP_PO4+xtemp[i+70])*xtemp[i+80]/(KP_ALK+xtemp[i+80])*((xtemp[i+140]/xtemp[i+120])/(KP_PHA+xtemp[i+140]/xtemp[i+120]))*xtemp[i+120];
proc15[i] = b_PAO_T[i]*xtemp[i+80]/(KP_ALK+xtemp[i+80])*xtemp[i+120];
proc16[i] = b_PP_T[i]*xtemp[i+80]/(KP_ALK+xtemp[i+80])*xtemp[i+130];
proc17[i] = b_PHA_T[i]*xtemp[i+80]/(KP_ALK+xtemp[i+80])*xtemp[i+140];
proc18[i] = Mu_A_T[i]*xtemp[i]/(KA_O2+xtemp[i])*xtemp[i+40]/(KA_NH4+xtemp[i+40])*xtemp[i+70]/(KA_PO4+xtemp[i+70])*xtemp[i+80]/(KA_ALK+xtemp[i+80])*xtemp[i+150];
proc19[i] = b_A_T[i]*xtemp[i+150];
proc20[i] = k_PRE*xtemp[i+70]*xtemp[i+170];
proc21[i] = k_RED*xtemp[i+180]*xtemp[i+80]/(KPr_ALK+xtemp[i+80]);

}

if (reactive_settler > 0.5) {
reac1[i]   = (-(1.0-Y_H)/Y_H)*(proc4[i]+proc5[i])-Y_PHA*proc11[i]+(-(1.0-Y_PAO)/Y_PAO)*proc13[i]+(-((64.0/14.0)-Y_A)/Y_A)*proc18[i];
reac2[i]   = (1.0-f_SI)*(proc1[i]+proc2[i]+proc3[i])+(-1.0/Y_H)*(proc4[i]+proc6[i])-proc8[i];
reac3[i]   = (-1.0/Y_H)*(proc5[i]+proc7[i])+proc8[i]-proc10[i]+proc17[i];
reac4[i]   = f_SI*(proc1[i]+proc2[i]+proc3[i]);
reac5[i]   = (iN_XS-iN_SI*f_SI-iN_SF*(1.0-f_SI))*(proc1[i]+proc2[i]+proc3[i])+(iN_SF/Y_H-iN_BM)*(proc4[i]+proc6[i])-iN_BM*(proc5[i]+proc7[i]+proc13[i]+proc14[i])+iN_SF*proc8[i]+(iN_BM-iN_XI*f_XIH-iN_XS*(1.0-f_XIH))*proc9[i]+(iN_BM-iN_XI*f_XIP-iN_XS*(1.0-f_XIP))*proc15[i]+(-iN_BM-1.0/Y_A)*proc18[i]+(iN_BM-iN_XI*f_XIA-iN_XS*(1.0-f_XIA))*proc19[i];
reac6[i]   = ((1.0-Y_H)/((40.0/14.0)*Y_H))*(proc6[i]+proc7[i])+(Y_PHA/(40.0/14.0))*proc12[i]+((1.0-Y_PAO)/((40.0/14.0)*Y_PAO))*proc14[i];
reac7[i]   = (-(1.0-Y_H)/((40.0/14.0)*Y_H))*(proc6[i]+proc7[i])+(-Y_PHA/(40.0/14.0))*proc12[i]+(-(1.0-Y_PAO)/((40.0/14.0)*Y_PAO))*proc14[i]+(1.0/Y_A)*proc18[i];
reac8[i]   = (iP_XS-iP_SI*f_SI-iP_SF*(1.0-f_SI))*(proc1[i]+proc2[i]+proc3[i])+(iP_SF/Y_H-iP_BM)*(proc4[i]+proc6[i])-iP_BM*(proc5[i]+proc7[i]+proc13[i]+proc14[i]+proc18[i])+iP_SF*proc8[i]+(iP_BM-iP_XI*f_XIH-iP_XS*(1.0-f_XIH))*proc9[i]+Y_PO4*proc10[i]-proc11[i]-proc12[i]+(iP_BM-iP_XI*f_XIP-iP_XS*(1.0-f_XIP))*proc15[i]+proc16[i]+(iP_BM-iP_XI*f_XIA-iP_XS*(1.0-f_XIA))*proc19[i]-proc20[i]+proc21[i];
reac9_1[i] = ((iN_XS-iN_SI*f_SI-iN_SF*(1.0-f_SI))/14.0-(iP_XS-iP_SI*f_SI-iP_SF*(1.0-f_SI))*(1.5/31.0))*(proc1[i]+proc2[i]+proc3[i])+((iN_SF/Y_H-iN_BM)/14.0-(iP_SF/Y_H-iP_BM)*(1.5/31.0))*(proc4[i]+proc6[i])+(-iN_BM/14.0-(-iP_BM)*(1.5/31.0)+1.0/(64.0*Y_H))*(proc5[i]+proc7[i])+((1.0-Y_H)/(14.0*(40.0/14.0)*Y_H))*(proc6[i]+proc7[i])+(iN_SF/14.0-iP_SF*(1.5/31.0)-1.0/64.0)*proc8[i];
reac9_2[i] = ((iN_BM-iN_XI*f_XIH-iN_XS*(1.0-f_XIH))/14.0-(iP_BM-iP_XI*f_XIH-iP_XS*(1.0-f_XIH))*(1.5/31.0))*proc9[i]+(-Y_PO4*((1.5-1.0)/31.0)+1.0/64.0)*proc10[i]+((1.5-1.0)/31.0)*proc11[i]+((1.5-1.0)/31.0+Y_PHA/(14.0*(40.0/14.0)))*proc12[i]+(-iN_BM/14.0-(-iP_BM)*(1.5/31.0))*proc13[i]+(-iN_BM/14.0-(-iP_BM)*(1.5/31.0)+(1.0-Y_PAO)/(14.0*(40.0/14.0)*Y_PAO))*proc14[i];
reac9_3[i] = ((iN_BM-iN_XI*f_XIP-iN_XS*(1.0-f_XIP))/14.0-(iP_BM-iP_XI*f_XIP-iP_XS*(1.0-f_XIP))*(1.5/31.0))*proc15[i]+((1.0-1.5)/31.0)*proc16[i]+(-1.0/64.0)*proc17[i]+((-iN_BM-1.0/Y_A)/14.0-(-iP_BM)*(1.5/31.0)-1.0/(14.0*Y_A))*proc18[i]+((iN_BM-iN_XI*f_XIA-iN_XS*(1.0-f_XIA))/14.0-(iP_BM-iP_XI*f_XIA-iP_XS*(1.0-f_XIA))*(1.5/31.0))*proc19[i]+(1.5/31.0)*(proc20[i]-proc21[i]);
reac9[i]   = reac9_1[i]+reac9_2[i]+reac9_3[i];
reac10[i]  = f_XIH*proc9[i]+f_XIP*proc15[i]+f_XIA*proc19[i];
reac11[i]  = -proc1[i]-proc2[i]-proc3[i]+(1.0-f_XIH)*proc9[i]+(1.0-f_XIP)*proc15[i]+(1.0-f_XIA)*proc19[i];
reac12[i]  = proc4[i]+proc5[i]+proc6[i]+proc7[i]-proc9[i];
reac13[i]  = proc13[i]+proc14[i]-proc15[i];
reac14[i]  = -Y_PO4*proc10[i]+proc11[i]+proc12[i]-proc16[i];
reac15[i]  = proc10[i]+(-Y_PHA)*(proc11[i]+proc12[i])+(-1.0/Y_PAO)*(proc13[i]+proc14[i])-proc17[i];
reac16[i]  = proc18[i]-proc19[i];
reac17[i]  = -iSS_XS*(proc1[i]+proc2[i]+proc3[i])+iSS_BM*(proc4[i]+proc5[i]+proc6[i]+proc7[i]+proc18[i])+(iSS_XI*f_XIH+iSS_XS*(1.0-f_XIH)-iSS_BM)*proc9[i]+(-3.23*Y_PO4+0.6)*proc10[i]+(3.23-0.6*Y_PHA)*(proc11[i]+proc12[i])+(iSS_BM-0.6/Y_PAO)*(proc13[i]+proc14[i])+(iSS_XI*f_XIP+iSS_XS*(1.0-f_XIP)-iSS_BM)*proc15[i]-3.23*proc16[i]-0.6*proc17[i]+(iSS_XI*f_XIA+iSS_XS*(1.0-f_XIA)-iSS_BM)*proc19[i]+1.42*(proc20[i]-proc21[i]);
reac18[i]  = -3.45*proc20[i]+3.45*proc21[i];
reac19[i]  = 4.87*proc20[i]-4.87*proc21[i];

reac20[i]  = 0.0;
reac21[i]  = 0.0;
reac22[i]  = 0.0;
reac23[i]  = 0.0;
reac24[i]  = 0.0;
    
}
else if (reactive_settler  < 0.5) {
reac1[i]   = 0.0;
reac2[i]   = 0.0;
reac3[i]   = 0.0;
reac4[i]   = 0.0;
reac5[i]   = 0.0;
reac6[i]   = 0.0;
reac7[i]   = 0.0;
reac8[i]   = 0.0;
reac9_1[i] = 0.0;
reac9_2[i] = 0.0;
reac9_3[i] = 0.0;
reac9[i]   = 0.0;
reac10[i]  = 0.0;
reac11[i]  = 0.0;
reac12[i]  = 0.0;
reac13[i]  = 0.0;
reac14[i]  = 0.0;
reac15[i]  = 0.0;
reac16[i]  = 0.0;
reac17[i]  = 0.0;
reac18[i]  = 0.0;
reac19[i]  = 0.0;

reac20[i]  = 0.0;
reac21[i]  = 0.0;
reac22[i]  = 0.0;
reac23[i]  = 0.0;
reac24[i]  = 0.0;

}
}

/* ASM2d_CEP model component balances over the layers */

/* Sol. comp. S_O2    ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i]     = (-v_up*xtemp[i]    +v_up*xtemp[i+1])/h   +reac1[i];
   else if (i > (feedlayer-eps)) 
      dx[i]     = (v_dn*xtemp[i-1]    -v_dn*xtemp[i])/h    +reac1[i];
   else 
      dx[i]     = (v_in*u[0] -v_up*xtemp[i]    -v_dn*xtemp[i])/h    +reac1[i];
}

/* Sol. comp. S_F     ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps))
      dx[i+10]  = (-v_up*xtemp[i+10] +v_up*xtemp[i+1+10])/h +reac2[i];
   else if (i > (feedlayer-eps)) 
      dx[i+10]  = (v_dn*xtemp[i-1+10] -v_dn*xtemp[i+10])/h +reac2[i];
   else
      dx[i+10]  = (v_in*u[1] -v_up*xtemp[i+10] -v_dn*xtemp[i+10])/h +reac2[i];
}

/* Sol. comp. S_A     ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+20]  = (-v_up*xtemp[i+20] +v_up*xtemp[i+1+20])/h +reac3[i];
   else if (i > (feedlayer-eps)) 
      dx[i+20]  = (v_dn*xtemp[i-1+20] -v_dn*xtemp[i+20])/h +reac3[i];
   else
      dx[i+20]  = (v_in*u[2] -v_up*xtemp[i+20] -v_dn*xtemp[i+20])/h +reac3[i];
}

/* Sol. comp. S_I     ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+30]  = (-v_up*xtemp[i+30] +v_up*xtemp[i+1+30])/h +reac4[i];                              
   else if (i > (feedlayer-eps)) 
      dx[i+30]  = (v_dn*xtemp[i-1+30] -v_dn*xtemp[i+30])/h +reac4[i];
   else
      dx[i+30]  = (v_in*u[3] -v_up*xtemp[i+30] -v_dn*xtemp[i+30])/h +reac4[i];
}

/* Sol. comp. S_NH4   ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+40]  = (-v_up*xtemp[i+40] +v_up*xtemp[i+1+40])/h +reac5[i];
   else if (i > (feedlayer-eps)) 
      dx[i+40]  = (v_dn*xtemp[i-1+40] -v_dn*xtemp[i+40])/h +reac5[i];
   else
      dx[i+40]  = (v_in*u[4] -v_up*xtemp[i+40] -v_dn*xtemp[i+40])/h +reac5[i];
}

/* Sol. comp. S_N2    ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+50]  = (-v_up*xtemp[i+50] +v_up*xtemp[i+1+50])/h +reac6[i];
   else if (i > (feedlayer-eps)) 
      dx[i+50]  = (v_dn*xtemp[i-1+50] -v_dn*xtemp[i+50])/h +reac6[i];
   else
      dx[i+50]  = (v_in*u[5] -v_up*xtemp[i+50] -v_dn*xtemp[i+50])/h +reac6[i];
}

/* Sol. comp. S_NOX   ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+60]  = (-v_up*xtemp[i+60] +v_up*xtemp[i+1+60])/h +reac7[i];
   else if (i > (feedlayer-eps)) 
      dx[i+60]  = (v_dn*xtemp[i-1+60] -v_dn*xtemp[i+60])/h +reac7[i];
   else
      dx[i+60]  = (v_in*u[6] -v_up*xtemp[i+60] -v_dn*xtemp[i+60])/h +reac7[i];
}

/* Sol. comp. S_PO4   ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+70]  = (-v_up*xtemp[i+70] +v_up*xtemp[i+1+70])/h +reac8[i];
   else if (i > (feedlayer-eps)) 
      dx[i+70]  = (v_dn*xtemp[i-1+70] -v_dn*xtemp[i+70])/h +reac8[i];
   else
      dx[i+70]  = (v_in*u[7] -v_up*xtemp[i+70] -v_dn*xtemp[i+70])/h +reac8[i];
}

/* Sol. comp. S_ALK   ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+80]  = (-v_up*xtemp[i+80] +v_up*xtemp[i+1+80])/h +reac9[i];
   else if (i > (feedlayer-eps)) 
      dx[i+80]  = (v_dn*xtemp[i-1+80] -v_dn*xtemp[i+80])/h +reac9[i];
   else
      dx[i+80]  = (v_in*u[8] -v_up*xtemp[i+80] -v_dn*xtemp[i+80])/h +reac9[i];
}

/* Part. comp. X_I    ; ASM2d */
      dx[90] = ((x[90]/x[160])*(-Jflow[0]-Js[1])+(x[91]/x[161])*Jflow[1])/h +reac10[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+90] = ((xtemp[i+90]/xtemp[i+160])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+90]/xtemp[i-1+160])*Js[i]+(xtemp[i+1+90]/xtemp[i+1+160])*Jflow[i+1])/h +reac10[i];
   else if (i > (feedlayer-eps)) 
      dx[i+90] = ((xtemp[i+90]/xtemp[i+160])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+90]/xtemp[i-1+160])*(Jflow[i]+Js[i]))/h +reac10[i];
   else
      dx[i+90] = ((xtemp[i+90]/xtemp[i+160])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+90]/xtemp[i-1+160])*Js[i]+v_in*u[9])/h +reac10[i];
}

/* Part. comp. X_S    ; ASM2d */
      dx[100] = ((x[100]/x[160])*(-Jflow[0]-Js[1])+(x[101]/x[161])*Jflow[1])/h +reac11[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+100] = ((xtemp[i+100]/xtemp[i+160])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+100]/xtemp[i-1+160])*Js[i]+(xtemp[i+1+100]/xtemp[i+1+160])*Jflow[i+1])/h +reac11[i];
   else if (i > (feedlayer-eps)) 
      dx[i+100] = ((xtemp[i+100]/xtemp[i+160])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+100]/xtemp[i-1+160])*(Jflow[i]+Js[i]))/h +reac11[i];
   else
      dx[i+100] = ((xtemp[i+100]/xtemp[i+160])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+100]/xtemp[i-1+160])*Js[i]+v_in*u[10])/h +reac11[i];
}

/* Part. comp. X_H    ; ASM2d */
      dx[110] = ((x[110]/x[160])*(-Jflow[0]-Js[1])+(x[111]/x[161])*Jflow[1])/h +reac12[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+110] = ((xtemp[i+110]/xtemp[i+160])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+110]/xtemp[i-1+160])*Js[i]+(xtemp[i+1+110]/xtemp[i+1+160])*Jflow[i+1])/h +reac12[i];
   else if (i > (feedlayer-eps)) 
      dx[i+110] = ((xtemp[i+110]/xtemp[i+160])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+110]/xtemp[i-1+160])*(Jflow[i]+Js[i]))/h +reac12[i];
   else
      dx[i+110] = ((xtemp[i+110]/xtemp[i+160])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+110]/xtemp[i-1+160])*Js[i]+v_in*u[11])/h +reac12[i];
}

/* Part. comp. X_PAO  ; ASM2d */
      dx[120] = ((x[120]/x[160])*(-Jflow[0]-Js[1])+(x[121]/x[161])*Jflow[1])/h +reac13[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+120] = ((xtemp[i+120]/xtemp[i+160])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+120]/xtemp[i-1+160])*Js[i]+(xtemp[i+1+120]/xtemp[i+1+160])*Jflow[i+1])/h +reac13[i];
   else if (i > (feedlayer-eps)) 
      dx[i+120] = ((xtemp[i+120]/xtemp[i+160])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+120]/xtemp[i-1+160])*(Jflow[i]+Js[i]))/h +reac13[i];
   else
      dx[i+120] = ((xtemp[i+120]/xtemp[i+160])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+120]/xtemp[i-1+160])*Js[i]+v_in*u[12])/h +reac13[i];
}

/* Part. comp. X_PP   ; ASM2d */
      dx[130] = ((x[130]/x[160])*(-Jflow[0]-Js[1])+(x[131]/x[161])*Jflow[1])/h +reac14[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+130] = ((xtemp[i+130]/xtemp[i+160])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+130]/xtemp[i-1+160])*Js[i]+(xtemp[i+1+130]/xtemp[i+1+160])*Jflow[i+1])/h +reac14[i];
   else if (i > (feedlayer-eps)) 
      dx[i+130] = ((xtemp[i+130]/xtemp[i+160])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+130]/xtemp[i-1+160])*(Jflow[i]+Js[i]))/h +reac14[i];
   else
      dx[i+130] = ((xtemp[i+130]/xtemp[i+160])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+130]/xtemp[i-1+160])*Js[i]+v_in*u[13])/h +reac14[i];
}

/* Part. comp. X_PHA  ; ASM2d */
      dx[140] = ((x[140]/x[160])*(-Jflow[0]-Js[1])+(x[141]/x[161])*Jflow[1])/h +reac15[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+140] = ((xtemp[i+140]/xtemp[i+160])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+140]/xtemp[i-1+160])*Js[i]+(xtemp[i+1+140]/xtemp[i+1+160])*Jflow[i+1])/h +reac15[i];
   else if (i > (feedlayer-eps)) 
      dx[i+140] = ((xtemp[i+140]/xtemp[i+160])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+140]/xtemp[i-1+160])*(Jflow[i]+Js[i]))/h +reac15[i];
   else
      dx[i+140] = ((xtemp[i+140]/xtemp[i+160])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+140]/xtemp[i-1+160])*Js[i]+v_in*u[14])/h +reac15[i];
}

/* Part. comp. X_A    ; ASM2d */
      dx[150] = ((x[150]/x[160])*(-Jflow[0]-Js[1])+(x[151]/x[161])*Jflow[1])/h +reac16[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+150] = ((xtemp[i+150]/xtemp[i+160])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+150]/xtemp[i-1+160])*Js[i]+(xtemp[i+1+150]/xtemp[i+1+160])*Jflow[i+1])/h +reac16[i];
   else if (i > (feedlayer-eps)) 
      dx[i+150] = ((xtemp[i+150]/xtemp[i+160])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+150]/xtemp[i-1+160])*(Jflow[i]+Js[i]))/h +reac16[i];
   else
      dx[i+150] = ((xtemp[i+150]/xtemp[i+160])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+150]/xtemp[i-1+160])*Js[i]+v_in*u[15])/h +reac16[i];
}

/* Part. comp. X_TSS  ; ASM2d */
      dx[160] = ((x[160]/x[160])*(-Jflow[0]-Js[1])+(x[161]/x[161])*Jflow[1])/h +reac17[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+160] = ((xtemp[i+160]/xtemp[i+160])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+160]/xtemp[i-1+160])*Js[i]+(xtemp[i+1+160]/xtemp[i+1+160])*Jflow[i+1])/h +reac17[i];
   else if (i > (feedlayer-eps)) 
      dx[i+160] = ((xtemp[i+160]/xtemp[i+160])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+160]/xtemp[i-1+160])*(Jflow[i]+Js[i]))/h +reac17[i];
   else
      dx[i+160] = ((xtemp[i+160]/xtemp[i+160])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+160]/xtemp[i-1+160])*Js[i]+v_in*u[16])/h +reac17[i];
}

/* Part. comp. X_MeOH ; ASM2d */
      dx[170] = ((x[170]/x[160])*(-Jflow[0]-Js[1])+(x[171]/x[161])*Jflow[1])/h +reac18[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+170] = ((xtemp[i+170]/xtemp[i+160])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+170]/xtemp[i-1+160])*Js[i]+(xtemp[i+1+170]/xtemp[i+1+160])*Jflow[i+1])/h +reac18[i];
   else if (i > (feedlayer-eps)) 
      dx[i+170] = ((xtemp[i+170]/xtemp[i+160])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+170]/xtemp[i-1+160])*(Jflow[i]+Js[i]))/h +reac18[i];
   else
      dx[i+170] = ((xtemp[i+170]/xtemp[i+160])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+170]/xtemp[i-1+160])*Js[i]+v_in*u[17])/h +reac18[i];
}

/* Part. comp. X_MeP  ; ASM2d */
      dx[180] = ((x[180]/x[160])*(-Jflow[0]-Js[1])+(x[181]/x[161])*Jflow[1])/h +reac19[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+180] = ((xtemp[i+180]/xtemp[i+160])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+180]/xtemp[i-1+160])*Js[i]+(xtemp[i+1+180]/xtemp[i+1+160])*Jflow[i+1])/h +reac19[i];
   else if (i > (feedlayer-eps)) 
      dx[i+180] = ((xtemp[i+180]/xtemp[i+160])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+180]/xtemp[i-1+160])*(Jflow[i]+Js[i]))/h +reac19[i];
   else
      dx[i+180] = ((xtemp[i+180]/xtemp[i+160])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+180]/xtemp[i-1+160])*Js[i]+v_in*u[18])/h +reac19[i];
}
      
/* Sol. comp. Temperature   ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+190]  = (-v_up*xtemp[i+190] +v_up*xtemp[i+1+190])/h;
   else if (i > (feedlayer-eps)) 
      dx[i+190]  = (v_dn*xtemp[i-1+190] -v_dn*xtemp[i+190])/h;
   else
      dx[i+190]  = (v_in*u[20] -v_up*xtemp[i+190] -v_dn*xtemp[i+190])/h;
}

/* Sol. comp. D1   ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+200]  = (-v_up*xtemp[i+200] +v_up*xtemp[i+1+200])/h + reac20[i];
   else if (i > (feedlayer-eps)) 
      dx[i+200]  = (v_dn*xtemp[i-1+200] -v_dn*xtemp[i+200])/h + + reac20[i];
   else
      dx[i+200]  = (v_in*u[21] -v_up*xtemp[i+200] -v_dn*xtemp[i+200])/h + + reac20[i];
}  
            
/* Sol. comp. D2   ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+210]  = (-v_up*xtemp[i+210] +v_up*xtemp[i+1+210])/h + reac21[i];
   else if (i > (feedlayer-eps)) 
      dx[i+210]  = (v_dn*xtemp[i-1+210] -v_dn*xtemp[i+210])/h + + reac21[i];
   else
      dx[i+210]  = (v_in*u[22] -v_up*xtemp[i+210] -v_dn*xtemp[i+210])/h + + reac21[i];
}   
      
/* Sol. comp. D3   ; ASM2d */
for (i = 0; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+220]  = (-v_up*xtemp[i+220] +v_up*xtemp[i+1+220])/h + reac22[i];
   else if (i > (feedlayer-eps)) 
      dx[i+220]  = (v_dn*xtemp[i-1+220] -v_dn*xtemp[i+220])/h + + reac22[i];
   else
      dx[i+220]  = (v_in*u[23] -v_up*xtemp[i+220] -v_dn*xtemp[i+220])/h + + reac22[i];
}    
      
      
/* Part. comp. D4  ; ASM2d */
      dx[230] = ((x[230]/x[160])*(-Jflow[0]-Js[1])+(x[231]/x[161])*Jflow[1])/h +reac23[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+230] = ((xtemp[i+230]/xtemp[i+160])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+230]/xtemp[i-1+160])*Js[i]+(xtemp[i+1+230]/xtemp[i+1+160])*Jflow[i+1])/h +reac23[i];
   else if (i > (feedlayer-eps)) 
      dx[i+230] = ((xtemp[i+230]/xtemp[i+160])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+230]/xtemp[i-1+160])*(Jflow[i]+Js[i]))/h +reac23[i];
   else
      dx[i+230] = ((xtemp[i+230]/xtemp[i+160])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+230]/xtemp[i-1+160])*Js[i]+v_in*u[24])/h + reac23[i];
}      

/* Part. comp. D5  ; ASM2d */
      dx[240] = ((x[240]/x[160])*(-Jflow[0]-Js[1])+(x[241]/x[161])*Jflow[1])/h +reac24[0];
for (i = 1; i < 10; i++) {
   if (i < (feedlayer-1-eps)) 
      dx[i+240] = ((xtemp[i+240]/xtemp[i+160])*(-Jflow[i]-Js[i+1])+(xtemp[i-1+240]/xtemp[i-1+160])*Js[i]+(xtemp[i+1+240]/xtemp[i+1+160])*Jflow[i+1])/h +reac24[i];
   else if (i > (feedlayer-eps)) 
      dx[i+240] = ((xtemp[i+240]/xtemp[i+160])*(-Jflow[i+1]-Js[i+1])+(xtemp[i-1+240]/xtemp[i-1+160])*(Jflow[i]+Js[i]))/h +reac24[i];
   else
      dx[i+240] = ((xtemp[i+240]/xtemp[i+160])*(-Jflow[i]-Jflow[i+1]-Js[i+1])+(xtemp[i-1+240]/xtemp[i-1+160])*Js[i]+v_in*u[25])/h + reac24[i];
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
