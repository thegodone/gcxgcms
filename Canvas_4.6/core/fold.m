function N = fold(ch,period,shift)
    
    acq_rate = 1/(ch(2,1)-ch(1,1))/60;
    nr_float = period * acq_rate;
    nr = ceil(nr_float);                           % modified on 10/15/2016
    nc = floor((ch(end,1)-ch(1,1))*60/period)-1;
    n0 = round(acq_rate * mod(-shift,period))+1;
    
    N = zeros(nr,nc);
    for i = 1 : nc
        a = n0 + round((i-1)*nr_float);
        N(:,i) = linspace(a,a+nr-1,nr)';
    end

