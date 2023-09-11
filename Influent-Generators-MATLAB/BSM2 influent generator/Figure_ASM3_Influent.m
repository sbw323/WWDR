% This script will generate the Figures containing the influent profiles
% BSM2 influent file, 
% Run this script after ending a simulation with the influent model.
%
% Xavier Flores Alsina
% Copyright: Xavier Flores-Alsina, IEA, Lund University, Lund, Sweden
% Last update : June, 2010

% cut away first and last samples, i.e. t=smaller than starttime and 
% t = larger than stoptime

tout1=tout-119;

ASM3_Influent=[tout1,simout_ASM3];

starttime = 245; 
stoptime = 609;

time = ASM3_Influent(:,1);

startindex=max(find(time <= starttime));
stopindex=min(find(time >= stoptime));

time_eval=time(startindex:stopindex);

sampletime = time_eval(2)-time_eval(1);
totalt=time_eval(end)-time_eval(1);

timevector = time_eval(2:end)-time_eval(1:(end-1));

ASM3_Influentpart = ASM3_Influent(startindex:(stopindex-1),:);

f_P = 0.08; % adimensional parameter (BOD calculation)

% Influent concentrations
Qinvec = ASM3_Influentpart(:,15).*timevector;
SOinvec = ASM3_Influentpart(:,2).*Qinvec;
SIinvec = ASM3_Influentpart(:,3).*Qinvec;
SSinvec = ASM3_Influentpart(:,4).*Qinvec; 
SNHinvec = ASM3_Influentpart(:,5).*Qinvec;
SN2invec = ASM3_Influentpart(:,6).*Qinvec;
SNOinvec = ASM3_Influentpart(:,7).*Qinvec;
SALKinvec = ASM3_Influentpart(:,8).*Qinvec;
XIinvec = ASM3_Influentpart(:,9).*Qinvec;
XSinvec = ASM3_Influentpart(:,10).*Qinvec;  
XBHinvec = ASM3_Influentpart(:,11).*Qinvec;  
XSTOinvec = ASM3_Influentpart(:,12).*Qinvec;  
XBAinvec = ASM3_Influentpart(:,13).*Qinvec;
TSSinvec = ASM3_Influentpart(:,14).*Qinvec;
Tempinvec = ASM3_Influentpart(:,16).*Qinvec;

Qintot = sum(Qinvec);
Qinav = Qintot/totalt;


SOinload = sum(SOinvec );
SIinload = sum(SIinvec);
SSinload = sum(SSinvec); 
SNHinload = sum(SNHinvec);
SN2inload = sum(SN2invec);
SNOinload = sum(SNOinvec);
SALKinload = sum(SALKinvec);
XIinload = sum(XIinvec);
XSinload = sum(XSinvec);  
XBHinload = sum(XBHinvec);  
XSTOinload = sum(XSTOinvec);  
XBAinload = sum(XBAinvec);
TSSinload = sum(TSSinvec );
Tempinload = sum(Tempinvec);

SOinav = SOinload /Qintot;
SIinav = SIinload/Qintot;
SSinav = SSinload/Qintot; 
SNHinav = SNHinload/Qintot;
SN2inav = SN2inload/Qintot;
SNOinav = SNOinload/Qintot;
SALKinav = SALKinload/Qintot;
XIinav = XIinload /Qintot;
XSinav = XSinload /Qintot;  
XBHinav = XBHinload /Qintot;  
XSTOinav = XSTOinload /Qintot;  
XBAinav = XBAinload /Qintot;
TSSinav = TSSinload /Qintot;
Tempinav = Tempinload /Qintot;

totalNKjinvec2= (SNHinvec+ iN_SI*(SIinvec) + iN_SS*(SSinvec) + iN_XI*(XIinvec) + iN_XS*(XSinvec) + iN_XB*( XBHinvec + XBAinvec))./Qinvec;
totalNinvec2=   (SNOinvec + SNHinvec+ iN_SI*(SIinvec) + iN_SS*(SSinvec) + iN_XI*(XIinvec) + iN_XS*(XSinvec) + iN_XB*( XBHinvec + XBAinvec))./Qinvec;
totalCODinvec2= (SIinvec+SSinvec+XIinvec+XSinvec+XBHinvec+XBAinvec+XSTOinvec)./Qinvec;
SNHinvec2=       SNHinvec./Qinvec;
TSSinvec2=       TSSinvec./Qinvec;
BOD5invec2=     (0.65*(SSinvec+XSinvec+(1-f_P)*(XBHinvec+XBAinvec + XSTOinvec )))./Qinvec;

totalNKjinload= SNHinload+ iN_SI*(SIinload) + iN_SS*(SSinload) + iN_XI*(XIinload) + iN_XS*(XSinload) + iN_XB*( XBHinload + XBAinload);
totalNinload=   SNOinload+totalNKjinload;
totalCODinload=(SIinload+SSinload+XIinload+XSinload+XBHinload+XBAinload+XSTOinload);
BOD5inload=     (0.65*(SSinload+XSinload+(1-f_P)*(XBHinload+XBAinload + XSTOinload)));


% Influent quality index (IQ)

BSS=2;
BCOD=1;
BNKj=20; % original BSM1
BNO=20; % original BSM1
BBOD5=2;
BNKj_new = 30; % updated BSM TG meeting no 8
BNO_new = 10; % updated BSM TG meeting no 8



SSin=       ASM3_Influentpart(:,14);
CODin=      ASM3_Influentpart(:,3)+ ASM3_Influentpart(:,4)+ ASM3_Influentpart(:,9)+ASM3_Influentpart(:,10)+ASM3_Influentpart(:,11)+ASM3_Influentpart(:,12) + ASM3_Influentpart(:,13);
SNKjin=     ASM3_Influentpart(:,5)+ iN_SI*(ASM3_Influentpart(:,2)) + iN_SS*(ASM3_Influentpart(:,3)) + iN_XI*(ASM3_Influentpart(:,9)) + iN_XS*(ASM3_Influentpart(:,10)) + iN_XB*( ASM3_Influentpart(:,11) + ASM3_Influentpart(:,12));
SNOin=      ASM3_Influentpart(:,7);
BOD5in=0.65*(ASM3_Influentpart(:,4)+ASM3_Influentpart(:,10)+(1-f_P)*(ASM3_Influentpart(:,11)+ASM3_Influentpart(:,12)+ ASM3_Influentpart(:,13) ));

IQvec=(BSS*SSin+BCOD*CODin+BNKj*SNKjin+BNO*SNOin+BBOD5*BOD5in).*Qinvec;
IQvec_new=(BSS*SSin+BCOD*CODin+BNKj_new*SNKjin+BNO_new*SNOin+BBOD5*BOD5in).*Qinvec; %updated BSM TG meeting no 8
IQ=sum(IQvec)/(totalt*1000);
IQ_new=sum(IQvec_new)/(totalt*1000);

% Influent dispersion
Qinfprctile95 = prctile(ASM3_Influentpart(:,15),95);
CODinfprctile95 = prctile(totalCODinvec2,95);
BOD5infprctile95 = prctile(BOD5invec2,95);
totalNKjinprctile95 = prctile(totalNKjinvec2,95);
totalNinprctile95 = prctile(totalNinvec2,95);
TSSinprctile95 = prctile(TSSinvec2,95);

Qinfprctile5 = prctile(ASM3_Influentpart(:,15),5);
CODinfprctile5 = prctile(totalCODinvec2,5);
BOD5infprctile5 = prctile(BOD5invec2,5);
totalNKjinprctile5 = prctile(totalNKjinvec2,5);
totalNinprctile5 = prctile(totalNinvec2,5);
TSSinprctile5 = prctile(TSSinvec2,5);

CODinfloadprctile95 = prctile(totalCODinvec2,95);
BOD5infloadprctile95 = prctile(BOD5invec2,95);
totalNKjinloadprctile95 = prctile(totalNKjinvec2,95);
totalNinloadprctile95 = prctile(totalNinvec2,95);
TSSinloadprctile95 = prctile(TSSinvec2,95);

CODinfloadprctile5 = prctile(totalCODinvec2,5);
BOD5infloadprctile5 = prctile(BOD5invec2,5);
totalNKjinloadprctile5 = prctile(totalNKjinvec2,5);
totalNinloadprctile5 = prctile(totalNinvec2,5);
TSSinloadprctile5 = prctile(TSSinvec2,5);

disp(' ')
disp(['Overall Influent performance during time ',num2str(time_eval(1)),' to ',num2str(time_eval(end)),' days'])
disp('**************************************************')
disp(' ')
disp('Effluent average concentrations based on load')
disp('---------------------------------------------')
disp(['Influent average flow rate = ',num2str(Qinav),' m3/d'])
disp(['Influent average SO conc = ',num2str(SOinav),' mg (-COD)/l'])
disp(['Influent average SI conc = ',num2str(SIinav),' mg COD/l'])
disp(['Influent average SS conc = ',num2str(SSinav),' mg COD/l'])
disp(['Influent average SNH conc = ',num2str(SNHinav),' mg N/l'])
disp(['Influent average SN2 conc = ',num2str(SN2inav),' mg N/l'])
disp(['Influent average SNO conc = ',num2str(SNOinav),' mg COD/l'])
disp(['Influent average SALK conc = ',num2str(SALKinav),' mol HCO3/l'])
disp(['Influent average XI conc = ',num2str(XIinav),' mg COD/l'])
disp(['Influent average XS conc = ',num2str(XSinav),' mg COD/l'])
disp(['Influent average XBH conc = ',num2str(XBHinav),' mg COD/l'])
disp(['Influent average XSTO conc = ',num2str(XSTOinav),' mg COD/l'])
disp(['Influent average XBA conc = ',num2str(XBAinav),' mg COD/l'])
disp(['Influent average TSS conc = ',num2str(TSSinav),' mg TSS/m3'])
disp(['Influent average Temperature = ',num2str(Tempinav),' C '])
disp(' ')
disp(['Influent average Kjeldahl N conc = ',num2str(SNHinav+ iN_SI*(SIinav) + iN_SS*(SSinav) + iN_XI*(XIinav) + iN_XS*(XSinav) + iN_XB*( XBHinav + XBAinav)),' mg N/l'])
disp(['Influent average total N conc = ',num2str(SNOinav + SNHinav+ iN_SI*(SIinav) + iN_SS*(SSinav) + iN_XI*(XIinav) + iN_XS*(XSinav) + iN_XB*( XBHinav + XBAinav)),' mg N/l  '])
disp(['Influent average total COD conc = ',num2str(SIinav+SSinav+XIinav+XSinav+XBHinav+XBAinav+XSTOinav),' mg COD/l '])
disp(['Influent average BOD5 conc = ',num2str(0.65*(SSinav+XSinav+(1-f_P)*(XBHinav+XBAinav + XSTOinav))),' mg/l '])
disp(' ')
disp(['Influent 95 percentile flow rate = ',num2str(Qinfprctile95),' m3/d'])
disp(['Influent 95 percentile Kjeldahl N conc = ',num2str(totalNKjinprctile95),' mg N/l'])
disp(['Influent 95 percentile total N conc = ',num2str(totalNinprctile95),' mg N/l'])
disp(['Influent 95 percentile total COD conc = ',num2str(CODinfprctile95),' mg COD/l'])
disp(['Influent 95 percentile total BOD5 conc = ',num2str(BOD5infprctile95),' mg /l'])
disp(['Influent 95 percentile total TSS conc = ',num2str(TSSinprctile95),' mg TSS/l'])
disp(' ')
disp(['Influent 5 percentile flow rate = ',num2str(Qinfprctile5),' m3/d'])
disp(['Influent 5 percentile Kjeldahl N conc = ',num2str(totalNKjinprctile5),' mg N/l'])
disp(['Influent 5 percentile total N conc = ',num2str(totalNinprctile5),' mg N/l'])
disp(['Influent 5 percentile total COD conc = ',num2str(CODinfprctile5),' mg COD/l'])
disp(['Influent 5 percentile total BOD5 conc = ',num2str(BOD5infprctile5),' mg /l'])
disp(['Influent 5 percentile total TSS conc = ',num2str(TSSinprctile5),' mg TSS/l'])
disp(' ')
disp(['Influent inter percentile range for flow rate = ',num2str(Qinfprctile95 - Qinfprctile5),' m3/d'])
disp(['Influent inter percentile range Kjeldahl N conc = ',num2str(totalNKjinprctile95 - totalNKjinprctile5),' mg N/l'])
disp(['Influent inter percentile range total N conc = ',num2str(totalNinprctile95 - totalNinprctile5),' mg N/l'])
disp(['Influent inter percentile range total COD conc = ',num2str(CODinfprctile95 - CODinfprctile5),' mg COD/l'])
disp(['Influent inter percentile range total BOD5 conc = ',num2str(BOD5infprctile95 - BOD5infprctile5),' mg /l'])
disp(['Influent inter percentile range total TSS conc = ',num2str(TSSinprctile95 - TSSinprctile5),' mg TSS/l'])
% 
disp(' ')
disp('Influent average load')
disp('---------------------')
disp(['Influent average SO load = ',num2str(SOinload/(1000*totalt)),' kg (-COD)/day'])
disp(['Influent average SI load = ',num2str(SIinload/(1000*totalt)),' kg COD/day'])
disp(['Influent average SS load = ',num2str(SSinload/(1000*totalt)),' kg COD/day'])
disp(['Influent average SNH load = ',num2str(SNHinload/(1000*totalt)),' kg N/day'])
disp(['Influent average SN2 load = ',num2str(SN2inload/(1000*totalt)),' kg N/day'])
disp(['Influent average SNO load = ',num2str(SNOinload/(1000*totalt)),' kg N/day'])
disp(['Influent average SALK load = ',num2str(SALKinload/(1000*totalt)),' kmol HCO3 /day'])
disp(['Influent average XI load = ',num2str(XIinload/(1000*totalt)),' kg COD)/day'])
disp(['Influent average XS load = ',num2str(XSinload/(1000*totalt)),' kg COD/day'])
disp(['Influent average XBH load = ',num2str(XBHinload/(1000*totalt)),' kg COD/day'])
disp(['Influent average XSTO load = ',num2str(XSTOinload/(1000*totalt)),' kg COD/day'])
disp(['Influent average XBA load = ',num2str(XBAinload/(1000*totalt)),' kg COD/day'])
disp(['Influent average TSS load = ',num2str(TSSinload/(1000*totalt)),' kg TSS/day'])
disp(' ')

disp(['Influent average Kjeldahl N load = ',num2str(totalNKjinload/(1000*totalt)),' kg N/d'])
disp(['Influent average total N load = ',num2str(totalNinload/(1000*totalt)),' kg N/d'])
disp(['Influent average total COD load = ',num2str(totalCODinload/(1000*totalt)),' kg COD/d'])
disp(['Influent average BOD5 load = ',num2str(BOD5inload/(1000*totalt)),' kg/d'])
disp(' ')
disp('Other Influent quality variables')
disp('--------------------------------')
disp(['Influent Quality (I.Q.) index = ',num2str(IQ),' kg poll.units/d (original BSM1 version)'])
disp(['Influent Quality (I.Q.) index = ',num2str(IQ_new),' kg poll.units/d (updated BSM1 version)'])
disp(' ')
% 
% % Dynamic influent profiles
% 
Qdynamic =      ASM3_Influentpart(:,15);
CODdynamic =    (SIinvec+SSinvec+XIinvec+XSinvec+XBHinvec+XBAinvec+XSTOinvec)./Qinvec;
BOD5dynamic =   (0.65*(SSinvec+XSinvec+(1-f_P)*(XBHinvec+XBAinvec + XSTOinvec))./Qinvec);
TSSdynamic =    TSSinvec./Qinvec;
KjeldahlNdynamic = (SNHinvec + iN_SI*(SIinav) + iN_SS*(SSinav) + iN_XI*(XIinav) + iN_XS*(XSinav) + iN_XB*( XBHinav + XBAinav))./Qinvec;
TNdynamic =     (SNOinvec + SNHinvec + iN_SI*(SIinav) + iN_SS*(SSinav) + iN_XI*(XIinav) + iN_XS*(XSinav) + iN_XB*( XBHinav + XBAinav))./Qinvec;

% Dynamic influent (smoothed) profiles

Qdynamic_smooth = smoothing_data(Qdynamic,3)';
CODdynamic_smooth = smoothing_data(CODdynamic,3)';
BOD5dynamic_smooth = smoothing_data(BOD5dynamic,3)';
KjeldahlNdynamic_smooth = smoothing_data(KjeldahlNdynamic,3)';
TNdynamic_smooth = smoothing_data(TNdynamic,3)';
TSSdynamic_smooth = smoothing_data(TSSdynamic,3)';
 
figure(1)
plot (time_eval(1:(end-1)),Qdynamic,'b')
hold on
plot (time_eval(1:(end-1)),Qdynamic_smooth,'r')
xlabel ('time (days)')
xlim([245 609])
title('Influent dynamic flow rate');
hold off

figure(2)
plot (time_eval(1:(end-1)),CODdynamic,'b')
hold on
plot (time_eval(1:(end-1)),CODdynamic_smooth,'r')
xlabel ('time (days)')
xlim([245 609])
title('Influent dynamic COD');
hold off

figure(3)
plot (time_eval(1:(end-1)),BOD5dynamic,'b')
hold on
plot (time_eval(1:(end-1)),BOD5dynamic_smooth,'r')
xlabel ('time (days)')
xlim([245 609])
title('Influent dynamic BOD5');
hold off

figure(4)
plot (time_eval(1:(end-1)),KjeldahlNdynamic,'b')
hold on
plot (time_eval(1:(end-1)),KjeldahlNdynamic_smooth,'r')
xlabel ('time (days)')
xlim([245 609])
title('Influent dynamic TKN');
hold off

figure(5)
plot (time_eval(1:(end-1)),TNdynamic,'b')
hold on
plot (time_eval(1:(end-1)),TNdynamic_smooth,'r')
xlabel ('time (days)')
xlim([245 609])
title('Influent dynamic TN');
hold off

figure(6)
plot (time_eval(1:(end-1)),TSSdynamic,'b')
hold on
plot (time_eval(1:(end-1)),TSSdynamic_smooth,'r')
xlabel ('time (days)')
xlim([245 609])
title('Influent dynamic TSS');
hold off


