function [f, s, g] = interpol(t, y)
% interpol: Linear interpolation used to apply the warping function to a
% signal.
%
% Implicit assumption: y given on grid 1:m
%
% Input:
% t: points at which to compute interpolated values (the warping
%    function)
% y: signal to be interpolated
%
% Output:
% f: interpolated signal
% s: points of t with 1 <= t <= m
% g: gradient of y at points t
%
% Paul Eilers, 2002

m = length(y);
s = find(1 < t & t < m);  % find points at which to compute interpolated 
                          % values from vector t between 1 and the length 
                          % of the signal
                          
% for the values of t that were found in the length of the signal:
ti = floor(t(s));   % get integer part
tr = t(s) - ti;     % get fractional part
g = y(ti + 1) - y(ti);  % get signal values on ends of the interval
f = y(ti) + tr .* g;    % interpolate signal value at fractional part of interval
