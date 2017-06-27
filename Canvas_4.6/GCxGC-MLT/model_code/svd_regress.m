% [x, unc, b_pred, r2] = svd_regress(A,b);
%
% where A is an M by N overdetermined system of N parameters and 
%         M linear operators (parameter weights), and
%       b is the vector of dependent (r.h.s.) variables, of length M
%
% returns the least squares fit of the coefficients to solve the  
% problem A*x = b, the associated parameter uncertainties (std dev),
% the predicted (fitted) values of the dependent variables b, and the
% correlation coefficient r^2 of the fit residuals.
%
% J. Samuel Arey, EPFL, 2014.

function [coeffs, unc, b_calc, r2] = svd_regress(X,b)

[U,S,V] = svd(X);
N_parms = size(X,2);
N_molec = size(X,1);

%disp(' ');
%disp('The eigenvalues of the covariance matrix, S, are: ')
%if (N_parms == 1)
% disp(S(1));
%else
% disp(diag(S));
%end
%%cutoff = input('Define the desired S matrix lower cutoff\n? ');
cutoff = 0;

S_inv = S';
for k=1:N_parms
    if(S_inv(k,k) > cutoff)
        S_inv(k,k) = 1/S(k,k);
    else
        S_inv(k,k) = 0;
    end
end

%disp(' ');
%disp('The S_inverse diagonal values are now:');
%if (N_parms == 1)
% disp(S_inv(1));
%else
% disp(diag(S_inv));
%end

coeffs = zeros(N_parms,1);
for i = 1:N_parms
 coeffs = coeffs + U(:,i)'*b*S_inv(i,i)*V(:,i);
end

soln_terms = zeros(N_molec,N_parms);
for i = 1:N_molec
 soln_terms(i,:) = coeffs'.*X(i,:);
end

b_calc = sum(soln_terms,2);

unc = zeros(N_parms,1);
for i = 1:N_parms
 unc = unc + abs(V(:,i))*S_inv(i,i);
end

r2 = corr(b_calc,b)^2;

%figure
%plot(b_calc,b,'*');
%xlabel('computed b_fit value');
%ylabel('measured b value');
%hold on
%line = min(b):0.01*(max(b)-min(b)):max(b);
%plot(line,line)
%hold off
