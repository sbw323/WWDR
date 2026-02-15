% This script will generate the Figures containing the influent profiles
% ASM2d influent file, 
% Run this script after ending a simulation with the influent model.
%
% Xavier Flores Alsina
% Copyright: Xavier Flores-Alsina, IEA, Lund University, Lund, Sweden
% Ulf Jeppsson, Krist Gernaey
% Last update : June, 2010

% cut away first and last samples, i.e. t=smaller than starttime and 
% t = larger than stoptime

% simout_ASM2d(1,:)=[];    % Influent data
% tout(1)=[];              % Time
% 
% tout=tout-119;
% 
tout1=tout-119;

ASM2d_Influent=[tout1,simout_ASM2d];


starttime = 245; 
stoptime = 609;

time = ASM2d_Influent(:,1);

startindex=max(find(time <= starttime));
stopindex=min(find(time >= stoptime));

time_eval=time(startindex:stopindex);

sampletime = time_eval(2)-time_eval(1);
totalt=time_eval(end)-time_eval(1);

timevector = time_eval(2:end)-time_eval(1:(end-1));

ASM2d_Influentpart = ASM2d_Influent(startindex:(stopindex-1),:);


% Influent concentrations
Qinvec =    ASM2d_Influentpart(:,21).*timevector;
SOinvec  =  ASM2d_Influentpart(:,2).*Qinvec;
SAinvec  =  ASM2d_Influentpart(:,3).*Qinvec;    
SFinvec  =  ASM2d_Influentpart(:,4).*Qinvec;  
SIinvec =   ASM2d_Influentpart(:,5).*Qinvec;
SNHinvec =  ASM2d_Influentpart(:,6).*Qinvec;
SN2invec =  ASM2d_Influentpart(:,7).*Qinvec;
SNOinvec =  ASM2d_Influentpart(:,8).*Qinvec;
SPO4invec = ASM2d_Influentpart(:,9).*Qinvec;
SALKinvec = ASM2d_Influentpart(:,10).*Qinvec;
XIinvec =   ASM2d_Influentpart(:,11).*Qinvec;
XSinvec =   ASM2d_Influentpart(:,12).*Qinvec;  
XBHinvec =  ASM2d_Influentpart(:,13).*Qinvec; 
XPAOinvec = ASM2d_Influentpart(:,14).*Qinvec; 
XPPinvec =  ASM2d_Influentpart(:,15).*Qinvec; 
XPHAinvec = ASM2d_Influentpart(:,16).*Qinvec; 
XBAinvec =  ASM2d_Influentpart(:,17).*Qinvec; 
XMeOHinvec = ASM2d_Influentpart(:,18).*Qinvec; 
XMePinvec = ASM2d_Influentpart(:,19).*Qinvec; 
TSSinvec =  ASM2d_Influentpart(:,20).*Qinvec;
Tempinvec = ASM2d_Influentpart(:,22).*Qinvec;

Qintot = sum(Qinvec);
Qinav = Qintot/totalt;

Qinload =    sum(Qinvec);
SOinload  =  sum(SOinvec);
SAinload  =  sum(SAinvec);    
SFinload  =  sum(SFinvec);  
SIinload =   sum(SIinvec);
SNHinload =  sum(SNHinvec);
SN2inload =  sum(SN2invec);
SNOinload =  sum(SNOinvec);
SPO4inload = sum(SPO4invec);
SALKinload = sum(SALKinvec);
XIinload =   sum(XIinvec);
XSinload =   sum(XSinvec);  
XBHinload =  sum(XBHinvec); 
XPAOinload = sum(XPPinvec); 
XPPinload =  sum(XPPinvec); 
XPHAinload = sum(XPHAinvec); 
XBAinload =  sum(XBAinvec); 
XMeOHinload = sum(XMeOHinvec); 
XMePinload = sum(XMePinvec); 
TSSinload =  sum(TSSinvec);
Tempinload = sum(Tempinvec);

SOinav  =  SOinload/Qintot;
SAinav  =  SAinload/Qintot;    
SFinav  =  SFinload/Qintot ;  
SIinav =   SIinload/Qintot ;
SNHinav =  SNHinload/Qintot;
SN2inav =  SN2inload/Qintot;
SNOinav =  SNOinload/Qintot;
SPO4inav = SPO4inload/Qintot;
SALKinav = SALKinload/Qintot;
XIinav =   XIinload/Qintot ;
XSinav =   XSinload/Qintot;  
XBHinav =  XBHinload/Qintot; 
XPAOinav = XPAOinload/Qintot; 
XPPinav =  XPPinload/Qintot; 
XPHAinav = XPHAinload/Qintot; 
XBAinav =  XBAinload/Qintot ; 
XMeOHinav = XMeOHinload/Qintot; 
XMePinav = XMePinload/Qintot; 
TSSinav =  TSSinload/Qintot ;
Tempinav = Tempinload/Qintot;

totalNKjinvec2=(SNHinvec+iN_SF*SFinvec+iN_SI*SIinvec+iN_XI*XIinvec+iN_XS*XSinvec+iN_BM*(XBHinvec+XPAOinvec+XBAinvec))./Qinvec;
totalNinvec2=(SNOinvec+SNHinvec+iN_SF*SFinvec+iN_SI*SIinvec+iN_XI*XIinvec+iN_XS*XSinvec+iN_BM*(XBHinvec+XPAOinvec+XBAinvec))./Qinvec;    % SN2 not included!!!
totalPorginvec2=(XPPinvec+iP_SF*SFinvec+iP_SI*SIinvec+iP_XI*XIinvec+iP_XS*XSinvec+iP_BM*(XBHinvec+XPAOinvec+XBAinvec))./Qinvec;           
totalPinvec2=(SPO4invec+XPPinvec+iP_SF*SFinvec+iP_SI*SIinvec+iP_XI*XIinvec+iP_XS*XSinvec+iP_BM*(XBHinvec+XPAOinvec+XBAinvec)+(1/4.87)*XMePinvec)./Qinvec;    % XMeP is included!!!
totalCODinvec2=(SFinvec+SAinvec+SIinvec+XIinvec+XSinvec+XBHinvec+XPAOinvec+XPHAinvec+XBAinvec)./Qinvec;
SNH4invec2=SNHinvec./Qinvec;
SPO4invec2=SPO4invec./Qinvec;
TSSinvec2=TSSinvec./Qinvec;
BOD5invec2=(0.65*(SFinvec+SAinvec+(1-f_SI)*XSinvec+(1-f_XIH)*XBHinvec+(1-f_XIP)*(XPAOinvec+XPHAinvec)+(1-f_XIA)*XBAinvec))./Qinvec;

totalNKjinload=(SNHinload+iN_SF*SFinload+iN_SI*SIinload+iN_XI*XIinload+iN_XS*XSinload+iN_BM*(XBHinload+XPAOinload+XBAinload));
totalNinload=(SNOinload+SNHinload+iN_SF*SFinload+iN_SI*SIinload+iN_XI*XIinload+iN_XS*XSinload+iN_BM*(XBHinload+XPAOinload+XBAinload));    % SN2 not included!!!
totalPorginload=(XPPinload+iP_SF*SFinload+iP_SI*SIinload+iP_XI*XIinload+iP_XS*XSinload+iP_BM*(XBHinload+XPAOinload+XBAinload));           
totalPinload=(SPO4inload+XPPinload+iP_SF*SFinload+iP_SI*SIinload+iP_XI*XIinload+iP_XS*XSinload+iP_BM*(XBHinload+XPAOinload+XBAinload)+(1/4.87)*XMePinload);    % XMeP is included!!!
totalCODinload=(SFinload+SAinload+SIinload+XIinload+XSinload+XBHinload+XPAOinload+XPHAinload+XBAinload);
SNH4inload=SNHinload;
SPO4inload=SPO4inload;
TSSinload=TSSinload;
BOD5inload=(0.65*(SFinload+SAinload+(1-f_SI)*XSinload+(1-f_XIH)*XBHinload+(1-f_XIP)*(XPAOinload+XPHAinload)+(1-f_XIA)*XBAinload));

 
% % Influent quality index (IQ)
 
BSS=2;
BCOD=1;
BNKj=20; % original BSM1
BNO=20; % original BSM1
BBOD5=2;
BNKj_new = 30; % updated BSM TG meeting no 8
BNO_new = 10; % updated BSM TG meeting no 8
BPorg=50;   
BPinorg=50;

SSin=ASM2d_Influentpart(:,20);          % Influent suspended solids
CODin=ASM2d_Influentpart(:,3)+ASM2d_Influentpart(:,4)+ASM2d_Influentpart(:,5)+ASM2d_Influentpart(:,11)+ASM2d_Influentpart(:,12)+ASM2d_Influentpart(:,13)+ASM2d_Influentpart(:,14)+ASM2d_Influentpart(:,16)+ASM2d_Influentpart(:,17);
SNKjin=ASM2d_Influentpart(:,6)+iN_SF*ASM2d_Influentpart(:,4)+iN_SI*ASM2d_Influentpart(:,5)+iN_XI*ASM2d_Influentpart(:,11)+iN_XS*ASM2d_Influentpart(:,12)+iN_BM*(ASM2d_Influentpart(:,13)+ASM2d_Influentpart(:,14)+ASM2d_Influentpart(:,17));
SNOin=ASM2d_Influentpart(:,8);          % Influent nitrate
SPorgin=(ASM2d_Influentpart(:,15) +iP_SF*ASM2d_Influentpart(:,4) + iP_SI*ASM2d_Influentpart(:,5) + iP_XI*ASM2d_Influentpart(:,11)+ iP_XS*ASM2d_Influentpart(:,12) + iP_BM*(ASM2d_Influentpart(:,13)+ASM2d_Influentpart(:,14)+ASM2d_Influentpart(:,17)));
SPinorgin=ASM2d_Influentpart(:,9)+(1/4.87)*ASM2d_Influentpart(:,19);    % Influent inorganic P
BOD5in=0.65*(ASM2d_Influentpart(:,3)+ASM2d_Influentpart(:,4)+(1-f_SI)*ASM2d_Influentpart(:,12)+(1-f_XIH)*ASM2d_Influentpart(:,12)+(1-f_XIP)*(ASM2d_Influentpart(:,14)+ASM2d_Influentpart(:,16))+(1-f_XIA)*ASM2d_Influentpart(:,17));

IQvec=(BSS*SSin+ BCOD*CODin + BNKj*SNKjin + BNO*SNOin + BBOD5*BOD5in + BPorg*SPorgin + BPinorg*SPinorgin).*Qinvec;
IQvec_new=(BSS*SSin+BCOD*CODin+BNKj_new*SNKjin+BNO_new*SNOin+BBOD5*BOD5in +BPorg*SPorgin+BPinorg*SPinorgin).*Qinvec; %updated BSM TG meeting no 8
IQ=sum(IQvec)/(totalt*1000);
IQ_new=sum(IQvec_new)/(totalt*1000);


% % Influent dispersion
Qinfprctile95 = prctile(ASM2d_Influentpart(:,21),95);
CODinfprctile95 = prctile(totalCODinvec2,95);
BOD5infprctile95 = prctile(BOD5invec2,95);
totalNKjinprctile95 = prctile(totalNKjinvec2,95);
totalNinprctile95 = prctile(totalNinvec2,95);
totalPinprctile95 = prctile(totalPinvec2,95);
TSSinprctile95 = prctile(TSSinvec2,95);

Qinfprctile5 = prctile(ASM2d_Influentpart(:,21),5);
CODinfprctile5 = prctile(totalCODinvec2,5);
BOD5infprctile5 = prctile(BOD5invec2,5);
totalNKjinprctile5 = prctile(totalNKjinvec2,5);
totalNinprctile5 = prctile(totalNinvec2,5);
totalPinprctile5 = prctile(totalPinvec2,5);
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
% 
disp(' ')
disp(['Overall Influent performance during time ',num2str(time_eval(1)),' to ',num2str(time_eval(end)),' days'])
disp('**************************************************')
disp(' ')
disp('Effluent average concentrations based on load')
disp('---------------------------------------------')
disp(['Influent average flow rate  = ',num2str(Qinav),' m3/d'])
disp(['Influent average SO conc   = ',num2str(SOinav),' mg (-COD)/l'])
disp(['Influent average SF conc    = ',num2str(SFinav),' mg COD/l'])
disp(['Influent average SA conc    = ',num2str(SAinav),' mg COD/l'])
disp(['Influent average SI conc    = ',num2str(SIinav),' mg COD/l'])
disp(['Influent average SNH conc  = ',num2str(SNHinav),' mg N/l'])
disp(['Influent average SN2 conc   = ',num2str(SN2inav),' mg N/l'])
disp(['Influent average SNOX conc  = ',num2str(SNOinav),' mg N/l'])
disp(['Influent average SPO4 conc  = ',num2str(SPO4inav),' mg P/l'])
disp(['Influent average SALK conc  = ',num2str(SALKinav),' mol HCO3/m3'])
disp(['Influent average XI conc    = ',num2str(XIinav),' mg COD/l'])
disp(['Influent average XS conc    = ',num2str(XSinav),' mg COD/l'])
disp(['Influent average XBH conc    = ',num2str(XBHinav),' mg COD/l'])
disp(['Influent average XPAO conc  = ',num2str(XPAOinav),' mg COD/l'])
disp(['Influent average XPP conc   = ',num2str(XPPinav),' mg P/l'])
disp(['Influent average XPHA conc  = ',num2str(XPHAinav),' mg COD/l'])
disp(['Influent average XBA conc    = ',num2str(XBAinav),' mg COD/l'])
disp(['Influent average XTSS conc  = ',num2str(TSSinav),' mg SS/l '])
disp(['Influent average XMeOH conc = ',num2str(XMeOHinav),' mg SS/l'])
disp(['Influent average XMeP conc  = ',num2str(XMePinav),' mg SS/l'])
disp(['Influent average Temperature  = ',num2str(Tempinav),' mg SS/l'])
disp(' ')
disp(['Influent average Kjeldahl N conc = ',num2str(SNHinav+iN_SF*SFinav+iN_SI*SIinav+iN_XI*XIinav+iN_XS*XSinav+iN_BM*(XBHinav+XPAOinav+XBAinav)),' mg N/l'])
disp(['Influent average total N conc    = ',num2str(SNOinav+SNHinav+iN_SF*SFinav+iN_SI*SIinav+iN_XI*XIinav+iN_XS*XSinav+iN_BM*(XBHinav+XPAOinav+XBAinav)),' mg N/l '])
disp(['Influent average total P conc    = ',num2str(SPO4inav+XPPinav+iP_SF*SFinav+iP_SI*SIinav+iP_XI*XIinav+iP_XS*XSinav+iP_BM*(XBHinav+XPAOinav+XBAinav)+(1/4.87)*XMePinav),' mg P/l '])
disp(['Influent average total COD conc  = ',num2str(SFinav+SAinav+SIinav+XIinav+XSinav+XBHinav+XPAOinav+XPHAinav+XBAinav),' mg COD/l'])
disp(['Influent average BOD5 conc       = ',num2str(0.65*(SFinav+SAinav+(1-f_SI)*XSinav+(1-f_XIH)*XBHinav+(1-f_XIP)*(XPAOinav+XPHAinav)+(1-f_XIA)*XBAinav)),' mg/l  '])
disp(' ')

disp(['Influent 95 percentile flow rate = ',num2str(Qinfprctile95),' m3/d'])
disp(['Influent 95 percentile Kjeldahl N conc = ',num2str(totalNKjinprctile95),' mg N/l'])
disp(['Influent 95 percentile total N conc = ',num2str(totalNinprctile95),' mg N/l'])
disp(['Influent 95 percentile total P conc = ',num2str(totalPinprctile95),' mg P/l'])
disp(['Influent 95 percentile total COD conc = ',num2str(CODinfprctile95),' mg COD/l'])
disp(['Influent 95 percentile total BOD5 conc = ',num2str(BOD5infprctile95),' mg /l'])
disp(['Influent 95 percentile total TSS conc = ',num2str(TSSinprctile95),' mg TSS/l'])
disp(' ')
disp(['Influent 5 percentile flow rate = ',num2str(Qinfprctile5),' m3/d'])
disp(['Influent 5 percentile Kjeldahl N conc = ',num2str(totalNKjinprctile5),' mg N/l'])
disp(['Influent 5 percentile total N conc = ',num2str(totalNinprctile5),' mg N/l'])
disp(['Influent 5 percentile total P conc = ',num2str(totalPinprctile5),' mg P/l'])
disp(['Influent 5 percentile total COD conc = ',num2str(CODinfprctile5),' mg COD/l'])
disp(['Influent 5 percentile total BOD5 conc = ',num2str(BOD5infprctile5),' mg /l'])
disp(['Influent 5 percentile total TSS conc = ',num2str(TSSinprctile5),' mg TSS/l'])
disp(' ')
disp(['Influent inter percentile range for flow rate = ',num2str(Qinfprctile95 - Qinfprctile5),' m3/d'])
disp(['Influent inter percentile range Kjeldahl N conc = ',num2str(totalNKjinprctile95 - totalNKjinprctile5),' mg N/l'])
disp(['Influent inter percentile range total N conc = ',num2str(totalNinprctile95 - totalNinprctile5),' mg N/l'])
disp(['Influent inter percentile range total P conc = ',num2str(totalPinprctile95 - totalPinprctile5),' mg N/l'])
disp(['Influent inter percentile range total COD conc = ',num2str(CODinfprctile95 - CODinfprctile5),' mg COD/l'])
disp(['Influent inter percentile range total BOD5 conc = ',num2str(BOD5infprctile95 - BOD5infprctile5),' mg /l'])
disp(['Influent inter percentile range total TSS conc = ',num2str(TSSinprctile95 - TSSinprctile5),' mg TSS/l'])

disp(' ')
disp('Influent average load')
disp('---------------------')
disp(['Influent average SO load   = ',num2str(SOinload/(1000*totalt)),' kg (-COD)/d'])
disp(['Influent average SF load    = ',num2str(SFinload/(1000*totalt)),' kg COD/d'])
disp(['Influent average SA load    = ',num2str(SAinload/(1000*totalt)),' kg COD/d'])
disp(['Influent average SI load    = ',num2str(SIinload/(1000*totalt)),' kg COD/d'])
disp(['Influent average SNH load  = ',num2str(SNHinload/(1000*totalt)),' kg N/d'])
disp(['Influent average SN2 load   = ',num2str(SN2inload/(1000*totalt)),' kg N/d'])
disp(['Influent average SNOX load  = ',num2str(SNOinload/(1000*totalt)),' kg N/d'])
disp(['Influent average SPO4 load  = ',num2str(SPO4inload/(1000*totalt)),' kg P/d'])
disp(['Influent average SALK load  = ',num2str(SALKinload/(1000*totalt)),' kmol HCO3/d'])
disp(['Influent average XI load    = ',num2str(XIinload/(1000*totalt)),' kg COD/d'])
disp(['Influent average XS load    = ',num2str(XSinload/(1000*totalt)),' kg COD/d'])
disp(['Influent average XBH load    = ',num2str(XBHinload/(1000*totalt)),' kg COD/d'])
disp(['Influent average XPAO load  = ',num2str(XPAOinload/(1000*totalt)),' kg COD/d'])
disp(['Influent average XPP load   = ',num2str(XPPinload/(1000*totalt)),' kg P/d'])
disp(['Influent average XPHA load  = ',num2str(XPHAinload/(1000*totalt)),' kg COD/d'])
disp(['Influent average XBA load    = ',num2str(XBAinload/(1000*totalt)),' kg COD/d'])
disp(['Influent average XTSS load  = ',num2str(TSSinload/(1000*totalt)),' kg SS/d '])
disp(['Influent average XMeOH load = ',num2str(XMeOHinload/(1000*totalt)),' kg SS/d'])
disp(['Influent average XMeP load  = ',num2str(XMePinload/(1000*totalt)),' kg SS/d'])
disp(' ')
disp(['Influent average Kjeldahl N load = ',num2str(totalNKjinload/(1000*totalt)),' kg N/d'])
disp(['Influent average total N load = ',num2str(totalNinload/(1000*totalt)),' kg N/d'])
disp(['Influent average total P load = ',num2str(totalPinload/(1000*totalt)),' kg N/d'])
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
Qdynamic = ASM2d_Influentpart(:,21);      
CODdynamic = (SFinvec+SAinvec+SIinvec+XIinvec+XSinvec+XBHinvec+XPAOinvec+XPHAinvec+XBAinvec)./Qinvec;
BOD5dynamic =(0.65*(SFinvec+SAinvec+(1-f_SI)*XSinvec+(1-f_XIH)*XBHinvec+(1-f_XIP)*(XPAOinvec+XPHAinvec)+(1-f_XIA)*XBAinvec))./Qinvec;
TSSdynamic =  TSSinvec./Qinvec;
KjeldahlNdynamic = (SNHinvec+iN_SF*SFinvec+iN_SI*SIinvec+iN_XI*XIinvec+iN_XS*XSinvec+iN_BM*(XBHinvec+XPAOinvec+XBAinvec))./Qinvec;
TNdynamic = (SNOinvec+SNHinvec+iN_SF*SFinvec+iN_SI*SIinvec+iN_XI*XIinvec+iN_XS*XSinvec+iN_BM*(XBHinvec+XPAOinvec+XBAinvec))./Qinvec;
TPdynamic = (SPO4invec+XPPinvec+iP_SF*SFinvec+iP_SI*SIinvec+iP_XI*XIinvec+iP_XS*XSinvec+iP_BM*(XBHinvec+XPAOinvec+XBAinvec)+(1/4.87)*XMePinvec)./Qinvec; 
% 
% % Dynamic influent (smoothed) profiles
% 
 Qdynamic_smooth = smoothing_data(Qdynamic,3)';
 CODdynamic_smooth = smoothing_data(CODdynamic,3)';
 BOD5dynamic_smooth = smoothing_data(BOD5dynamic,3)';
 KjeldahlNdynamic_smooth = smoothing_data(KjeldahlNdynamic,3)';
 TNdynamic_smooth = smoothing_data(TNdynamic,3)';
 TSSdynamic_smooth = smoothing_data(TSSdynamic,3)';
 TPdynamic_smooth = smoothing_data(TPdynamic,3)';
  
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

figure(7)
plot (time_eval(1:(end-1)),TPdynamic,'b')
hold on
plot (time_eval(1:(end-1)),TPdynamic_smooth,'r')
xlabel ('time (days)')
xlim([245 609])
title('Influent dynamic TP');
hold off


