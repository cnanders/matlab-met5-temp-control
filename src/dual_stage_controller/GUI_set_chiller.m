function GUI_set_chiller

global controlParams
global csgHandle

s=get(gcbo,'String');
v=str2num(s);
if isempty(v)
    set(gcbo,'String',num2str(controlParams.setPoint,'%3.1f'));
    return;
end

controlParams.setPoint = v;
if (controlParams.setPoint<controlParams.minSetPoint) controlParams.setPoint=controlParams.minSetPoint; end;
if (controlParams.setPoint>controlParams.maxSetPoint) controlParams.setPoint=controlParams.maxSetPoint; end;

%chiller_comm(setPoint); % send command to chill plates
set(gcbo,'String',num2str(controlParams.setPoint,'%3.1f'));

