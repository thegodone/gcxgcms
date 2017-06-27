% [x, x_unc, b_calc, r2, r2_unc] = svd_regress_boot(A,b,N_boot);
%
% where A is an M by N overdetermined system of N parameters and 
%         M linear operators (parameter weights), and
%       b is the vector of dependent (r.h.s.) variables, of size M by 1
%       N_boot is the number of bootstrap samples to be drawn
%
% Returns the least squares fit of the coefficients x to solve the problem
% A*x = b; the bootstrapped set of distributed x values, x_boot; the 
% 2.3 and 97.7 percentile confidence values of this distribution, x_unc; 
% the fitted values b_calc of the dependent variables b using the original 
% sample A; the model "predictive" residuals over the bootstrap sample, 
% resid_boot = b - A.*x_boot, the correlation coefficient r2 of fit 
% residuals of the original solution A*x = b; the set of bootstrap samples 
% of the correlation coefficient r2_boot; and the 2.3 and 97.7 percentile 
% confidence values of this distribution r2_unc.
%
% To quickly view the distributions of the bootstrapped parameters, use:
% >> hist(x_boot);
% >> hist(resid_boot);
% >> hist(r2_boot);
%
% J. Samuel Arey, EPFL, 2014.

function [x, x_unc, b_calc, r2, r2_unc] = svd_regress_boot(A, b, Nboot);

% function [x_boot, r2_boot] = svd_regress_boot(A, b, Nboot);

% function [coeffs, unc, b_calc, r2] = svd_regress(X,b)

C = [A,b];

Np = size(A,2);
Nm = size(A,1);

Y = svd_proc(C);

x = Y(1:Np);
r2 = Y(Np+1);

soln_terms = zeros(Nm,Np);
for i = 1:Nm
 soln_terms(i,:) = x'.*A(i,:);
end

x = x';

b_calc = sum(soln_terms,2);

Y_boot = bootstrp(Nboot, @svd_proc, C);

[x_boot, r2_boot] = deal(Y_boot(:,1:Np),Y_boot(:,Np+1));

%x_unc = [[prctile(x_boot,15.87)]; [prctile(x_boot,84.13)]];     % lower/upper bound of the 68.3% confidence interval of x

x_unc = [[(x-prctile(x_boot,2.5))]; [(prctile(x_boot,97.5)-x)]];     % lower/upper bound of the 95% confidence interval of x

%r2_unc = [prctile(r2_boot,15.87); prctile(r2_boot,84.13)];  % lower/upper bound of the 68.3% confidence interval of r2

r2_unc = [(r2-prctile(r2_boot,2.5)); (prctile(r2_boot,97.5)-r2)];  % lower/upper bound of the 95% confidence interval of r2

%resid_boot = zeros(Nboot,Nm,Np);
for j = 1:Nboot
 for i = 1:Nm
  soln_terms(i,:) = x_boot(j,:).*A(i,:);
 end
 b_pred_boot = sum(soln_terms,2);
 resid_boot(:,j) = b_pred_boot - b;
end

% ----------------------------------------------------------------
function svd_out = svd_proc(Ci);
Ai = Ci(:,1:size(Ci,2)-1);
bi = Ci(:,size(Ci,2));
[U,S,V] = svd(Ai);
N_parms = size(Ai,2);
N_molec = size(Ai,1);

cutoff = 0;

S_inv = S';
for k=1:N_parms
    if(S_inv(k,k) > cutoff)
        S_inv(k,k) = 1/S(k,k);
    else
        S_inv(k,k) = 0;
    end
end

xi = zeros(N_parms,1);
for i = 1:N_parms
 xi = xi + U(:,i)'*bi*S_inv(i,i)*V(:,i);
end

soln_terms = zeros(N_molec,N_parms);
for i = 1:N_molec
 soln_terms(i,:) = xi'.*Ai(i,:);
end

bi_calc = sum(soln_terms,2);

r2i = corr(bi_calc,bi)^2;

svd_out = [xi; r2i];

