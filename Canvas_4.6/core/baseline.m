function [RISE,LEVEL,RISE2,LEVEL2,NOISE] = baseline(c,interval,w1,w2)

    n1 = interval(1); % starting index of baseline
    n2 = interval(2); % ending index of baseline
    m = (n2-n1)/2;    % even number of spacing is assumed

    c1 = dot(w1,c(n1:n2,2));          % mean of starting point for 1st derivative
    c2 = dot(w2,c(n1:n2,2));          % mean of ending point for 1st derivative
%    line = c1+[0:2*m]'*(c2-c1)/2/m;   % linear trendline for 1st derivative
    line = c1+linspace(0,2*m,2*m+1)'*(c2-c1)/2/m;   % linear trendline for 1st derivative
    delta = c(n1:n2,2)-line;          % difference between trendline and actual baseline
    RMS = sqrt(mean(delta.^2));       % root-mean-square of baseline
    LEVEL = c2;                       

    c1 = dot(w1,c(n1:n2,3));          % mean of starting point for 2nd derivative
    c2 = dot(w2,c(n1:n2,3));          % mean of ending point for 2nd derivative
%    line = c1+[0:2*m]'*(c2-c1)/2/m;   % linear trendline for 2nd derivative
    line = c1+linspace(0,2*m,2*m+1)'*(c2-c1)/2/m;   % linear trendline for 2nd derivative
    delta = c(n1:n2,3)-line;          % difference between trendline and actual baseline
    RMS2 = sqrt(mean(delta.^2));      % root-mean-square of baseline
    LEVEL2 = c2;

    RISE = 4*RMS;
    RISE2 = 2*RMS2;
    NOISE = 6*RMS2;
    
%    printf('baseline checked at %8.4f ~ %8.4f min\n',c(interval(1),1),c(interval(2),1));

