function chiller_com(temp)

warning off;

s1 = serial('COM3');
set(s1,'BaudRate',9600,'Parity','none','DataBits',8,'StopBits',1);
fopen(s1);
fprintf(s1,'RO,'); % remote on
pause(1);

% cnanderson:  add checkCommStatus functionality
% that makes sure we can talk with the chiller 
% before setting its goal temperture.  If communication
% link is broken, checkCommStatus sends trouble email
% and returns 0.

if checkCommStatus(s1)

	% cnanderson: add checkAlarmStatus functionality
	% that will attempt to reset the chiller with Paul's
	% COM4 software override if a trip has occurred and
    % ALARM: 4 (reset avail) shows up.  
    
	checkAlarmStatus(s1);
	
	% set chiller to goal
	fprintf(s1,'SA%d,',round(temp*10)); 
	%fprintf(s1,'RF,'); % remote off
        
end


fclose(s1);
delete(s1);
clear s1;

warning on;