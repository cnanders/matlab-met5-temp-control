% callback function from the temperature control loop timer

function tempSensorTimerCallback

%% global vars
global csgHandle    % handle to the control planel figure
global tempSensorTimer  % handle to the control loop timer
global controlParams    % control parameters structure (see tempControlLoop.m for details)
global tempSensorData   % temperature data structure (see tempControlLoop.m for details)
global currentTemp      % stucture holding vector with the current temperature values for all physical channels and the averaging index

try
    %% call function to read all the temperatures
    tempSensorData = getTemps(tempSensorData,currentTemp);
    % dummy code that assumes that the chill plates achieved target temp since last cycle 
    tempSensorData.temps(2,tempSensorData.currentIdx)=controlParams.setPoint;

    %% maybe add code to plot all the temps here

    %% set the current chillplate temp field in the control loop structure
    controlParams.chillPlateTemp=tempSensorData.temps(2,tempSensorData.currentIdx);

    %% execute the control loop which will return a target temp for the chill
    %   plates through the controlParams structure
    controlParams = tempControlLoop(tempSensorData,controlParams);

    %% call function set the chill plate temps
    %%fprintf('Setting the chill plate temps to %3.2f\n',controlParams.setPoint);
    % add actual code

    %% save all data and parameters to disk
    save controlParamsSave.mat controlParams
    save tempDataSave.mat tempSensorData
catch mE
    error(getReport(mE));
end;