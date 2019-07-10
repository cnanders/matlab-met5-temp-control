% function dataOut = readChillers()
%
% Read temps from the chiller controllers
%

function dataOut = readChillers()

global ATEC302
global virtualMode      % global variable that allow system to be put into virtual mode (no hardware connection)

if virtualMode
    dataOut = ones(1,4)*controlParams.setPoint+randn(1,4).*0.5;
else
    for i=1:4
        dataOut(i)=ATEC302(i).comm.getTemperature();
    end;
end;