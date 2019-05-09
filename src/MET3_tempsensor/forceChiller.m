function forceChiller(setPoint)

% if (setPoint<15) setPoint=15; end;
% if (setPoint>25) setPoint=25; end;
% fid=fopen('c:\temp.txt','wt');
% fprintf(fid,'%3.1f',setPoint);
% fclose(fid);
% !copy c:\\temp.txt c:\\chiller_command.txt
chiller_comm(setPoint)