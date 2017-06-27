% gas: 'H2'/'He'/'N2'
%   d: column internal diameter [mm]
%  Po: outlet pressure [psia]
%   T: column temperature [C]
%  tm: holdup time [s]
%   E0: column efficiency at EOF
% Emax: maximum column efficiency
function [E0,Emax]=d2hof(gas,d,Po,T,tm)
    T = max(0,T+273.15);                  % [K] converted from [C]    
    Tref = 298;                           % [K]
    Pref = 14.696;                        % [psia]
    k = 3;                                % retention factor
    ds = d*0.001;                         % [mm], film thickness
    Ds = 1e-5;                            % [cm^2/s], solute diffusivity in stationary phase
    C = 50767;
    G1 = sqrt((1+6*k+11*k^2)/3)/(1+k);

    vis = viscosity(gas,T);               % [uPoise]
    SOF = getSOF(gas,d);                  % [sccm]
    hmin = d*G1/2;                        % [mm], minimum plate height for thin film column under low pressure
    Fmin = SOF/sqrt(2);                   % [sccm], rigorously Fmin = 12*pi*Tref/Pref/T*d*Dm(gas,T,Pref)*Pref/G1
        
    n = 1500;
    dF = 0.01;
    m = 10;
    F = linspace(Fmin-dF*m,Fmin+dF*(n-1),n+m);
    
    if (Po==0)
        Po = sqrt(F/C*Pref/Tref*(250+273.15)*viscosity(gas,250+273.15)*0.17/d^4);  % [psia]
    end    
    Pi = ((T*Pref/Tref/d^3*sqrt(tm*vis/10/pi/C)*F).^2+Po.^3).^(1/3);  % [psia]
    L = C*Tref/Pref*d^4/T/vis./F.*(Pi.^2-Po.^2);                      % [m]
    Fchar = 9*C/4*d^4/vis/T/Pref*Tref*Po.^2./L;                       % [sccm]
    v = F./Fchar;
    vmin = Fmin./Fchar;
    delta = 2*C/pi*k/(1+k)^2/G1*d*ds^2*Po/Ds/vis./L.*y(vmin)./f1(vmin);
    Y = y(v)./y(vmin);

    H = (f1(v)./f1(vmin).*(F/Fmin+Fmin./F)/2+delta.*Y).*f1(vmin)*hmin;    
    N = (L/L(m+1))./(H/H(m+1));
    Emax = sqrt(max(N)*L(m+1)*1000/hmin);
    E0 = sqrt(L(m+1)*1000/hmin);
    
    count = 0;
    N1 = N;
    Lmin = L;
    while (max(abs(N1-1))>0.0001 && count<10)
        Lmin = Lmin./N1;
        Fchar1 = Fchar.*L./Lmin;
        v = F./Fchar1;
        vmin = Fmin./Fchar1;
        delta1 = 2*C/pi*k/(1+k)^2/G1*d*ds^2*Po/Ds/vis./Lmin.*y(vmin)./f1(vmin);
        Y1 = y(v)./y(vmin);
        H = (f1(v)./f1(vmin).*(F/Fmin+Fmin./F)/2+delta1.*Y1).*f1(vmin)*hmin;   
        N1 = (Lmin/Lmin(m+1))./(H/H(m+1));
        count = count + 1;
    end
    if (count==100)
        disp(['not converged after ',num2str(count),' iterations!']);
    end
    Pi_min = sqrt(F.*Lmin*vis*T*Pref/Tref/C/d^4+Po.^2);
    tm_min = 10*pi/C*vis*(Lmin/d).^2.*(Pi_min.^3-Po.^3)./(Pi_min.^2-Po.^2).^2/tm; 
    
    figure(3);
    n = find(SOF<F,1);
    fisheye = [SOF,N(n-1)+(N(n)-N(n-1))*(SOF-F(n-1))/dF];
    plot(F,N,'b-',F,L,'b:',F,tm_min,'r-',F,Lmin,'r:',F,N1,'k-',fisheye(1),fisheye(2),'ko');
    [val,n] = min(abs(N(1,2:end)-N1(1,2:end)));
%    if (n==1)
        n = length(F);
%    end
    grid on;
    xlim([0,F(n)+2*Fmin]);
    ylim([0,max(max(N),L(n))*1.05]);
    xlabel('F[sccm]');
    ylabel('N/N(EOF), tm/tm(EOF), L[m]');
    h = gca;
    set(h,'xminorgrid','on');
    set(h,'yminorgrid','on');
    
%    figure(4);
%    plot(F,delta.*Y,'b-',F,delta1.*Y1,'r-');
%    xlim([0,F(n)+Fmin]);
%    grid on;

function vis = viscosity(gas,T)
    if (strcmp(gas,'H2'))
        vis = 7.42 * sqrt(T) - 39.5;
    elseif (strcmp(gas,'He'))
        vis = 16.5 * sqrt(T) - 87.8;
    elseif (strcmp(gas,'N2'))
        vis = 15.43 * sqrt(T) - 89.4;
    else
        disp('only H2/He/N2 are supported.');
        return;
    end

function SOF = getSOF(gas,d)
    if (strcmp(gas,'H2'))
        SOF = 1 * d / 0.1;
    elseif (strcmp(gas,'He'))
        SOF = 0.8 * d / 0.1;
    elseif (strcmp(gas,'N2'))
        SOF = 0.25 * d / 0.1;
    else
        disp('only H2/He/N2 are supported.');
        return;
    end
    
function x = f1(v)
    x = 729*v.^2.*(8+9*v)/8./((4+9*v).^(3/2)-8).^2;
    
function z = y(v)
    z = 27*v.^2./((4+9*v).^(3/2)-8);
    