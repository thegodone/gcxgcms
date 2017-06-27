function dotshown = showdot(D,mark_string)

dotshown = 0;
figure(2);
if (size(D)(2)>1)
    hold on; 
    N = size(D)(1);
    Nseg = ceil(N/50);
    k = [1,round([1:Nseg-1]*(N-1)/Nseg+1),N];
    for i = 1 : Nseg,
        plot(D(k(i):k(i+1),1),D(k(i):k(i+1),2),mark_string); 
    end
    hold off;
    dotshown = 1;
end
