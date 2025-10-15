% determining SRT
% determining Biomass in activated sludge tanks 
Biomassvec=0.75*([reac1part(:,12)*VOL1+reac1part(:,13)*VOL1+reac1part(:,16)*VOL1] + [reac2part(:,12)*VOL2+reac2part(:,13)*VOL2+reac2part(:,16)*VOL2]+ [reac3part(:,12)*VOL3+reac3part(:,13)*VOL3+reac3part(:,16)*VOL3] + [reac4part(:,12)*VOL4+reac4part(:,13)*VOL4+reac4part(:,16)*VOL4] + [reac5part(:,12)*VOL5+reac5part(:,13)*VOL5+reac5part(:,16)*VOL5] + [reac6part(:,12)*VOL6+reac6part(:,13)*VOL6+reac6part(:,16)*VOL6]+ [reac7part(:,12)*VOL7+reac2part(:,13)*VOL7+reac7part(:,16)*VOL7]);
TSSvecreactor=reac1part(:,17)*VOL1+reac2part(:,17)*VOL2+reac3part(:,17)*VOL3+reac4part(:,17)*VOL4+reac5part(:,17)*VOL5 + reac6part(:,17)*VOL6+reac7part(:,17)*VOL7 ; %TSS in aeration tanks

% Waste sludge production
Qwasteflow = settlerpart(:,27);
TSSwasteconc = settlerpart(:,17);%%(changed from BSM1*)
TSSuvec2 =TSSwasteconc.*Qwasteflow; % TSS in WAS, in g/d
TSSevec2=settlerpart(:,44).*settlerpart(:,47); %TSS in the effluent, in g/d (changed from BSM1*)

% SRT for sludge in aeration tanks, settler not considered
SRTvec =TSSvecreactor./(TSSuvec2+TSSevec2); % TSS in reactor / TSS removed from the system
SRTvec = smoothing_data(SRTvec,3)'; % SRTvec filtering using 3 days data

SRTReasonableLimit=20;

for i=1:length(SRTvec) %To replace SRTvec values >SRTReasonableLimit for SRTReasonableLimit
    if SRTvec(i)>SRTReasonableLimit
       SRTvec(i)=SRTReasonableLimit;
     else
       SRTvec(i)=SRTvec(i);     
    end     
end

%%%3. Secondary treatment data

%Hidraulic_RT    = (VOL1+VOL2+VOL3+VOL4+VOL5)/(Qinav);
AAA       = (sum(SRTvec.*timevector))/totalt;
