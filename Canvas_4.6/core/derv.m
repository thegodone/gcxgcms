function cs = derv(c,m,p,s)
    N = length(c);
    cs = zeros(N,1);
    Nseg = length(m);

    n = [1,round([1:Nseg-1]*(N-1)/Nseg+1),N];  % divide chromatogram into Nseg segments 

    for k = 1 : Nseg,
        w = weight(0,m(k),p,s); % filter 
    
        Lgap = 0;
        Rgap = 0;
        if (k==1) 
            Lgap = m(k); 
            for i = 1 : m(k),
                cs(n(k)+i-1) = dot(weight(i-m(k)-1,m(k),p,s),c(n(k):n(k)+2*m(k)));
            end
        end
        if (k==Nseg) 
            Rgap = m(k); 
            for i = 1 : m(k),
                cs(n(k+1)-i+1) = dot(weight(m(k)-i+1,m(k),p,s),c(n(k+1)-2*m(k):n(k+1)));
            end
        end
        
        if (k>1) 
            ngap = m(k)-m(k-1);
            j = 1;
            if (ngap>1)
                while (j<ngap)
                    cs(n(k)+Lgap+j) = dot(weight(0,m(k-1)+j,p,s),c(n(k)-m(k-1):n(k)+j+m(k-1)+j));
                    j = j + 1;
                end
            elseif (ngap<-1)
                while (j<-ngap)
                    cs(n(k)+Lgap+j) = dot(weight(0,m(k-1)-j,p,s),c(n(k)+j-m(k-1)+j:n(k)+m(k-1)));
                    j = j + 1;
                end
            end
        else
            j = 0;
        end
        
        L_bound = n(k)+Lgap+j;
        R_bound = n(k+1)-Rgap;

% Following dot product codes are replaced by calling 'conv' to speed up
%     
%        for i = L_bound : R_bound,
%            cs(i) = dot(w,c(i-m(k):i+m(k)));
%        end
            
        if (s==1)  % negative sign to address a likely bug in Freemat 'conv' function
            cs(L_bound:R_bound) = -conv(c(L_bound-m(k):R_bound+m(k)),w)(2*m(k)+1:2*m(k)+1+R_bound-L_bound);
        else
            cs(L_bound:R_bound) = conv(c(L_bound-m(k):R_bound+m(k)),w)(2*m(k)+1:2*m(k)+1+R_bound-L_bound);
        end
    end
    
