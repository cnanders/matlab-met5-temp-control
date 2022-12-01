% function f=linfit(x,y,[xi])
%
%  return linear fit to y of x
%  x = x values
%  y = y values
%  [xi] = x values for polynomial evaluation
%           if not passed xi=x
%
%  if only one variable is passed x is assumed to be 0:length(y)-1

function [f,p]=linfit(x,y,xi)

if nargin<2
   y=x;
   x=0:length(y)-1;
end;

if (nargin<3)
   xi=x;
end;

[f,p]=ppolyfit(x,y,1,xi);