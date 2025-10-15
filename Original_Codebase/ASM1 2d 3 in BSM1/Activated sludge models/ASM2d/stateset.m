% save states to initialization files

% This file has been created by Xavier Flores-Alsina
% July, 2010
% IEA, Lund University, Lund, Sweden



[m n] = size(reac1);
Qin0 = 18446;

if (exist('in'))
  Qin = in(end,20);
else
  Qin = Qin0;
end

if (exist('rec'))
  Qintr = rec(end,20);
else
  Qintr = 3*Qin0;
end

% _ASin represents mass (g/d), flow is still m3/d, used by hydraulic delay

%hyddelay
S_O2_ASin  = ASinput(m,1);
S_F_ASin   = ASinput(m,2);
S_A_ASin   = ASinput(m,3);
S_I_ASin   = ASinput(m,4);
S_NH4_ASin = ASinput(m,5);
S_N2_ASin  = ASinput(m,6);
S_NOX_ASin = ASinput(m,7);
S_PO4_ASin = ASinput(m,8);
S_ALK_ASin = ASinput(m,9);
X_I_ASin   = ASinput(m,10);
X_S_ASin   = ASinput(m,11);
X_H_ASin   = ASinput(m,12);
X_PAO_ASin = ASinput(m,13);
X_PP_ASin  = ASinput(m,14);
X_PHA_ASin = ASinput(m,15);
X_A_ASin   = ASinput(m,16);
X_TSS_ASin = ASinput(m,17);
X_MeOH_ASin= ASinput(m,18);
X_MeP_ASin = ASinput(m,19);
Q_ASin     = ASinput(m,20);
T_ASin =     ASinput(m,21);
S_D1_ASin =  ASinput(m,22);
S_D2_ASin =  ASinput(m,23);
S_D3_ASin =  ASinput(m,24);
X_D4_ASin =  ASinput(m,25);
X_D5_ASin =  ASinput(m,26);

% bioreactor 1%
S_O2_1 =    reac1(m,1);
S_F_1 =     reac1(m,2);
S_A_1 =     reac1(m,3);
S_I_1 =     reac1(m,4);
S_NH4_1 =   reac1(m,5);
S_N2_1 =    reac1(m,6);
S_NOX_1 =   reac1(m,7);
S_PO4_1 =   reac1(m,8);
S_ALK_1 =   reac1(m,9);
X_I_1 =     reac1(m,10);
X_S_1 =     reac1(m,11);
X_H_1 =     reac1(m,12);
X_PAO_1 =   reac1(m,13);
X_PP_1 =    reac1(m,14);
X_PHA_1 =   reac1(m,15);
X_A_1 =     reac1(m,16);
X_TSS_1 =   reac1(m,17);
X_MeOH_1 =  reac1(m,18);
X_MeP_1 =   reac1(m,19);
Q1 =        reac1(m,20);
T1 =        reac1(m,21);
S_D1_1 =    reac1(m,22);
S_D2_1 =    reac1(m,23);
S_D3_1 =    reac1(m,24);
X_D4_1 =    reac1(m,25);
X_D5_1 =    reac1(m,26);

% bioreactor 2%
S_O2_2 =    reac2(m,1);
S_F_2 =     reac2(m,2);
S_A_2 =     reac2(m,3);
S_I_2 =     reac2(m,4);
S_NH4_2 =   reac2(m,5);
S_N2_2 =    reac2(m,6);
S_NOX_2 =   reac2(m,7);
S_PO4_2 =   reac2(m,8);
S_ALK_2 =   reac2(m,9);
X_I_2 =     reac2(m,10);
X_S_2 =     reac2(m,11);
X_H_2 =     reac2(m,12);
X_PAO_2 =   reac2(m,13);
X_PP_2 =    reac2(m,14);
X_PHA_2 =   reac2(m,15);
X_A_2 =     reac2(m,16);
X_TSS_2 =   reac2(m,17);
X_MeOH_2 =  reac2(m,18);
X_MeP_2 =   reac2(m,19);
Q2 =        reac2(m,20);
T2 =        reac2(m,21);
S_D1_2 =    reac2(m,22);
S_D2_2 =    reac2(m,23);
S_D3_2 =    reac2(m,24);
X_D4_2 =    reac2(m,25);
X_D5_2 =    reac2(m,26);

% bioreactor 3%
S_O2_3 =    reac3(m,1);
S_F_3 =     reac3(m,2);
S_A_3 =     reac3(m,3);
S_I_3 =     reac3(m,4);
S_NH4_3 =   reac3(m,5);
S_N2_3 =    reac3(m,6);
S_NOX_3 =   reac3(m,7);
S_PO4_3 =   reac3(m,8);
S_ALK_3 =   reac3(m,9);
X_I_3 =     reac3(m,10);
X_S_3 =     reac3(m,11);
X_H_3 =     reac3(m,12);
X_PAO_3 =   reac3(m,13);
X_PP_3 =    reac3(m,14);
X_PHA_3 =   reac3(m,15);
X_A_3 =     reac3(m,16);
X_TSS_3 =   reac3(m,17);
X_MeOH_3 =  reac3(m,18);
X_MeP_3 =   reac3(m,19);
Q3 =        reac3(m,20);
T3 =        reac3(m,21);
S_D1_3 =    reac3(m,22);
S_D2_3 =    reac3(m,23);
S_D3_3 =    reac3(m,24);
X_D4_3 =    reac3(m,25);
X_D5_3 =    reac3(m,26);

% bioreactor 4%
S_O2_4 =    reac4(m,1);
S_F_4 =     reac4(m,2);
S_A_4 =     reac4(m,3);
S_I_4 =     reac4(m,4);
S_NH4_4 =   reac4(m,5);
S_N2_4 =    reac4(m,6);
S_NOX_4 =   reac4(m,7);
S_PO4_4 =   reac4(m,8);
S_ALK_4 =   reac4(m,9);
X_I_4 =     reac4(m,10);
X_S_4 =     reac4(m,11);
X_H_4 =     reac4(m,12);
X_PAO_4 =   reac4(m,13);
X_PP_4 =    reac4(m,14);
X_PHA_4 =   reac4(m,15);
X_A_4 =     reac4(m,16);
X_TSS_4 =   reac4(m,17);
X_MeOH_4 =  reac4(m,18);
X_MeP_4 =   reac4(m,19);
Q4 =        reac4(m,20);
T4 =        reac4(m,21);
S_D1_4 =    reac4(m,22);
S_D2_4 =    reac4(m,23);
S_D3_4 =    reac4(m,24);
X_D4_4 =    reac4(m,25);
X_D5_4 =    reac4(m,26);

% bioreactor 5%
S_O2_5 =    reac5(m,1);
S_F_5 =     reac5(m,2);
S_A_5 =     reac5(m,3);
S_I_5 =     reac5(m,4);
S_NH4_5 =   reac5(m,5);
S_N2_5 =    reac5(m,6);
S_NOX_5 =   reac5(m,7);
S_PO4_5 =   reac5(m,8);
S_ALK_5 =   reac5(m,9);
X_I_5 =     reac5(m,10);
X_S_5 =     reac5(m,11);
X_H_5 =     reac5(m,12);
X_PAO_5 =   reac5(m,13);
X_PP_5 =    reac5(m,14);
X_PHA_5 =   reac5(m,15);
X_A_5 =     reac5(m,16);
X_TSS_5 =   reac5(m,17);
X_MeOH_5 =  reac5(m,18);
X_MeP_5 =   reac5(m,19);
Q5 =        reac5(m,20);
T5 =        reac5(m,21);
S_D1_5 =    reac5(m,22);
S_D2_5 =    reac5(m,23);
S_D3_5 =    reac5(m,24);
X_D4_5 =    reac5(m,25);
X_D5_5 =    reac5(m,26);

% bioreactor 6%
S_O2_6 =    reac6(m,1);
S_F_6 =     reac6(m,2);
S_A_6 =     reac6(m,3);
S_I_6 =     reac6(m,4);
S_NH4_6 =   reac6(m,5);
S_N2_6 =    reac6(m,6);
S_NOX_6 =   reac6(m,7);
S_PO4_6 =   reac6(m,8);
S_ALK_6 =   reac6(m,9);
X_I_6 =     reac6(m,10);
X_S_6 =     reac6(m,11);
X_H_6 =     reac6(m,12);
X_PAO_6 =   reac6(m,13);
X_PP_6 =    reac6(m,14);
X_PHA_6 =   reac6(m,15);
X_A_6 =     reac6(m,16);
X_TSS_6 =   reac6(m,17);
X_MeOH_6 =  reac6(m,18);
X_MeP_6 =   reac6(m,19);
Q6 =        reac6(m,20);
T6 =        reac6(m,21);
S_D1_6 =    reac6(m,22);
S_D2_6 =    reac6(m,23);
S_D3_6 =    reac6(m,24);
X_D4_6 =    reac6(m,25);
X_D5_6 =    reac6(m,26);

% bioreactor 7%
S_O2_7=    reac7(m,1);
S_F_7=     reac7(m,2);
S_A_7=     reac7(m,3);
S_I_7=     reac7(m,4);
S_NH4_7=   reac7(m,5);
S_N2_7=    reac7(m,6);
S_NOX_7=   reac7(m,7);
S_PO4_7=   reac7(m,8);
S_ALK_7=   reac7(m,9);
X_I_7=     reac7(m,10);
X_S_7=     reac7(m,11);
X_H_7=     reac7(m,12);
X_PAO_7=   reac7(m,13);
X_PP_7=    reac7(m,14);
X_PHA_7=   reac7(m,15);
X_A_7=     reac7(m,16);
X_TSS_7=   reac7(m,17);
X_MeOH_7=  reac7(m,18);
X_MeP_7=   reac7(m,19);
Q7 =       reac7(m,20);
T7 =       reac7(m,21);
S_D1_7=    reac7(m,22);
S_D2_7=    reac7(m,23);
S_D3_7=    reac7(m,24);
X_D4_7=    reac7(m,25);
X_D5_7=    reac7(m,26);


XINITDELAY = [S_O2_ASin S_F_ASin S_A_ASin S_I_ASin S_NH4_ASin S_N2_ASin S_NOX_ASin S_PO4_ASin S_ALK_ASin X_I_ASin X_S_ASin X_H_ASin X_PAO_ASin X_PP_ASin X_PHA_ASin X_A_ASin X_TSS_ASin X_MeOH_ASin X_MeP_ASin Q_ASin  T_ASin S_D1_ASin S_D2_ASin S_D3_ASin X_D4_ASin X_D5_ASin];
XINIT1 = [ S_O2_1  S_F_1  S_A_1  S_I_1  S_NH4_1  S_N2_1  S_NOX_1  S_PO4_1  S_ALK_1  X_I_1  X_S_1  X_H_1  X_PAO_1  X_PP_1  X_PHA_1  X_A_1  X_TSS_1  X_MeOH_1  X_MeP_1  Q1  T1 S_D1_1 S_D2_1 S_D3_1 X_D4_1 X_D5_1];
XINIT2 = [ S_O2_2  S_F_2  S_A_2  S_I_2  S_NH4_2  S_N2_2  S_NOX_2  S_PO4_2  S_ALK_2  X_I_2  X_S_2  X_H_2  X_PAO_2  X_PP_2  X_PHA_2  X_A_2  X_TSS_2  X_MeOH_2  X_MeP_2  Q2  T2 S_D1_2 S_D2_2 S_D3_2 X_D4_2 X_D5_2];
XINIT3 = [ S_O2_3  S_F_3  S_A_3  S_I_3  S_NH4_3  S_N2_3  S_NOX_3  S_PO4_3  S_ALK_3  X_I_3  X_S_3  X_H_3  X_PAO_3  X_PP_3  X_PHA_3  X_A_3  X_TSS_3  X_MeOH_3  X_MeP_3  Q3  T3 S_D1_3 S_D2_3 S_D3_3 X_D4_3 X_D5_3];
XINIT4 = [ S_O2_4  S_F_4  S_A_4  S_I_4  S_NH4_4  S_N2_4  S_NOX_4  S_PO4_4  S_ALK_4  X_I_4  X_S_4  X_H_4  X_PAO_4  X_PP_4  X_PHA_4  X_A_4  X_TSS_4  X_MeOH_4  X_MeP_4  Q4  T4 S_D1_4 S_D2_4 S_D3_4 X_D4_4 X_D5_4];
XINIT5 = [ S_O2_5  S_F_5  S_A_5  S_I_5  S_NH4_5  S_N2_5  S_NOX_5  S_PO4_5  S_ALK_5  X_I_5  X_S_5  X_H_5  X_PAO_5  X_PP_5  X_PHA_5  X_A_5  X_TSS_5  X_MeOH_5  X_MeP_5  Q5  T5 S_D1_5 S_D2_5 S_D3_5 X_D4_5 X_D5_5];
XINIT6 = [ S_O2_6  S_F_6  S_A_6  S_I_6  S_NH4_6  S_N2_6  S_NOX_6  S_PO4_6  S_ALK_6  X_I_6  X_S_6  X_H_6  X_PAO_6  X_PP_6  X_PHA_6  X_A_6  X_TSS_6  X_MeOH_6  X_MeP_6  Q6  T6 S_D1_6 S_D2_6 S_D3_6 X_D4_6 X_D5_6];
XINIT7 = [ S_O2_7  S_F_7  S_A_7  S_I_7  S_NH4_7  S_N2_7  S_NOX_7  S_PO4_7  S_ALK_7  X_I_7  X_S_7  X_H_7  X_PAO_7  X_PP_7  X_PHA_7  X_A_7  X_TSS_7  X_MeOH_7  X_MeP_7  Q7  T7 S_D1_7 S_D2_7 S_D3_7 X_D4_7 X_D5_7];

% layer 1 %
SO_1 =  settler(m,67);
SF_1 =  settler(m,68);
SA_1 =  settler(m,69);
SI_1 =  settler(m,70);
SNH_1 = settler(m,71);
SN2_1 = settler(m,72);
SNO_1 = settler(m,73);
SPO_1 = settler(m,74);
SALK_1 =settler(m,75);
XI_1 =  settler(m,76);
XS_1 =  settler(m,77);
XBH_1 = settler(m,78);
XPAO_1 =settler(m,79);
XPP_1 = settler(m,80);
XPHA_1 =settler(m,81);
XBA_1 = settler(m,82);
TSS_1 = settler(m,83);
XMEOH_1 = settler(m,84);
XMEP_1 =    settler(m,85);
T_1 =   settler(m,86);
SD1_1 = settler(m,87);
SD2_1 = settler(m,88);
SD3_1 = settler(m,89);
XD4_1 = settler(m,90);
XD5_1 = settler(m,91);

% layer 2 %
SO_2 =  settler(m,92);
SF_2 =  settler(m,93);
SA_2 =  settler(m,94);
SI_2 =  settler(m,95);
SNH_2 = settler(m,96);
SN2_2 = settler(m,97);
SNO_2 = settler(m,98);
SPO_2 = settler(m,99);
SALK_2 =settler(m,100);
XI_2 =  settler(m,101);
XS_2 =  settler(m,102);
XBH_2 = settler(m,103);
XPAO_2 =settler(m,104);
XPP_2 = settler(m,105);
XPHA_2 =settler(m,106);
XBA_2 = settler(m,107);
TSS_2 = settler(m,108);
XMEOH_2 = settler(m,109);
XMEP_2 =    settler(m,110);
T_2 =   settler(m,111);
SD1_2 = settler(m,112);
SD2_2 = settler(m,113);
SD3_2 = settler(m,114);
XD4_2 = settler(m,115);
XD5_2 = settler(m,116);

% layer 3 %
SO_3 =  settler(m,117);
SF_3 =  settler(m,118);
SA_3 =  settler(m,119);
SI_3 =  settler(m,120);
SNH_3 = settler(m,121);
SN2_3 = settler(m,122);
SNO_3 = settler(m,123);
SPO_3 = settler(m,124);
SALK_3 =settler(m,125);
XI_3 =  settler(m,126);
XS_3 =  settler(m,127);
XBH_3 = settler(m,128);
XPAO_3 =settler(m,129);
XPP_3 = settler(m,130);
XPHA_3 =settler(m,131);
XBA_3 = settler(m,132);
TSS_3 = settler(m,133);
XMEOH_3 = settler(m,134);
XMEP_3 =    settler(m,135);
T_3 =   settler(m,136);
SD1_3 = settler(m,137);
SD2_3 = settler(m,138);
SD3_3 = settler(m,139);
XD4_3 = settler(m,140);
XD5_3 = settler(m,141);

% layer 4 %
SO_4 =  settler(m,142);
SF_4 =  settler(m,143);
SA_4 =  settler(m,144);
SI_4 =  settler(m,145);
SNH_4 = settler(m,146);
SN2_4 = settler(m,147);
SNO_4 = settler(m,148);
SPO_4 = settler(m,149);
SALK_4 =settler(m,150);
XI_4 =  settler(m,151);
XS_4 =  settler(m,152);
XBH_4 = settler(m,153);
XPAO_4 =settler(m,154);
XPP_4 = settler(m,155);
XPHA_4 =settler(m,156);
XBA_4 = settler(m,157);
TSS_4 = settler(m,158);
XMEOH_4 = settler(m,159);
XMEP_4 =    settler(m,160);
T_4 =   settler(m,161);
SD1_4 = settler(m,162);
SD2_4 = settler(m,163);
SD3_4 = settler(m,164);
XD4_4 = settler(m,165);
XD5_4 = settler(m,166);

% layer 5 %
SO_5 =  settler(m,167);
SF_5 =  settler(m,168);
SA_5 =  settler(m,169);
SI_5 =  settler(m,170);
SNH_5 = settler(m,171);
SN2_5 = settler(m,172);
SNO_5 = settler(m,173);
SPO_5 = settler(m,174);
SALK_5 =settler(m,175);
XI_5 =  settler(m,176);
XS_5 =  settler(m,177);
XBH_5 = settler(m,178);
XPAO_5 =settler(m,179);
XPP_5 = settler(m,180);
XPHA_5 =settler(m,181);
XBA_5 = settler(m,182);
TSS_5 = settler(m,183);
XMEOH_5 = settler(m,184);
XMEP_5 =    settler(m,185);
T_5 =   settler(m,186);
SD1_5 = settler(m,187);
SD2_5 = settler(m,188);
SD3_5 = settler(m,189);
XD4_5 = settler(m,190);
XD5_5 = settler(m,191);

% layer 6 %
SO_6 =  settler(m,192);
SF_6 =  settler(m,193);
SA_6 =  settler(m,194);
SI_6 =  settler(m,195);
SNH_6 = settler(m,196);
SN2_6 = settler(m,197);
SNO_6 = settler(m,198);
SPO_6 = settler(m,199);
SALK_6 =settler(m,200);
XI_6 =  settler(m,201);
XS_6 =  settler(m,202);
XBH_6 = settler(m,203);
XPAO_6 =settler(m,204);
XPP_6 = settler(m,205);
XPHA_6 =settler(m,206);
XBA_6 = settler(m,207);
TSS_6 = settler(m,208);
XMEOH_6 = settler(m,209);
XMEP_6 =    settler(m,210);
T_6 =   settler(m,211);
SD1_6 = settler(m,212);
SD2_6 = settler(m,213);
SD3_6 = settler(m,214);
XD4_6 = settler(m,215);
XD5_6 = settler(m,216);

% layer 7 %
SO_7 =  settler(m,217);
SF_7 =  settler(m,218);
SA_7 =  settler(m,219);
SI_7 =  settler(m,220);
SNH_7 = settler(m,221);
SN2_7 = settler(m,222);
SNO_7 = settler(m,223);
SPO_7 = settler(m,224);
SALK_7 =settler(m,225);
XI_7 =  settler(m,226);
XS_7 =  settler(m,227);
XBH_7 = settler(m,228);
XPAO_7 =settler(m,229);
XPP_7 = settler(m,230);
XPHA_7 =settler(m,231);
XBA_7 = settler(m,232);
TSS_7 = settler(m,233);
XMEOH_7 = settler(m,234);
XMEP_7 =    settler(m,235);
T_7 =   settler(m,236);
SD1_7 = settler(m,237);
SD2_7 = settler(m,238);
SD3_7 = settler(m,239);
XD4_7 = settler(m,240);
XD5_7 = settler(m,241);

% layer 8 %
SO_8 =  settler(m,242);
SF_8 =  settler(m,243);
SA_8 =  settler(m,244);
SI_8 =  settler(m,245);
SNH_8 = settler(m,246);
SN2_8 = settler(m,247);
SNO_8 = settler(m,248);
SPO_8 = settler(m,249);
SALK_8 =settler(m,250);
XI_8 =  settler(m,251);
XS_8 =  settler(m,252);
XBH_8 = settler(m,253);
XPAO_8 =settler(m,254);
XPP_8 = settler(m,255);
XPHA_8 =settler(m,256);
XBA_8 = settler(m,257);
TSS_8 = settler(m,258);
XMEOH_8 = settler(m,259);
XMEP_8 =    settler(m,260);
T_8 =   settler(m,261);
SD1_8 = settler(m,262);
SD2_8 = settler(m,263);
SD3_8 = settler(m,264);
XD4_8 = settler(m,265);
XD5_8 = settler(m,266);

% layer 9 %
SO_9 =  settler(m,267);
SF_9 =  settler(m,268);
SA_9 =  settler(m,269);
SI_9 =  settler(m,270);
SNH_9 = settler(m,271);
SN2_9 = settler(m,272);
SNO_9 = settler(m,273);
SPO_9 = settler(m,274);
SALK_9 =settler(m,275);
XI_9 =  settler(m,276);
XS_9 =  settler(m,277);
XBH_9 = settler(m,278);
XPAO_9 =settler(m,279);
XPP_9 = settler(m,280);
XPHA_9 =settler(m,281);
XBA_9 = settler(m,282);
TSS_9 = settler(m,283);
XMEOH_9 = settler(m,284);
XMEP_9 =    settler(m,285);
T_9 =   settler(m,286);
SD1_9 = settler(m,287);
SD2_9 = settler(m,288);
SD3_9 = settler(m,289);
XD4_9 = settler(m,290);
XD5_9 = settler(m,291);

% layer 10 %
SO_10 =  settler(m,292);
SF_10 =  settler(m,293);
SA_10 =  settler(m,294);
SI_10 =  settler(m,295);
SNH_10 = settler(m,296);
SN2_10 = settler(m,297);
SNO_10 = settler(m,298);
SPO_10 = settler(m,299);
SALK_10 =settler(m,300);
XI_10 =  settler(m,301);
XS_10 =  settler(m,302);
XBH_10 = settler(m,303);
XPAO_10 =settler(m,304);
XPP_10 = settler(m,305);
XPHA_10 =settler(m,306);
XBA_10 = settler(m,307);
TSS_10 = settler(m,308);
XMEOH_10 = settler(m,309);
XMEP_10 =    settler(m,310);
T_10 =   settler(m,311);
SD1_10 = settler(m,312);
SD2_10 = settler(m,313);
SD3_10 = settler(m,314);
XD4_10 = settler(m,315);
XD5_10 = settler(m,316);

SETTLERINIT2D = [  SO_1 SO_2 SO_3 SO_4 SO_5 SO_6 SO_7 SO_8 SO_9 SO_10          SF_1 SF_2 SF_3 SF_4 SF_5 SF_6 SF_7 SF_8 SF_9 SF_10         SA_1 SA_2 SA_3 SA_4 SA_5 SA_6 SA_7 SA_8 SA_9 SA_10          SI_1 SI_2 SI_3 SI_4 SI_5 SI_6 SI_7 SI_8 SI_9 SI_10         SNH_1 SNH_2 SNH_3 SNH_4 SNH_5 SNH_6 SNH_7 SNH_8 SNH_9 SNH_10      SN2_1 SN2_2 SN2_3 SN2_4 SN2_5 SN2_6 SN2_7 SN2_8 SN2_9 SN2_10     SNO_1 SNO_2 SNO_3 SNO_4 SNO_5 SNO_6 SNO_7 SNO_8 SNO_9 SNO_10     SPO_1 SPO_2 SPO_3 SPO_4 SPO_5 SPO_6 SPO_7 SPO_8 SPO_9 SPO_10   SALK_1 SALK_2 SALK_3 SALK_4 SALK_5 SALK_6 SALK_7 SALK_8 SALK_9 SALK_10   XI_1 XI_2 XI_3 XI_4 XI_5 XI_6 XI_7 XI_8 XI_9 XI_10    XS_1 XS_2 XS_3 XS_4 XS_5 XS_6 XS_7 XS_8 XS_9 XS_10    XBH_1 XBH_2 XBH_3 XBH_4 XBH_5 XBH_6 XBH_7 XBH_8 XBH_9 XBH_10    XPAO_1 XPAO_2 XPAO_3 XPAO_4 XPAO_5 XPAO_6 XPAO_7 XPAO_8 XPAO_9 XPAO_10    XPP_1 XPP_2 XPP_3 XPP_4 XPP_5 XPP_6 XPP_7 XPP_8 XPP_9 XPP_10    XPHA_1 XPHA_2 XPHA_3 XPHA_4 XPHA_5 XPHA_6 XPHA_7 XPHA_8 XPHA_9 XPHA_10    XBA_1 XBA_2 XBA_3 XBA_4 XBA_5 XBA_6 XBA_7 XBA_8 XBA_9 XBA_10    TSS_1 TSS_2 TSS_3 TSS_4 TSS_5 TSS_6 TSS_7 TSS_8 TSS_9 TSS_10    XMEOH_1 XMEOH_2 XMEOH_3 XMEOH_4 XMEOH_5 XMEOH_6 XMEOH_7 XMEOH_8 XMEOH_9 XMEOH_10    XMEP_1 XMEP_2 XMEP_3 XMEP_4 XMEP_5 XMEP_6 XMEP_7 XMEP_8 XMEP_9 XMEP_10    T_1 T_2 T_3 T_4 T_5 T_6 T_7 T_8 T_9 T_10    SD1_1 SD1_2 SD1_3 SD1_4 SD1_5 SD1_6 SD1_7 SD1_8 SD1_9 SD1_10       SD2_1 SD2_2 SD2_3 SD2_4 SD2_5 SD2_6 SD2_7 SD2_8 SD2_9 SD2_10     SD3_1 SD3_2 SD3_3 SD3_4 SD3_5 SD3_6 SD3_7 SD3_8 SD3_9 SD3_10   XD4_1 XD4_2 XD4_3 XD4_4 XD4_5 XD4_6 XD4_7 XD4_8 XD4_9 XD4_10       XD5_1 XD5_1 XD5_2 XD5_3 XD5_4 XD5_5 XD5_6 XD5_7 XD5_8 XD5_9 XD5_10];


% 
% 
% save states Qin0 Qin Qintr XINITDELAY XINIT1 XINIT2 XINIT3 XINIT4 XINIT5 SETTLERINIT 
