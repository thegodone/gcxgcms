% A heuristic approach to estimate the range of peak-width-at-half-height in a chromatogram.
% It is used later as the range of window size for Savitsky-Golay filtering.
function [m,kd,base,peak] = pkwidth(ch,Nseg,GCGC)

segLen = round(length(ch)/Nseg)-1; % divide chromatogram into Nseg segments for search of major peaks
m = zeros(Nseg,1);
kd = zeros(Nseg,1);
fall = zeros(Nseg,1);
noise = zeros(Nseg,1);
Cycle = 3; % number of baseline period (a full up-and-down) to be collected in each direction  

base = [];
peak = [];
pknum = 0;
for i = 2 : Nseg-1, % disregard first and last segments 
    segStart =(i-1)*segLen+1;
    segEnd = segStart + segLen;
    
    [lo,k] = min(ch(segStart:segEnd,2)); k = k + segStart - 1;

    j = 0; k0 = k;
    while (j<Cycle) % collect baseline from lowest point to the right
         while (ch(k0+1,2)>=ch(k0,2)) k0 = k0 + 1; end
         while (ch(k0+1,2)<=ch(k0,2)) k0 = k0 + 1; end
         j = j + 1;
    end
    kp = k0 - k + 1;
    noise_p = max(ch(k:k0,2))-min(ch(k:k0,2));
        
    j = 0; k0 = k;
    while (j<Cycle) % collect baseline from lowest point to the left
         while (ch(k0-1,2)>=ch(k0,2)) k0 = k0 - 1; end
         while (ch(k0-1,2)<=ch(k0,2)) k0 = k0 - 1; end
         j = j + 1;
    end
    km = k - k0 + 1;
    noise_m = max(ch(k0:k,2))-min(ch(k0:k,2));
    
    if (km > 1.5*kp) kc = round(kp/Cycle/2); noise(i) = noise_p; base = [base;[k,k+kp-1]];
    elseif (kp > 1.5*km) kc = round(km/Cycle/2); noise(i) = noise_m; base = [base;[k-km+1,k]];
    else kc = round(0.5*(km+kp)/Cycle/2); noise(i) = 0.5*(noise_p+noise_m); base = [base;[k-km+1,k+kp-1]];
    end 
    kd(i) = max(kc,2);
    
    [hi,n] = max(ch(segStart:segEnd,2)); n = n + segStart - 1;
    if (n>segStart && n<segEnd)
        half = (hi+lo)/2; % estimate of major peak half height in individual segment
        
        tolerance = 0;                         
        if (hi-lo>10*noise(i) && kd(i)<4)  % modified on 3/28/2016    
            tolerance = noise(i);
        end                                    

        hi1 = hi; n1 = n-1; while (ch(n1,2)>half && ch(n1,2)<hi1+tolerance) hi1 = min(hi1,ch(n1,2)); n1 = n1 - 1; end  % modified on 7/26/2015
        hi2 = hi; n2 = n+1; while (ch(n2,2)>half && ch(n2,2)<hi2+tolerance) hi2 = min(hi2,ch(n2,2)); n2 = n2 + 1; end  % modified on 7/26/2015
    
        if (ch(n1,2)<=half && ch(n2,2)<=half) nm = min(n-n1,n2-n); pw = 2*nm; peak = [peak;[n-nm,n+nm]]; 
        elseif (ch(n1,2)<=half && ch(n2,2)>half) pw = (n-n1)*2; peak = [peak;[n1,n1+pw]];                
        elseif (ch(n1,2)>half && ch(n2,2)<=half) pw = (n2-n)*2; peak = [peak;[n2-pw,n2]];                
        else pw = 0;
        end
        
        fall(i) = max(ch(n,2)-ch(n-pw,2),ch(n,2)-ch(n+pw,2));
        m(i) = pw;

        if (pw>0) pknum = pknum + 1; end
    end
end

%for i = 2 : Nseg-1,
%    printf('kc=%d pw=%d fall=%f noise=%f\n',kd(i),m(i),fall(i),noise(i));
%end
printf('  0,');
for i = 2 : Nseg-1,
    printf('%3d,',m(i));
end
printf('  0\n');

if (pknum<2)
    m = ones(Nseg,1)*max(m); % no peaks found
    kd = ones(Nseg,1)*max(kd); % single peak found
else
    kdmin = max(kd);
    for i = 1 : Nseg,
        if (kd(i)>0) kdmin = min(kd(i),kdmin); end  % get minimum non-zero baseline period
    end
    for i = 1 : Nseg;
        if (kd(i)==0 || kd(i)>2*kdmin) kd(i) = kdmin; end % remove excessive wandering in baseline
    end    
    
    for i = 1: Nseg,
        if (m(i)<kd(i)*2 || fall(i)<3*noise(i)) m(i) = 0; end % remove spike/baseline taken as peak   % modified on 8/13/2015
    end
    
    if (~GCGC)  % used for 1D data
        for i = 1 : Nseg - 1,
            if (m(i)>0)
                for j = i+1 : Nseg,
                    if (m(j)>0 && m(i)>1.1*m(j)) % assume increasing peak width with time and so 
                        m(i) = 0;                % remove wider peaks preceeding narrower ones  
                        break;
                    end
                end
            end
        end
    else            % used for 2D data, added on 3/22/2016
        for i = 1 : Nseg - 1,
            if (m(i)>0)
                for j = i+1 : Nseg-1,
                    if (m(j)>0 && m(i)>1.1*m(j)) % assume increasing peak width with time and so 
                        m(j) = 0;                % remove narrower peaks following wider ones  
                    end
                end
            end
        end
    end

    if (max(m)>0)
        for i = 1: Nseg,
           offset = 1;
           while (m(i)==0)
              if (i-offset>0) m(i) = m(i-offset); end % assign proper peak widths to empty segments
              if (i+offset<=Nseg && m(i+offset)>0) m(i) = m(i+offset); end
              offset = offset + 1;
           end
       end
    end
end 

%printf('%d~%d points/peak in chromatogram.\n',min(m),max(m));



