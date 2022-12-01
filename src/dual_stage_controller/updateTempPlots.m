function updateTempPlots

global epHandle
global ctpHandle     % handle to individual channel plot figure
global controlParams
global tempSensorData

figure(epHandle);
h=findobj(epHandle,'Tag','time_range_eb');
tr=str2num(get(h,'string'));
if isempty(tr)
    tr=controlParams.Nbuf*controlParams.T/60;
end;
if tr<=0
    tr=controlParams.Nbuf*controlParams.T/60;
end;
if tr>controlParams.Nbuf*controlParams.T/60
    tr=controlParams.Nbuf*controlParams.T/60;
end;
tri=max(1,controlParams.Nbuf-round(tr*60/controlParams.T));
tri=min(tri,controlParams.Nbuf-2);
h=findobj(epHandle,'Tag','po_temp_axes');
axes(h);
bs=historyUnwrap(controlParams.tempErrorHist,controlParams.currentIdx);
t=plotdom(-controlParams.Nbuf*controlParams.T/60,0,controlParams.Nbuf);
plot(t(tri:end),bs(tri:end),t(tri:end),bs(tri:end)*0+0.01,'r',t(tri:end),bs(tri:end)*0-0.01,'r');
grid on;
ylabel('PO Temperature Error');

h=findobj(epHandle,'Tag','room_temp_axes');
axes(h);
bs1=historyUnwrap(tempSensorData.temps(9,:),tempSensorData.currentIdx);
bs2=historyUnwrap(tempSensorData.temps(8,:),tempSensorData.currentIdx);
bs3=historyUnwrap(tempSensorData.temps(10,:),tempSensorData.currentIdx);
plot(t(tri:end),bs1(tri:end),t(tri:end),bs2(tri:end),'r',t(tri:end),bs3(tri:end),'g');
grid on;
ylabel('AirLid (b), Lid(r), AirFloor(g)');

h=findobj(epHandle,'Tag','sf_temp_axes');
axes(h);
bs=historyUnwrap(controlParams.subframeHist,controlParams.currentIdx);
%plot(t(tri:end),bs(tri:end),t(tri:end),bs(tri:end)*0+controlParams.subframeSetPoint+0.02,'r',t(tri:end),bs(tri:end)*0+controlParams.subframeSetPoint-0.02,'r');
plot(t(tri:end),bs(tri:end),t(tri:end),bs(tri:end)*0+controlParams.adp_Kpr+0.02,'r',t(tri:end),bs(tri:end)*0+controlParams.adp_Kpr-0.02,'r');
grid on;
ylabel('Subframe Temp');

h=findobj(epHandle,'Tag','cp_temp_axes');
axes(h);
bs=historyUnwrap(controlParams.chillplateHist,controlParams.currentIdx);
bs2=historyUnwrap(controlParams.setPointHist,controlParams.currentIdx);
plot(t(tri:end),bs(tri:end),t(tri:end),bs2(tri:end));
grid on;
ylabel('Chill Plate: actual(b) setpoint (r)');

figure(ctpHandle);
h=findobj(ctpHandle,'Tag','channel_temps_axes');
axes(h);
bs1=historyUnwrap(tempSensorData.temps(18+3,:),tempSensorData.currentIdx);bs1=bs1-median(bs1);
bs2=historyUnwrap(tempSensorData.temps(19+3,:),tempSensorData.currentIdx);bs2=bs2-median(bs2);
bs3=historyUnwrap(tempSensorData.temps(20+3,:),tempSensorData.currentIdx);bs3=bs3-median(bs3);
bs4=historyUnwrap(tempSensorData.temps(17+3,:),tempSensorData.currentIdx);bs4=bs4-median(bs4);
bs5=historyUnwrap(tempSensorData.temps(31+3,:),tempSensorData.currentIdx);bs5=bs5-median(bs5);
bs6=historyUnwrap(tempSensorData.temps(32+3,:),tempSensorData.currentIdx);bs6=bs6-median(bs6);
bs7=historyUnwrap(tempSensorData.temps(30+3,:),tempSensorData.currentIdx);bs7=bs7-median(bs7);
plot(t(tri:end),bs1(tri:end),t(tri:end),bs2(tri:end),'r',t(tri:end),bs3(tri:end),'g',t(tri:end),bs4(tri:end),'m',t(tri:end),bs5(tri:end),'m',t(tri:end),bs6(tri:end),'m',t(tri:end),bs7(tri:end),'c');
grid on;
ylabel('M1a (b), M1b(r), M1c(g), M2(m), Mod3TC(c)');
title('Individual PO temps');
