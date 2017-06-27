function [ rho] = calculateCorrelationCoefficients( allsignals,ref,ref_orig,allbutref,apply_sigs,print )
%calculateCorrelationCoefficients: Calculates and, if specified, prints
%correlation coefficients before and after alignment.
% Correlation coefficients are calculated with the built-in MATLAB function
% corr. 
%   
% Input:
%   allsignals: all signals after alignment
%   ref: reference signal for calculating the correlation coefficient after
%       alignment
%   ref_orig: reference signal for calculating the original correlation
%       coefficient before alignment
%   allbutref: all non-reference signals before alignment
%   apply_sigs: "apply" signals, if any
%   print: defines whether the correlation coefficients should be printed
%       in the command window (1 = yes, 0 = no)
%
% Output:
%   rho: vector of correlation coefficients after alignment
%
% Christina de Bruyn Kops, 2015

rho = zeros(size(allsignals,2)-1,1);
for i = 2:size(allsignals,2)
    
    % calculate correlation coefficients after alignment
    rho(i-1,1) = corr(ref{i-1},allsignals{i});
    
    % print correlation coefficients before and after alignment, if desired
    if print == 1
        if any(apply_sigs) == 1
            if i == 2
                sigtype = 'warp';
            else 
                sigtype = 'apply';
            end
        else
            sigtype = 'warp';
        end

        fprintf('\n')
        disp(['Pairwise Correlation Coefficients ( ',sigtype,...
              ', signal ', num2str(i-1), '):  '])
        disp(['STW: ',num2str(rho(i-1)),'   unaligned:',...
              num2str(corr(ref_orig,allbutref(:,i-1)))]);
    end
end
if print == 1
    fprintf('\n')
end
end

