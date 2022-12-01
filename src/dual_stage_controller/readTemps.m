% function dataOut = readTemps(numChan)
%
% Read temps from the hardware
%

function [dataOut,readError] = readTemps(numChan)

global measurePoint
global virtualMode      % global variable that allow system to be put into virtual mode (no hardware connection)
persistent lastReading  % keep a local copy of last reading in case of read error

if isempty(lastReading)
    lastReading=ones(1,48)*22;
end;

readError=0;

if virtualMode
    dataOut = randn(1,48)+22.5;
else
    try
        [dataOut, lError] = measurePoint.getScanData();
        dataOut(14)=22.5;
    catch
    	disp('measurePoint read error, last good readings used');
    	readError=1;
    end;
    
    if ~readError && lError == false
        lastReading=dataOut;
    else
        dataOut=lastReading;
        readError=1;
    end;
end;