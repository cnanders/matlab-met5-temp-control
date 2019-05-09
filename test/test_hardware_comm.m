
%% Add src and mpm dependencies to path

[cDirThis, ~, ~] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', 'mpm-packages')));


%% Initiate a MesaurPoint client

cIP = '192.168.20.27';
mp = datatranslation.MeasurPoint(cIP);


%% Connect the instrument through TCP/IP
mp.connect();

%% Ask the instument its id using SCPI standard queries
mp.idn();

%% Enable readout on protected channels
mp.enable();

%% Configure all channels for scan list (internal fast scan with circular memory buffer)
% mp.configureScanListAll()

%% Start scan
% mp.initiateScan();

%% Read all values from the scan buffer
results = mp.getScanData()

%% Disconnect
mp.disconnect();



