function GUI_set_acpr

global controlParams
global csgHandle
global tempSensorData   % temperature data structure (see tempControlLoop.m for details)

s=get(gcbo,'String');
v=str2num(s);
if isempty(v)
    set(gcbo,'String',num2str(controlParams.adp_Kpr,'%4.2f'));
    return;
end

%% reset the history arrays
controlParams.sfTempErrorHist = controlParams.sfTempErrorHist*0;
controlParams.sfTempDerivHist = controlParams.sfTempDerivHist*0;
controlParams.chillplateHist = controlParams.chillplateHist*0+v;

%% call the control loop
    controlParams = tempControlLoop(tempSensorData,controlParams,1); % do not add to control error history
    setChillers(controlParams.setPoint);