function [ warpedsignals, isel, alignedtraces, iselt ] = traceSTW( ref_trace, warp_trace_s, warp_trace, warp, apply, ndx, numit, t )
%traceSTW: Calculates a warping function iteratively using the
%user-specified mass traces. 
% The warping function is first calculated from the first trace, then
% updated according to each additional trace. The warping function is then
% applied to the entire "warp" and "apply" signals (the TIC).
%
%   Inputs:
%       ref_trace: traces of reference signal from which to calculate
%           the alignment
%       warp_trace_s: smoothed traces of "warp" signals from which to
%           calculate the alignment
%       warp_trace: traces of "warp" signals to apply warping function to
%       warp: unnormalized, unsmoothed "warp" signals
%       apply: signals the warping function is to be applied to
%       ndx: defines number of basis functions for STW algorithm
%       numit: number of iterations of the STW algorithm (semiparwarp)
%       t: time axis, allows plotting
%
%   Outputs:
%       warpedsignals: "warp" signals after alignment
%       isel: selection of time axis warped to (indices for which the
%           interpolation is valid)
%       alignedtraces: aligned mass traces of the "warp" signals
%       iselt: indices for which the alignment of the "warp" traces is
%           valid
%
% Christina de Bruyn Kops, 2015

isel = cell(1,size(warp,2)+size(apply,2));
warpedsignals = cell(1,size(warp,2)+size(apply,2));
alignedtraces = cell(1,size(warp,2));
iselt = cell(1,size(warp,2));

% initial coefficients of basis functions
init_a = vertcat(1,zeros(ndx+3,1));

for sig = 1:size(warp_trace,2)

    % initialize with alignment of first trace
    [w sel a] = semiparwarp(warp_trace_s{sig}(:,1), ref_trace(:,1), ndx, numit, init_a);

    % update coefficients for warping function with each additional trace used
    if size(ref_trace,2) > 1
        for i = 2:size(ref_trace,2)
            [w sel a] = semiparwarp(warp_trace_s{sig}(:,i), ref_trace(:,i), ndx, numit, a);
        end
    end

    [warp_w is] = interpol(w, warp); % w is warping function
    [warp_trace_w it] = interpol(w, warp_trace{sig});
    isel{1,sig} = is;
    warpedsignals{sig} = warp_w;
    alignedtraces{sig} = warp_trace_w;
    iselt{sig} = it;

end

% apply warping function to signals in apply
for i = 1:size(apply,2)
    z = apply(:,i);
    [zw is] = interpol(w,z);
    warpedsignals{size(warp_trace,2) + i} = zw; 
    isel{size(warp_trace,2) + i} = is;
end

end

