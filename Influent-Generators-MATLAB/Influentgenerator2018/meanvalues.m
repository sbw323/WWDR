 function [ym, yw, yd, yh]=meanvalues(t,x)

%t is the time vector 
%x is the vector with flow rate data
%Note that the length of t and x should be identical

data=timetable(t,x);
ym=retime(data,'monthly',@(x)nanmean(x(:)));
yw=retime(data,'weekly',@(x)nanmean(x(:)));
yd=retime(data,'daily',@(x)nanmean(x(:)));
yh=retime(data,'hourly',@(x)nanmean(x(:)));
end
  