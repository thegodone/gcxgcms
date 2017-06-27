function [alpha3] = fit_deltaL12(X,p1,beta_SO,program_flag,plotflag,prompt_output)

% retention time data
rt.calib = X.calib(:,1:2);
rt.alkanes = X.alkanes(:,1:3);

% fit parameters for the 1st dimension retention index
Ncref = interp1(rt.alkanes(:,2),rt.alkanes(:,1),rt.calib(:,1),'linear','extrap');
logL1_pred = polyval(p1,Ncref);

n = length(rt.calib);

% Abraham parameters
ABSEVLc = [X.calib(:,3:8) ones(n,1)];

% SE-30 coefficients taken from Abraham 1999 review
y_1 = [0.125 0.0 0.190 0.024 0.0 0.498 -0.194];

% OV-17 coefficients taken from Abraham 1999 review
y_2 = [0.263 0.0 0.653 0.071 0.0 0.518 -0.372];

logL1 = sum(ABSEVLc.*(ones(n,1)*y_1),2);
logL2 = sum(ABSEVLc.*(ones(n,1)*y_2),2);

delta_logL12 = logL2-beta_SO*logL1;

alpha3_guess = min([rt.calib(:,2); rt.alkanes(:,2)])/4;

if or(strcmp(prompt_output,'normal'), strcmp(prompt_output,'verbose'))
 disp('Now fitting alpha_3 with a nonlinear optimization of eq 7.');
end

% This nonlinear fit could be improved using the objective function Jacobian
alpha3 = lsqcurvefit(@(x,rt) convert_t2_to_logL(x,rt,program_flag)-beta_SO*logL1_pred, alpha3_guess, rt, delta_logL12);

logL2_pred = convert_t2_to_logL(alpha3,rt,program_flag);

delta_logL12_pred = logL2_pred - beta_SO*logL1_pred;

% bootstrap uncertainties using a clunky loop
N_boot = 1000;

if or(strcmp(prompt_output,'normal'), strcmp(prompt_output,'verbose'))
 disp('Conducting a bootstrap uncertainty analysis of alpha_3. This may take a minute.');
end

rng('shuffle');
for ind_b = 1:N_boot
 ind_r = randi(n,1,n);
 rt_b = rt;
 rt_b.calib = rt.calib(ind_r,:);
 Ncref_b = Ncref(ind_r);
 logL1_b = logL1(ind_r);
 p1_b = polyfit(Ncref_b,logL1_b,1);
 logL1_pred_b = polyval(p1_b,Ncref_b);
 logL2_b = logL2(ind_r);
 delta_logL12_b = logL2_b-beta_SO*logL1_b;
 options = optimset('display','off');
 alpha3_b(ind_b) = lsqcurvefit(@(x,rt_b) convert_t2_to_logL(x,rt_b,program_flag)-beta_SO*logL1_pred_b, alpha3_guess, rt_b, delta_logL12_b, [], [], options);
end

alpha3_median_boot = quantile(alpha3_b,0.5);
alpha3_unc(1) = alpha3-quantile(alpha3_b,0.025);
alpha3_unc(2) = quantile(alpha3_b,0.975)-alpha3;
alpha3_unc = mean(alpha3_unc);

if or(strcmp(prompt_output,'normal'), strcmp(prompt_output,'verbose'))
 disp('The fitted alpha_3 value is:');
 disp(alpha3);

 disp('The bootstrap uncertainty estimate of alpha_3 is:');
 disp(alpha3_unc);
end

if plotflag >= 1
 scrsz = get(0,'ScreenSize');
 figure('Position',[1 scrsz(4)/2 scrsz(3)/2.5 scrsz(4)/2]);
 plot(delta_logL12, delta_logL12_pred,'*');
 hold on; grid;
 plot(min(delta_logL12):0.1:max(delta_logL12),min(delta_logL12):0.1:max(delta_logL12),'--');
 hold off;
 title('Fitted delta log L_1_2 Values for the Calibration Analyte Set');
 xlabel('Abraham delta log L_1_2 Values');
 ylabel('Eq 7 Fitted delta log L_1_2 Values');
end

r2_deltaL12 = corrcoef(delta_logL12, delta_logL12_pred).^2;
rmse_deltaL12 = sqrt(sum((delta_logL12_pred-delta_logL12).^2)./length(delta_logL12));

if or(strcmp(prompt_output,'normal'), strcmp(prompt_output,'verbose'))
 disp('The r^2 and RMSE values of eq 7 fitted u_2 values are:'); 
 disp([r2_deltaL12(1,2) rmse_deltaL12]);
end

