function tclShutdown

global csgHandle    % handle to the control planel figure
global epHandle     % handle to the error plot figureglobal tempSensorTimer  % handle to the control loop timer
global tempSensorTimer  % handle to the control loop timer
global tempReadTimer    % handle to the temperature reading timer
global controlParams    % control parameters structure (see tempControlLoop.m for details)
global tempSensorData   % temperature data structure (see tempControlLoop.m for details)
global currentTemp      % stucture holding vector with the current temperature values for all physical channels and the averaging index

stop(tempSensorTimer);
stop(tempReadTimer);
delete(tempSensorTimer);
delete(tempReadTimer);
delete(csgHandle);
delete(epHandle);
clear global
