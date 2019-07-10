% callback function from the temperature control loop timer

function tempSensorTimerCallback

%% global vars
global csgHandle    % handle to the control planel figure
global tempReadTimer
global tempSensorTimer  % handle to the control loop timer
global controlParams    % control parameters structure (see tempControlLoop.m for details)
global tempSensorData   % temperature data structure (see tempControlLoop.m for details)
global currentTemp      % stucture holding vector with the current temperature values for all physical channels and the averaging index

try
    %% ensure that the tempReadTimer is still running
    % I have this here because I have observed the timer being shut off for not reason
    if ~isempty(tempReadTimer)
        if ~strcmp(get(tempReadTimer,'running'),'on')
            start(tempReadTimer);
        end;
    end;
    
    %% call function to read all the temperatures
    tempSensorData = getTemps(tempSensorData,currentTemp);

    %% maybe add code to plot all the temps here

    %% set the current chillplate temp field in the control loop structure
    controlParams.chillPlateTemp=tempSensorData.temps(2,tempSensorData.currentIdx);

    %% execute the control loop which will return a target temp for the chill
    %   plates through the controlParams structure
    controlParams = tempControlLoop(tempSensorData,controlParams);

    %% call function set the chill plate temps
    %disp(sprintf('Setting chillplate setpoints to %3.1f',controlParams.setPoint));
    setChillers(controlParams.setPoint);

    %% save all data and parameters to disk
    save controlParamsSave.mat controlParams
    save tempDataSave.mat tempSensorData
catch mE
    error(getReport(mE));
end;