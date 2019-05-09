function success = checkCommStatus(s)

% INPUT
% s: serial object connected to 1M9W-S Water Cooled Chiller

% RETURN
% success: Boolean (1 or 0)

% This function will try to communicate with 's' and make sure
% the communication channel is working properly.  If an error
% is found, send out an email. For a check, we will ask for the
% alarm status and look for the word 'ALARM' in the return 
% string

% MOD 2010.11.09 Comment out
% disp('checkCommStatus: checking COM link ...');

warning off
flushQueue(s);

% If COM is down, fscanf(s) will issue a warning:
% 'timeout occurred before Terminator was reached' 
% There is no need to display this

fprintf(s,'AL,');
a = fscanf(s);

if(findstr(a,'ALARM'))
    % Communication is successful. Do nothing
    % disp('checkCommStatus: communications are OK.');
    success = 1;
else
    % Send email
    disp('checkCommStatus: chiller communication is down, sending email.');
    subject = 'MET chiller communication error';
    text = 'The MET chiller is not responding to COM requests.  Check out immediately!';
    sendResetEmail(text,subject);
    success = 0;
end
warning on
