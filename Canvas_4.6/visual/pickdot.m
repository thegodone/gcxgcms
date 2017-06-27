function [i0,Dot] = pickdot(ch,N,L,M,D)

global Period;    
    
figure(2);
h = gca;
x = get(h,'xlim');
y = get(h,'ylim');
xrange = x(2)-x(1);
yrange = y(2)-y(1);
cords = point;

if (isnan(cords(1)) || isnan(cords(2)))
    i0 = -1;
    Dot = [];
    return;
end
[val, i] = min(abs(cords(1)-ch(N(1,:),1)));
t0 = ch(N(1,i),1);
t1 = cords(2);


d1tor = min(2*Period/60,xrange*0.05);
candidate = [];
n = 0;
for i = 1 : size(D)(1),
    if (D(i,1)<t0-d1tor || D(i,1)>t0+d1tor) 
        continue; 
    else
%        d2tor = min(60*(ch(L(D(i,3),3),1)-ch(L(D(i,3),1),1))/4,yrange*0.05);
        d2tor = min(0.05,yrange*0.05);
        if (D(i,2)<t1-d2tor || D(i,2)>t1+d2tor)
            continue;
        else
            n = n + 1;
            candidate(n) = i;
        end
    end
end

if (n==0)
    printf('\nCmpd# n/a, RT1=%8.4fmin, RT2=%6.3fsec\n',t0,t1);
    printf('-----------------------------------------\n');
    i0 = 0;
    Dot = [t0,t1];
else
    i0 = nearest([t0,t1],D,candidate,xrange,yrange);
    Dot = [D(i0,1),D(i0,2)];
    
    col = D(i0,5);
    t0 = ch(N(1,col),1);
    t1 = t0+Period/60;
    printf('\nCmpd# %d (%8.4f min)\n',L(D(i0,3),6),ch(L(D(i0,3),2),1));
    printf('RT1=%8.4f min, RT2=%6.3f sec\n',D(i0,1),D(i0,2)); % modified on 11/12/2016
    printf('-----------------------------------------\n');

    j = D(i0,3);
    while (L(j,7)~=0) j=L(j,7); end
    k = 1;
    printf(['slice   PWHM(ms)    area (sum=',num2str(D(i0,4)),')\n']);
    printf('-----------------------------------------\n');
    while (1) 
        if (j==D(i0,3))
            printf('* ');
        else
            printf('  ');
        end
        if (M(j,3)==0)
            printf('%d         -       %13.4f\n',k,M(j,1));
        else
            printf('%d       %3d       %13.4f\n',k,round(60*(M(j,4)-M(j,3))*1000),M(j,1));
        end
        k = k + 1;
        if (L(j,8)==0) 
            break;
        else
            j = L(j,8);
        end
    end
end
printf('\n');

