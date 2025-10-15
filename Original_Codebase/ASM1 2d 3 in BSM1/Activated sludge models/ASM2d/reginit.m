%use these for discrete PI O2 controller
%K = 40;
%Ti = 0.0003;
%h = 0.001;

%continuous PI O2-controller
KSO5 = 500;      %Amplification
TiSO5 = 0.001;   %I-part time constant, integral time constant
TtSO5 = 0.0002;  %Antiwindup time constant, tracking time constant
SO5intstate = 50;    %initial value of I-part
SO5awstate = 0;  %initial value of antiwindup I-part
SO5ref = 2;      %setpoint for controller
useantiwindupSO5 = 1;  %0=no antiwindup, 1=use antiwindup for oxygen control

%continuous PI Qintr-controller
KQintr = 15000;      %Amplification
TiQintr = 0.05;   %I-part time constant, integral time constant
TtQintr = 0.03;   %Antiwindup time constant, tracking time constant
Qintrintstate = 0;    %initial value of I-part
Qintrawstate = 0;  %initial value of antiwindup I-part
SNO2delayinit = 1;     %initial value of delayed measurement value
SNO2ref = 1;      %setpoint for controller
useantiwindupQintr = 1;  %0=no antiwindup, 1=use antiwindup for Qintr control
Kfeedforward = 0;  %1.2 Amp. for feedforward of Qin to Qintr (0=off)
		     %K=Kfeedforward*(SNOref/(SNOref+1))*(Qffref*Qin0-55338)
Qffref = 3;

usenoiseSNO2 = 1;     %0=no noise, 1=use noise for nitrate sensor

noiseseedSNO2 = 1;
noisevarianceSNO2 = 0.01;
noisemeanSNO2 = 0;
