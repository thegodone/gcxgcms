function colorgram(ch,N,L,M,t0,t1)

n = size(L,1);
if (n==0) 
    figure(1);
    chromz(ch,2,t0,t1,3);
    return; 
end

figure(1);
cla;    
%printf('plotting...\n');
if (size(N,1)==0)
    GCGC = 0;
else
    GCGC = 1;
    nr = size(N,1);
    nc = size(N,2);
end

if (GCGC)
    hold on;
    [val, i] = min(abs(t0-ch(N(1,:),1)));
    if (i>1)
        plot(ch(N(1,i):N(1,i)+nr,1),ch(N(1,i-1):N(1,i-1)+nr,2),'k:');
    end
    if (i<nc)
        plot(ch(N(1,i):N(1,i)+nr,1),ch(N(1,i+1):N(1,i+1)+nr,2),'color',[.8 .8 .8]);
    end
    plot(ch(N(1,i):N(1,i)+nr,1),ch(N(1,i):N(1,i)+nr,2),'color',[.4 .4 .4]);
elseif (n<400)
    chromz(ch,2,t0,t1,0);
else
    chromz(ch,2,t0,t1,3);
    return;
end
if (size(ch,2)>3)
    h = get(1,'userdata');
    if (length(h.ions)==0)
        legend('TIC');
    else
        legend(num2str(h.ions(end)));
    end
    legend('boxoff');
end

cstring = 'gbcmyk';

for i0 = 1 : n,
    if (ch(L(i0,3),1)>t0)
        break;
    end
end
for i1 = i0 : n,
    if (ch(L(i1,1),1)>t1)
        i1 = i1-1;
        break;
    end
end

n = i1-i0+1;
if (n>0)
    hold on; 
    Lmax = L(i0,3); 
    plot(ch(L(i0,1):L(i0,3),1),ch(L(i0,1):L(i0,3),2),cstring(mod(i0-1,length(cstring))+1),'linewidth',1.25);
%    if (M(i0,2)>0) plot([M(i0,3),M(i0,4)],[M(i0,2),M(i0,2)],'k-','linewidth',1.5); end
else
    xlim([t0,t1]);     % added on 1/21/2016
    return;
end

for i = i0+1 : i1,
    if (L(i,3)<=Lmax && L(i,3)<=L(i-1,3))  % first shoulder peak in an exception window
        mcolor = mod(i-1,length(cstring))+1;
        color = cstring(mcolor);
        ncolor = mod(i-2,length(cstring))+1;
        cstring0 = cstring;
        cstring = [cstring(1:ncolor-1),cstring(ncolor+1:end)];
        while (cstring(mod(i-1,length(cstring))+1)~=color)
            cstring = [cstring(end),cstring(1:end-1)];
        end
    elseif (L(i,3)>Lmax && L(i-1,3)<Lmax) % first peak out of an exception window
        mcolor = mod(i-1,length(cstring))+1;
        color = cstring(mcolor);
        cstring = cstring0;
        while (cstring(mod(i-1,length(cstring))+1)~=color)
            cstring = [cstring(end),cstring(1:end-1)];
        end
    end
    Lmax = max(Lmax,L(i,3));
    plot(ch(L(i,1):L(i,3),1),ch(L(i,1):L(i,3),2),cstring(mod(i-1,length(cstring))+1),'linewidth',1.25);
%    if (M(i,2)>0) plot([M(i,3),M(i,4)],[M(i,2),M(i,2)],'k-','linewidth',1.5); end
end

labels = {};
for i = i0 : i1,
    plot([ch(L(i,1),1),ch(L(i,3),1)],[L(i,4),L(i,5)],'r-');
    if (~GCGC) 
        labels{i-i0+1,1} = num2str(i);
    else
        labels{i-i0+1,1} = num2str(L(i,6));
    end
end
text(ch(L(i0:i1,2),1),ch(L(i0:i1,2),2),labels);

hold off; grid on; 
xlim([t0,t1]); 
figure(1);
h = gca;
y = get(h,'ylim');
dy = (y(2)-y(1))/20;
ylim([y(1)-dy,y(2)+dy]);


    