%   function [d,fs]=plotdom(x1,x2,N)
% © Patrick Naulleau 1995
% This function returns a domain for plotting (1-D) 
%  and the sampling freq. 
%  fs is returned in samples per meter or second 
%   assuming x1 and x2 are in meters or seconds
%
%   given:
%       x1 = starting point ( meters or seconds)
%       x2 = end point ( meters or seconds)
%       N  = number of samples
%       returns d: the plot domain
%		fs: the smapling rate
%
%   function [d,fs]=plotdom(x1,x2,N)
  
function [d,fs]=plotdom(x1,x2,N)

 %  if x1>=x2 error('   End point larger than or equal to starting point'); end;
   ss = abs(x2-x1)/(N-1);    % get step size
   if ss==0
       d=zeros(1,N)+x1;
       return;
   end;
   d = x1:ss*sign(x2-x1):x2;   % produce N point domain
   fs = 1/ss;         % get sampling rate (samples per meter or second)
                      %  assuming x1 and x2 are in meters or seconds
