a = 'this is a test';
tok = 'notempty';
while(~isempty(tok))
    [tok,a] = strtok(a,' ');
    disp(a);
end