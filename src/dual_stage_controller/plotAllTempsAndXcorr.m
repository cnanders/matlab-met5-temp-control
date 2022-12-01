function updateTempPlots(tr)

global epHandle
global controlParams
global tempSensorData

figure();
if nargin==0
    tr=controlParams.Nbuf*controlParams.T/60;
end;

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

bs=historyUnwrap(controlParams.tempErrorHist,controlParams.currentIdx);
t=plotdom(-controlParams.Nbuf*controlParams.T/60,0,controlParams.Nbuf);
plot(t(tri:end),bs(tri:end),'ro');
grid on;
hold all;

clear xc;
for i=1:32
    tmp(i).a=historyUnwrap(tempSensorData.temps(i,:),tempSensorData.currentIdx);
    tmp(i).a=tmp(i).a-mean(tmp(i).a);
    w=find(abs(tmp(i).a)>4);
    tmp(i).a(w)=0;
    plot(t(tri:end),tmp(i).a(tri:end));
    xc(i)=xcorr(bs,tmp(i).a,0)./sqrt(abs(sum(bs)).*abs(sum(tmp(i).a)));
end;

figure;
plot(xc);
figure
for i=1:32
    plot(t(tri:end),bs(tri:end),t(tri:end),tmp(i).a(tri:end));
    title(sprintf('%d',i-1));
    pause;
end;