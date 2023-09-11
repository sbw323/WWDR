startindex=max(find(t <= starttime));
stopindex=min(find(t >= stoptime));

time=t(startindex:stopindex);
ASinputx=ASinput(startindex:stopindex,:);
reac1x=reac1(startindex:stopindex,:);
reac2x=reac2(startindex:stopindex,:);
reac3x=reac3(startindex:stopindex,:);
reac4x=reac4(startindex:stopindex,:);
reac5x=reac5(startindex:stopindex,:);
settlerx=settler(startindex:stopindex,:);
inx=in(startindex:stopindex,:);

figure(14);
subplot(3,3,1);
plot(time,reac1x(:,14));
grid on;
title('TSS, reactor 1');
subplot(3,3,2);
plot(time,reac2x(:,14));
grid on;
title('TSS, reactor 2');
subplot(3,3,3);
plot(time,reac3x(:,14));
grid on;
title('TSS, reactor 3');
subplot(3,3,4);
plot(time,reac4x(:,14));
grid on;
title('TSS, reactor 4');
subplot(3,3,5);
plot(time,reac5x(:,14));
grid on;
title('TSS, reactor 5');

subplot(3,3,6);
plot(time,(ASinputx(:,14)./ASinputx(:,15)));
grid on;
title('TSS, input to AS');

subplot(3,3,7);
plot(time,settlerx(:,14));
grid on;
title('TSS, underflow');
subplot(3,3,8);
plot(time,settlerx(:,30));
grid on;
title('TSS, effluent');
subplot(3,3,9);
plot(time,inx(:,14));
grid on;
title('TSS, influent');
