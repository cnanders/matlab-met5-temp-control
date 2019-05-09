function TimerAction_Fcn(g1,event)
% TimerAction function for the GPIB object g1 executes every TimerPeriod,
% which is set by the subfunction Interval_Callback in SensorLog.
% This function initiates a scan and asynchronous read when the Sensor Log
% is controling the scan interval of the Agilent 34970A. 

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
    
case 'SL'               % initiate asynchronously reading data now
    fprintf(g1,'INIT')
    fprintf(g1,'FETCH?')
    readasync(g1)
    tic
case 'AC1'              % tell actuator control to store data now
    g1.name = 'AC1a';       
    
case 'AC2'              % tell actuator control to store data now
    g1.name = 'AC2a';       
end


