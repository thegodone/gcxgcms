% Augmented peak list L: 
% column 6 stores index of species. 
% column 7 stores index of last peak of the same species (0 means starting 1D peak).
% column 8 stores index of next peak of the same species (0 means finishing 1D peak).
%
% 2D species list D:
% column 1 stores dim-1 RT (in minute)
% column 2 stores dim-2 RT (in second)
% column 3 stores index of major peak (with largest peak area)
% column 4 stores total area of all associated peaks
% column 5 stores modulation number in dim-1
% column 6 stores pixel number in dim-2
function [L,D] = merge(ch,N,L,M,COARSE)   % modified on 8/12/2015

    nr = size(N)(1);
    nc = size(N)(2);
    period = round((ch(2,1)-ch(1,1))*nr*600)/600;   % in unit of minute
    dt = ch(2,1)-ch(1,1);
    if (COARSE)
        dt = dt*2;
    else
        dt = dt/4;
    end

    n = size(L)(1);
    pknum = 0;
    for i = 1 : n,
        % locate first potentially overlapped peak in last period
        j = i - 1;
        while (j>0 && ch(L(j,1),1)>ch(L(i,2),1)-period-dt)
            j = j - 1;                     
        end
        
        % the peak must not have a smaller RT in D2 for positively ramped oven programs
        OVERLAP = 0;
        while (j>0 && ch(L(j,2),1)>ch(L(i,2),1)-period-dt)
            if (~COARSE && M(i,2)>0)                     
                t = ch(L(j,2),1) + period; 
                OVERLAP = (M(i,3)<t && t<M(i,4));
            end
            if (~COARSE && ~OVERLAP && M(j,2)>0)             
                t = ch(L(i,2),1) - period; 
                OVERLAP = (M(j,3)<t && t<M(j,4));
            end
            if (COARSE || (M(i,2)==0 && M(j,2)==0))
                t = ch(L(j,2),1) + period;
                OVERLAP = (ch(L(i,1),1)<t && t<ch(L(i,3),1)); 
            end
            
            if (OVERLAP)
                break;
            else
                j = j - 1;
            end
        end
        
        if (OVERLAP==0)
            pknum = pknum + 1;
            L(i,6) = pknum;
            L(i,7) = 0;
            L(i,8) = 0;
        elseif (ch(L(i,2),2)<ch(L(j,2),2) || L(j,7)==0 || ch(L(L(j,7),2),2)<ch(L(j,2),2))
            L(i,6) = L(j,6);
            L(i,7) = j;
            L(i,8) = 0;
            L(j,8) = i;
        else
            pknum = pknum + 1;
            L(i,6) = pknum;
            L(i,7) = 0;
            L(i,8) = 0;
            if (L(L(j,7),7)>0 && abs(L(L(j,7),2)-L(j,2)-L(L(L(j,7),7),2)+L(L(j,7),2))>...
                                 abs(L(j,2)-L(i,2)-L(L(L(j,7),7),2)+L(L(j,7),2)))
                L(j,6) = pknum;
                L(L(j,7),8) = 0;
                L(j,7) = 0;
                L(j,8) = i;
                L(i,7) = j;
            end
        end
    end
    
    D = zeros(pknum,6);
    pknum = 0;
    for i = 1 : n,
        if (L(i,7)==0)
            j = i;
            jmax = j;
            hmax = ch(L(j,2),2);
            S = M(j,1);
            while (L(j,8)~=0)
                j = L(j,8);
                if (ch(L(j,2),2)>hmax)
                    hmax = ch(L(j,2),2);
                    jmax = j;
                end
                S = S + M(j,1);
            end

            col = find(L(jmax,2)<N(1,:),1,'first') - 1;
            if (L(jmax,2)<N(nr,nc) && L(jmax,2)>=N(1,nc))
                col = nc;
            end
            if (col>=1 && col<=nc)
                row = L(jmax,2)-N(1,col)+1;
            
                pknum = pknum + 1;
                D(pknum,1) = ch(N(1,col),1);
                D(pknum,2) = (ch(N(row,col),1)-ch(N(1,col),1))*60;
                D(pknum,3) = jmax;
                D(pknum,4) = S;
                D(pknum,5) = col;
                D(pknum,6) = row;
            end
        end
    end

    D = D(1:pknum,:);
    

         
