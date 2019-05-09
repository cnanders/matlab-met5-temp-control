function GUI_set_K

global Kp;
global Ki;
global Kd;
global Kic;
global slgHandle;

s=get(gcbo,'String');
v=str2num(s);
t=get(gcbo,'Tag');
switch (t)
case 'ed_kp'
    if isempty(v)
        set(gcbo,'String',num2str(Kp,'%4.2f'));
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        Kp=v;
    end; 
case 'ed_ki'
    if isempty(v)
        set(gcbo,'String',num2str(Ki,'%4.2f'));
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        Ki=v;
    end; 
case 'ed_kd'
    if isempty(v)
        set(gcbo,'String',num2str(Kd,'%4.2f'));
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        Kd=v;
    end; 
case 'ed_kic'
    if isempty(v)
        set(gcbo,'String',num2str(Kic,'%4.2f'));
    else
        set(gcbo,'String',num2str(v,'%4.2f'));
        Kic=v;
    end; 
end;

sensorlog('Value_Callback',slgHandle);


