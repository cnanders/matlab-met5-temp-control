% function dataOut = readChillers()
%
% Read temps from the chiller controllers
%

function dataOut = readChillers()

%% dummy code, this will be replaced with Chris' read function
global controlParams

dataOut=ones(1,4)*controlParams.setPoint+randn*0.5;

% end of dummy code
