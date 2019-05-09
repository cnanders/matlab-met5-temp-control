% function dataOut = readTemps(numChan)
%
% Read temps from the hardware
%

function dataOut = readTemps(numChan)

%% dummy code, this will be replaced with Chris' read function
global tempdatabase
persistent readCnt

if isempty(readCnt)
    readCnt=1;
else
    readCnt=readCnt+1;
end;
if readCnt>length(tempdatabase)
    readCnt=1;
end;

dataOut=tempdatabase(readCnt,1:numChan);

% end of dummy code
