% MET5 Temperature Control Loop Startup Script

function tclStartup
%% clear old variables
clear global 
clear tempReadTimerCallback

%% define global variables
global csgHandle    % handle to the control planel figure
global epHandle     % handle to the error plot figure
global tempSensorTimer  % handle to the control loop timer
global tempReadTimer    % handle to the temperature reading timer
global controlParams    % control parameters structure (see tempControlLoop.m for details)
global tempSensorData   % temperature data structure (see tempControlLoop.m for details)
global currentTemp      % stucture holding vector with the current temperature values for all physical channels and the averaging index
global measurePoint     % variable to hold the measure point object
global ATEC302          % variable to hold the atec objects
global virtualMode      % global variable that allow system to be put into virtual mode (no hardware connection)

%% allow system to be put into virtual mode (no hardware connection)
virtualMode=0;

%% Make sure that we only allow one instance of control loop to run
if ~isempty(findobj(csgHandle,'Name','CONTROL PANEL'))
    beep;
    fprintf('TEMP SENSOR ALREADY RUNNING!!!\n');
    return;
end;

%% add temp controller working foder to path
addpath(pwd);

if ~virtualMode      % enable hardware if no in vitrual mode 
    %% Create MesaurPoint client
    [cDirThis, ~, ~] = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));

    % Initiate a MesaurPoint client
    cIP = '192.168.20.27';
    measurePoint = datatranslation.MeasurPoint(cIP);
    measurePoint.connect(); % Connect the instrument through TCP/IP
    measurePoint.idn(); % Ask the instument its id using SCPI standard queries
    measurePoint.enable(); % Enable readout on protected channels
    
     % Show all MeasurePoint channel hardware types (These cannot be set)
    [tc, rtd, volt] = measurePoint.channelType();
    fprintf('bl12014.Logger.init():\n');
    fprintf('DataTranslation MeasurPoint Hardware configuration:\n');
    fprintf('TC   sensor channels = %s\n',num2str(tc,'%1.0f '))
    fprintf('RTD  sensor channels = %s\n',num2str(rtd,'%1.0f '))
    fprintf('Volt sensor channels = %s\n',num2str(volt,'%1.0f '))

    % Configure MeasurePoint to know what hardware we have connected
    % to each channel
    channels = 0 : 7;
    for n = channels
       measurePoint.setSensorType(n, 'J');
    end

    channels = 8 : 15;
    for n = channels
        measurePoint.setSensorType(n, 'PT1000');
    end

    channels = 16 : 19;
    for n = channels
        measurePoint.setSensorType(n, 'PT100');
    end

    channels = 20 : 23;
    for n = channels
       measurePoint.setSensorType(n, 'PT1000');
    end

    channels = 24 : 31;
    for n = channels
        measurePoint.setSensorType(n, 'PT100');
    end

    channels = 32 : 47;
    for n = channels
        measurePoint.setSensorType(n, 'V');
    end

    % Set up continuous population of internal memory buffer
    measurePoint.setScanList(0:47);
    measurePoint.setScanPeriod(0.1);
    measurePoint.initiateScan();
    % measurePoint.abortScan();
    measurePoint.clearBytesAvailable();

    %% Create ATEC302 instance for each controller
    % 1, 2, 3, 4 correspond to FTC1,2,3,4 as shown on the chassis
    % (left to right)
    cHost = '192.168.20.36';

    ATEC302(1).comm = atec.ATEC302('u16Port', 4001,'cHost', cHost);
    ATEC302(1).comm.init();

    ATEC302(2).comm = atec.ATEC302('u16Port', 4002,'cHost', cHost);
    ATEC302(2).comm.init();

    ATEC302(3).comm = atec.ATEC302('u16Port', 4003,'cHost', cHost);
    ATEC302(3).comm.init();

    ATEC302(4).comm = atec.ATEC302('u16Port', 4004,'cHost', cHost);
    ATEC302(4).comm.init();
end;

%% set the default values for the temperature reading structure
currentTemp.avgCnt=0;  % current averaging counter
currentTemp.avg=300;  % number of readings to average (rolling)
currentTemp.Nchan=55;  % number of channels, include both real and 3 virtual channels (optic avg, chiller avg, subframe avg)
currentTemp.buffer=zeros(currentTemp.Nchan,currentTemp.avg);
currentTemp.avgTemps=zeros(currentTemp.Nchan,1);

%% set the default values for control structure
tempSensorData.Nbuf=2688;
tempSensorData.Nchan=currentTemp.Nchan;
tempSensorData.Labels={'Avg Optic Temp','Avg Chill Plate Temp','c1','c2','c3','c4','c5','c6','c7','c8','c9','c10','c11','c12','c13','c14','c15','c16','c17','c18','c19','c20'};
tempSensorData.temps=zeros(tempSensorData.Nchan,tempSensorData.Nbuf);
tempSensorData.currentIdx=0;

controlParams.tempGoal=22.5;
controlParams.controlChannel=1;
controlParams.controlMode=1;
controlParams.Kp=1;
controlParams.Ki=0.1;
controlParams.Kd=10;
controlParams.Kpsf=1;    % subframe control PID values
controlParams.Kisf=0.1;
controlParams.Kdsf=10;
controlParams.T=15;
controlParams.KdT=60;
controlParams.Nbuf=2688;
controlParams.currentIdx=1;
controlParams.loopPassCnt=0;
controlParams.adp_Kpr=18;
controlParams.subframeSetPoint=18;
controlParams.chillPlateTemp=12;
controlParams.setPoint=12;
controlParams.adp_Kprsf=12;
controlParams.maxSetPoint=28;
controlParams.minSetPoint=10;
controlParams.setPointHist=ones(1,2688)*18;
controlParams.chillplateHist=ones(1,2688)*12;
controlParams.subframeHist=ones(1,2688)*22.5;
controlParams.tempErrorHist=zeros(1,2688);
controlParams.tempDerivHist=zeros(1,2688);
controlParams.sfTempErrorHist=zeros(1,2688);
controlParams.sfTempDerivHist=zeros(1,2688);

%% load the last save data
try
   load controlParamsSave.mat;
catch
end;
try
    load tempDataSave.mat
catch
end;

%% Setup the figures
csgHandle=openfig('CoolStateGUI.fig','reuse');
%tpHandle=SensorPlot;

% initialize ErrorPlot
epHandle=openfig('CoolStatePlots.fig','reuse');
%epHandle=figure('Name','CONTROL ERROR PANEL','NumberTitle','off','CloseRequestFcn','tclShutdown');

% initialize the control panel
h=findobj(csgHandle,'Tag','ed_T');
set(h,'String',num2str(controlParams.T,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_kp');
set(h,'String',num2str(controlParams.Kp,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_ki');
set(h,'String',num2str(controlParams.Ki,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_kd');
set(h,'String',num2str(controlParams.Kd,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_kpsf');
set(h,'String',num2str(controlParams.Kpsf,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_kisf');
set(h,'String',num2str(controlParams.Kisf,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_kdsf');
set(h,'String',num2str(controlParams.Kdsf,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_kdT');
set(h,'String',num2str(controlParams.KdT,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_set_target');
set(h,'String',num2str(controlParams.tempGoal,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_set_arr');
set(h,'String',num2str(controlParams.adp_Kpr,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_set_chiller');
set(h,'String',num2str(controlParams.setPoint,'%3.1f'));
h=findobj(csgHandle,'Tag','st_ot');
set(h,'String',num2str(0,'%5.3f'));
h=findobj(csgHandle,'Tag','st_cpt');
set(h,'String',num2str(controlParams.chillPlateTemp,'%4.2f'));
h=findobj(csgHandle,'Tag','st_cptg');
set(h,'String',num2str(0,'%4.2f'));

h=findobj(csgHandle,'Tag','st_kpg');
set(h,'String',num2str(0,'%4.2f'));
h=findobj(csgHandle,'Tag','st_kig');
set(h,'String',num2str(0,'%4.2f'));
h=findobj(csgHandle,'Tag','st_kdg');
set(h,'String',num2str(0,'%4.2f'));


%% Load in some historic temperature data just for debugging
% this code should be removed before deploying
%global tempdatabase
%tempdatabase=csvread('templog.csv');

%% setup the recurring temperature reading timer
tempReadTimer = timer('Name', 'tempReadTimer', 'ExecutionMode','FixedRate','Period', 1, 'TimerFcn', 'tempReadTimerCallback'); 
start(tempReadTimer);

%% setup the recurring control timer
% dont forget to change the timer delay time multiplier from 6 back to 60, this is for debug mode
tempSensorTimer = timer('Name', 'tempSensorTimer', 'ExecutionMode','FixedRate','Period', controlParams.T*60, 'TimerFcn', 'tempSensorTimerCallback'); 
start(tempSensorTimer);