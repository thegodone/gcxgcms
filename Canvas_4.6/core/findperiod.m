% ch, chromatogram whose modulation period is to be found
% freq, minimum sampling rate for narrowest peak [hz]
% dt, minimum increment in modulation period [sec]
% pmax, upper limit of modulation period [sec]

function period = findperiod(ch,freq,dt,pmax)    

threshold = 0.2;     % modified on 7/22/2015
    
% reduce data size by a factor of m
m = round(1/(ch(2,1)-ch(1,1))/60/freq);
m = max(m,1);
ch = ch(1:m:length(ch),:); 

n = length(ch);
dn = round(dt/2/(ch(2,1)-ch(1,1))/60); 
dn = max(dn,1);
dt0 = dn*(ch(2,1)-ch(1,1))*60;

% correct baseline drift
k = [0,round([1:11]/11*n)];
for i = 1 : length(k)-1,
    b(i) = min(ch(k(i)+1:k(i+1),2));
end    
b = [b,b(length(b))];
for i = 1 : length(k)-1,
    base = b(i) + (b(i+1)-b(i))/(k(i+1)-k(i)-1)*[0:(k(i+1)-k(i)-1)]'; 
    ch(k(i)+1:k(i+1),2) = ch(k(i)+1:k(i+1),2) - base; 
end

% binning the data
N = floor(n/dn)-1 ;
c = zeros(N,1);
for i = 1 : N,
    c(i) = sum(ch((i-1)*dn+(1:dn),2)); 
end
%c = c - mean(c);     % modified on 7/22/2015

% calculate auto-correlation
period = 0;
Lag = min(N-1,round(pmax/dt0));
a = zeros(Lag+1,2);
a0 = dot(c,c)/N;      % modified on 7/22/2015
a(1,2) = 1;           % modified on 7/22/2015
BLANK = 1;
for i = 1 : Lag,
    a(i+1,1) = i*dt0;
    a(i+1,2) = dot(c(1:end-i),c(i+1:end))/(N-i)/a0; % modified on 7/22/2015
    
    if (a(i+1,2)<threshold) BLANK = 0; end          % modified on 7/22/2015 
    if (i>2 && ~BLANK && a(i,2)<a(i-1,2) && a(i-2,2)<a(i-1,2) && a(i-1,2)>threshold) % modified on 7/22/2015 
        period = a(i-1,1);
        break;
    end
end

%plot(a(1:i+1,1),a(1:i+1,2));ylim([-0.2,1]);grid on;
