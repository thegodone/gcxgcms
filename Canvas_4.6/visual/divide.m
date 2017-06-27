function lo = divide(cluster,time)
    n = size(cluster)(1);
    left = 0;
    for i = 1 : n,
        if (cluster(i,1)<=time)
            left = left + cluster(i,4);
        end
    end
    total = sum(cluster(:,4));
    lo = left/total;
   