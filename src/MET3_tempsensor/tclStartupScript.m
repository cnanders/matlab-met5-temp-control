global slgHandle

if ~isempty(findobj(slgHandle,'Name','Sensor Log'))
    %figure(0);
    beep;
    fprintf('TEMP SENSOR ALREADY RUNNING!!!\n');
    return;
end;
bs=pwd;
cd c:\
dos('c:\tempmon &');
cd(bs);

global coolMode
global heatMode
global coastMode
global Ki
global Kp
global Kd
global Kic
global tempGoal
global currentTemp;
global roomTemp;
global setPoint
global roomSetPoint;
global setPointHist;
global tempErrorHist;
global tempDerivHist;
global default_setPoint    
global roomSetPoint
global roomSetPointHist;
global roomTempErrorHist;
global roomTempHist
global adp_kpr_cnt
global adp_Kpr
global csgHandle   

%dos('C:\MATLAB6p5\bin\win32\matlab.exe /r chiller_server /minimize &');

!copy TV_history.mat TV_history.mat.bak;

fid=fopen('c:\roomtemp.txt','rt');
roomTemp=fscanf(fid,'%f',1);
fclose(fid);
if (roomTemp<15)
   fid=fopen('c:\roomtemp.txt','wt');
   roomTemp=fprintf(fid,'0.0');
   fclose(fid);
end;

load tcl.mat
csgHandle=CoolStateGUI;
slgHandle=sensorlog;

disp('cnanderson added this 2010.06.02 \n');
disp('Values loaded from tcl.mat \n')
Kp
Ki
Kd
Kic
adp_Kpr
setPoint

h=findobj(csgHandle,'Tag','ed_kp');
set(h,'String',num2str(Kp,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_ki');
set(h,'String',num2str(Ki,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_kd');
set(h,'String',num2str(Kd,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_kic');
set(h,'String',num2str(Kic,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_set_arr');
set(h,'String',num2str(adp_Kpr,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_set_chiller');
set(h,'String',num2str(setPoint,'%3.1f'));
h=findobj(csgHandle,'Tag','st_ot');
set(h,'String',num2str(currentTemp,'%5.3f'));
h=findobj(csgHandle,'Tag','st_rt');
set(h,'String',num2str(roomTemp,'%4.2f'));
h=findobj(csgHandle,'Tag','st_rtg');
set(h,'String',num2str(roomSetPoint,'%4.2f'));

h=findobj(csgHandle,'Tag','st_kpg');
set(h,'String',num2str(0,'%4.2f'));
h=findobj(csgHandle,'Tag','st_kig');
set(h,'String',num2str(0,'%4.2f'));
h=findobj(csgHandle,'Tag','st_kdg');
set(h,'String',num2str(0,'%4.2f'));
figure(10);