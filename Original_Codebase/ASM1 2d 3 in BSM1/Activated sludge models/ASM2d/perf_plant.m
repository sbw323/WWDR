% Plant performance module for BSM1 benchmarking
% 990410 UJ, updated many times

% Last update 2007-11-13
% Copyright: Ulf Jeppsson, IEA, Lund University, Lund, Sweden
% 2007-12-07 file updated to include both original and updated BSM1
% evaluation criteria, UJ

% This file has been modified in order to be with the ASM2d standards
% Xavier Flores-Alsina
% July, 2010, IEA, Lund University, Lund, Sweden

% cut away first and last samples, i.e. t=smaller than starttime and 
% t = larger than stoptime

[m n] = size(in);

starttime = 7;
stoptime = 14;
startindex=max(find(t <= starttime));
stopindex=min(find(t >= stoptime));

time=t(startindex:stopindex);

sampletime = time(2)-time(1);
totalt=time(end)-time(1);

totalCODemax = 100;
totalNemax = 18;
SNHemax = 4;
TSSemax = 30;
BOD5emax = 10;
totalPemax = 2; %%% ASM2d specific

BSS=2;
BCOD=1;
BNKj=20; % original BSM1
BNO=20; % original BSM1
BBOD5=2;
BNKj_new = 30; % updated BSM TG meeting no 8
BNO_new = 10; % updated BSM TG meeting no 8

BPorg=20; %%% ASM2d specific 
BPinorg=20; %%% ASM2d specific

pumpfactor = 0.04; % original BSM1, same for all pumped flows
PF_Qintr = 0.004;  % kWh/m3, pumping energy factor, internal AS recirculation
PF_Qr = 0.008;  % kWh/m3, pumping energy factor, AS sludge recycle 
PF_Qw = 0.05;  % kWh/m3, pumping energy factor, AS wastage flow

%cut out the parts of the files to be used
inpart=in(startindex:(stopindex-1),:);
reac1part=reac1(startindex:(stopindex-1),:);
reac2part=reac2(startindex:(stopindex-1),:);
reac3part=reac3(startindex:(stopindex-1),:);
reac4part=reac4(startindex:(stopindex-1),:);
reac5part=reac5(startindex:(stopindex-1),:);
reac6part=reac6(startindex:(stopindex-1),:);
reac7part=reac7(startindex:(stopindex-1),:);

settlerpart=settler(startindex:(stopindex-1),:);
recpart=rec(startindex:(stopindex-1),:);

% Effluent concentrations
timevector=time(2:end)-time(1:(end-1));

Qevec=settlerpart(:,47).*timevector;        % effluent flow rate of settler
Qinvec=inpart(:,20).*timevector;            % influent flow rate
SO2evec=settlerpart(:,28).*Qevec;           % SO2 in settler effluent
SFevec=settlerpart(:,29).*Qevec;            % SF in settler effluent
SAevec=settlerpart(:,30).*Qevec;            % SA in settler effluent
SIevec=settlerpart(:,31).*Qevec;            % SI in settler effluent
SNH4evec=settlerpart(:,32).*Qevec;          % SNH4 in settler effluent
SN2evec=settlerpart(:,33).*Qevec;           % SN2 in settler effluent
SNOXevec=settlerpart(:,34).*Qevec;          % SNOX in settler effluent
SPO4evec=settlerpart(:,35).*Qevec;          % SPO4 in settler effluent
SALKevec=settlerpart(:,36).*Qevec;          % SALK in settler effluent
XIevec=settlerpart(:,37).*Qevec;            % XI in settler effluent
XSevec=settlerpart(:,38).*Qevec;            % XS in settler effluent
XHevec=settlerpart(:,39).*Qevec;            % XH in settler effluent
XPAOevec=settlerpart(:,40).*Qevec;          % XPAO in settler effluent
XPPevec=settlerpart(:,41).*Qevec;           % XPP in settler effluent
XPHAevec=settlerpart(:,42).*Qevec;          % XPHA in settler effluent
XAevec=settlerpart(:,43).*Qevec;            % XA in settler effluent
XTSSevec=settlerpart(:,44).*Qevec;          % XTSS in settler effluent
XMeOHevec=settlerpart(:,45).*Qevec;         % XMeOH in settler effluent
XMePevec=settlerpart(:,46).*Qevec;          % XMeP in settler effluent

Qetot = sum(Qevec);
Qeav = Qetot/totalt;

SO2eload = sum(SO2evec);
SFeload = sum(SFevec);
SAeload = sum(SAevec);
SIeload = sum(SIevec);
SNH4eload = sum(SNH4evec);
SN2eload = sum(SN2evec);
SNOXeload = sum(SNOXevec);
SPO4eload = sum(SPO4evec);
SALKeload = sum(SALKevec);
XIeload = sum(XIevec);
XSeload = sum(XSevec);
XHeload = sum(XHevec);
XPAOeload = sum(XPAOevec);
XPPeload = sum(XPPevec);
XPHAeload = sum(XPHAevec);
XAeload = sum(XAevec);
XTSSeload = sum(XTSSevec);
XMeOHeload = sum(XMeOHevec);
XMePeload = sum(XMePevec);

SO2eav = SO2eload/Qetot;
SFeav = SFeload/Qetot;
SAeav = SAeload/Qetot;
SIeav = SIeload/Qetot;
SNH4eav = SNH4eload/Qetot;
SN2eav = SN2eload/Qetot;
SNOXeav = SNOXeload/Qetot;
SPO4eav = SPO4eload/Qetot;
SALKeav = SALKeload/Qetot;
XIeav = XIeload/Qetot;
XSeav = XSeload/Qetot;
XHeav = XHeload/Qetot;
XPAOeav = XPAOeload/Qetot;
XPPeav = XPPeload/Qetot;
XPHAeav = XPHAeload/Qetot;
XAeav = XAeload/Qetot;
XTSSeav = XTSSeload/Qetot;
XMeOHeav = XMeOHeload/Qetot;
XMePeav = XMePeload/Qetot;
 
totalNKjevec2=(SNH4evec+iN_SF*SFevec+iN_SI*SIevec+iN_XI*XIevec+iN_XS*XSevec+iN_BM*(XHevec+XPAOevec+XAevec))./Qevec;
totalNevec2=(SNOXevec+SNH4evec+iN_SF*SFevec+iN_SI*SIevec+iN_XI*XIevec+iN_XS*XSevec+iN_BM*(XHevec+XPAOevec+XAevec))./Qevec;    % SN2 not included!!!
totalPorgevec2=(XPPevec+iP_SF*SFevec+iP_SI*SIevec+iP_XI*XIevec+iP_XS*XSevec+iP_BM*(XHevec+XPAOevec+XAevec))./Qevec;           
totalPevec2=(SPO4evec+XPPevec+iP_SF*SFevec+iP_SI*SIevec+iP_XI*XIevec+iP_XS*XSevec+iP_BM*(XHevec+XPAOevec+XAevec)+(1/4.87)*XMePevec)./Qevec;    % XMeP is included!!!
totalCODevec2=(SFevec+SAevec+SIevec+XIevec+XSevec+XHevec+XPAOevec+XPHAevec+XAevec)./Qevec;
SNH4evec2=SNH4evec./Qevec;
SPO4evec2=SPO4evec./Qevec;
XTSSevec2=XTSSevec./Qevec;
BOD5evec2=(0.25*(SFevec+SAevec+(1-f_SI)*XSevec+(1-f_XIH)*XHevec+(1-f_XIP)*(XPAOevec+XPHAevec)+(1-f_XIA)*XAevec))./Qevec;

totalNKjeload=SNH4eload+iN_SF*SFeload+iN_SI*SIeload+iN_XI*XIeload+iN_XS*XSeload+iN_BM*(XHeload+XPAOeload+XAeload);
totalNeload=SNOXeload+totalNKjeload;                % SN2 not included
totalPorgeload=(XPPeload+iP_SF*SFeload+iP_SI*SIeload+iP_XI*XIeload+iP_XS*XSeload+iP_BM*(XHeload+XPAOeload+XAeload));
totalPeload=SPO4eload+totalPorgeload+(1/4.87)*XMePeload;
totalCODeload=(SFeload+SAeload+SIeload+XIeload+XSeload+XHeload+XPAOeload+XPHAeload+XAeload);
BOD5eload=(0.25*(SFeload+SAeload+(1-f_SI)*XSeload+(1-f_XIH)*XHeload+(1-f_XIP)*(XPAOeload+XPHAeload)+(1-f_XIA)*XAeload));

% % Influent and Effluent quality index

SSin=inpart(:,17);          % Influent suspended solids
CODin=inpart(:,2)+inpart(:,3)+inpart(:,4)+inpart(:,10)+inpart(:,11)+inpart(:,12)+inpart(:,13)+inpart(:,15)+inpart(:,16);
SNKjin=inpart(:,5)+iN_SF*inpart(:,2)+iN_SI*inpart(:,4)+iN_XI*inpart(:,10)+iN_XS*inpart(:,11)+iN_BM*(inpart(:,12)+inpart(:,13)+inpart(:,16));
SNOXin=inpart(:,7);          % Influent nitrate
SPorgin=(inpart(:,14)+iP_SF*inpart(:,2)+iP_SI*inpart(:,4)+iP_XI*inpart(:,10)+iP_XS*inpart(:,11)+iP_BM*(inpart(:,12)+inpart(:,13)+inpart(:,16)));
SPinorgin=inpart(:,8)+(1/4.87)*inpart(:,19);    % Influent inorganic P
BOD5in=0.65*(inpart(:,2)+inpart(:,3)+(1-f_SI)*inpart(:,11)+(1-f_XIH)*inpart(:,12)+(1-f_XIP)*(inpart(:,13)+inpart(:,15))+(1-f_XIA)*inpart(:,16));

SSe=settlerpart(:,38);      % Effluent suspended solids
CODe=settlerpart(:,23)+settlerpart(:,24)+settlerpart(:,25)+settlerpart(:,31)+settlerpart(:,32)+settlerpart(:,33)+settlerpart(:,34)+settlerpart(:,36)+settlerpart(:,37);
SNKje=settlerpart(:,26)+iN_SF*settlerpart(:,23)+iN_SI*settlerpart(:,25)+iN_XI*settlerpart(:,31)+iN_XS*settlerpart(:,32)+iN_BM*(settlerpart(:,33)+settlerpart(:,34)+settlerpart(:,37));
SNOXe=settlerpart(:,28);
SPorge=(settlerpart(:,35)+iP_SF*settlerpart(:,23)+iP_SI*settlerpart(:,25)+iP_XI*settlerpart(:,31)+iP_XS*settlerpart(:,32)+iP_BM*(settlerpart(:,33)+settlerpart(:,34)+settlerpart(:,37)));
SPinorge=settlerpart(:,29)+(1/4.87)*settlerpart(:,40);    % Effluent inorganic P
BOD5e=0.25*(settlerpart(:,23)+settlerpart(:,24)+(1-f_SI)*settlerpart(:,32)+(1-f_XIH)*settlerpart(:,33)+(1-f_XIP)*(settlerpart(:,34)+settlerpart(:,36))+(1-f_XIA)*settlerpart(:,37));

 
EQvecinst=      (BSS*SSe+BCOD*CODe+BNKj*SNKje+BNO*SNOXe+BBOD5*BOD5e).*settlerpart(:,47);
EQvecinst_new=  (BSS*SSe+BCOD*CODe+BNKj_new*SNKje+BNO_new*SNOXe+BBOD5*BOD5e).*settlerpart(:,47); %updated BSM TG meeting no 8
EQvecinst_P =   (BSS*SSe+BCOD*CODe+BNKj_new*SNKje+BNO_new*SNOXe+BBOD5*BOD5e+BPorg*SPorge+BPinorg*SPinorge).*settlerpart(:,47);   % ASM2d

IQvec=    (BSS*SSin+BCOD*CODin+BNKj*SNKjin+BNO*SNOXin+BBOD5*BOD5in).*Qevec;
IQvec_new=(BSS*SSin+BCOD*CODin+BNKj_new*SNKjin+BNO_new*SNOXin+BBOD5*BOD5in).*Qinvec; %updated BSM TG meeting no 8
IQvec_P=  (BSS*SSin+BCOD*CODin+BNKj_new*SNKjin+BNO_new*SNOXin+BBOD5*BOD5in+BPorg*SPorgin+BPinorg*SPinorgin).*Qinvec;   % ASM2d

IQ=    sum(IQvec)/(totalt*1000);
IQ_new=sum(IQvec_new)/(totalt*1000);
IQ_P = sum(IQvec_P)/(totalt*1000);

EQvec=    (BSS*SSe+BCOD*CODe+BNKj*SNKje+BNO*SNOXe+BBOD5*BOD5e).*Qevec;
EQvec_new=(BSS*SSe+BCOD*CODe+BNKj_new*SNKje+BNO_new*SNOXe+BBOD5*BOD5e).*Qevec; %updated BSM TG meeting no 8
EQvec_P=  (BSS*SSe+BCOD*CODe+BNKj*SNKje+BNO*SNOXe+BBOD5*BOD5e+BPorg*SPorge+BPinorg*SPinorge).*Qevec;

EQ=         sum(EQvec)/(totalt*1000);
EQ_new=     sum(EQvec_new)/(totalt*1000); %updated BSM TG meeting no 8
EQ_P=       sum(EQvec_P)/(totalt*1000);  % ASM2d

% 
% % Costfactors for operation
% 
% % Sludge production

TSSreactors_start = (reac1part(1,17)*VOL1+reac2part(1,17)*VOL2+reac3part(1,17)*VOL3+reac4part(1,17)*VOL4+reac5part(1,17)*VOL5+reac6part(1,17)*VOL6+reac7part(1,17)*VOL7)/1000;
TSSreactors_end =(reac1part(end,17)*VOL1+reac2part(end,17)*VOL2+reac3part(end,17)*VOL3+reac4part(end,17)*VOL4+reac5part(end,17)*VOL5+reac6part(end,17)*VOL6+reac7part(end,17)*VOL7)/1000;
% 
TSSsettler_start=   (settlerpart(1,55)*DIM2D(1)*DIM2D(2)/10+settlerpart(1,56)*DIM2D(1)*DIM2D(2)/10+settlerpart(1,57)*DIM2D(1)*DIM2D(2)/10+settlerpart(1,58)*DIM2D(1)*DIM2D(2)/10+settlerpart(1,59)*DIM2D(1)*DIM2D(2)/10+settlerpart(1,60)*DIM2D(1)*DIM2D(2)/10+settlerpart(1,61)*DIM2D(1)*DIM2D(2)/10+settlerpart(1,62)*DIM2D(1)*DIM2D(2)/10+settlerpart(1,63)*DIM2D(1)*DIM2D(2)/10+settlerpart(1,64)*DIM2D(1)*DIM2D(2)/10)/1000;
TSSsettler_end=     (settlerpart(end,55)*DIM2D(1)*DIM2D(2)/10+settlerpart(end,56)*DIM2D(1)*DIM2D(2)/10+settlerpart(end,57)*DIM2D(1)*DIM2D(2)/10+settlerpart(end,58)*DIM2D(1)*DIM2D(2)/10+settlerpart(end,59)*DIM2D(1)*DIM2D(2)/10+settlerpart(end,60)*DIM2D(1)*DIM2D(2)/10+settlerpart(end,61)*DIM2D(1)*DIM2D(2)/10+settlerpart(end,62)*DIM2D(1)*DIM2D(2)/10+settlerpart(end,63)*DIM2D(1)*DIM2D(2)/10+settlerpart(end,64)*DIM2D(1)*DIM2D(2)/10)/1000;

TSSwasteconc=settlerpart(:,64)/1000;  %kg/m3
Qwasteflow=settlerpart(:,27);         %m3/d
TSSuvec=TSSwasteconc.*Qwasteflow.*timevector;
TSSproduced=sum(TSSuvec)+TSSreactors_end+TSSsettler_end-TSSreactors_start-TSSsettler_start;
TSSproducedperd = TSSproduced/totalt; %for OCI
 
% % Aeration energy, original BSM1

%Script to modify the workspace variables (Kla, carb, metal) from scalars to
%vectors in the openloop simulations. The function changeScalarToVector is
%defined at the end of this script.
invecsize = size(t);
kla1in=changeScalarToVector(kla1in,invecsize);
kla2in=changeScalarToVector(kla2in,invecsize);
kla3in=changeScalarToVector(kla3in,invecsize);
kla4in=changeScalarToVector(kla4in,invecsize);
kla5in=changeScalarToVector(kla5in,invecsize);
kla6in=changeScalarToVector(kla6in,invecsize);
kla7in=changeScalarToVector(kla7in,invecsize);

carbon1in=changeScalarToVector(carbon1in,invecsize);
carbon2in=changeScalarToVector(carbon2in,invecsize);
carbon3in=changeScalarToVector(carbon3in,invecsize);
carbon4in=changeScalarToVector(carbon4in,invecsize);
carbon5in=changeScalarToVector(carbon5in,invecsize);
carbon6in=changeScalarToVector(carbon6in,invecsize);
carbon7in=changeScalarToVector(carbon7in,invecsize);

metal1in=changeScalarToVector(metal1in,invecsize);
metal2in=changeScalarToVector(metal2in,invecsize);
metal3in=changeScalarToVector(metal3in,invecsize);
metal4in=changeScalarToVector(metal4in,invecsize);
metal5in=changeScalarToVector(metal5in,invecsize);
metal6in=changeScalarToVector(metal6in,invecsize);
metal7in=changeScalarToVector(metal7in,invecsize);

kla1vec = kla1in(startindex:(stopindex-1),:);
kla2vec = kla2in(startindex:(stopindex-1),:);
kla3vec = kla3in(startindex:(stopindex-1),:);
kla4vec = kla4in(startindex:(stopindex-1),:);
kla5vec = kla5in(startindex:(stopindex-1),:);
kla6vec = kla6in(startindex:(stopindex-1),:);
kla7vec = kla7in(startindex:(stopindex-1),:);
% 
kla1newvec = 0.0007*(VOL1/1333)*(kla1vec.*kla1vec)+0.3267*(VOL1/1333)*kla1vec;
kla2newvec = 0.0007*(VOL2/1333)*(kla2vec.*kla2vec)+0.3267*(VOL2/1333)*kla2vec;
kla3newvec = 0.0007*(VOL3/1333)*(kla3vec.*kla3vec)+0.3267*(VOL3/1333)*kla3vec;
kla4newvec = 0.0007*(VOL4/1333)*(kla4vec.*kla4vec)+0.3267*(VOL4/1333)*kla4vec;
kla5newvec = 0.0007*(VOL5/1333)*(kla5vec.*kla5vec)+0.3267*(VOL5/1333)*kla5vec;
kla6newvec = 0.0007*(VOL6/1333)*(kla4vec.*kla4vec)+0.3267*(VOL6/1333)*kla4vec;
kla7newvec = 0.0007*(VOL7/1333)*(kla5vec.*kla5vec)+0.3267*(VOL7/1333)*kla5vec;

airenergyvec = 24*(kla1newvec+kla2newvec+kla3newvec+kla4newvec+kla5newvec+kla6newvec+ kla7newvec);
airenergy = sum(airenergyvec.*timevector);
airenergyperd = airenergy/totalt; % for OCI
% 
% % Aeration energy, updated BSM1 (and also for BSM2)
kla1newvec_new = SOSAT1*VOL1*kla1vec;
kla2newvec_new = SOSAT2*VOL2*kla2vec;
kla3newvec_new = SOSAT3*VOL3*kla3vec;
kla4newvec_new = SOSAT4*VOL4*kla4vec;
kla5newvec_new = SOSAT5*VOL5*kla5vec;
kla6newvec_new = SOSAT6*VOL6*kla4vec;
kla7newvec_new = SOSAT7*VOL7*kla5vec;

airenergyvec_new = (kla1newvec_new+kla2newvec_new+kla3newvec_new+kla4newvec_new+kla5newvec_new + kla6newvec_new + kla7newvec_new )/(1.8*1000);
airenergy_new = sum(airenergyvec_new.*timevector);
airenergy_newperd = airenergy_new/totalt; % for OCI
 
% % Mixing energy (calculated as kWh consumed for the complete evaluation
% % period), same as for BSM2
mixnumreac1 = length(find(kla1vec<20));
mixnumreac2 = length(find(kla2vec<20));
mixnumreac3 = length(find(kla3vec<20));
mixnumreac4 = length(find(kla4vec<20));
mixnumreac5 = length(find(kla5vec<20));
mixnumreac6 = length(find(kla6vec<20));
mixnumreac7 = length(find(kla7vec<20));
 
mixenergyunitreac = 0.005; %kW/m3
 
mixenergyreac1 = mixnumreac1*mixenergyunitreac*VOL1;
mixenergyreac2 = mixnumreac2*mixenergyunitreac*VOL2;
mixenergyreac3 = mixnumreac3*mixenergyunitreac*VOL3;
mixenergyreac4 = mixnumreac4*mixenergyunitreac*VOL4;
mixenergyreac5 = mixnumreac5*mixenergyunitreac*VOL5;
mixenergyreac6 = mixnumreac6*mixenergyunitreac*VOL6;
mixenergyreac7 = mixnumreac7*mixenergyunitreac*VOL7;

mixenergy = 24*(mixenergyreac1+mixenergyreac2+mixenergyreac3+mixenergyreac4+mixenergyreac5 + mixenergyreac6+ mixenergyreac7)*sampletime;
mixenergyperd = mixenergy/totalt; % for OCI

% % Pumping energy, original BSM1
Qintrflow = recpart(:,20);
Qrflow = settlerpart(:,20);
pumpenergyvec = pumpfactor*(Qwasteflow+Qintrflow+Qrflow);
pumpenergy = sum(pumpenergyvec.*timevector);
pumpenergyperd = pumpenergy/totalt; %for OCI
% 
% % Pumping energy (based on BSM2 principles)
Qintrflow_new = recpart(:,20);
Qrflow_new = settlerpart(:,20);
Qwflow_new = settlerpart(:,27);
pumpenergyvec_new = PF_Qintr*Qintrflow_new+PF_Qr*Qrflow_new+PF_Qw*Qwflow_new;
pumpenergy_new = sum(pumpenergyvec_new.*timevector);
pumpenergy_newperd = pumpenergy_new/totalt; % for OCI
% 
% % % Carbon source addition
carbon1vec = carbon1in(startindex:(stopindex-1),:);
carbon2vec = carbon2in(startindex:(stopindex-1),:);
carbon3vec = carbon3in(startindex:(stopindex-1),:);
carbon4vec = carbon4in(startindex:(stopindex-1),:);
carbon5vec = carbon5in(startindex:(stopindex-1),:);
carbon6vec = carbon6in(startindex:(stopindex-1),:);
carbon7vec = carbon7in(startindex:(stopindex-1),:);

Qcarbonvec = (carbon1vec+carbon2vec+carbon3vec+carbon4vec+carbon5vec+carbon6vec+carbon7vec);
carbonmassvec = Qcarbonvec*CARBONSOURCECONC/1000;
Qcarbon = sum(Qcarbonvec.*timevector); %m3
carbonmass = sum(carbonmassvec.*timevector); %kg COD
carbonmassperd = carbonmass/totalt; %for OCI
%
% % % metal salt addition
metal1vec = metal1in(startindex:(stopindex-1),:);
metal2vec = metal2in(startindex:(stopindex-1),:);
metal3vec = metal3in(startindex:(stopindex-1),:);
metal4vec = metal4in(startindex:(stopindex-1),:);
metal5vec = metal5in(startindex:(stopindex-1),:);
metal6vec = metal6in(startindex:(stopindex-1),:);
metal7vec = metal7in(startindex:(stopindex-1),:);

Qmetalvec = (metal1vec+metal2vec+metal3vec+metal4vec+metal5vec+metal6vec+metal7vec);
metalmassvec = Qmetalvec*METALSOURCECONC/1000;
Qmetal = sum(Qmetalvec.*timevector); %m3
metalmass = sum(metalmassvec.*timevector); %kg COD
metalmassperd = metalmass/totalt; %for OCI
 
% % Operational Cost Index for BSM1
TSScost = 5*TSSproducedperd;
airenergycost = 1*airenergyperd; %original BSM1
airenergy_newcost = 1*airenergy_newperd; %updated BSM1
mixenergycost = 1*mixenergyperd; %based on BSM2
pumpenergycost = 1*pumpenergyperd; % original BSM1
pumpenergy_newcost = 1*pumpenergy_newperd; % based on BSM2
carbonmasscost = 3*carbonmassperd;
metalmasscost = 1.5*metalmassperd;

OCI = TSScost + airenergycost + mixenergycost + pumpenergycost + carbonmasscost + metalmasscost;
OCI_new = TSScost + airenergy_newcost + mixenergycost + pumpenergy_newcost + carbonmasscost + metalmasscost;
% 

% % Calculate 95% percentiles for effluent SNH, TN and TSS; BSM2 standard criteria
SNHeffprctile=prctile(SNH4evec2,95);
SPO4effprctile=prctile(SPO4evec2,95);
TNeffprctile=prctile(totalNevec2,95);
TPeffprctile=prctile(totalPevec2,95);
TSSeffprctile=prctile(XTSSevec2,95); 
% 
disp(' ')
disp(['Overall plant performance during time ',num2str(time(1)),' to ',num2str(time(end)),' days'])
disp('**************************************************')
disp(' ')
disp('Effluent average concentrations based on load')
disp('---------------------------------------------')
disp(['Effluent average flow rate  = ',num2str(Qeav),' m3/d'])
disp(['Effluent average SO2 conc   = ',num2str(SO2eav),' mg (-COD)/l'])
disp(['Effluent average SF conc    = ',num2str(SFeav),' mg COD/l'])
disp(['Effluent average SA conc    = ',num2str(SAeav),' mg COD/l'])
disp(['Effluent average SI conc    = ',num2str(SIeav),' mg COD/l'])
disp(['Effluent average SNH4 conc  = ',num2str(SNH4eav),' mg N/l'])
disp(['Effluent average SN2 conc   = ',num2str(SN2eav),' mg N/l'])
disp(['Effluent average SNOX conc  = ',num2str(SNOXeav),' mg N/l'])
disp(['Effluent average SPO4 conc  = ',num2str(SPO4eav),' mg P/l'])
disp(['Effluent average SALK conc  = ',num2str(SALKeav),' mol HCO3/m3'])
disp(['Effluent average XI conc    = ',num2str(XIeav),' mg COD/l'])
disp(['Effluent average XS conc    = ',num2str(XSeav),' mg COD/l'])
disp(['Effluent average XH conc    = ',num2str(XHeav),' mg COD/l'])
disp(['Effluent average XPAO conc  = ',num2str(XPAOeav),' mg COD/l'])
disp(['Effluent average XPP conc   = ',num2str(XPPeav),' mg P/l'])
disp(['Effluent average XPHA conc  = ',num2str(XPHAeav),' mg COD/l'])
disp(['Effluent average XA conc    = ',num2str(XAeav),' mg COD/l'])
disp(['Effluent average XTSS conc  = ',num2str(XTSSeav),' mg SS/l  (limit = 35 mg SS/l)'])
disp(['Effluent average XMeOH conc = ',num2str(XMeOHeav),' mg SS/l'])
disp(['Effluent average XMeP conc  = ',num2str(XMePeav),' mg SS/l'])
disp(' ')
disp(['Effluent average Kjeldahl N conc = ',num2str(SNH4eav+iN_SF*SFeav+iN_SI*SIeav+iN_XI*XIeav+iN_XS*XSeav+iN_BM*(XHeav+XPAOeav+XAeav)),' mg N/l'])
disp(['Effluent average total N conc    = ',num2str(SNOXeav+SNH4eav+iN_SF*SFeav+iN_SI*SIeav+iN_XI*XIeav+iN_XS*XSeav+iN_BM*(XHeav+XPAOeav+XAeav)),' mg N/l  (limit = 15 mg N/l)'])
disp(['Effluent average total P conc    = ',num2str(SPO4eav+XPPeav+iP_SF*SFeav+iP_SI*SIeav+iP_XI*XIeav+iP_XS*XSeav+iP_BM*(XHeav+XPAOeav+XAeav)+(1/4.87)*XMePeav),' mg P/l  (limit = 2 mg P/l)'])
disp(['Effluent average total COD conc  = ',num2str(SFeav+SAeav+SIeav+XIeav+XSeav+XHeav+XPAOeav+XPHAeav+XAeav),' mg COD/l  (limit = 125 mg COD/l)'])
disp(['Effluent average BOD5 conc       = ',num2str(0.25*(SFeav+SAeav+(1-f_SI)*XSeav+(1-f_XIH)*XHeav+(1-f_XIP)*(XPAOeav+XPHAeav)+(1-f_XIA)*XAeav)),' mg/l  (limit = 25 mg/l)'])
disp(' ')
disp('Effluent average load')
disp('---------------------')
disp(['Effluent average SO2 load   = ',num2str(SO2eload/(1000*totalt)),' kg (-COD)/day'])
disp(['Effluent average SF load    = ',num2str(SFeload/(1000*totalt)),' kg COD/day'])
disp(['Effluent average SA load    = ',num2str(SAeload/(1000*totalt)),' kg COD/day'])
disp(['Effluent average SI load    = ',num2str(SIeload/(1000*totalt)),' kg COD/day'])
disp(['Effluent average SNH4 load  = ',num2str(SNH4eload/(1000*totalt)),' kg N/day'])
disp(['Effluent average SN2 load   = ',num2str(SN2eload/(1000*totalt)),' kg N/day'])
disp(['Effluent average SNOX load  = ',num2str(SNOXeload/(1000*totalt)),' kg N/day'])
disp(['Effluent average SPO4 load  = ',num2str(SPO4eload/(1000*totalt)),' kg P/day'])
disp(['Effluent average SALK load  = ',num2str(SALKeload/(1000*totalt)),' kmol HCO3/day'])
disp(['Effluent average XI load    = ',num2str(XIeload/(1000*totalt)),' kg COD/day'])
disp(['Effluent average XS load    = ',num2str(XSeload/(1000*totalt)),' kg COD/day'])
disp(['Effluent average XH load    = ',num2str(XHeload/(1000*totalt)),' kg COD/day'])
disp(['Effluent average XPAO load  = ',num2str(XPAOeload/(1000*totalt)),' kg COD/day'])
disp(['Effluent average XPP load   = ',num2str(XPPeload/(1000*totalt)),' kg P/day'])
disp(['Effluent average XPHA load  = ',num2str(XPHAeload/(1000*totalt)),' kg COD/day'])
disp(['Effluent average XA load    = ',num2str(XAeload/(1000*totalt)),' kg COD/day'])
disp(['Effluent average XTSS load  = ',num2str(XTSSeload/(1000*totalt)),' kg SS/day'])
disp(['Effluent average XMeOH load = ',num2str(XMeOHeload/(1000*totalt)),' kg SS/day'])
disp(['Effluent average XMeOH load = ',num2str(XMeOHeload/(1000*totalt)),' kg SS/day'])

disp(' ')
disp(['Effluent average Kjeldahl N load = ',num2str(totalNKjeload/(1000*totalt)),' kg N/d'])
disp(['Effluent average total N load    = ',num2str(totalNeload/(1000*totalt)),' kg N/d'])
disp(['Effluent average organic P load  = ',num2str(totalPorgeload/(1000*totalt)),' kg P/d'])
disp(['Effluent average total P load    = ',num2str(totalPeload/(1000*totalt)),' kg P/d'])
disp(['Effluent average total COD load  = ',num2str(totalCODeload/(1000*totalt)),' kg COD/d'])
disp(['Effluent average BOD5 load       = ',num2str(BOD5eload/(1000*totalt)),' kg/d'])
disp(' ')

disp('Other effluent quality variables')
disp('--------------------------------')
disp(['Influent Quality (I.Q.) index = ',num2str(IQ),' kg poll.units/d (original BSM1 version)'])
disp(['Effluent Quality (E.Q.) index = ',num2str(EQ),' kg poll.units/d (original BSM1 version)'])
disp(['Influent Quality (I.Q.) index = ',num2str(IQ_new),' kg poll.units/d (updated BSM1 version)'])
disp(['Effluent Quality (E.Q.) index = ',num2str(EQ_new),' kg poll.units/d (updated BSM1 version)'])
disp(['Influent Quality (I.Q.) index = ',num2str(IQ_P),' kg poll.units/d (updated ASM2d version)'])
disp(['Effluent Quality (E.Q.) index = ',num2str(EQ_P),' kg poll.units/d (updated ASM2d version)'])

disp(' ')
disp(['Sludge production for disposal = ',num2str(TSSproduced),' kg SS'])
disp(['Average sludge production for disposal per day = ',num2str(TSSproduced/totalt),' kg SS/d'])
disp(['Sludge production released into effluent = ',num2str(XTSSeload /1000),' kg SS'])
disp(['Average sludge production released into effluent per day = ',num2str(XTSSeload /(1000*totalt)),' kg SS/d'])
disp(['Total sludge production = ',num2str(TSSproduced+XTSSeload /1000),' kg SS'])
disp(['Total average sludge production per day = ',num2str(TSSproduced/totalt+XTSSeload/(1000*totalt)),' kg SS/d'])
% 
disp(' ')
disp(['Total aeration energy = ',num2str(airenergy),' kWh (original BSM1 version)'])
disp(['Average aeration energy per day = ',num2str(airenergy/totalt),' kWh/d (original BSM1 version)'])
disp(['Total aeration energy = ',num2str(airenergy_new),' kWh (updated BSM1 version)'])
disp(['Average aeration energy per day = ',num2str(airenergy_new/totalt),' kWh/d (updated BSM1 version)'])
disp(' ')
disp(['Total pumping energy (for Qintr, Qr and Qw) = ',num2str(pumpenergy),' kWh (original BSM1 version)'])
disp(['Average pumping energy per day (for Qintr, Qr and Qw) = ',num2str(pumpenergy/totalt),' kWh/d (original BSM1 version)'])
disp(['Total pumping energy (for Qintr, Qr and Qw) = ',num2str(pumpenergy_new),' kWh (based on BSM2 principles)'])
disp(['Average pumping energy per day (for Qintr, Qr and Qw) = ',num2str(pumpenergy_new/totalt),' kWh/d (based on BSM2 principles)'])
disp(' ')
disp(['Total mixing energy = ',num2str(mixenergy),' kWh (based on BSM2 principles)'])
disp(['Average mixing energy per day = ',num2str(mixenergy/totalt),' kWh/d (based on BSM2 principles)'])
disp(' ')
disp(['Total added carbon volume = ',num2str(Qcarbon),' m3'])
disp(['Average added carbon flow rate = ',num2str(Qcarbon/totalt),' m3/d'])
disp(['Total added carbon mass = ',num2str(carbonmass),' kg COD'])
disp(['Average added carbon mass per day = ',num2str(carbonmass/totalt),' kg COD/d'])
disp(' ')
disp(['Total added metal volume = ',num2str(Qmetal),' m3'])
disp(['Average added metal flow rate = ',num2str(Qmetal/totalt),' m3/d'])
disp(['Total added metal mass = ',num2str(metalmass),' kg COD'])
disp(['Average added metal mass per day = ',num2str(metalmass/totalt),' kg COD/d'])
disp(' ')
disp('Operational Cost Index')
disp('----------------------')
disp(['Sludge production cost index = ',num2str(TSScost),' (using weight 5 for BSM1)'])
disp(['Aeration energy cost index = ',num2str(airenergycost),' (original BSM1 version)'])
disp(['Updated aeration energy cost index = ',num2str(airenergy_newcost),' (updated BSM1 version)'])
disp(['Pumping energy cost index = ',num2str(pumpenergycost),' (original BSM1 version)'])
disp(['Updated pumping energy cost index = ',num2str(pumpenergy_newcost),' (based on BSM2 principles)'])
disp(['Carbon source addition cost index = ',num2str(carbonmasscost)])
disp(['Metal source addition cost index = ',num2str(metalmasscost)])
disp(['Mixing energy cost index = ',num2str(mixenergycost),' (based on BSM2 principles)'])
disp(['Total Operational Cost Index (OCI) = ',num2str(OCI),' (original BSM1 version)'])
disp(['Updated Total Operational Cost Index (OCI) = ',num2str(OCI_new),' (using new aeraration and pumping costs)'])
disp(' ')
% 
Nviolation=find(totalNevec2>totalNemax);
Pviolation=find(totalPevec2>totalPemax);
CODviolation=find(totalCODevec2>totalCODemax);
SNHviolation=find(SNH4evec2>SNHemax);
TSSviolation=find(XTSSevec2>TSSemax);
BOD5violation=find(BOD5evec2>BOD5emax);
% 
noofNviolation = 1;
noofPviolation = 1;
noofCODviolation = 1;
noofSNHviolation = 1;
noofTSSviolation = 1;
noofBOD5violation = 1;

disp('Effluent violations')
disp('-------------------')
disp(['95% percentile for effluent SNH (Ammonia95) = ',num2str(SNHeffprctile),' g N/m3'])
disp(['95% percentile for effluent SPO4(Phosphate95) = ',num2str(SPO4effprctile),' g N/m3'])
disp(['95% percentile for effluent TN (TN95) = ',num2str(TNeffprctile),' g N/m3'])
disp(['95% percentile for effluent TP (TP95) = ',num2str(TPeffprctile),' g N/m3'])
disp(['95% percentile for effluent TSS (TSS95) = ',num2str(TSSeffprctile),' g SS/m3'])
disp(' ')
% 
if not(isempty(Pviolation))
  disp('The maximum effluent total phosphorus level (2 mg N/l) was violated')
  disp(['during ',num2str(min(totalt,length(Pviolation)*sampletime)),' days, i.e. ',num2str(min(100,length(Pviolation)*sampletime/totalt*100)),'% of the operating time.'])
  for i=2:length(Pviolation)
    if Pviolation(i-1)~=(Pviolation(i)-1)
      noofPviolation = noofPviolation+1;
    end
  end
  disp(['The limit was violated at ',num2str(noofPviolation),' different occasions.'])
  disp(' ')
end

if not(isempty(Nviolation))
  disp('The maximum effluent total nitrogen level (18 mg N/l) was violated')
  disp(['during ',num2str(min(totalt,length(Nviolation)*sampletime)),' days, i.e. ',num2str(min(100,length(Nviolation)*sampletime/totalt*100)),'% of the operating time.'])
  for i=2:length(Nviolation)
    if Nviolation(i-1)~=(Nviolation(i)-1)
      noofNviolation = noofNviolation+1;
    end
  end
  disp(['The limit was violated at ',num2str(noofNviolation),' different occasions.'])
  disp(' ')
end

if not(isempty(CODviolation))
  disp('The maximum effluent total COD level (100 mg COD/l) was violated')
  disp(['during ',num2str(min(totalt,length(CODviolation)*sampletime)),' days, i.e. ',num2str(min(100,length(CODviolation)*sampletime/totalt*100)),'% of the operating time.'])
  for i=2:length(CODviolation)
    if CODviolation(i-1)~=(CODviolation(i)-1)
      noofCODviolation = noofCODviolation+1;
    end
  end
  disp(['The limit was violated at ',num2str(noofCODviolation),' different occasions.'])
  disp(' ')
end

if not(isempty(SNHviolation))
  disp('The maximum effluent ammonia nitrogen level (4 mg N/l) was violated')
  disp(['during ',num2str(min(totalt,length(SNHviolation)*sampletime)),' days, i.e. ',num2str(min(100,length(SNHviolation)*sampletime/totalt*100)),'% of the operating time.'])
  for i=2:length(SNHviolation)
    if SNHviolation(i-1)~=(SNHviolation(i)-1)
      noofSNHviolation = noofSNHviolation+1;
    end
  end
  disp(['The limit was violated at ',num2str(noofSNHviolation),' different occasions.'])
  disp(' ')
end

if not(isempty(TSSviolation))
  disp('The maximum effluent total suspended solids level (30 mg SS/l) was violated')
  disp(['during ',num2str(min(totalt,length(TSSviolation)*sampletime)),' days, i.e. ',num2str(min(100,length(TSSviolation)*sampletime/totalt*100)),'% of the operating time.'])
  for i=2:length(TSSviolation)
    if TSSviolation(i-1)~=(TSSviolation(i)-1)
      noofTSSviolation = noofTSSviolation+1;
    end
  end
  disp(['The limit was violated at ',num2str(noofTSSviolation),' different occasions.'])
  disp(' ')
end

if not(isempty(BOD5violation))
  disp('The maximum effluent BOD5 level (10 mg/l) was violated')
  disp(['during ',num2str(min(totalt,length(BOD5violation)*sampletime)),' days, i.e. ',num2str(min(100,length(BOD5violation)*sampletime/totalt*100)),'% of the operating time.'])
  for i=2:length(BOD5violation)
    if BOD5violation(i-1)~=(BOD5violation(i)-1)
      noofBOD5violation = noofBOD5violation+1;
    end
  end
  disp(['The limit was violated at ',num2str(noofBOD5violation),' different occasions.'])
  disp(' ')
end

figure(2)
plot(time(1:(end-1)),totalPevec2)
hold on
plot([time(1) time(end-1)],[totalPemax totalPemax],'r')
xlabel('time (days)')
ylabel('Total phosphorus concentration in effluent (mg N/l)')
title('Effluent total phosphorus and limit value')
hold off

figure(3)
plot(time(1:(end-1)),totalNevec2)
hold on
plot([time(1) time(end-1)],[totalNemax totalNemax],'r')
xlabel('time (days)')
ylabel('Total nitrogen concentration in effluent (mg N/l)')
title('Effluent total nitrogen and limit value')
hold off

figure(4)
plot(time(1:(end-1)),totalCODevec2)
hold on
plot([time(1) time(end-1)],[totalCODemax totalCODemax],'r')
xlabel('time (days)')
ylabel('Total COD concentration in effluent (mg COD/l)')
title('Effluent total COD and limit value')
hold off

figure(5)
plot(time(1:(end-1)),SNH4evec2)
hold on
plot([time(1) time(end-1)],[SNHemax SNHemax],'r')
xlabel('time (days)')
ylabel('Ammonia concentration in effluent (mg N/l)')
title('Effluent total ammonia and limit value')
hold off

figure(6)
plot(time(1:(end-1)),XTSSevec2)
hold on
plot([time(1) time(end-1)],[TSSemax TSSemax],'r')
xlabel('time (days)')
ylabel('Suspended solids concentration in effluent (mg SS/l)')
title('Effluent suspended solids and limit value')
hold off

figure(7)
plot(time(1:(end-1)),BOD5evec2)
hold on
plot([time(1) time(end-1)],[BOD5emax BOD5emax],'r')
xlabel('time (days)')
ylabel('BOD5 concentration in effluent (mg/l)')
title('Effluent BOD5 and limit value')
hold off

figure(8)
plot(time(1:(end-1)),TSSwasteconc.*Qwasteflow)
xlabel('time (days)')
ylabel('Instantaneous sludge wastage rate (kg SS/d)')

figure(9)
plot(time(1:(end-1)),EQvecinst_new./1000)
hold on
plot(time(1:(end-1)),EQvecinst_P./1000,'r')
xlabel('time (days)')
ylabel('Instantaneous Effluent Quality index (kg poll.units/d)')
hold off

figure(10)
plot(time(1:(end-1)),pumpenergyvec)
hold on
plot(time(1:(end-1)),pumpenergyvec_new,'r')
xlabel('time (days)')
ylabel('Instantaneous pumping energy (kWh/d)')
hold off

figure(11)
plot(time(1:(end-1)),airenergyvec)
hold on
plot(time(1:(end-1)),airenergyvec_new,'r')
xlabel('time (days)')
ylabel('Instantaneous aeration energy (kWh/d)')
hold off

 figure(12)
 plot(time(1:(end-1))-starttime,carbonmassvec,'b','LineWidth',1.5)
 xlabel('time (days)','FontSize',10,'FontWeight','bold')
 ylabel('Instantaneous carbon source dosage(kg COD/d)','FontSize',10,'FontWeight','bold')
 xlim([0 (stoptime-starttime)])
 set(gca,'LineWidth',1.5,'FontSize',10,'FontWeight','bold')
    
 figure(13)
 plot(time(1:(end-1))-starttime,metalmassvec,'b','LineWidth',1.5)
 xlabel('time (days)','FontSize',10,'FontWeight','bold')
 ylabel('Instantaneous metal salt dosage(kg MeOH/d)','FontSize',10,'FontWeight','bold')
 xlim([0 (stoptime-starttime)])
 set(gca,'LineWidth',1.5,'FontSize',10,'FontWeight','bold')
 
% Plot of the SNH, TN and TSS curves
SNHeffsort = sort(SNH4evec2);
TNeffsort = sort(totalNevec2);
TPeffsort = sort(totalPevec2);
TSSeffsort = sort(XTSSevec2);
n = size(SNH4evec2,1);
xvalues = [1:n].*(100/n);

figure(14)
plot(xvalues,SNHeffsort,'b','LineWidth',1.5)
hold on
plot([0 95],[SNHeffprctile SNHeffprctile],'k--','LineWidth',1.5)
plot([95 95],[0 SNHeffprctile],'k--','LineWidth',1.5)
xlabel('Ordered S_N_H effluent concentrations (%)','FontSize',10,'FontWeight','bold')
ylabel('S_N_H effluent concentrations (g N/m^3)','FontSize',10,'FontWeight','bold')
title('Ordered effluent S_N_H concentrations with 95% percentile','FontSize',10,'FontWeight','bold')
xlim([0 105])
set(gca,'LineWidth',1.5,'FontSize',10,'FontWeight','bold')
hold off

figure(15)
plot(xvalues,TNeffsort,'b','LineWidth',1.5)
hold on
plot([0 95],[TNeffprctile TNeffprctile],'k--','LineWidth',1.5)
plot([95 95],[0 TNeffprctile],'k--','LineWidth',1.5)
xlabel('Ordered TN effluent concentrations (%)','FontSize',10,'FontWeight','bold')
ylabel('TN effluent concentrations (g N/m^3)','FontSize',10,'FontWeight','bold')
title('Ordered effluent TN concentrations with 95% percentile','FontSize',10,'FontWeight','bold')
xlim([0 105])
set(gca,'LineWidth',1.5,'FontSize',10,'FontWeight','bold')
hold off

figure(16)
plot(xvalues,TPeffsort,'b','LineWidth',1.5)
hold on
plot([0 95],[TPeffprctile TPeffprctile],'k--','LineWidth',1.5)
plot([95 95],[0 TPeffprctile],'k--','LineWidth',1.5)
xlabel('Ordered TP effluent concentrations (%)','FontSize',10,'FontWeight','bold')
ylabel('TP effluent concentrations (g P/m^3)','FontSize',10,'FontWeight','bold')
title('Ordered effluent TP concentrations with 95% percentile','FontSize',10,'FontWeight','bold')
xlim([0 105])
set(gca,'LineWidth',1.5,'FontSize',10,'FontWeight','bold')
hold off

figure(17)
plot(xvalues,TSSeffsort,'b','LineWidth',1.5)
hold on
plot([0 95],[TSSeffprctile TSSeffprctile],'k--','LineWidth',1.5)
plot([95 95],[0 TSSeffprctile],'k--','LineWidth',1.5)
xlabel('Ordered TSS effluent concentrations (%)','FontSize',10,'FontWeight','bold')
ylabel('TSS effluent concentrations (g SS/m^3)','FontSize',10,'FontWeight','bold')
title('Ordered effluent TSS concentrations with 95% percentile','FontSize',10,'FontWeight','bold')
xlim([0 105])
set(gca,'LineWidth',1.5,'FontSize',10,'FontWeight','bold')
hold off

function [outvector] = changeScalarToVector(invariable,outvecsize)
%Vector to modify variables like Kla1in, carb1in etc to vectors from
%scalars
%% Inputs
%invariable - input variable that needs to be changed, if required
%outvecsize  - Size of the output vector
%outvector - output vector

if size(invariable,1)>1
    outvector=invariable;
else
    outvector=ones(outvecsize).*invariable;
end
end
