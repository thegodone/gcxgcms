function [logL12,p] = Abraham_model_predictions(Y)

n = length(Y);

X = Y(:,1).*Y(:,2);  % "interaction" term for pure liquid properties pl and sw

Y = [Y ones(n,1) X];

y = load('../model_parameters/Abraham_coeffs.dat');
% indices:
% 1 SE-30
% 2 OV-17
% 3 aw
% 4 ow
% 5 ca
% 6 oa
% 7 pl
% 8 sw
% 9 cw
% 10 dw
% 11 bc
% 12 ha
% 13 hw
% 14 nw
% 15 tw

logL12(:,1) = sum(Y.*(ones(n,1)*y(1,:)),2);
logL12(:,2) = sum(Y.*(ones(n,1)*y(2,:)),2);

for y_ind = 1:size(y,1)-2
 p(:,y_ind) = sum(Y.*(ones(n,1)*y(y_ind+2,:)),2);
end

