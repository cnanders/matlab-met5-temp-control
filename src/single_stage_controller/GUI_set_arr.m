function GUI_set_arr

global controlParams
global csgHandle

s=get(gcbo,'String');
v=str2num(s);
if isempty(v)
    set(gcbo,'String',num2str(controlParams.adp_Kpr,'%4.2f'));
    return;
end

%% reset the history arrays
controlParams.tempErrorHist = controlParams.tempErrorHist*0;
controlParams.tempDerivHist = controlParams.tempDerivHist*0;
controlParams.chillplateHist = controlParams.chillplateHist*0+v;

%% call the control loop
tempSensorTimerCallback;
