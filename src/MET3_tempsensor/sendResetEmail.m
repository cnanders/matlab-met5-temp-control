function sendResetEmail(fileText,subject)
disp(fileText);
fid=fopen('reset.txt','wt');
fprintf(fid,'%s',fileText);
fclose(fid);
%5183217116@vtext.com,
cmd=sprintf('!blat trouble.txt -to pnaulleau@lbl.gov,spnaulleau@yahoo.com,mbinenbaum@lbl.gov,jsincher@lbl.gov,jmritland@lbl.gov,cnanderson@lbl.gov,msjones@lbl.gov,gideonsf@sonic.net -subject "%s" -body "%s"',subject,fileText); 
eval(cmd);