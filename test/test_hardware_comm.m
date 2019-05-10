
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

%% Create ATEC302 instance for each controller

% 1, 2, 3, 4 correspond to FTC1,2,3,4 as shown on the chassis
% (left to right)

cHost = '192.168.20.36';

comm1 = atec.ATEC302(...
    'u16Port', 4001, ...
    'cHost', cHost ...
);

comm1.init();
comm1.getSetValue()
comm1.getTemperature()
% comm1.setSetValue(15); % this works


comm2 = atec.ATEC302(...
    'u16Port', 4002, ...
    'cHost', cHost ...
);

comm2.init();
comm2.getSetValue()
comm2.getTemperature()



comm3 = atec.ATEC302(...
    'u16Port', 4003, ...
    'cHost', cHost ...
);

comm3.init();
comm3.getSetValue()
comm3.getTemperature()


comm4 = atec.ATEC302(...
    'u16Port', 4004, ...
    'cHost', cHost ...
);

comm4.init();
comm4.getSetValue()
comm4.getTemperature()



