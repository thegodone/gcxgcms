function [alpha12] = fit_L1(X,plotflag,prompt_output)

n = length(X.calib(:,1));

Ncref = interp1(X.alkanes(:,2),X.alkanes(:,1),X.calib(:,1),'linear','extrap'); 

ABSEVLc = [X.calib(:,3:8) ones(n,1)];

% SE-30 coefficients taken from Abraham 1999 review
y_1 = [0.125 0.0 0.190 0.024 0.0 0.498 -0.194];

logL1 = sum(ABSEVLc.*(ones(n,1)*y_1),2);

% alpha12 contains the slope and intercept parameters of the regression of eq 6
N_boot = 1000;

[alpha12, alpha12_unc, logL1_pred, r2_L1, r2_L1_unc] = svd_regress_boot([Ncref ones(n,1)],logL1,N_boot);

if ( 0.5*mean(alpha12_unc(:,2)) > abs(alpha12(2)) )
 disp('During the regression of eq 6, the intercept is found to be statistically equivalent to zero.');
 disp('Refitting with alpha2 set to zero.');
 [alpha12, alpha12_unc, logL1_pred, r2_L1, r2_L1_unc] = svd_regress_boot([Ncref],logL1,N_boot);
 alpha12 = [alpha12 0];
 alpha12_unc = [alpha12_unc zeros(2,1)];
end

alpha12_unc = mean(alpha12_unc);
rmse_L1 = sqrt(sum((logL1_pred-logL1).^2)./length(logL1));

if or(strcmp(prompt_output,'normal'), strcmp(prompt_output,'verbose'))
 disp('Fitted alpha_1 and alpha_2 values (eq 6) are:');
 disp(alpha12);

 disp('Bootstrap uncertainty estimates of alpha_1 and alpha_2 are:');
 disp(alpha12_unc);

 disp('The resulting r^2 and RMSE values of eq 6 fitted u_1 values are:'); 
 disp([r2_L1 rmse_L1])
end

if plotflag >= 1
 scrsz = get(0,'ScreenSize');
 figure('Position',[1 scrsz(4)/2 scrsz(3)/2.5 scrsz(4)/2]);
 plot(logL1,logL1_pred,'*');
 hold on; plot(min(logL1):0.1:max(logL1),min(logL1):0.1:max(logL1),'--'); grid;
 hold off;
 title('Fitted log L_1 Values for the Calibration Analyte Set');
 xlabel('Abraham log L_1 Values');
 ylabel('Eq 6 Fitted log L_1 Values');
end

