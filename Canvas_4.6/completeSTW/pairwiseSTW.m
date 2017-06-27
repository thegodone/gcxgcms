function [ warp_w, isel ] = pairwiseSTW( reference_s, warp_s, warp, ndx, numit,t )
%pairwiseSTW: Calculates the pairwise warping function between each "warp"
%signal and the reference signal, then applies the corresponding warping
%function to each "warp" signal.
%
%   Input:
%       reference_s: reference signal used to calculate warping function
%       warp_s: signal used to calculate the warping function
%       warp: unnormalized, unsmoothed version of warp_s
%       ndx: defines number of basis functions for STW algorithm
%       numit: number of iterations of the STW algorithm (semiparwarp)
%       t: time axis, allows plotting
%
%   Output:
%       warp_w: warped signals
%       isel: selection of time axis corresponding to data points of the 
%             warped signal (the indices for which the
%             interpolation is valid)
%
% Christina de Bruyn Kops, 2014

warp_w = cell(1,size(warp_s,2));
isel = cell(1,size(warp_s,2));

for f = 1:size(warp_s,2)
    xs = warp_s(:,f);
    
    % Compute warping function based on smoothed signals and use it on
    % unsmoothed, unnormalized signal
    [w sel a] = semiparwarp(xs, reference_s, ndx, numit);
    [xw is] = interpol(w, warp(:,f)); % w is warping function
    warp_w{1,f} = xw;
    isel{1,f} = is;
    
    
%     % Plot the warping function
%
%     figure
%     subplot(1, 3, 1)
%     plot(w)         
%     fs = 8;
%     set(gca, 'FontSize', fs)
%     title({['Warping function',num2str(f)],'w(t)'})
%     subplot(1, 3, 2);
%     plot(w - t);
%     set(gca, 'FontSize', fs)
%     title('w(t) - t')
%     subplot(1, 3, 3)
%     plot(diff(w))
%     set(gca, 'FontSize', fs)
%     title('\Delta w(t)')

end  
 
end

