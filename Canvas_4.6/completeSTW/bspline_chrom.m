function B = bspline_chrom(x, xl, xr, ndx, bdeg)
%bspline_chrom: Compute B-splines over a given interval with specified
%degree and number of knots.
% Calculates B-splines in the case of equidistant knots using the
% recurrence relation from Eilers and Marx (1996). 
%
% Input:
%   x: vector of the x-domain
%   xl: left end of the x-domain (position of left-most spline)
%   xr: right end of the x-domain (position of right-most spline)
%   ndx: number of knots (number of intervals on the x-domain)
%   bdeg: degree of B-splines
%   
%
% Code from Eilers and Marx 1996
% Comments: Christina de Bruyn Kops, 2014

dx = (xr - xl) / ndx;           % calculate distance between knots
t = xl + dx * [-bdeg:ndx-1];
T = (0 * x + 1) * t;            % = ones(size(x)) * t 
X = x * (0 * t + 1);            % = x * ones(size(t))
P = (X - T) / dx;               % divide by distance between knots
B = (T <= X) & (X < (T + dx));  % initialize B
r = [2:length(t) 1];
 
% update B to define B-splines
for k = 1:bdeg
    B = (P .* B + (k + 1 - P) .* B(:, r)) / k;
end

%Plot B-splines:
% figure
% for i = 1:size(B,2)
%     plot(1:size(x,1), B(:,i))
%     hold on
% end
% title('B-splines')
% xlabel('x scale')
% ylabel('B-splines')

end

