% pklist is augmented by B which are re-calculated starting and ending baseline points for each peak 
function pklist = beneath(ch,pklist)
    
N = length(ch);
pknum = size(pklist)(1);
B = zeros(pknum,2);
START = 1;
for i = 1 : pknum,
    if (START)
        j = i; 
        B(j,1) = ch(pklist(j,1),2);
        START = 0;
    end

    if (i==pknum || pklist(i,3)~=pklist(i+1,1)) 
        k = i;
        B(k,2) = ch(pklist(k,3),2);
        if (pklist(i,3)==N) B(k,2) = min(B(k,2),B(j,1)); end
        
        while (k>=j)
            p = k;

            while (p>=j)
                intra = ch(pklist(p,1),2);
                r = p;
                while (intra>=ch(pklist(p,1),2) && r>j)
                    r = r - 1;
                    intra = (ch(pklist(r,1),2)*(pklist(k,3)-pklist(p,1))+B(k,2)*(pklist(p,1)-pklist(r,1)))/(pklist(k,3)-pklist(r,1));
                end
                if (intra>=ch(pklist(p,1),2))
                    break;
                else
                    p = r; 
                end
            end
                  
%            while (p>=j)
%                extra = ch(pklist(p,1),2);
%                r = p;
%                item1 = (ch(pklist(p,1),2)*pklist(k,3)-B(k,2)*pklist(p,1))/(pklist(k,3)-pklist(p,1));
%                item2 = (B(k,2)-ch(pklist(p,1),2))/(pklist(k,3)-pklist(p,1));
%                while (extra<=ch(pklist(r,1),2) && r>j)
%                    r = r - 1;
%                    extra = item1 + item2*pklist(r,1);
%                end
%                if (extra<=ch(pklist(r,1),2))
%                    break;
%                else
%                    p = r; 
%                end
%            end

            B(p,1) = ch(pklist(p,1),2);
            if (p>j) B(p-1,2) = B(p,1); end
            
            p0 = pklist(p,1); 
            p1 = pklist(k,3);
            while (1)
%                [val,s] = min(ch(p0:p1,2)-[0:1:p1-p0]'/(p1-p0)*(ch(p1,2)-ch(p0,2))-ch(p0,2));
                [val,s] = min(ch(p0:p1,2)-linspace(0,p1-p0,p1-p0+1)'/(p1-p0)*(ch(p1,2)-ch(p0,2))-ch(p0,2));
                s = s + p0 - 1;
                if (s>pklist(k,2) && s<p1)
                    p1 = s;
                elseif (s<pklist(p,2) && s>p0)
                    p0 = s;
                else
                    break;
                end
            end
            pklist(k,3) = p1;
            B(k,2) = ch(p1,2);
            pklist(p,1) = p0;
            B(p,1) = ch(p0,2);
            
%            item1 = (B(p,1)*pklist(k,3)-B(k,2)*pklist(p,1))/(pklist(k,3)-pklist(p,1));
%            item2 = (B(k,2)-B(p,1))/(pklist(k,3)-pklist(p,1));
            for r = p : k-1,
                B(r,2) = (B(p,1)*(pklist(k,3)-pklist(r,3))+B(k,2)*(pklist(r,3)-pklist(p,1)))/(pklist(k,3)-pklist(p,1));
%                B(r,2) = item1+item2*pklist(r,3);
                B(r+1,1) = B(r,2);
            end
            k = p - 1;
        end

        START = 1;
    end
end

pklist = [pklist,B];