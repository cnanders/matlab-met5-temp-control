% function dataOut = readTemps(numChan)
%
% Read temps from the hardware
%

function dataOut = readTemps(numChan)

global measurePoint
global virtualMode      % global variable that allow system to be put into virtual mode (no hardware connection)

if virtualMode
    dataOut = randn(1,48)+22.5;
else
    dataOut = measurePoint.getScanData();
end;