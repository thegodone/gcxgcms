function [ warp_w, apply_w, isel ] = applySTW( reference_s, warp_s, warp, apply, ndx, numit, t )
%applySTW: Calculates a warping function based on the reference signal and
%the "warp" signal, then applies this one warping function to each of the
%"apply" signals.
%
%   Inputs:
%       reference_s: reference signal used to calculate warping function
%       warp_s: signal used to calculate the warping function
%       warp: unnormalized, unsmoothed version of warp_s
%       apply: signals the warping function is to be applied to
%       ndx: defines number of basis functions for STW algorithm
%       numit: number of iterations of the STW algorithm (semiparwarp)
%       t: time axis, allows plotting
%
%   Outputs:
%       warp_w: warped signal from "warp" array
%       apply_w: warped signals from "apply" array
%       isel: selection of time axis warped to (indices for which the
%             interpolation is valid
%
% Christina de Bruyn Kops, 2014

isel = cell(1,size(warp_s,2)+size(apply,2));

% calculate warping function based on signal in warp_s
[w sel a] = semiparwarp(warp_s, reference_s, ndx, numit);
[warp_w is] = interpol(w, warp); % w is warping function
isel{1} = is;

apply_w = cell(1,size(apply,2));

% apply warping function to signals in apply
for i = 1:size(apply,2)
    z = apply(:,i);
    [zw is] = interpol(w,z);
    apply_w{i} = zw; 
    isel{i+1} = is;
end

end

