function flushQueue(s)

% INPUT
% s: serial object connected to 1M9W-S Water Cooled Chiller

% RETURN
% void

% When the 1M9W-S queue is empty, calling fscanf(s) evokes a
% 'Warning: A timeout occurred before the Terminator was reached'
% warning message after several seconds and returns a string 
% '>' or ''.  The fscanf(s) call is blocking.

% The '>' is returned the first time fscanf(s) is called in an
% emptyqueue state and the empty string is returned in all 
% subsequent fscanf(s) calls in the same emptyqueue state.

warning off;
% disp('flushQueue: flushing ...');

while(1)
    a = fscanf(s);
    if(isempty(a) | a == '>')
        % disp('flushQueue: complete');
        break;
    end
end

warning on;
