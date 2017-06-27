function [c, beta_SO] = fit_eq_5_coeffs(groupflag,plotflag,output_path,prompt_output)

% order of parameters: A B S E V L const X
Y = load('../model_parameters/Abraham_parms_training_set.dat');

group = Y(:,7);

% In case of groupflag set to zero, select all data for training.
% Otherwise use only the subset that matches the groupflag value.
if groupflag == 0
 group = group*0; 
end

Y = Y(group==groupflag,:);

p_exp_all = importdata('../model_parameters/expt_properties_training_set.dat','\t');
p_exp.data = p_exp_all.data(group==groupflag,:);

X = Y(:,1).*Y(:,2);  % "interaction" term for pure liquid properties pl and sw
n = length(X);

Y = [Y(:,1:6) ones(n,1) X];

y = load('../model_parameters/Abraham_coeffs.dat');
% indices:
% 1 SE-30
% 2 OV-17
% 3 pL
% 4 delta Hvap
% 5 Kha
% 6 Koa
% 7 Koc-a
% 8 Kaw
% 9 SwL
% 10 Kow
% 11 Koc-w
% 12 Kdoc-w
% 13 BCF
% 14 Khw
% 15 Knw
% 16 Ktw

% computation of hypothetical partition constant values
p_1 = sum(Y.*(ones(n,1)*y(1,:)),2);
p_2 = sum(Y.*(ones(n,1)*y(2,:)),2);

% save logL1 and logL2 values of the training set
logL12_training_set = [p_1 p_2];
savefilename = strcat('../',output_path,'logL12_training_set.dat');
save(savefilename,'logL12_training_set','-ascii','-tabs');

% Define u_1 and u_2 as two orthogonal bases of p_1 and p_2. First set:
u_1 = p_1;

% then determine a constant beta_SO relating p_1 and p_2 via Schmidt
% Orthogonalization of the system <u_1*(u_1-beta_SO*p_2)> = 0, which is:
beta_SO = sum(p_1.*p_2)/sum(p_1.^2);

% where for the orthogonal vectors <u_1*u_2> = 0
u_2 = p_2-beta_SO*p_1;

% fit eq 5 coeffs for properties for which experimental data is available
y_ind = [3 4 5 6 7 8 9 10 11 12 13];

Nboot = 1000;

for exp_ind = 1:length(y_ind)

 p(:,exp_ind) = sum(Y.*(ones(n,1)*y(y_ind(exp_ind),:)),2);

% substitute experimental data, where available
 p_exp_ind = p_exp.data(:,exp_ind);
 p(p_exp_ind==p_exp_ind,exp_ind)=p_exp_ind(p_exp_ind==p_exp_ind);

 [c(exp_ind,:), c_CI, p_pred(:,exp_ind), r2(exp_ind), r2_unc] = svd_regress_boot([u_1 u_2 ones(n,1)],p(:,exp_ind),Nboot);
 c_unc(exp_ind,:) = mean(c_CI); 
 
 if c_unc(exp_ind,2) > abs(c(exp_ind,2))
  [c_tmp, c_CI_tmp, p_pred(:,exp_ind), r2(exp_ind), r2_unc] = svd_regress_boot([u_1 ones(n,1)],p(:,exp_ind),Nboot);
  c(exp_ind,:) = [c_tmp(1) 0 c_tmp(2)];
  c_CI = [c_CI_tmp(:,1) zeros(2,1) c_CI_tmp(:,2)];
  c_unc(exp_ind,:) = mean(c_CI); 
 end

 % obtain rmse values for the eq 5 fit
 rmse(exp_ind) = sqrt(sum((p_pred(:,exp_ind)-p(:,exp_ind)).^2)./length(p(:,exp_ind)));

 if plotflag == 2
  scrsz = get(0,'ScreenSize');
  figure('Position',[1 1 scrsz(3)/2.5 scrsz(4)/2]);
  plot(p(:,exp_ind),p_pred(:,exp_ind),'g^');
  hold on; plot(min(p(:,exp_ind)):0.1:max(p(:,exp_ind)),min(p(:,exp_ind)):0.1:max(p(:,exp_ind)),'k--');
  hold off;
  xlabel('Experimental or ASM-predicted Value');
  ylabel('Fitted Value');
  switch exp_ind
   case 1
    title('Fitted log p_L Values (Pa) of the Training Set Using Eq 5');
   case 2
    title('Fitted Enthalpy of Vaporization Values (kJ/mol) of the Training Set Using Eq 5');
   case 3
    title('Fitted log K hexadecane-air Values of the Training Set Using Eq 5');
   case 4
    title('Fitted log K octanol-air Values of the Training Set Using Eq 5');
   case 5
    title('Fitted log K organic carbon-air Values of the Training Set Using Eq 5');
   case 6
    title('Fitted log K air-water Values of the Training Set Using Eq 5');
   case 7
    title('Fitted log S_w_L Values (mol/m3) of the Training Set Using Eq 5');
   case 8
    title('Fitted log K octanol-water Values of the Training Set Using Eq 5');
   case 9 
    title('Fitted log K amorphous organic carbon-water Values of the Training Set Using Eq 5');
   case 10
    title('Fitted log K dissolved organic carbon-water Values of the Training Set Using Eq 5');
   case 11
    title('Fitted Bioconcentration Factor Values of the Training Set Using Eq 5');
  end
 end
end

c_unc(c==0) = 0;
all_eq5_statistics = [c c_unc rmse' r2'];

%disp('Eq 5 Training Set Fit Statistics are as Follows:');
%disp('     lam1      lam2      lam3    pm_lam1   pm_lam2   pm_lam3     RMSE      r^2');
%disp(all_eq5_statistics);

if strcmp(prompt_output,'verbose')
 property_names = importdata('../model_parameters/properties_list.txt');
 disp('Eq 5 Training Set Fit Statistics are as Follows:');
 disp('r^2      RMSE      property');
 for ind_prop = 1:length(rmse)
  str1 = sprintf('%1.2f     ',r2(ind_prop));
  str2 = sprintf('%2.2f     ',rmse(ind_prop));
  disp([str1,str2,property_names{ind_prop}]);
 end
 disp(' ');
end

savefilename = strcat('../',output_path,'eq5_training_set_fit_statistics.dat');
save(savefilename,'all_eq5_statistics','-ascii');

% correlation of u_1 with u_2 
r2_u1_u2_training_set = corrcoef(u_1-mean(u_1),u_2-mean(u_2)).^2;

if strcmp(prompt_output,'verbose')
 disp('The correlation of u_1 and u_2 of the training set is described by r^2 of:');
 disp(r2_u1_u2_training_set(1,2))
end

u12 = [u_1 u_2];
savefilename = strcat('../',output_path,'u1_u2_values_training_set.dat');
save(savefilename,'u12','-ascii');

