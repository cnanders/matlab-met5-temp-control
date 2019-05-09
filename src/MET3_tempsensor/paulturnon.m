s1 = serial('COM1');
fopen(s1);
fprintf(s1,'RO,'); % Tells it to allow remote control
fprintf(s1,'GO,'); % Tells pump to turn on
flushQueue(s1); % clears all messages out of queue
fprintf(s1,'TE1,'); % asks for chiller status
fscanf(s1) % Print status of chiller.

% 707-529-8229 Chris cell phone.