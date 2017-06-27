function baselines = asysm(signals, lambda, p, d)
% asysm: Baseline estimation with asymmetric least squares using weighted
% smoothing with a finite difference penalty. 
%
% Input:
%   signals: signal, each column represents one signal
%   lambda: smoothing parameter (generally 1e5 to 1e8)
%   p: asymmetry parameter (generally 0.001)
%   d: order of differences in penalty (generally 2)
%
% Output:
%   baselines: estimated baselines for each corresponding signal in signals
%
% Paul Eilers, 2002. 
% Edited by Christina de Bruyn Kops (2015) for use on multiple signals and
% to include epsilon from the ptw package in R by Jan Gerretzen, Paul
% Eilers, Hans Wouters, Tom Bloemberg, Ron Wehrens and The R Development
% Core Team, 2014.


eps = 1e-8; % epsilon from ptw package in R

m = size(signals,1);      
w = ones(m, 1);   
baselines = zeros(size(signals));

% for each signal:
for i = 1:size(signals,2)
    
    y = signals(:,i);
    repeat = 1;
    while repeat 
       z = difsmw(y, lambda, w, d); 
       w0 = w;
       w = p * (y - z > eps) + (1 - p) * (y - z <= eps);
       repeat = sum(abs(w - w0)) > 0;
    end
    baselines(:,i) = z;
end

end