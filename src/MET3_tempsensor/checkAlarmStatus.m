function success = checkAlarmStatus(s)

% INPUT
% s: serial object connected to 1M9W-S Water Cooled Chiller

% RETURN
% success: Boolean (1 or 0)

% If no alarm, or successful reset, checkAlarmStatus return 1,
% else retirm 0. Send an email with info about the alarm and
% whether or not the reset attempt was a success
	
% MOD 2010.11.09 commenting out display text
% disp('checkAlarmStatus: checking alarm status ...');

% If trip has occurred, alarm messages will be stored in
% the queue.  Flush them before checking the alarm status
warning off;
flushQueue(s);

% Check alarm status, look for a '4' in the return string
% which indicates the device needs to be reset
fprintf(s,'AL,');
a = fscanf(s);
acopy = a;

% Unfortunately, the char array returned by the chiller is not directly
% passable to Naulleau's E-mail routine.  I will go through
% it and build a string that can be interpreted by the email
% method

tok = 'notempty';
alarmMsg = 'ALARM: ';
alarm = 0; % init to no alarm

while(~isempty(tok))
    [tok,acopy] = strtok(acopy,' ');
    if(~isempty(tok))
        if(~isempty(str2num(tok)))
            if(str2num(tok) ~= 0)
                % We've found an alarm code that isn't 0
                alarmMsg= [alarmMsg,' ',tok];
                alarm = 1;
            end
        end
    end
end

if(alarm)
    
    disp('checkAlarmStatus: alarm identified.');
    
    % Check if reset is available.  If so, try to reset.
    % Then send email
    
	if(findstr(a,'4'))
        
        % NEED TO RESET
        
        % open COM4 link, issue reset call. This will add an
        % 'ALARM: 0' to the queue, so need to clear it.
        
        disp('checkAlarmStatus: opening COM4 link to reset chiller ...');
        
        s4 = serial('COM4');pause(1);
        set(s4,'BaudRate',1200) % Low BaudRate forces a long data transmission
        fopen(s4);
        fprintf(s4,'%1.300f',pi);
        fclose(s4);
        delete(s4);
        flushQueue(s);
        
        % Re-establish RS-232 control, clear the blank string
        % this adds to the queue
        fprintf(s,'RO,');fscanf(s);
        
        % Start the compressor and pump, clear the blank string
        % this adds to the queue
        fprintf(s,'GO,');fscanf(s);
        
        % Enter a while loop that repeatedly calls the device
        % and checks its system on/off status.  Once on status
        % is reached, break.  If on status is not reached within
        % 1 minute, send email.
        
        tic
        on = 0;
        while toc<20
            disp('checkAlarmStatus: checking status post reset...');
            fprintf(s,'TE1,');pause(5);
            status = fscanf(s);
			if findstr(status,'ON')
	            on = 1;
	            break;
            end
	    end
        
        if(~on)
            % Send E-mail with alarm code that says we could not
            % get the Chiller to turn back on
            disp('checkAlarmStatus: reset failed, sending email.');
            subject = 'MET chiller problem!!!';
            text = ['The chiller issued the following alarm code: ',alarmMsg,'  The COM4 software reset FAILED.'];
            sendResetEmail(text,subject);
            success = 0;
        else
            % Send an E-mail with alarm code that saya we were
            % able to get the Chiller back on
            disp('checkAlarmStatus: reset successful, sending email.');
            subject = 'MET chiller has been reset';
            text = ['The chiller issued the following alarm code: ',alarmMsg,'  The software reset was successful.'];
            sendResetEmail(text,subject);
            success = 1;
        end         
    else
        % Here there was an alarm code but no reset avail.  Send
        % appropriate email.
        disp('checkAlarmStatus: reset not available, sending email.');
        subject = 'MET chiller problem!!!';
        text = ['The chiller issued the following alarm code: ',alarmMsg,'  Reset option (CODE 4) was not available.  Check out immediately!'];
        sendResetEmail(text,subject);
        success = 1;
    end
else
    % disp('checkAlarmStatus: everything is OK.')
    success = 1;
end
warning on;