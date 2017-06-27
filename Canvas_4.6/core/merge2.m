function [L,D] = merge2(joindots,ch,L,D)
    
    n = size(joindots)(1);
    if (n==0)
        return;
    end
    
    for i = 1 : n,                                  % loop through all merging-dots entries
        j1 = find(abs(ch(L(D(:,3),2),1)-joindots(i,1))<0.001);
        j2 = find(abs(ch(L(D(:,3),2),1)-joindots(i,2))<0.001);
        if (isempty(j1) || isempty(j2))
            continue;
        end

        a1 = L(D(j1,3),6);
        a2 = L(D(j2,3),6);
        
        k1 = find(L(:,6)==a1);
        k2 = find(L(:,6)==a2);

        L(k1(end),8) = k2(1);
        L(k2(1),7) = k1(end);
        
        if (ch(L(D(j2,3),2),2)>=ch(L(D(j1,3),2),2))
            L(k1,6) = a2;
            D(j2,4) = D(j2,4) + D(j1,4);
            j = j1;
        else
            L(k2,6) = a1;
            D(j1,4) = D(j1,4) + D(j2,4);
            j = j2;
        end
                
        nD = size(D)(1);
        D = [D(1:j-1,:);D(j+1:nD,:)];
    end
