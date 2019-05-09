function BytesAvailableAction_Fcn(g1,event,h1,h2)
% BytesAvailableAction function for the GPIB object g1.
% This function stores one data set from the Agilent 34970A.
% The channels in the data set depend on the state stored in g1.name.

% State definitions for g1.name (in the order they cycle through):

% 'SL'   Sensor Log controls the Agilent 34970A

% Normal cycle for Actuator Control
% 'AC1'  Actuator Control state 1 (read LVDTs 1-3, scan LVDTs 4-6)
% 'AC2'  Actuator Control state 2 (read LVDTs 4-6, scan LVDTs 1-3)

% Time to store data in Sensor Log
% 'AC1a' read and store LVDTs 1-3, scan LVDTs 4-6
% 'AC2b' read and store LVDTs 4-6, scan Temp 7-10
% 'AC2c' read and store Temp 7-10, scan LVDTs 1-3

% Time to store data in Sensor Log
% 'AC2a' read and store LVDTs 4-6, scan LVDTs 1-3
% 'AC1b' read and store LVDTs 1-3, scan Temp 7-10
% 'AC1c' read and store Temp 7-10, scan LVDTs 4-6

switch g1.name
    
case 'SL'               % store new data in Sensor Log
    T = repmat(datenum(event.Data.AbsTime),1,10);   % channel 1-10 times
    V = sscanf(fscanf(g1),'%e,',[1,10]);            % channel 1-10 values
    g1.UserData = [g1.UserData;[T,V]];
    SensorLog('Value_Callback',h1);                 % update the display
    SensorLog('Plot_Fcn',h1);                       % update the plot
    
case 'AC1'              % read LVDTs 1-3, scan LVDTs 4-6
    g1.name = 'AC2';
    V = sscanf(fscanf(g1),'%e,',[1,3]);             % LVDT 1-3 values
    ActuatorControl('MotorCommand',h2,1:3,V)        % move motors 1-3
    fprintf(g1,'ROUT:SCAN (@104:106)')
    StartScanning(g1)
case 'AC2'              % read LVDTs 4-6, scan LVDTs 1-3
    g1.name = 'AC1';
    V = sscanf(fscanf(g1),'%e,',[1,3]);             % LVDT 4-6 values
    ActuatorControl('MotorCommand',h2,4:6,V)        % move motors 4-6
    fprintf(g1,'ROUT:SCAN (@101:103)')
    StartScanning(g1)
    
case 'AC1a'             % read and store LVDTs 1-3, scan LVDTs 4-6
    g1.name = 'AC2b';
    T = repmat(datenum(event.Data.AbsTime),1,3);    % LVDT 1-3 times
    V = sscanf(fscanf(g1),'%e,',[1,3]);             % LVDT 1-3 values
    ActuatorControl('MotorCommand',h2,1:3,V)        % move motors 1-3
    fprintf(g1,'ROUT:SCAN (@104:106)')
    StartScanning(g1)
    g1.UserData = ChangeLastRow(g1.UserData,[1:3,11:13],[T,V],1);
    
case 'AC2b'             % read and store LVDTs 4-6, scan Temp 7-10
    g1.name = 'AC2c';
    T = repmat(datenum(event.Data.AbsTime),1,3);    % LVDT 4-6 times
    V = sscanf(fscanf(g1),'%e,',[1,3]);             % LVDT 4-6 values
    ActuatorControl('MotorCommand',h2,4:6,V)        % move motors 4-6
    fprintf(g1,'ROUT:SCAN (@107:110)')
    StartScanning(g1)
    g1.UserData = ChangeLastRow(g1.UserData,[4:6,14:16],[T,V],0);
    
case 'AC2c'             % read and store Temp 7-10, scan LVDTs 1-3
    g1.name = 'AC1';
    T = repmat(datenum(event.Data.AbsTime),1,4); % Temp 7-10 times
    V = sscanf(fscanf(g1),'%e,',[1,4]);          % Temp 7-10 values
    fprintf(g1,'ROUT:SCAN (@101:103)')
    StartScanning(g1)
    g1.UserData = ChangeLastRow(g1.UserData,[7:10,17:20],[T,V],0);
    SensorLog('Value_Callback',h1)              % update the display
    SensorLog('Plot_Fcn',h1)                    % update the plot
    
case 'AC2a'             % read and store LVDTs 4-6, scan LVDTs 1-3
    g1.name = 'AC1b';
    T = repmat(datenum(event.Data.AbsTime),1,3);    % LVDT 4-6 times
    V = sscanf(fscanf(g1),'%e,',[1,3]);             % LVDT 4-6 values
    ActuatorControl('MotorCommand',h2,4:6,V)        % move motors 4-6
    fprintf(g1,'ROUT:SCAN (@101:103)')
    StartScanning(g1)
    g1.UserData = ChangeLastRow(g1.UserData,[4:6,14:16],[T,V],1);
    
case 'AC1b'             % read and store LVDTs 1-3, scan Temp 7-10
    g1.name = 'AC1c';
    T = repmat(datenum(event.Data.AbsTime),1,3);    % LVDT 1-3 times
    V = sscanf(fscanf(g1),'%e,',[1,3]);             % LVDT 1-3 values
    ActuatorControl('MotorCommand',h2,1:3,V)        % move motors 1-3
    fprintf(g1,'ROUT:SCAN (@107:110)')
    StartScanning(g1)
    g1.UserData = ChangeLastRow(g1.UserData,[1:3,11:13],[T,V],0);
    
case 'AC1c'             % read and store Temp 7-10, scan LVDTs 4-6
    g1.name = 'AC2';
    T = repmat(datenum(event.Data.AbsTime),1,4);    % Temp 7-10 times
    V = sscanf(fscanf(g1),'%e,',[1,4]);             % Temp 7-10 values
    fprintf(g1,'ROUT:SCAN (@104:106)')
    StartScanning(g1)
    g1.UserData = ChangeLastRow(g1.UserData,[7:10,17:20],[T,V],0);
    SensorLog('Value_Callback',h1)                  % update the display
    SensorLog('Plot_Fcn',h1);                       % update the plot
end

% --------------------------------------------------------------------
function StartScanning(g1)
% Start the Agilent 34970A scanning the current scan list. 

    fprintf(g1,'INIT')
    fprintf(g1,'FETCH?')
    readasync(g1)
    
% --------------------------------------------------------------------
function M = ChangeLastRow(M,i,r,a)
% This function changes the last row of matrix M at the indices i to 
% values given by the vector r. Set a = 1 to append or a = 0 to change.
% Does no error checking for more speed.

[m,n] = size(M);
M(m+a,i) = r;

% --------------------------------------------------------------------
