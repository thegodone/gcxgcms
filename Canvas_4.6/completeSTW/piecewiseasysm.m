function [ baselines ] = piecewiseasysm( signals )
%piecewiseasysm: Checks if the signal is too big for matlab memory. 
%If so, the signal is broken into aproximately equally-sized pieces, the
%asymmetric least squares smoothing is performed on each piece, and the
%pieces are reassembled. The cutoff length for choosing to break the
%signals and perform a piecewise baseline calculation is chosen to be 12000
%data points. If the signals are too long, the matrix generated in difsmw
%was found to be too large for Matlab's memory. 
%   
% Input:
%   signals: each column is a signal
%
% Output:
%   baselines: each column is the baseline of the corresponding signal
%
% Christina de Bruyn Kops, 2015

n = 12000; % number of acceptable data points
baselines = zeros(size(signals));

if size(signals,1) > n
    numpieces = ceil(size(signals,1)/n);
    for i = 1:numpieces
        endshort = min(i*(ceil(size(signals,1)/numpieces)),...
                       size(signals,1));
        shortsignal = signals((i-1)*ceil(size(signals,1)/numpieces)...
                              + 1:endshort,:);
        baselines((i-1)*ceil(size(signals,1)/numpieces)+1:endshort,:) = ...
                  asysm(shortsignal,1e7,0.001,2);
    end 
else
    baselines = asysm(signals,1e7,0.001,2);
end

end
