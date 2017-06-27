% main_code.m script called from "main.m" by user.
% 
% *** Do not modify this file. Normally the user should not need to adjust *** 
% *** anything in this script.                                             ***
%
% J. Samuel Arey and Jonas Gros, EPFL, March 17, 2016.
%

% mild exception handling

switch prompt_output
 case {'minimal'}
 case {'normal'}
 case {'verbose'}
 otherwise 
 disp('ERROR. The prompt_output variable is not properly set in file main.m');
 cd('../users');
 return;
end

% Additional error checks:
if ~exist(['../',input_path,Weathered_chromatogram_file],'file')
    error(['ERROR. Weathered chromatogram file (',['../users/input/',Weathered_chromatogram_file],' ) does not exist.'])
end
if ~exist(['../',input_path,Reference_chromatogram_file],'file')
    error(['ERROR. Reference chromatogram file (',['../users/input/',Reference_chromatogram_file],' ) does not exist.'])
end
if ~exist(['../',output_path],'dir')
    warning(['Indicated output directory, ''',...
        output_path,''' does not exist... Creating it.'])
    mkdir(['../',output_path])
end

% Which properties do you want to map onto the chromatogram?
% Enter a vector of integers ranging from 1 to 11. 
% (used when plot_flag==2)
mapped_properties = [1 7];

% determine eq 5 coefficients for 11 interesting properties
[eq5_coeffs, beta_SO] = fit_eq_5_coeffs(group_flag,plot_flag,output_path,prompt_output);

if strcmp(prompt_output,'verbose')
 disp('The beta parameter from the Schmidt orthogonalization of the training set is:');
 disp(beta_SO);
end

% load GCxGC retention times and Abraham parameters of measured analyte set
X.alkanes = load(strcat('../',input_path,'retention_times_alkanes_prog',program_flag,'.dat'));
X.calib = load(strcat('../',input_path,'retention_times_calibration_prog',program_flag,'.dat'));
% X.test = load(strcat('../',input_path,'retention_times_test_prog',program_flag,'.dat'));
try load(strcat('../',input_path,'retention_times_test_prog',program_flag,'.dat'))
    X.test = load(strcat('../',input_path,'retention_times_test_prog',program_flag,'.dat'));
catch
    X.test = [];
end

N_calib = length(X.calib);
N_test = length(X.calib) + length(X.test);

% fit parameters for the 1st dimension parameter u1 (eq 6)
a12 = fit_L1(X,plot_flag,prompt_output);

% fit parameters for the 2nd dimension parameter u2 (eq 7)
a3 = fit_deltaL12(X, a12, beta_SO, program_flag, plot_flag, prompt_output);

% calculate logL values for both instrument calibration analytes + test analytes
rt.calib = [X.calib(:,1:2); X.test];
rt.alkanes = X.alkanes(:,1:3);
Ncref = interp1(rt.alkanes(:,2),rt.alkanes(:,1),rt.calib(:,1),'linear','extrap');
logL1 = polyval(a12,Ncref);
logL2 = convert_t2_to_logL(a3,rt,program_flag);

logL12_test = [logL1 logL2];

savefilename = strcat('../',output_path,'logL12_test_prog',program_flag,'.dat');
% logL values predicted by eqs 6-7
save(savefilename,'logL12_test','-ascii','-tabs');

u_1 = logL1;
u_2 = logL2-beta_SO*logL1;

r2_u1_u2_test = corrcoef(u_1,u_2).^2;

if strcmp(prompt_output,'verbose')
 disp('Correlation of u_1 and u_2 values for the complete analyte set is given by r^2:');
 disp(r2_u1_u2_test(1,2));
end

savefilename = strcat('../',output_path,'u1_u2_test_prog',program_flag,'.dat');
u1_u2_test = [u_1 u_2 ones(N_test,1)];
save(savefilename,'u1_u2_test','-ascii','-tabs');

if plot_flag == 2
 scrsz = get(0,'ScreenSize');
 figure('Position',[1 scrsz(4)/2 scrsz(3)/2.5 scrsz(4)/2]);
 plot(u_1,u_2,'g*'); grid;
 title('Plot of u_1 and u_2 Values for the Complete Analyte Set');
 xlabel('u_1');
 ylabel('u_2');
end

for ind = 1:length(eq5_coeffs)
 predicted_properties_test(:,ind) = sum(u1_u2_test.*(ones(N_test,1)*eq5_coeffs(ind,:)),2);
end

savefilename = strcat('../',output_path,'predicted_properties_test_prog',program_flag,'.dat');
% partitioning properties predicted by eqs 5-7
save(savefilename,'predicted_properties_test','-ascii','-tabs');

savefilename = strcat('../',output_path,'ASM_predicted_properties_calib_prog',program_flag,'.dat');
[logL12_Abr, Abr_pred_properties] = Abraham_model_predictions(X.calib(:,3:8));
save(savefilename,'Abr_pred_properties','-ascii','-tabs');

% plot_property_maps(a12,a3,beta_SO,eq5_coeffs,modulation_period,acquisition_rate,program_flag,plot_flag,input_path,mapped_properties);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% MLT CODE:
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% Import the reference chromatogram:
Chromato = importChromato(['../',input_path,Reference_chromatogram_file],'SR',acquisition_rate,'MP',modulation_period);

% How many pixels we have in the first dimension:
nb_measX = size(Chromato,2); % [pixel], number of 1st dimension measurements
    
% 2-D matrices of 1st (X) and 2nd (Y) dimension elution times:
X = acquisition_delay/60+ones(modulation_period*acquisition_rate,1)*(0:(nb_measX-1))*modulation_period/60; % min, first dimension elution times for all pixels
Y = ((0:(modulation_period*acquisition_rate-1))'/acquisition_rate)*ones(1,nb_measX); % s, second dimension elution times for all pixels

% Remove column bleed and noise:
Chromato(Y<=Bleed_cutoff) = 0;

%     Compute u1 and u2 for whole chromatogram:
%     (adapted from model/main_code.m, lines 44 - 57)
Ncref = interp1(rt.alkanes(:,2),rt.alkanes(:,1),X,'linear','extrap');
logL1 = polyval(a12,Ncref);
rt2.alkanes = rt.alkanes;
rt2.calib = [X(:),Y(:)];
logL2 = convert_t2_to_logL(a3,rt2,program_flag);
logL2 = reshape(logL2,modulation_period*acquisition_rate,[]);
logL2 = real(logL2); % remove complexe part

u1 = logL1;

u2 = logL2 - beta_SO*logL1;

% figure; plotChromato(X,Y,u1*eq5_coeffs(1,1)+u2*eq5_coeffs(1,2)+eq5_coeffs(1,3),'MP',modulation_period,'SR',acquisition_rate); colorbar
% caxis([-5,3])

% 1st property = vapor pressure
% 7th property = solubility
% Compute vapor pressure and solubility for each pixel in the chromatogram:
logPl = u1*eq5_coeffs(1,1)+u2*eq5_coeffs(1,2)+eq5_coeffs(1,3); % vapor pressure Pa !!!!
logCw = u1*eq5_coeffs(7,1)+u2*eq5_coeffs(7,2)+eq5_coeffs(7,3); % solubility mol/m3 !!!

% % Decide on the finite element cell size
% winP = 0.4;  % logPl dim window size. A value of 0.4 is about 1 alkane / window
% winC = 0.5;  % logCw dim window size

if plot_flag>=2
    plot_property_maps(a12,a3,beta_SO,eq5_coeffs,modulation_period,acquisition_rate,program_flag,plot_flag,input_path,mapped_properties);
end
% Import a chromatogram:

% Generate the cells:
[NvarsP, NvarsC, P, C, cellsubind, cellsubind_wt] = make_finiteelements(winP,winC,logPl,logCw,Chromato,acquisition_rate,modulation_period,acquisition_delay,plot_flag,program_flag,Bleed_cutoff,bdP,bdC);
% Import the weathered chromatogram:
weathered_Chromato = importChromato(['../',input_path,Weathered_chromatogram_file],'SR',acquisition_rate,'MP',modulation_period);
% Normalize the weathered Chromatogram:
weathered_Chromato = weathered_Chromato * (Vol_Reference/Vol_Weathered);

% Remove column bleed and noise:
weathered_Chromato(Y<=Bleed_cutoff) = 0;

% SortedData = Chromato(:);
% SortedData = sort(SortedData(SortedData~=0),'descend');
% NoiseCutoff = SortedData(round(0.95*length(SortedData)));

% Finally draw the MLT:
figure;
plot_MLT(Chromato,weathered_Chromato,NvarsP,NvarsC,cellsubind,cellsubind_wt,P,C,'MLT',NoiseCutoff);


disp('Done.');

cd('../users');

