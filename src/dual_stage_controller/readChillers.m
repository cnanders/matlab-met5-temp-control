% function dataOut = readChillers()
%
% Read temps from the chiller controllers
%

function dataOut = readChillers()

global ATEC302
global virtualMode      % global variable that allow system to be put into virtual mode (no hardware connection)
persistent lastReading  % keep a local copy of last reading in case of read error

if isempty(lastReading)
    lastReading=ones(1,4)*22;
end;

readError=0;

if virtualMode
    dataOut = ones(1,4)*controlParams.setPoint+randn(1,4).*0.5;
else
    for i=1:4
        try
            dataOut(i)=ATEC302(i).comm.getTemperature();
        catch
            disp('ATEC read error, last good reading used');
            readError=1;
        end;
    end;
    if ~readError
        lastReading=dataOut;
    else
        dataOut=lastReading;
    end;
end;
