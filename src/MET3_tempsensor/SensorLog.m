function varargout = SensorLog(varargin)
% SENSORLOG Application M-file for SensorLog.fig
%    FIG = SENSORLOG launch SensorLog GUI.
%    SENSORLOG('callback_name', ...) invoke the named callback.

% Last Modified by Layton Hale 7/23/2001

if nargin == 0  % Launch the GUI program
    
    % Open the Sensor Log window (figure1)
    fig1 = openfig(mfilename,'reuse');
    % mod by Patrick Naulleau
	%if nargout > 0
	%	varargout{1} = fig1;
    %end
	set(fig1,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure containing gui handles. This structure can
    % also hold application data to pass to callbacks. When finished 
    % adding application data, store it using guidata(). 
	Data = guihandles(fig1);
    Data.figure2 = [];
    
    % Open the Agilent 34970A data acquisition system
    g1 = gpib('ni',0,1);            % Create GPIB object
    
    disp(g1)
    
    g1.name = 'SL';                 % Use GPIB name as a control state
    fopen(g1);                      % Open connection
	Data.g1 = g1;
    guidata(fig1, Data);
    
    ID = query(g1,'*IDN?');         % Instrument identification
    disp(['Connecting to the ',ID])
    
    % Initialize calibration table
    Calibration_Callback(fig1)    
    
    % Get any sensor data stored in the Agilent 34970A
    %GetSensorData(Data)         % See the subfunction in this file
    % instead of getting data from Agilent reload old data from disk
    set(Data.Interval,'Value',4); % set read interval to 15 minutes
    set(Data.Temp1,'Value',1); % turn on all temp sensor plotting
    set(Data.Temp2,'Value',1);
    set(Data.Temp3,'Value',1);
    set(Data.Temp4,'Value',1);
    RestoreOldSensorData(Data);
    
    % Configure scanning for the Sensor Log at the start
    ConfigScanOnce(Data)        % See the subfunction in this file

    % Set TimerPeriod to the current Interval
    Interval_Callback(fig1)     % See the subfunction in this file
    
    % Set the property TimerAction to call TimerAction_Fcn.
    g1.TimerAction = 'TimerAction_Fcn';
    
    % Set the property BytesAvailableAction to call BytesAvailableAction_Fcn.
    g1.BytesAvailableAction = {'BytesAvailableAction_Fcn',fig1,[]};

    fprintf(g1,'INIT')
    fprintf(g1,'FETCH?')
    readasync(g1)
    
    if nargout > 0
		varargout{1} = Data.figure1;
	end

    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
		disp(lasterr);
    end

end

%| ABOUT HANDLES:
%| A structure containing handles of components in the GUI (using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2, etc.)
%| is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback. You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| ABOUT CALLBACKS:
%| Subfunctions in this file execute when objects' callback properties 
%| call them through the FEVAL switchyard above. 
%| This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the object. Add any extra arguments after the 
%| last argument, before the final closing parenthesis.

% --------------------------------------------------------------------
function Interval_Callback(h)
% Callback subfunction for the popup menu Interval (Data.Interval)
Data = guidata(h);
interval_index = get(Data.Interval,'Value');
interval_array = get(Data.Interval,'UserData');
interval = interval_array(1,interval_index);
      
% Change TimerPeriod only if Interval is different
if Data.g1.TimerPeriod ~= interval
    if strcmp(Data.g1.name,'SL')    % and if sensor Log is active
        
        % Set the Data Storage textbox
        nDays = 5000*interval/86400;
        set(Data.Storage,'String',sprintf('%5.3g days',nDays));

        % Set Display to be larger than Interval
        display_index = get(Data.Display,'Value');
        display_array = get(Data.Display,'UserData');
        display = display_array(display_index);
        if interval >= display
            I = find(display > interval);
            set(Data.Display,'Value',I(1))
        end

        % Wait to communicate with GPIB until idle
        while ~strcmp(Data.g1.TransferStatus,'idle')
            pause(0.1)
        end
        pause(0.1)
        
        % Set the integration time (power line cycles)
        NPLC = interval_array(2,interval_index);
        fprintf(Data.g1,'VOLT:DC:NPLC %d,(@101:106)',NPLC)
        fprintf(Data.g1,'ZERO:AUTO OFF, (@101:110)')
        
        % Set the GPIB TimerPeriod and Timeout properties
        fclose(Data.g1)
        Data.g1.TimerPeriod = interval;
        Data.g1.Timeout = 0.2*NPLC + 5;
        fopen(Data.g1)
        
    else                % Actuator Control is active, can't close g1
        interval_index = ...
            find(interval_array(1,:) == Data.g1.TimerPeriod);
        if interval_index
            set(Data.Interval,'Value',interval_index);
        end
    end
end

% --------------------------------------------------------------------
function Calibration_Callback(h)
% Callback subfunction for the popup menu Calibration (Data.Calibration) 
% Store current calibration table in UserData.
Data = guidata(h);

switch get(Data.Calibration,'Value')

case 1  % Nominal calibration
    cal = {
        [-10,0,10;-130,0,130]           % {1} LVDT 1 (volts; microns)
        [-10,0,10;-130,0,130]           % {2} LVDT 2 (volts; microns)
        [-10,0,10;-130,0,130]           % {3} LVDT 3 (volts; microns)
        [-10,0,10;-130,0,130]           % {4} LVDT 4 (volts; microns)
        [-10,0,10;-130,0,130]           % {5} LVDT 5 (volts; microns)
        [-10,0,10;-130,0,130]           % {6} LVDT 6 (volts; microns)
        
        [15,25;15,25]                   % {7}  Temp 1 (C; C)
        [15,25;15,25]                   % {8}  Temp 2 (C; C)
        [15,25;15,25]                   % {9}  Temp 3 (C; C)
        [15,25;15,25]                   % {10} Temp 4 (C; C)
        
        % {11} A = T*S
        [0.28679 -0.49673 0.81915  0.059195 -0.055682
        -0.28679  0.49673 0.81915  0.018624 -0.079105
         0.28679  0.49673 0.81915  0.018624  0.079105
        -0.28679 -0.49673 0.81915  0.059195  0.055682
        -0.57358  0       0.81915 -0.077819 -0.023424
         0.57358  0       0.81915 -0.077819  0.023424]
     
        % {12} S = T*A
        [0.44206 -0.13908 0.13908 -0.44206 -0.58114  0.58114
        -0.41583  0.59076 0.59076 -0.41583 -0.17493 -0.17493
         0.20346  0.20346 0.20346  0.20346  0.20346  0.20346
         2.1417   2.1417  2.1417   2.1417  -4.2834  -4.2834
        -3.7096  -3.7095  3.7095   3.7096   0        0]
    
        120};   % {13} Travel limit (+/- micron all actuators)
    
case 2  % POB 1 calibration
    cal = {
        % {1} LVDT 1
        [-10.791, -9.019, -4.516, 0,  3.730, 7.204, 10.250  % volts
        -128,   -101,    -49,     0, 52,    98,    126]     %microns
        % {2} LVDT 2
        [-10.379, -7.322, -3.297, 0,  4.039, 8.081, 10.511; % volts
        -136,    -98,    -47,     0, 50,   102,    137]     %microns
        % {3} LVDT 3
        [-10.291, -8.042, -3.993, 0,  3.886, 7.498, 10.133; % volts
        -130,   -101,    -50,     0, 50,    98,    133]     %microns
        % {4} LVDT 4
        [-10.222, -7.292, -3.599,  0,  4.434, 8.710, 10.070 % volts
        -127,   -101,    -48,      0, 53,   100,    129]    %microns
        % {5} LVDT 5
        [-10.248, -7.779, -3.466, 0,  3.525, 7.717, 10.021  % volts
        -131,   -102,    -48,     0, 50,   102,    129]     %microns
        % {6} LVDT 6
        [-10.521, -7.294, -3.509, 0,  4.281, 8.483, 9.984   % volts
        -133,    -99,    -49,     0, 53,    99,   130]      %microns
        
        [15,25;15,25]                   % {7}  Temp 1 (C; C)
        [15,25;15,25]                   % {8}  Temp 2 (C; C)
        [15,25;15.015,25.015]           % {9}  Temp 3 (C; C)
        [15,25;15.006,24.996]           % {10} Temp 4 (C; C)
        
        % {11} A = T*S
        [0.28679 -0.49673 0.81915  0.059195 -0.055682
        -0.28679  0.49673 0.81915  0.018624 -0.079105
         0.28679  0.49673 0.81915  0.018624  0.079105
        -0.28679 -0.49673 0.81915  0.059195  0.055682
        -0.57358  0       0.81915 -0.077819 -0.023424
         0.57358  0       0.81915 -0.077819  0.023424]
     
        % {12} S = T*A
        [0.44206 -0.13908 0.13908 -0.44206 -0.58114  0.58114
        -0.41583  0.59076 0.59076 -0.41583 -0.17493 -0.17493
         0.20346  0.20346 0.20346  0.20346  0.20346  0.20346
         2.1417   2.1417  2.1417   2.1417  -4.2834  -4.2834
        -3.7096  -3.7095  3.7095   3.7096   0        0]
    
        120};   % {13} Travel limit (+/- micron all actuators)
    
case 3  % POB 2 calibration currently has nominal values
    cal = {
        % {1} LVDT volts;microns
        [-8.232,-6.548,-4.883,-3.207,-1.530,0.137,1.803,3.460,5.125,6.764,8.439
         -122.9,-97.9, -73.1,-48.1,-23.0, 2.1, 27.1, 52.1, 77.2, 102.0, 127.2]
        % {2} LVDT 2 (volts; microns)
        [-8.366,-6.67, -4.966,-3.27, -1.60, 0.086,1.75, 3.42, 5.06, 6.71, 8.33
         -125.0,-100.2,-75.1,-50.0,-25.2, 0.1, 25.1, 50.1, 75.0, 100.0, 125.0]           
        % {3} LVDT 3 (volts; microns)
        [-8.344,-6.64, -4.95, -3.266,-1.58, 0.114,1.789,3.46, 5.12, 6.775,8.415
         -125.1,-99.9, -75.0,-50.1,-25.1, 0.0, 25.0, 50.1, 75.1, 100.1, 125.0]    
        % {4} LVDT 4 (volts; microns)
        [-8.34, -6.67, -4.93, -3.27, -1.572,0.111,1.78, 3.44, 5.10, 6.74, 8.36
         -125.0,-100.6,-74.8,-50.2,-24.9, 0.2, 25.3, 50.2, 75.2, 100.1, 124.9]     
        % {5} LVDT 5 (volts; microns)
        [-8.415,-6.69, -5.00, -3.33, -1.63, 0.044,1.719,3.38, 5.04, 6.69, 8.34
         -125.0,-100.1,-75.0,-50.2,-25.0, 0.0, 25.0, 50.0, 75.1, 100.1, 125.0]  
        % {6} LVDT 6 (volts; microns)
        [-8.246,-6.525,-4.826,-3.153,-1.431,0.231,1.908,3.586,5.241,6.893,8.535
         -124.9,-99.9,-75.2, -49.8,-25.1, -2.0, 25.2, 50.1, 75.1, 99.9, 125.1]
        
        [15,25;15,25]                           % {7}  Temp 1 (C; C)
        [15,25;15.047,25.047]                   % {8}  Temp 2 (C; C)
        [15,25;15.029,25.029]                   % {9}  Temp 3 (C; C)
        [15,25;14.925,24.925]                   % {10} Temp 4 (C; C)
        
        % {11} A = T*S
        [0.2833   -0.4884    0.8143    0.0584   -0.0548
        -0.2793    0.4990    0.8119    0.0181   -0.0787
         0.2875    0.4930    0.8078    0.0189    0.0797
        -0.2889   -0.4907    0.8251    0.0593    0.0559
        -0.5682   -0.0131    0.8266   -0.0767   -0.0234
         0.5693   -0.0005    0.8127   -0.0779    0.0234]
     
        % {12} S = T*A
        [0.4543   -0.1388    0.1393   -0.4383   -0.5854    0.5854
        -0.4204    0.6000    0.5917   -0.4100   -0.1721   -0.1750
         0.2052    0.2059    0.2025    0.2029    0.2046    0.2038
         2.2210    2.1250    2.1000    2.1790   -4.2830   -4.2920
        -3.7300   -3.7250    3.7250    3.6670    0.0125    0.0208]
    
        120};   % {13} Travel limit (+/- micron all actuators)
    
end
set(Data.Calibration,'UserData',cal);
Plot_Fcn(h)
Value_Callback(h)

% --------------------------------------------------------------------
function Value_Callback(h)
% Callback subfunction for the popup menu value type (Data.Value)
% Display selected value type for channels 1-10.
Data = guidata(h);
TV = Data.g1.UserData;
%save TV_history.mat TV;

[m,n] = size(TV);
if n ~= 20, return, end

% Apply calibration table to all channels
cal = get(Data.Calibration,'UserData');
for i=1:10
    V(:,i) = interp1(cal{i}(1,:),cal{i}(2,:),...
        TV(:,i+10),'linear','extrap');
end
            
ValueNames = [
    Data.Value_LVDT1,Data.Value_LVDT2,Data.Value_LVDT3,...
    Data.Value_LVDT4,Data.Value_LVDT5,Data.Value_LVDT6,...
    Data.Value_Temp1,Data.Value_Temp2,Data.Value_Temp3,Data.Value_Temp4];

switch get(Data.Value,'Value');
    
case 1  % display the last value
    channel = V(m,:);
    
case 2  % display the average 
    channel = mean(V);
    
case 3  % display the peak to valley
    channel = max(V) - min(V);
    
case 4  % display the standard deviation 
    channel = std(V);
end

% Update the display of all 10 channels
for i=1:10
    set(ValueNames(i),'String',sprintf('%0.3f',channel(i)));
end

% temperature control
global csgHandle;   
global currentTemp;
global roomTemp;
global setPoint;
global roomSetPoint;
if (isempty(setPoint))
    setPoint=17.6;
end;
global default_setPoint
if (isempty(default_setPoint))
    default_setPoint=setPoint;
end;
global roomSetPoint;
if (isempty(roomSetPoint))
    roomSetPoint=18.5;
end;
global adp_Kpr
if (isempty(adp_Kpr))
    adp_Kpr=roomSetPoint;
end;
global adp_setPoint
if (isempty(adp_setPoint))
    adp_setPoint=setPoint;
end;
global Ki;
if (isempty(Ki))
    Ki=0.1;
end;
global KiMem;
if (isempty(KiMem))
    KiMem=0.1;
end;
global Kp;
if (isempty(Kp))
    Kp=1;
end;
global KpMem;
if (isempty(KpMem))
    KpMem=1;
end;
global Kd;
if (isempty(Kd))
    Kd=10;
end;
global KdMem;
if (isempty(KdMem))
    KdMem=10;
end;
global Kic;
if (isempty(Kic))
    Kic=1/3;
end;
global tempGoal;
if (isempty(tempGoal))
    tempGoal=20;
end;
global setPointHist;
if (isempty(setPointHist))
    setPointHist=setPoint;
end;
global roomSetPointHist; 
if (isempty(roomSetPointHist))
    roomSetPointHist=roomSetPoint;
end;
global roomTempHist;
if (isempty(roomTempHist))
    roomTempHist=roomSetPoint;
end;
global tempErrorHist;
if (isempty(tempErrorHist))
    tempErrorHist=0;
end;
global roomTempErrorHist;
if (isempty(roomTempErrorHist))
    roomTempErrorHist=0;
end;
global tempDerivHist;
if (isempty(tempDerivHist))
    tempDerivHist=0;
end;
global adp_kpr_cnt
if (isempty(adp_kpr_cnt))
    adp_kpr_cnt=1;
end;

save tcl.mat setPoint default_setPoint roomSetPoint adp_Kpr Ki Kp Kd Kic tempGoal setPointHist roomSetPointHist roomTempHist tempErrorHist roomTempErrorHist tempDerivHist adp_kpr_cnt

% HACK PN 5/11/17 to remove channel 8 and force it equal to channel 7
goodTemps=[];
for i=7:10
    if channel(i)>10 & channel(i)<30
        goodTemps(end+1)=channel(i);
    else
        fprintf('Temp Channel %d is bad and being skipped, value = %1.3e\n',i,channel(i));
    end;
end;
if ~isempty(goodTemps)
     currentTemp=mean(goodTemps);
 else
     currentTemp=0;
     fprintf('ALL Temp Channels bad!!!  %1.3e\n',channel(7:10));
 end;
% END OF HACK

%ch7_optic_temp_sensor_1 = channel(7)
%ch8_optic_temp_sensor_2 = channel(8)
%ch9_optic_temp_sensor_3 = channel(9)
%ch10_optic_temp_sensor_4 = channel(10)

%get room temp
roomTempLast=roomTemp;
fid=fopen('c:\roomtemp.txt','rt');
roomTemp=fscanf(fid,'%f',1);
fclose(fid);

% mods cnanderson 2013.06.26 to give a better description of why it returns

    
if (currentTemp<15) 
    fprintf('Not updating chiller on this cycle because OPTIC temp is < 15 C. Something must be wrong \n');
    fprintf('SensorLog.m: Optic temperature is %1.2f.\n', currentTemp);

    return;
end;

if (currentTemp>29)
    fprintf('Not updating chiller on this cycle because OPTIC temp is > 29 C. Something must be wrong \n')
    fprintf('SensorLog.m: Optic temperature is %1.2f.\n', currentTemp);

    return;
end

roomTempMin = 10;
if (roomTemp< roomTempMin) 
    fprintf('SensorLog.m: room temperature is %1.2f.\n', roomTemp);
    fprintf('Not updating chiller on this cycle because ROOM temp < %1.0f C. \n', roomTempMin);
    fprintf('This always happens on first cycle because the tempmon C program\n');
    fprintf('reports its value as an average of a buffer and the buffer is filled\n');
    fprintf('with N zeros, e.g., [0 0 0 0 0 ... ], at the start. For the returned temp to be accurate,\n');
    fprintf('the buffer needs to be populated with N temp readings.  This takes a few min.\n');
    fprintf('Everything is OK. Wait until the next cycle\n')
    return;
end

roomTempMax = 29;
if (roomTemp> roomTempMax)
    fprintf('SensorLog.m: room temperature is %1.2f.\n', roomTemp);
    fprintf('Not updating chiller on this cycle because ROOM temp > %1.0f C (USB temp hardware may be flaky).\n', roomTempMac)
    return;
end

global troubleEmailSent;
if (roomTemp>20)
    if isempty(troubleEmailSent)
        troubleEmailSent=0;
    end;
    if ~troubleEmailSent
        troubleEmailSent=1; % disable further email warnings
        sendTroubleEmail(sprintf('MET room temp > 20    %s   Temp=%4.3f  RoomTemp=%4.2f  RoomGoal=%4.2f  Chiller=%3.1f  RoomAdpRef=%4.2f Kp=%4.3f Ki=%4.3f ChillerKi=%4.3f Kd=%4.3f',datestr(now),currentTemp,roomTemp,roomSetPoint,setPoint,adp_Kpr,Kp,Ki,Kic,Kd),'MET temperature problem!!!');
    end;
    %load alarm;
    %alarm=[alarm,alarm,alarm,alarm,alarm,alarm,alarm,alarm,alarm,alarm];  % 15 seconds
    %alarm=[alarm,alarm,alarm,alarm];  % 60 seconds
    %alarm=[alarm,alarm,alarm,alarm,alarm]; % 5 minutes
    %alarm=[alarm,alarm];  % 10 minutes
    %alarm=[alarm;alarm]';  % make it stereo and compatible in size with wavplay
    %wavplay(alarm,'async');
else
    troubleEmailSent=0;  % enable future email warnings
end;
if (roomTemp>29)
    fprintf('Bad room temperature reading control disabled\n');
    sendTroubleEmail('Bad room temperature reading control disabled','MET temperature warning!!!');
    return;
end;
if (abs(roomTemp-roomTempLast)>2)
    fprintf('Not updating chiller on this cycle because room temp change too large: old temp=%4.2f   new temp=%4.2f\n',roomTempLast,roomTemp);
    sendTroubleEmail(sprintf('Room temp change too large on this cycle: old temp=%4.2f   new temp=%4.2f\n',roomTempLast,roomTemp),'MET temperature problem!!!');
    return;
end;


tempError=currentTemp-tempGoal;

global coolMode
global heatMode
global coastMode

persistent offlineModeOn;
persistent tempErrorHist_bs;
if coastMode | coolMode | heatMode
    if isempty(offlineModeOn)
        offlineModeOn=1;
        tempErrorHist_bs=[tempErrorHist(adp_kpr_cnt+1:length(tempErrorHist)),tempErrorHist(1:adp_kpr_cnt)];
    end;
else
    offlineModeOn=[];
    tempErrorHist_bs=[];
end;

if(coastMode)
    coolMode=0;
    heatMode=0;
    h=findobj(csgHandle,'Tag','cb_cool');
    set(h,'Value',0);
    h=findobj(csgHandle,'Tag','cb_heat');
    set(h,'Value',0);
    h=findobj(csgHandle,'Tag','cb_coast');
    set(h,'Value',1);
    %fid=fopen('c:\temp.txt','wt');
    %fprintf(fid,'%3.1f',setPoint);
    %fclose(fid);
    %!copy c:\\temp.txt c:\\chiller_command.txt
    %chiller_comm(setPoint); % send command to chiller
    fprintf('%s ',datestr(now));
    fprintf('Coast%3.1f  Temp=%4.3f  RoomTemp=%4.2f  RoomGoal=%4.2f  Chiller=%3.1f  RoomAdpRef=%4.2f Kp=%4.3f Ki=%4.3f ChillerKi=%4.3f Kd=%4.3f\n',tempGoal,currentTemp,roomTemp,roomSetPoint,setPoint,adp_Kpr,Kp,Ki,Kic,Kd);
	% log file
	fid=fopen('c:\log.txt','at');
	fprintf(fid,'%s,',datestr(now));
	for i=7:10
        fprintf(fid,'%0.3f,',channel(i));
	end
    fprintf(fid,'%3.1f,%4.3f,%4.2f,%4.2f,%3.1f,%4.2f,%4.3f,%4.3f,%4.3f,%4.3f\n',tempGoal,currentTemp,roomTemp,roomSetPoint,setPoint,adp_Kpr,Kp,Ki,Kic,Kd);
	fclose(fid);
    
	figure(10);
    tempErrorHist_bs(1:end-1)=tempErrorHist_bs(2:end);
    tempErrorHist_bs(end)=tempError; % history of corresponding temp error
	plot((-length(tempErrorHist_bs)+1:0)*15/60,tempErrorHist_bs,(-length(tempErrorHist_bs)+1:0)*15/60,tempErrorHist_bs*0+0.01,'r',(-length(tempErrorHist_bs)+1:0)*15/60,tempErrorHist_bs*0-0.01,'r')
    title('COAST MODE');
    grid;
	xlabel('hours');
	ylabel('Optic average temperature error');
    
    return;
end;
    
if (coolMode)
    heatMode=0;
    coastMode=0
    h=findobj(csgHandle,'Tag','cb_cool');
    set(h,'Value',1);
    h=findobj(csgHandle,'Tag','cb_heat');
    set(h,'Value',0);
    h=findobj(csgHandle,'Tag','cb_coast');
    set(h,'Value',0);
    if (tempError>0.05) 
        %fid=fopen('c:\temp.txt','wt');
        %fprintf(fid,'%3.1f',15);
        %fclose(fid);
        %!copy c:\\temp.txt c:\\chiller_command.txt
        chiller_comm(setPoint); % send command to chiller
        fprintf('%s ',datestr(now));
        fprintf('Temp=%4.2f, Cooling mode, closed loop disabled, chiller set to 15\n',currentTemp);
		% log file
		fid=fopen('c:\log.txt','at');
		fprintf(fid,'%s,',datestr(now));
		for i=7:10
            fprintf(fid,'%0.3f,',channel(i));
		end
        fprintf(fid,'%3.1f,%4.3f,%4.2f,%4.2f,%3.1f,%4.2f,%4.3f,%4.3f,%4.3f,%4.3f\n',tempGoal,currentTemp,roomTemp,-1,15,adp_Kpr,-1,-1,-1,-1);
		fclose(fid);
    
		figure(10);
        tempErrorHist_bs(1:end-1)=tempErrorHist_bs(2:end);
        tempErrorHist_bs(end)=tempError; % history of corresponding temp error
		plot((-length(tempErrorHist_bs)+1:0)*15/60,tempErrorHist_bs,(-length(tempErrorHist_bs)+1:0)*15/60,tempErrorHist_bs*0+0.01,'r',(-length(tempErrorHist_bs)+1:0)*15/60,tempErrorHist_bs*0-0.01,'r')
        title('COOL MODE');
        grid;
		xlabel('hours');
		ylabel('Optic average temperature error');
                
        return;
    else
        roomSetPointHist=roomSetPointHist*0+adp_Kpr;
        roomTempErrorHist=roomTempErrorHist*0;
        tempErrorHist=tempErrorHist*0;
        setPoint=17.6;
        coolMode=0;
        h=findobj(csgHandle,'Tag','cb_cool');
        set(h,'Value',0);
        h=findobj(csgHandle,'Tag','cb_heat');
        set(h,'Value',0);
        h=findobj(csgHandle,'Tag','cb_coast');
        set(h,'Value',0);
    end;
end;
if (heatMode)
    coolMode=0;
    coastMode=0;
    h=findobj(csgHandle,'Tag','cb_cool');
    set(h,'Value',0);
    h=findobj(csgHandle,'Tag','cb_heat');
    set(h,'Value',1);
    h=findobj(csgHandle,'Tag','cb_coast');
    set(h,'Value',0);
    
    if (tempError<-0.02) 
        %fid=fopen('c:\temp.txt','wt');
        %fprintf(fid,'%3.1f',25);
        %fclose(fid);
        %!copy c:\\temp.txt c:\\chiller_command.txt
        chiller_comm(setPoint); % send command to chiller
        fprintf('%s ',datestr(now));
        fprintf('Temp=%4.2f, Heating mode, closed loop disabled, chiller set to 25\n',currentTemp);
		% log file
		fid=fopen('c:\log.txt','at');
		fprintf(fid,'%s,',datestr(now));
		for i=7:10
            fprintf(fid,'%0.3f,',channel(i));
		end
        fprintf(fid,'%3.1f,%4.3f,%4.2f,%4.2f,%3.1f,%4.2f,%4.3f,%4.3f,%4.3f,%4.3f\n',tempGoal,currentTemp,roomTemp,-1,25,adp_Kpr,-1,-1,-1,-1);
		fclose(fid);
    
		figure(10);
        tempErrorHist_bs(1:end-1)=tempErrorHist_bs(2:end);
        tempErrorHist_bs(end)=tempError; % history of corresponding temp error
		plot((-length(tempErrorHist_bs)+1:0)*15/60,tempErrorHist_bs,(-length(tempErrorHist_bs)+1:0)*15/60,tempErrorHist_bs*0+0.01,'r',(-length(tempErrorHist_bs)+1:0)*15/60,tempErrorHist_bs*0-0.01,'r')
        title('HEAT MODE');
        grid;
		xlabel('hours');
		ylabel('Optic average temperature error');
            
        return;
    else
        roomSetPointHist=roomSetPointHist*0+adp_Kpr;
        roomTempErrorHist=roomTempErrorHist*0;
        tempErrorHist=tempErrorHist*0;
        setPoint=default_setPoint;
        heatMode=0;
        h=findobj(csgHandle,'Tag','cb_cool');
        set(h,'Value',0);
        h=findobj(csgHandle,'Tag','cb_heat');
        set(h,'Value',0);
        h=findobj(csgHandle,'Tag','cb_coast');
        set(h,'Value',0);
    end;
end;

%adaptive Kp and Ki section
if tempError>0.1
    KpMem=Kp;
    KiMem=Ki;
    Kp=10;
    Ki=0;
end;

%adaptive Kp reference section
adp_kpr_cnt=adp_kpr_cnt+1;  % use last 1400 points for adaptive Kpr (~2 weeks with 15-minute sampling)
if (adp_kpr_cnt>1400) adp_kpr_cnt=1; end;

setPointHist(adp_kpr_cnt)=setPoint;  % history of chiller set points
roomSetPointHist(adp_kpr_cnt)=roomSetPoint;  % history of room set points
roomTempHist(adp_kpr_cnt)=roomTemp;  % history of chiller set points
tempErrorHist(adp_kpr_cnt)=tempError; % history of corresponding temp error

idx_1hour_past=adp_kpr_cnt-4;
if (idx_1hour_past<=0)
    idx_1hour_past=length(tempError)-idx_1hour_past;
end;
if (idx_1hour_past<=0)
    idx_1hour_past=1;
end;
if (idx_1hour_past<=length(tempErrorHist))
    idx_1hour_past=1;
end;
if length(tempErrorHist)<1
    tempErrorHist=0;
end;
tempDeriv=tempErrorHist(idx_1hour_past)-tempError;
if (abs(tempDeriv)>0.1) tempDeriv=0; end; % disable Kd under temp spike conditions
tempDerivHist(adp_kpr_cnt)=tempDeriv;

KiBoost=sum(tempErrorHist.*(exp(fliplr(-([adp_kpr_cnt:length(tempErrorHist)-1,0:adp_kpr_cnt-1]))/10)))*Ki; % put exponential decay on integral
if (abs(KiBoost)>3) KiBoost=3*sign(KiBoost); end; 
if (abs(tempErrorHist(adp_kpr_cnt))>1) tempErrorHist(adp_kpr_cnt)=1*sign(tempErrorHist(adp_kpr_cnt)); end;

% weight set by (1-error)^2 with exponential decay as a function of past time
w_factor=(max(1-abs(tempErrorHist*10),0).^2).*((1-abs(tempDerivHist*10)).^2).*(exp(fliplr(-([adp_kpr_cnt:length(tempErrorHist)-1,0:adp_kpr_cnt-1]))/600));
adp_Kpr=sum(roomTempHist.*w_factor)./sum(w_factor);
adp_setPoint=sum(setPointHist.*w_factor)./sum(w_factor);

roomSetPoint=adp_Kpr-KiBoost-Kp*tempError+tempDeriv*Kd; % combined Kp Ki Kp method

roomTempError=roomTemp-roomSetPoint;
roomTempErrorHist(adp_kpr_cnt)=roomTempError; % history of corresponding temp error
if adp_kpr_cnt>10
    integratedRoomTempError=sum(roomTempErrorHist(adp_kpr_cnt-10:adp_kpr_cnt));
else
    integratedRoomTempError=sum(roomTempErrorHist(1:adp_kpr_cnt))+sum(roomTempErrorHist(length(roomTempErrorHist)-10+adp_kpr_cnt:length(roomTempErrorHist)));
end

%setPoint=setPoint-Kic*roomTempError;  % pure Ki method
setPoint=adp_setPoint-roomTempError-Kic*integratedRoomTempError;  % pure Ki method
if (setPoint<15) setPoint=15; end;
if (setPoint>25) setPoint=25; end;
%fid=fopen('c:\temp.txt','wt');
%fprintf(fid,'%3.1f',setPoint);
%fclose(fid);
%!copy c:\\temp.txt c:\\chiller_command.txt
chiller_comm(setPoint); % send command to chiller
fprintf('%s ',datestr(now));
fprintf('Goal=%3.1f  Temp=%4.3f  RoomTemp=%4.2f  RoomGoal=%4.2f  Chiller=%3.1f  RoomAdpRef=%4.2f ChillerAdpRef=%4.2f Kp=%4.3f Ki=%4.3f Kd=%4.3f\n',tempGoal,currentTemp,roomTemp,roomSetPoint,setPoint,adp_Kpr,adp_setPoint,Kp,Ki,Kd);

% Send "I'm Alive" email
	global aliveCounter;
	if isempty(aliveCounter)
        aliveCounter=str2num(datestr(now,'dd'));
	end;
	if str2num(datestr(now,'dd')) ~= aliveCounter
        bs=datestr(now,'HH:MM');
        bs=str2num(bs(1:2));
        if bs>9
            aliveCounter=str2num(datestr(now,'dd'));
            sendTroubleEmail(sprintf('Matlab MET Temp Control Loop is Alive:  Optic Temp = %4.3f,   Room Temp = %4.2f,  Chiller Temp ==%3.1f ',currentTemp,roomTemp,setPoint),sprintf('MET Temperature Daily Update'));
        end;
	end;
    
% Check that room temp server is alive
	global roomTempHist;
	global roomTempHistCnt;
	if isempty(roomTempHist)
        roomTempHist=zeros(8);
        roomTempHistCnt=1;
	end;
	if isempty(roomTempHistCnt)
        roomTempHistCnt=1;
	end;
	if roomTempHistCnt==9
        roomTempHistCnt=1;
	end;
    roomTempHist(roomTempHistCnt)=roomTemp;
    roomTempHistCnt=roomTempHistCnt+1;
	if sum(roomTempHist-roomTempHist(1))==0
        sendTroubleEmail(sprintf('DOS room temperature server may be down, room temp has not changed in 2 hours.'),'MET Temp Sensor Problem!!!');
	end;


% log file
fid=fopen('c:\log.txt','at');
fprintf(fid,'%s,',datestr(now));
for i=7:10
    fprintf(fid,'%0.3f,',channel(i));
end
fprintf(fid,'%3.1f,%4.3f,%4.2f,%4.2f,%3.1f,%4.2f,%4.3f,%4.3f,%4.3f,%4.3f\n',tempGoal,currentTemp,roomTemp,roomSetPoint,setPoint,adp_Kpr,Kp,Ki,Kic,Kd);
fclose(fid);


% temprature control status and control GUI
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
set(h,'String',num2str(-Kp*tempError,'%4.2f'));
h=findobj(csgHandle,'Tag','st_kig');
set(h,'String',num2str(-KiBoost,'%4.2f'));
h=findobj(csgHandle,'Tag','st_kdg');
set(h,'String',num2str(tempDeriv*Kd,'%4.2f'));

figure(10);
plot((-length(tempErrorHist)+1:0)*15/60,[tempErrorHist(adp_kpr_cnt+1:length(tempErrorHist)),tempErrorHist(1:adp_kpr_cnt)],(-length(tempErrorHist)+1:0)*15/60,tempErrorHist*0+0.01,'r',(-length(tempErrorHist)+1:0)*15/60,tempErrorHist*0-0.01,'r')
grid;
xlabel('hours');
ylabel('Optic average temperature error');

% reset adaptive Kp and Ki section
if tempError>0.1
    Kp=KpMem;
    Ki=KiMem;
end;


% END OF TEMPERATURE CONTROL

% --------------------------------------------------------------------
function Control_Callback(h)
% Callback subfunction for the pushbutton Open Actuator Control 
% (data.act_contr)
Data = guidata(h);

% Activate the Actuator Control only if it is not active
if isempty(Data.figure2)
    if ~strcmp(Data.g1.TransferStatus,'idle')
        w = waitbar(0,sprintf('Reading sensors, please wait'));
        t0 = clock;
        interval_index = get(Data.Interval,'Value');
        interval_array = get(Data.Interval,'UserData');
        NPLC = interval_array(2,interval_index);
        t1 = NPLC*0.2;
        while ~strcmp(Data.g1.TransferStatus,'idle')
            pause(0.1)
            waitbar(etime(clock,t0)/t1)
        end
        waitbar(1)
        pause(0.1)
        close(w);
    end
    Data.g1.name = 'off';               % deactivate action functions
    Data.figure2 = ActuatorControl;     % open figure 2 and store handle
    guidata(h, Data);
    
    Data.g1.BytesAvailableAction = ...
        {'BytesAvailableAction_Fcn',Data.figure1,Data.figure2};
    
    ActuatorControl('Initialize',Data.figure1,Data.figure2);

    % Start scanning channels 1-3
    fprintf(Data.g1,'VOLT:DC:APER 0.2,(@101:106)')
    fprintf(Data.g1,'TEMP:NPLC 2,(@107:110)')
    fprintf(Data.g1,'ZERO:AUTO OFF, (@101:110)')
    fprintf(Data.g1,'ROUT:SCAN (@101:103)')
    fprintf(Data.g1,'INIT')
    fprintf(Data.g1,'FETCH?')
    readasync(Data.g1)
    Data.g1.name = 'AC1';       % activate action functions
end
    
% --------------------------------------------------------------------
function CloseRequestFcn(h)
% Close request subfunction to close the Sensor Log window

Data = guidata(h);

TV = Data.g1.UserData;    
save TV_history.mat TV;

if Data.figure2                 % need to close figure 2
    ActuatorControl('CloseRequestFcn',Data.figure2)
end
while ~strcmp(Data.g1.TransferStatus,'idle')
    pause(0.1)
end
pause(0.1)

Data.g1.name = 'off';           % deactivate action functions
fprintf(Data.g1,'ABORT')        % stop scanning sensors

% Set to record time stamps and channel numbers
fprintf(Data.g1,'FORM:READ:TIME ON')
fprintf(Data.g1,'FORM:READ:CHAN ON')

% Set to scan every TimerPeriod. 
fprintf(Data.g1,'TRIG:SOURCE TIMER')
fprintf(Data.g1,'TRIG:TIMER %d',Data.g1.TimerPeriod)
fprintf(Data.g1,'TRIG:COUNT INF')

% Set the data and time to match Matlab
date_time = clock;
fprintf(Data.g1,'SYST:DATE %d,%d,%d',date_time(1:3));
fprintf(Data.g1,'SYST:TIME %d,%d,%5.3f',date_time(4:6));

% Start the scan and close the GPIB object
ReConfigScan(Data)                  % See the subfunction in this file
fprintf(Data.g1,'INIT')
ID = query(Data.g1,'*IDN?');        % instrument identification
fclose(Data.g1)
disp([ID,' is now ',Data.g1.Status])
delete(Data.g1)

% Close the Sensor Log window
delete(Data.figure1)            
            

% --------------------------------------------------------------------
function GetSensorData(Data)
% Get any sensor data stored in the Agilent 34970A

% Determine the number of full 10-channel data sets
nPoints = query(Data.g1,'DATA:POINTS?','%s','%d');
nSets = floor(nPoints/10);

if nSets
    fprintf(Data.g1,'ABORT')        % stop scanning sensors

    % Set the scan interval to match the Agilent 34970A
    value = query(Data.g1,'TRIGGER:TIMER?','%s','%f');
    interval_array = get(Data.Interval,'UserData');
    interval_index = find(interval_array(1,:) == value);
    if interval_index
        set(Data.Interval,'Value',interval_index);  % matching interval
    end
    
    % Times from the Agilent 34970A (year,month,day,hour,minute,second)
    StartTime = sscanf(query(Data.g1,...
        'SYST:TIME:SCAN?'),'%d,%d,%d,%d,%d,%f,',[1,6]);
    CurrentTime = [
        sscanf(query(Data.g1,'SYST:DATE?'),'%d,%d,%d',[1,3]),...
        sscanf(query(Data.g1,'SYST:TIME?'),'%d,%d,%f',[1,3])];

    % Time differences used to synchronize stored data to Matlab's clock
    TimeDiff = etime(clock,CurrentTime);
    ElapsedTime = etime(CurrentTime,StartTime);
    
    % Change Matlab's buffer size and timeout to accept stored data
    nBytes = nPoints*33;            % 33 bytes/point
    est_time = nPoints/390;         % estimated transfer time
    if nBytes > 512
        fclose(Data.g1)
        Data.g1.InputBufferSize = nBytes;
        if est_time > 8
            Data.g1.Timeout = est_time*1.25;        % 25% margin
        end
        fopen(Data.g1)
    end
    
    % Asynchronously read sensor data
    fprintf(Data.g1,'FETCH?')
    readasync(Data.g1)
        
    % Display a waitbar that shows progress in reading sensor data
    w = waitbar(0,...
        sprintf('Getting %d data sets stored over %0.3g days',...
        nSets,ElapsedTime/86400));

    t0 = clock;
    while ~strcmp(Data.g1.TransferStatus,'idle')
        act_time = etime(clock,t0);
        waitbar(act_time/est_time)
        pause(0.1)
    end
    waitbar(1)
    
    % Sort the data by channel number and put in corresponding columns
    RawData = sscanf(fscanf(Data.g1),'%e,%f,%d,',[3,nSets*10]);
    T = zeros(nSets,10);
    V = T;
    for i=1:10
        I = find(RawData(3,:) == i+100)';   % indicies for channel i
        if length(I) == nSets
            T(:,i) = RawData(2,I)';             % times for channel i
            V(:,i) = RawData(1,I)';             % values for channel i
        end
    end
    
    % Convert time data to Matlab's serial date format and store
    start = now - (TimeDiff + ElapsedTime)/86400;   % days since 1/1/0000
    T = T/86400 + start;
    Data.g1.UserData = [T,V];
    
    % Restore Matlab's default buffer size
    if nBytes > 512
        fclose(Data.g1)
        Data.g1.InputBufferSize = 512;
        fopen(Data.g1)
    end
    close(w);
    Value_Callback(Data.figure1)
    Plot_Fcn(Data.figure1)
end

% --------------------------------------------------------------------
function RestoreOldSensorData(Data)
% Restore sensor data from previous instance of sensorlog program
% Added by Patrick Naulleau

load TV_history.mat
Data.g1.UserData = TV;    

Value_Callback(Data.figure1)
Plot_Fcn(Data.figure1)


% --------------------------------------------------------------------
function ConfigScanOnce(Data)
% Configure the Agilent 34970A scan count to one. 
% Used when the Sensor Log window is active.

fprintf(Data.g1,'ABORT')    % stop scanning sensors
fprintf(Data.g1,'*RST')     % Factory Reset (sets default values)

% Set channels 7 - 10 for reading Thermisters
fprintf(Data.g1,'CONF:TEMP THER,10000 ,(@107:110)')
fprintf(Data.g1,'TEMP:NPLC 1,(@107:110)')

% Setup channels 1 - 6 for reading LVDTs
fprintf(Data.g1,'FUNC "VOLT:DC",(@101:106)')
fprintf(Data.g1,'VOLT:DC:RANGE 10,(@101:106)')

% Set the scan list for channels 1 - 10
fprintf(Data.g1,'ROUT:SCAN (@101:110)')
fprintf(Data.g1,'ZERO:AUTO OFF, (@101:110)')

% --------------------------------------------------------------------
function ReConfigScan(Data)
% Reconfigure the Agilent 34970A to scan Sensor Log. 

% Set the number of power line cycles for the interval
interval_index = get(Data.Interval,'Value');
interval_array = get(Data.Interval,'UserData');
NPLC = interval_array(2,interval_index);
fprintf(Data.g1,'VOLT:DC:NPLC %d,(@101:106)',NPLC)

% Set the scan list for channels 1 - 10
fprintf(Data.g1,'ROUT:SCAN (@101:110)')
fprintf(Data.g1,'ZERO:AUTO OFF, (@101:110)')

% --------------------------------------------------------------------
function Plot_Fcn(h)
% Plot the user-selected channels to the SensorLog axes
Data = guidata(h);


% Set the foreground colors of checkboxes to match the curves
C = get(Data.axes1,'ColorOrder');
nColors = size(C,1);
gray = [0.5,0.5,0.5];
j = 0;
J = [];
if get(Data.LVDT1,'Value')
    j = j + 1;
    J(j) = 1;
    index = j - nColors.*floor((j-1)/nColors);
    set(Data.LVDT1,'ForegroundColor',C(index,:));
else
    set(Data.LVDT1,'ForegroundColor',gray);
end
if get(Data.LVDT2,'Value');
    j = j + 1;
    J(j) = 2;
    index = j - nColors.*floor((j-1)/nColors);
    set(Data.LVDT2,'ForegroundColor',C(index,:));
else
    set(Data.LVDT2,'ForegroundColor',gray);
end
if get(Data.LVDT3,'Value');
    j = j + 1;
    J(j) = 3;
    index = j - nColors.*floor((j-1)/nColors);
    set(Data.LVDT3,'ForegroundColor',C(index,:));
else
    set(Data.LVDT3,'ForegroundColor',gray);
end
if get(Data.LVDT4,'Value');
    j = j + 1;
    J(j) = 4;
    index = j - nColors.*floor((j-1)/nColors);
    set(Data.LVDT4,'ForegroundColor',C(index,:));
else
    set(Data.LVDT4,'ForegroundColor',gray);
end
if get(Data.LVDT5,'Value');
    j = j + 1;
    J(j) = 5;
    index = j - nColors.*floor((j-1)/nColors);
    set(Data.LVDT5,'ForegroundColor',C(index,:));
else
    set(Data.LVDT5,'ForegroundColor',gray);
end
if get(Data.LVDT6,'Value');
    j = j + 1;
    J(j) = 6;
    index = j - nColors.*floor((j-1)/nColors);
    set(Data.LVDT6,'ForegroundColor',C(index,:));
else
    set(Data.LVDT6,'ForegroundColor',gray);
end

if get(Data.Temp1,'Value');
    j = j + 1;
    J(j) = 7;
    index = j - nColors.*floor((j-1)/nColors);
    set(Data.Temp1,'ForegroundColor',C(index,:));
else
    set(Data.Temp1,'ForegroundColor',gray);
end
if get(Data.Temp2,'Value');
    j = j + 1;
    J(j) = 8;
    index = j - nColors.*floor((j-1)/nColors);
    set(Data.Temp2,'ForegroundColor',C(index,:));
else
    set(Data.Temp2,'ForegroundColor',gray);
end
if get(Data.Temp3,'Value');
    j = j + 1;
    J(j) = 9;
    index = j - nColors.*floor((j-1)/nColors);
    set(Data.Temp3,'ForegroundColor',C(index,:));
else
    set(Data.Temp3,'ForegroundColor',gray);
end
if get(Data.Temp4,'Value');
    j = j + 1;
    J(j) = 10;
    index = j - nColors.*floor((j-1)/nColors);
    set(Data.Temp4,'ForegroundColor',C(index,:));
else
    set(Data.Temp4,'ForegroundColor',gray);
end

% Plot any user-selected channels
if J                                % plot any available data
    TV=Data.g1.UserData;            % time and values of all data points
    nPoints = size(TV,1);
    if nPoints                      % there is data to plot
        T = TV(:,J) - TV(nPoints,J(j));     % all selected times w.r.t. last
        cal = get(Data.Calibration,'UserData');
    
        % Get the range of the time axis to be displayed
        display_index = get(Data.Display,'Value');
        display_array = get(Data.Display,'UserData');
        display_string = get(Data.Display,'String');
    
        if display_array(display_index) == Inf      % plot all time range
        
            if -T(1,1) > 1          % day
                unit_conv = 1;
                x_unit = 'days';
            elseif -T(1,1)*24 > 1   % hour
                unit_conv = 24;
                x_unit = 'hours';
            elseif -T(1,1)*1440 > 1 % min
                unit_conv = 1440;
                x_unit = 'minutes';
            else
                unit_conv = 86400;  % sec
                x_unit = 'seconds';
            end
        
            % Apply calibration table to selected channels
            for k=1:j
                V(:,k) = interp1(cal{J(k)}(1,:),cal{J(k)}(2,:),...
                    TV(:,J(k)+10),'linear','extrap');
            end
        
            if get(Data.Average,'Value')            % Subtract the average
                V = V - repmat(mean(V),nPoints,1);
            end
        
            plot(T*unit_conv,V,'parent',Data.axes1);
            set(Data.axes1,'XLimMode','auto','XTickMode','auto');
            set(Data.TimeUnit,'String',x_unit);
        else    % use the selected time range and truncate data if necessary
        
            x_axis = {
                [-4,-3.5,-3,-2.5,-2,-1.5,-1,-.5,0]      % min
                [-16,-14,-12,-10,-8,-6,-4,-2,0]         % min
                [-60,-50,-40,-30,-20,-10,0]             % min
                [-4,-3.5,-3,-2.5,-2,-1.5,-1,-.5,0]      % hr
                [-24,-20,-16,-12,-8,-4,0]               % hr
                [-7,-6,-5,-4,-3,-2,-1,0]                % days
                [-28,-24,-20,-16,-12,-8,-4,0]};         % days
            unit_conv = [1440,1440,1440,24,24,1,1];     % unit/day
            
            % Apply calibration table to selected channels
            I = min(find(T >= -display_array(display_index)/86400)):nPoints;
            for k=1:j
                V(:,k) = interp1(cal{J(k)}(1,:),cal{J(k)}(2,:),...
                    TV(I,J(k)+10),'linear','extrap');
            end
        
            if get(Data.Average,'Value')            % Subtract the average
                V = V - repmat(mean(V),length(I),1);
            end
        
            plot(T(I,:)*unit_conv(display_index),V,'parent',Data.axes1)
            set(Data.axes1,...
                'XLim',[x_axis{display_index}(1),0],...
                'XTick',x_axis{display_index});
            set(Data.TimeUnit,'String',display_string{display_index});
        end
    else
        plot(0,0,'w','parent',Data.axes1)       % plot nothing
    end
else
    plot(0,0,'w','parent',Data.axes1)           % plot nothing
end

% Display the current date and time
set(Data.DateTime,'String',datestr(now))
