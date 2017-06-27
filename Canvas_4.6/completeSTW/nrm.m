function [ normalized_sig ] = nrm( sig )
%nrm: Normalize the chromatogram signals by dividing each by its average
%value.
% Can be used on matrices and cells in which each signal is a column
% vector.
%   
%   Input:
%       sig: cell or matrix of signals to normalize
%   
%   Output:
%       normalized_sig: normalized signal
%
% Christina de Bruyn Kops, 2015

if iscell(sig) == 1
    normalized_sig = cell(size(sig));
    for i = 1:size(sig,2)
        normalized_sig{i} = bsxfun(@rdivide,sig{i},mean(sig{i},1));
    end
else
    normalized_sig = bsxfun(@rdivide,sig,mean(sig,1));
end

end

