function [logL2_To] = convert_t2_to_logL(x,rt,program_flag);

n = length(rt.calib);

% retention time data; 1st and 2nd dimension retention times
t1 = rt.calib(:,1);
t2 = rt.calib(:,2);
Nc = rt.alkanes(:,1);
t1a = rt.alkanes(:,2);
t2a = rt.alkanes(:,3);

t2ref = interp1(t1a,t2a,t1,'linear','extrap'); 
Ncref = interp1(t1a,Nc,t1,'linear','extrap'); 

% Coefficients are set based on logL values predicted by Abraham eq given in
% Abraham 1999 (review) for OV 17 (Table 13) at 120 C.
logL2ref_To = 0.2613*Ncref - 0.5566;

logL2_To = logL2ref_To + log10((t2 - x(1))./(t2ref - x(1)));


