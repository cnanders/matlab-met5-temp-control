% function dataOut = getTemps(tempSensorControlDataStruct,currentTemp)
%
% Fill the tempSensorControlDataStruct from the currentTemp stucture
%
% currentTemp stucture
% 	  avgCnt: rolling average buffer counter
% 	  avg: rolling average filter size in counts
% 	  Nchan: number of temperature channels
% 	  buffer: buffer for rolling average
% 	  avgTemps: current averaged temperature, this is the only field required in this function
%
% tempSensorControlDataStruct structure:
%     temps: 2d array with circular buffer history of temp data [channel,index]
%     currentIdx: index to current reading
%     Nbuf: buffer size
%     Nchan: number of channels
%     Labels: channel labels cell array
%     Channel 1 should always be set to the compound optic temp which is likely and average of multiple physical channels
%     Channel 2 should always be set to the compound chill plate temp (average of 4 chill plates)
%     Channel 3 should always be set to the compound subframe temp (average of subframe sensors)

function tempSensorControlDataStruct = getTemps(tempSensorControlDataStruct,currentTemp)

tempSensorControlDataStruct.currentIdx = tempSensorControlDataStruct.currentIdx+1;
if tempSensorControlDataStruct.currentIdx > tempSensorControlDataStruct.Nbuf
    tempSensorControlDataStruct.currentIdx = 1;
end;
if tempSensorControlDataStruct.currentIdx < 1
    tempSensorControlDataStruct.currentIdx = 1;
end;

% Fill the tempSensorControlDataStruct circular buffer with virtual and physical temperature channels
tempSensorControlDataStruct.temps(:,tempSensorControlDataStruct.currentIdx)=currentTemp.avgTemps;         % fill in all the raw channels from the averaging buffer