function checkForTrip(s)

% If trip has occurred, alarm messages will be stored in
% the queue.  Flush them before checking the alarm status
flushQueue(s);

% Check alarm status, look for a '4' in the return string
% which indicates the device needs to be reset
fprintf(s,'AL,');
a = fscanf(s);
if(findstr(a,'4')
    
    % NEED TO RESET
    
    % open COM4 link, issue reset call. This will add an
    % 'ALARM: 0' to the queue, so need to clear it.
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
    while(toc<60)
        fprintf(s,'TE1,');
        a = fscanf(s);
        if(findstr(a,'ON')
            on = 1;
            break;
        end
    end
    
    if(~on)
        % E-mail
    end
              
end