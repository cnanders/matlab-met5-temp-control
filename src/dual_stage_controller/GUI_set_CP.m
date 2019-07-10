function GUI_set_CP

global controlParams
global csgHandle

s=get(gcbo,'String');
v=str2num(s);
if isempty(v)
    set(gcbo,'String',num2str(controlParams.setPoint,'%4.2f'));
    return;
end

controlParams.setPoint=v;
setChillers(controlParams.setPoint);

