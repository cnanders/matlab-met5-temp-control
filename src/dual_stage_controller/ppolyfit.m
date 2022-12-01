% function [f,p]=ppolyfit(x,y,N,[xi])
%
%  return Nth order fit to y of x, p=polynomial coefficients
%
%  x = x values
%  y = y values
%  N = order of fit
%  [xi] = x values for polynomial evaluation
%           if not passed xi=x
%

function [f,p]=ppolyfit(x,y,N,xi)

if (nargin<3)
   error('not enough input arguments');
end;
if (nargin<4)
   xi=x;
end;
   
p=polyfit(x,reshape(y,size(x)),N);
f=polyval(p,xi);