function tempReadTimerCallback

global currentTemp      % vector holding the current temperature values for all physical channels
global csgHandle;
persistent bufferFull;

if isempty(bufferFull)
    bufferFull=0;
end;

currentTemp.avgCnt = currentTemp.avgCnt+1;
if currentTemp.avgCnt > currentTemp.avg
    currentTemp.avgCnt = 1;
    bufferFull=1;
end;

%% read actual hardware temps
currentTemp.buffer(4:currentTemp.Nchan-4,currentTemp.avgCnt) = readTemps(currentTemp.Nchan-7);  % read raw temps from data translation
currentTemp.buffer(currentTemp.Nchan-3:currentTemp.Nchan,currentTemp.avgCnt) = readChillers;  % read raw temps from chillers

%% create virtual temperature channels
currentTemp.buffer(1,currentTemp.avgCnt)=mean(currentTemp.buffer(9:11));  % average optic temp
currentTemp.buffer(2,currentTemp.avgCnt)=mean(currentTemp.buffer(currentTemp.Nchan-3:currentTemp.Nchan,currentTemp.avgCnt));  % average chiller temp
currentTemp.buffer(3,currentTemp.avgCnt)=mean(currentTemp.buffer(5:8));  % average subframe temp

%% get rolling average
if bufferFull
    currentTemp.avgTemps=mean(currentTemp.buffer,2);
else
    currentTemp.avgTemps=mean(currentTemp.buffer(:,1:currentTemp.avgCnt),2);
end;

%% Display "real time" temps in control panel
h=findobj(csgHandle,'Tag','st_ot');
set(h,'String',num2str(currentTemp.avgTemps(1),'%5.3f'));
h=findobj(csgHandle,'Tag','st_cp1');
set(h,'String',num2str(currentTemp.avgTemps(currentTemp.Nchan-3),'%4.2f'));
h=findobj(csgHandle,'Tag','st_cp2');
set(h,'String',num2str(currentTemp.avgTemps(currentTemp.Nchan-2),'%4.2f'));
h=findobj(csgHandle,'Tag','st_cp3');
set(h,'String',num2str(currentTemp.avgTemps(currentTemp.Nchan-1),'%4.2f'));
h=findobj(csgHandle,'Tag','st_cp4');
set(h,'String',num2str(currentTemp.avgTemps(currentTemp.Nchan),'%4.2f'));
h=findobj(csgHandle,'Tag','st_sf1'); 
set(h,'String',num2str(currentTemp.avgTemps(5),'%4.2f'));
h=findobj(csgHandle,'Tag','st_sf2'); 
set(h,'String',num2str(currentTemp.avgTemps(6),'%4.2f'));
h=findobj(csgHandle,'Tag','st_sf3'); 
set(h,'String',num2str(currentTemp.avgTemps(7),'%4.2f'));
h=findobj(csgHandle,'Tag','st_sf4'); 
set(h,'String',num2str(currentTemp.avgTemps(8),'%4.2f'));
