function cluster = interior(R,D,w,h)
    ndot = size(D)(1);
    nR = size(R)(1);

    if (abs(R(1,1)-R(nR,1))<1e-5 && abs(R(1,2)-R(nR,2))<1e-5)
        cluster = zeros(ndot,size(D)(2));
        num = 0;
        t1_min = min(R(:,1));
        t1_max = max(R(:,1));
        t2_min = min(R(:,2));
        t2_max = max(R(:,2));
        for i = 1 : ndot,
            if (D(i,1)<t1_min || D(i,1)>t1_max || D(i,2)<t2_min || D(i,2)>t2_max)
                continue;
            end
            cn = 0;
            for j = 1 : nR-1,
                if ((R(j,2)<=D(i,2) && D(i,2)<R(j+1,2)) || (R(j,2)>D(i,2) && D(i,2)>=R(j+1,2)))
                    vt = (D(i,2)-R(j,2))/(R(j+1,2)-R(j,2));
                    if (D(i,1)<R(j,1)+vt*(R(j+1,1)-R(j,1)))
                        cn = cn + 1;
                    end
                end
            end
            if (mod(cn,2)==1)
                num = num + 1;
                cluster(num,:) = D(i,:);
            end
        end
        cluster = cluster(1:num,:);
    else
        cluster = zeros(nR,size(D)(2));
        for k = 1 : nR,
            candidate = [];
            j = 0;
            for i = 1 : ndot,
                if (R(k,1)-w<=D(i,1) && D(i,1)<=R(k,1)+w && R(k,2)-h<=D(i,2) && D(i,2)<=R(k,2)+h)
                    j = j + 1;
                    candidate(j) = i;
                end
            end
            if (j==0) 
                continue; 
            end
            if (j==1)
                i0 = candidate(1);
            elseif (j>1)
                i0 = nearest([R(k,1),R(k,2)],D,candidate,w,h);
            end
            cluster(k,:) = D(i0,:);
        end
    end
    