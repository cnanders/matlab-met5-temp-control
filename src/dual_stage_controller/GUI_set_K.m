function GUI_set_K

global controlParams
global csgHandle
global tempSensorTimer

s=get(gcbo,'String');
v=str2num(s);
t=get(gcbo,'Tag');

%% read in value and set the appropriate control parameter structure value
switch (t)
case 'ed_set_target'
    if isempty(v)
        set(gcbo,'String',num2str(controlParams.tempGoal,'%4.2f'));
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        controlParams.tempGoal=v;
    end; 
case 'ed_kp'
    if isempty(v)
        set(gcbo,'String',num2str(controlParams.Kp,'%4.2f'));
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        controlParams.Kp=v;
    end; 
case 'ed_ki'
    if isempty(v)
        set(gcbo,'String',num2str(controlParams.Ki,'%4.2f'));
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        controlParams.Ki=v;
    end; 
case 'ed_kd'
    if isempty(v)
        set(gcbo,'String',num2str(controlParams.Kd,'%4.2f'));
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        controlParams.Kd=v;
    end; 
case 'ed_kpsf'
    if isempty(v)
        set(gcbo,'String',num2str(controlParams.Kpsf,'%4.2f'));
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        controlParams.Kpsf=v;
    end; 
case 'ed_kisf'
    if isempty(v)
        set(gcbo,'String',num2str(controlParams.Kisf,'%4.2f'));
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        controlParams.Kisf=v;
    end; 
case 'ed_kdsf'
    if isempty(v)
        set(gcbo,'String',num2str(controlParams.Kdsf,'%4.2f'));
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        controlParams.Kdsf=v;
    end;   
case 'ed_kdT'
    if isempty(v)
        set(gcbo,'String',num2str(controlParams.KdT,'%4.2f'));
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        controlParams.KdT=v;
    end; 
case 'ed_T'
    if isempty(v)
        set(gcbo,'String',num2str(controlParams.T,'%4.2f'));
    elseif v<1 | v>60
        set(gcbo,'String',num2str(controlParams.T,'%4.2f'));            
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        controlParams.T=v;
        stop(tempSensorTimer);
        set(tempSensorTimer,'Period', controlParams.T*60);
        start(tempSensorTimer);
        return;
    end; 
end;

%% call the control loop
tempSensorTimerCallback;


