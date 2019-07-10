function updateTempPlots

global epHandle
global controlParams

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
grid;
ylabel('Control Temperature Error');
h=findobj(epHandle,'Tag','sf_temp_axes');
axes(h);
bs=historyUnwrap(controlParams.subframeHist,controlParams.currentIdx);
plot(t(tri:end),bs(tri:end));
grid;
ylabel('Subframe Temp');
h=findobj(epHandle,'Tag','cp_temp_axes');
axes(h);
bs=historyUnwrap(controlParams.chillplateHist,controlParams.currentIdx);
plot(t(tri:end),bs(tri:end));
grid;
ylabel('Chill Plate Temp');