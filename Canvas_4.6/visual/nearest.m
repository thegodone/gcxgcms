function i0 = nearest(Dot,D,candidate,xrange,yrange)
    
    dist_min = 1000;
    t0 = Dot(1);
    t1 = Dot(2);
    n = length(candidate);
    for i = 1 : n,
        dist = sqrt(((D(candidate(i),1)-t0)/xrange)^2+((D(candidate(i),2)-t1)/yrange)^2);
        if (dist<dist_min)
            dist_min = dist;
            i0 = candidate(i);
        end
    end
