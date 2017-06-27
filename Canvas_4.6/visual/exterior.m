function D1 = exterior(cluster,D)
    ndot = size(D)(1);
    n = size(cluster)(1);
    
    if (n>0)
        D1 = zeros(ndot,size(D)(2));
        num = 0;
        for i = 1 : ndot,
            FOUND = 0;
            for j = 1 : n,
                if (abs(D(i,1)-cluster(j,1))<1e-5 && abs(D(i,2)-cluster(j,2))<1e-5)
                    FOUND = 1;
                    break;
                end
            end
            if (~FOUND)
                num = num + 1;
                D1(num,:) = D(i,:);
            end
        end
        D1 = D1(1:num,:);
    else
        D1 = D;
    end

    
        
    