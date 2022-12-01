% MET5 Temperature Control Loop Startup Script

function tclStartup
%% clear old variables
clear global 
clear tempReadTimerCallback

addpath C:\Users\metmatlab\Documents\MATLAB\matlab-met5-temp-control\src\dual_stage_controller

%% define global variables
global csgHandle    % handle to the control planel figure
global epHandle     % handle to the error plot figure
global ctpHandle     % handle to individual channel plot figure
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
if ~isempty(findobj(csgHandle,'Name','MET5 TEMPERATURE CONTROL PANEL'))
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
    
    measurePoint = init_measurePoint;

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
currentTemp.avg=800;  % number of readings to average (rolling)
currentTemp.Nchan=55;  % number of channels, include both real and 3 virtual channels (optic avg, chiller avg, subframe avg)
currentTemp.buffer=zeros(currentTemp.Nchan,currentTemp.avg);
currentTemp.avgTemps=zeros(currentTemp.Nchan,1);
currentTemp.measurePointError=0;

%% set the default values for control structure
tempSensorData.Nbuf=2688;
tempSensorData.Nchan=currentTemp.Nchan;
tempSensorData.Labels=getTempSensorLabels;
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
controlParams.minSetPoint=8;
controlParams.setPointHist=ones(1,tempSensorData.Nbuf)*18;
controlParams.chillplateHist=ones(1,tempSensorData.Nbuf)*12;
controlParams.subframeHist=ones(1,tempSensorData.Nbuf)*22.5;
controlParams.tempErrorHist=zeros(1,tempSensorData.Nbuf);
controlParams.tempDerivHist=zeros(1,tempSensorData.Nbuf);
controlParams.sfTempErrorHist=zeros(1,tempSensorData.Nbuf);
controlParams.sfTempDerivHist=zeros(1,tempSensorData.Nbuf);

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
set(csgHandle,'Name','MET5 TEMPERATURE CONTROL PANEL');
%tpHandle=SensorPlot;

% initialize ErrorPlot
epHandle=openfig('CoolStatePlots.fig','reuse');
set(epHandle,'Name','MET5 TEMPERATURE LOG');
%epHandle=figure('Name','MET5 TEMPERATURE LOG','NumberTitle','off','CloseRequestFcn','tclShutdown');
ctpHandle=openfig('ChannelPlots.fig','reuse');

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
set(h,'String',num2str(controlParams.tempGoal,'%5.3f'));
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

%% initialize plot windows
updateTempPlots;

%% setup the recurring temperature reading timer
tempReadTimer = timer('Name', 'tempReadTimer', 'ExecutionMode','fixedSpacing','Period', 0.5, 'TimerFcn', 'tempReadTimerCallback'); 
start(tempReadTimer);

%% setup the recurring control timer
% dont forget to change the timer delay time multiplier from 6 back to 60, this is for debug mode
tempSensorTimer = timer('Name', 'tempSensorTimer', 'ExecutionMode','FixedRate','Period', controlParams.T*60,'StartDelay', 2, 'TimerFcn', 'tempSensorTimerCallback'); 
if ~strcmp(get(tempSensorTimer,'running'),'on')  % may have been started already by the tempReadTimer callback
	start(tempSensorTimer);
end;

