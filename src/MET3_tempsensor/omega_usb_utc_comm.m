function chiller_com(temp)

warning off;

s = serial('COM5');
set(s, 'BaudRate',38400);
set(s, 'Parity', 'none');
set(s, 'DataBits', 8);
set(s, 'StopBits', 1);
set(s, 'Terminator', 'CR/LF');

fopen(s);

%% Get Model and firmware
fprintf(s, 'ENQ'); 

% Need to scan twice because return is in format
% USBUSB2 CR
% 090713 CR

cModel = fscanf(s);
cFirmware = fscanf(s);

% Remove terminator from returned value
cModel = cModel(1 : end - 2);
cFirmware = cFirmware(1 : end - 2);

fprintf('Model: %s\n', cModel);
fprintf('Firmware: %s\n', cFirmware);

%% Get thermocouple type
fprintf(s, 'TCTYPE');
cType = fscanf(s)
% Remove terminator
cType = cType(1 : end - 2);

% Get temperature in C
fprintf(s, 'C');
cTemp = fscanf(s);
% Remove terminator
cTemp = cTemp(1 : end - 2)


% Get temperature in F
fprintf(s, 'F');
cTemp = fscanf(s);
% Remove terminator
cTemp = cTemp(1 : end - 2)

fclose(s);
delete(s);
clear s;

warning on;