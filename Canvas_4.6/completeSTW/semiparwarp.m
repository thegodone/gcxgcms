function [w, sel, a] = semiparwarp(x, reference, ndx, numit, a)
% semiparwarp: Semi-parametric warping with B-splines
% 
% Input:
%   x: signal to warp
%   reference: reference signal
%   ndx: number of knots in the B-splines (number of B-splines is ndx+1)
%   numit: maximum number of iterations to be performed
%   a: vector of initial coefficients of basis functions
%
% Output:
%   w: warping function
%   sel: part of the reference signal that can be fitted (points of the
%        reference signal for which there is a matching point in the warped
%        signal)
%   a: coefficients of the basis functions
%
% Notes on the STW algorithm:
%   1) Time is implicit, indices in signal vector are used as the time axis
%      t.
%   2) A linear basis function was used in addition to the B-spline basis
%      functions, because the warping function should be initialized to be
%      linear.
%   3) The endpoints of the time axis were used as the endpoints for the
%      B-splines.
%
% Christina de Bruyn Kops, 2014
% Based on code from Paul Eilers' quadwarp function


m = max(length(x), length(reference));
t = (1:m)';   
bdeg = 3; % degree of the B-splines

% Generate basis functions (columns of B).
% Use a inear basis function and ndx+1 B-splines as the basis functions.
B = [t, bspline_chrom(t, 1, max(t), ndx, bdeg)]; 

n = size(B, 2); % number of basis functions

% If a not defined in function call, initialize warping coefficients of the
% B-splines to 0 and the coefficient of the linear basis function to 1
if ~exist('a','var') || isempty(a)
  a = vertcat(1,zeros(ndx+bdeg,1));  
end

% iterative optimization 
rms_old = 0;
for it = 1:numit  
   
   % Compute warping function w using equation 4 in the Nederkassel et al
   % (2006) paper
   w = B * a;
   
   % Warp chromatogram x to give z = x(w(x)) and its derivative g, i.e.
   % interpolate the warped time axis to the time axis of the reference
   % chromatogram
   [z sel g] = interpol(w, x);  

   % Compute residuals and check convergence
   r = reference(sel) - z;
   rms = sqrt(r' * r / m);      % calculate RMS
   drms = abs((rms - rms_old) / (rms + 1e-10));
   
   % stop iterations when change in RMS is small enough
   if drms < 1e-10    
      break
   end
   rms_old = rms;     % update RMS
   
   % Improve coeffcients with linear regression
   G = repmat(g, 1, n);
   Q = G .* B(sel, :);
   da = Q \ r; 
   a = a + da;

end

