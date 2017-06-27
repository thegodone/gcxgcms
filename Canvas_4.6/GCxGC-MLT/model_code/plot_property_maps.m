function [] = plot_property_maps(a12,a3,beta_SO,lam,modulation_period,acquisition_rate,program_flag,plot_flag,input_path,mapped_properties)

rt.alkanes = load(strcat('../',input_path,'retention_times_alkanes_prog',program_flag,'.dat'));

old = rt.alkanes(:,3);

rt.alkanes(:,3) = smooth(rt.alkanes(:,3));

C1 = rt.alkanes(1,1);

Nalk = length(rt.alkanes);

CN = rt.alkanes(Nalk,1);

if CN > 25
 CN = 25;
 Nalk = find(rt.alkanes(:,1)==CN);
end

run_time = [0 rt.alkanes(Nalk,2)+10];

rt1 = [rt.alkanes(1,2):(modulation_period/60):rt.alkanes(Nalk,2)]';
rt2 = [a3:(1/acquisition_rate):modulation_period];

[X,Y] = meshgrid(rt1,rt2);
N = prod(size(X));

rt.calib(:,1) = reshape(X,1,N);
rt.calib(:,2) = reshape(Y,1,N);

Ncref = interp1(rt.alkanes(:,2),rt.alkanes(:,1),rt.calib(:,1),'linear','extrap');

logL1 = polyval(a12,Ncref);

logL2 = convert_t2_to_logL(a3,rt,program_flag);

u_1 = logL1;

u_2 = logL2-beta_SO*logL1;

basis = [u_1 u_2 ones(N,1)];

scrsz = get(0,'ScreenSize');

if plot_flag == 2
 figure('Position',[1 1 scrsz(3)/2.5 scrsz(4)/2]);
 plot(rt.alkanes(:,2),rt.alkanes(:,3),'^');
 hold on;
 plot(rt.alkanes(:,2),old,'*k');
 legend('smoothed','actual');
 hold off;
 title('Smoothed and actual second dimension retention time data for n-alkanes');
 xlabel('First dimension retention time')
 ylabel('Second dimension retention time')
end

if plot_flag >= 1
 % set contour levels in property plot
 v{1} = [-4.5:0.5:2.5];  % vapor pressure
 v{2} = [45:5:115];      % delta H vap
 v{3} = [4.0:0.5:11.5];  % hexadecane-air partition coefficient
 v{4} = [4.0:0.5:10.5];  % dry octanol-air partition coefficient
 v{5} = [3.0:0.5:10.0];  % organic carbon-air partition coefficient 
 v{6} = [-3.5:1.0:2.5];  % air-water partition coefficient
 v{7} = [-5.0:1.0:0.5];  % pure liquid aqueous solubility
 v{8} = [3.0:1.0:8.0];   % wet octanol-water partition coefficient
 v{9} = [2.5:1.0:6.5];   % organic carbon-water partition coefficient
 v{10} = [3.0:1.0:7.0];  % dissolved organic carbon-water partition coefficient
 v{11} = [3.5:1.0:7.5];  % bioconcentration factor
 
%  List of property names:
prop_names = {'pure liquid vapor pressure (Pa)';
'enthalpy of vaporization (kJ/mol)';
'hexadecane-air partition coefficient ( (mol/L)/(mol/L) )';
'dry octanol-air partition coefficient ( (mol/L)/(mol/L) )';
'organic carbon-air partition coefficient ( (mol/kg)/(mol/L) )';
'air-water partition coefficient ( (mol/L)/(mol/L) )';
'pure liquid aqueous solubility (mol/m3)';
'wet octanol-water partition coefficient ( (mol/L)/(mol/L) )';
'organic carbon-water partition coefficient ( (mol/kg)/(mol/L) )';
'dissolved organic carbon-water partition coefficient ( (mol/kg)/(mol/L) )';
'bioconcentration factor ( (mol/kg)/(mol/L) )'};
 
 for ind = mapped_properties
  predicted_properties(:,ind) = sum(basis.*(ones(N,1)*lam(ind,:)),2);
  property_map(ind,:,:) = reshape(predicted_properties(:,ind),length(rt2),length(rt1));
  figure('Position',[1 1 scrsz(3)/2.5 scrsz(4)/2]);
%   figure(fig__)
  hold on;
  [cont, chandle] = contour(rt1,rt2,squeeze(property_map(ind,:,:)),v{ind});
  clabel(cont,chandle);
  grid;
%   colormap('cool');
  axis([run_time 0 rt2(end)]);
  title_string = ['Contour Plot of Partitioning Property ', num2str(ind),...
      prop_names(ind)];
  title(title_string);
  xlabel('1st Dimension Retention Time (min)');
  ylabel('2nd Dimension Retention Time (sec)');
  hold off;
 end
end

rt.calib = load(strcat('../',input_path,'retention_times_calibration_prog',program_flag,'.dat'));
rt.test = load(strcat('../',input_path,'retention_times_test_prog',program_flag,'.dat'));

if plot_flag >= 1
 scrsz = get(0,'ScreenSize');
 figure('Position',[1 scrsz(4)/2 scrsz(3)/2.5 scrsz(4)/2]);
 plot(rt.calib(:,1),rt.calib(:,2),'k^');
 hold on;
 if rt.test
  plot(rt.test(:,1),rt.test(:,2),'g^');
 end
 grid;
 axis([run_time 0 rt2(end)]);
 title('Plot of Retention Times for Calibration Analytes and Test Analytes');
 legend('Calibration','Test');
 xlabel('Retention Time 1 (min)');
 ylabel('Retention Time 2 (sec)');
 hold off;
end

