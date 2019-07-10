% function setChillers(setTemp)
%
% Set chiller setpoints
%

function setChillers(setTemp)

global ATEC302
global virtualMode      % global variable that allow system to be put into virtual mode (no hardware connection)

if virtualMode
    %
else
    for i=1:4
        ATEC302(i).comm.setSetValue(setTemp);
    end;
end;