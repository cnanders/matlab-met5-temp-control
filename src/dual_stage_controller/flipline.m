%  function f = flipline(x)
% © Patrick Naulleau 2002
%
%  flips a 1-D array
%
%  see also flipud, fliplr, flipdim
%
%  function f = flipline(x)

function f = flipline(x)

[bs,bsi]=max(size(x));
f=flipdim(x,bsi);