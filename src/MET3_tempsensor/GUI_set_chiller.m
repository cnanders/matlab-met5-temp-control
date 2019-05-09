function GUI_set_chiller

global setPoint

s=get(gcbo,'String');
v=str2num(s);
if isempty(v)
    set(gcbo,'String',num2str(setPoint,'%3.1f'));
    return;
end

setPoint = v;
if (setPoint<15) setPoint=15; end;
if (setPoint>25) setPoint=25; end;
%fid=fopen('c:\temp.txt','wt');
%fprintf(fid,'%3.1f',setPoint);
%fclose(fid);
%!copy c:\\temp.txt c:\\chiller_command.txt
chiller_comm(setPoint); % send command to chiller
set(gcbo,'String',num2str(setPoint,'%3.1f'));

