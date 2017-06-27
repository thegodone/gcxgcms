function pklist = pkfind2(ch,cs,Mseg,seed,hop)

Nseg = length(Mseg);
N = length(ch);
Nb = [1,round([1:Nseg-1]*(N-1)/Nseg+1),N];  % divide chromatogram into Nseg segments 

mw = 10*Mseg(1)/2;
w1 = weight(-mw,mw,1,0);
w2 = weight(mw,mw,1,0);

[RISE,LEVEL,RISE2,LEVEL2,NOISE] = baseline(cs,seed,w1,w2); 
TRSD1 = RISE+LEVEL;
TRSD2 = RISE/2+LEVEL;

cur_seg = 1;
pknum = 0;
FOUND = 0;
pklist = zeros(10000,3);
p = hop+1;
i = p;
while (i<=N)
    if (FOUND == 1)
        r = p;
        m = n;
    elseif (cs(i,2)>TRSD1)
%        printf('Rise at %f min\n',cs(i,1));
        [k,j,FOUND] = csmax(cs,i-hop,NOISE,RISE,LEVEL,RISE2,LEVEL2); 
        if (FOUND == 1)
            r = k;
            while (cs(r,2)>TRSD2 && cs(r,3)>0) r = r - 1; end    % modified on 7/14
            p_new = r - 10*Mseg(cur_seg); 
            if (p<=p_new)
                p = p_new;
                [RISE,LEVEL,RISE2,LEVEL2,NOISE] = baseline(cs,[p,r],w1,w2); % update baseline statistics
                TRSD1 = RISE+LEVEL;
                TRSD2 = RISE/2+LEVEL;
                FOUND = 0;
                j = i;
                p = r;
            else
                [m,j,FOUND] = csmin(cs,j-1,NOISE,RISE,LEVEL,RISE2,LEVEL2);
            end
        end
    elseif (i+hop>Nb(cur_seg+1) && cur_seg<Nseg)
        cur_seg = cur_seg + 1;
        if (Mseg(cur_seg)~=Mseg(cur_seg-1))
            k = Mseg(cur_seg-1)/Mseg(cur_seg);
            RISE = RISE*k;
            RISE2 = RISE2*k*k;
            NOISE = NOISE*k*k;
            TRSD1 = RISE+LEVEL;
            TRSD2 = RISE/2+LEVEL;
            mw = 10*Mseg(cur_seg)/2;
            w1 = weight(-mw,mw,1,0);
            w2 = weight(mw,mw,1,0);
        end
    end
      
    SEEK_NEXT_MIN = 1;
    while (FOUND == 1)
        if (SEEK_NEXT_MIN)
            [k,j,FOUND] = csmax(cs,j-1,NOISE,RISE,LEVEL,RISE2,LEVEL2);
            if (FOUND == 1)
                [n,j,FOUND] = csmin(cs,j-1,NOISE,RISE,LEVEL,RISE2,LEVEL2);
            else % baseline or end-of-chromatogram
                [val,p] = min(ch(m:k,2)); p = p + m - 1;
                SEEK_NEXT_MIN = 0;
                break;
            end
            [val,p] = max(cs(k:n,2)); p = p + k - 1; 
            [val,s] = min(cs(m:k,2)); s = s + m - 1;
            [val,q] = min(ch(s:p,2)); q = q + s - 1; % tentative peak end
%            printf('m=%d s=%d k=%d q=%d p=%d n=%d\n',m,s,k,q,p,n);
            if (q==s)
                p = m;
            elseif (p-q<2)
                p = q;                       % modification is made here
                q = 0;
            else
                p = q;
            end

            if (p==m) % front shoulder
                [val,k] = max(cs(r:m,3)); k = k + r - 1; 
                p = p - k + p;
                [val,k] = max(cs(m:n,3)); k = k + m - 1;
                p = min(p,k);

                SEEK_NEXT_MIN = 0;
                break;
            elseif (FOUND && (n-p<2 || cs(p,3)-cs(n,3)<NOISE)) % tentative rear shoulder
                SEEK_NEXT_MIN = (cs(n,3)>-NOISE && cs(j-1,2)>cs(n,2));
                if (SEEK_NEXT_MIN) 
                    curve = abs(cs(n,4))/max(NOISE,cs(n,3));
%                    printf('curve=%f @%f min\n',curve,cs(n,1));
                    SEEK_NEXT_MIN = (curve<3.5 || ch(n+1,2)>ch(n,2)); % a magic optimized number    % modification is made here
                end
            else % normal peak or baseline 
                SEEK_NEXT_MIN = 0;
                if (FOUND==0 || q>0) break; end      % modification is made here
            end
        else % rear shoulder peak end
            k = round((p+k)/2);
            if (k<=p)
                [val,s] = min(cs(k:p,4)); s = s + k - 1;
                if (p-s<2) s = k; end
                [val,p] = min(ch(k:s,2)); p = p + k - 1;
            end
            break;
        end
    end
            
    if (~SEEK_NEXT_MIN)
        pknum = pknum + 1;
        pklist(pknum,1) = r;
        if (m<p && ch(m+1,2)>ch(m,2))         % added on 10/15/2016
            m = m + 1;                        % .
        elseif (m>r && ch(m-1,2)>ch(m,2))     % .
            m = m - 1;                        % .
        end                                   % added on 10/15/2016
        pklist(pknum,2) = m;
        pklist(pknum,3) = p;
%        printf('Found peak #%d by %d\n\n',pknum,FOUND);
    end
    if (j>i) i = j; else i = i + 1 + hop; end
end

pklist = pklist(1:pknum,:);
printf('%d peaks found\n',pknum);

