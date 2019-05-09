function GUI_set_arr

global tempErrorHist;
global roomTempErrorHist;
global roomTempHist
global tempDerivHist;
global adp_Kpr
global slgHandle

s=get(gcbo,'String');
v=str2num(s);
if isempty(v)
    set(gcbo,'String',num2str(adp_Kpr,'%4.2f'));
    return;
end

tempErrorHist = tempErrorHist*0;
roomTempErrorHist = roomTempErrorHist*0;
tempDerivHist = tempDerivHist*0;
roomTempHist = roomTempHist*0+v;
sensorlog('Value_Callback',slgHandle);

