function cnum = drawcluster(i,R,cluster,cstring,cnum)
    
    h = get(2,'userdata');
    textcolor = h.textcolor;
    
    nR = size(R)(1);
    if (abs(R(1,1)-R(nR,1))<1e-5 && abs(R(1,2)-R(nR,2))<1e-5)
        drawpolygon(R);
    else
        marker = 'oxs+d<';
        showdot(R,[cstring(cnum),marker(cnum)]);
        showdot(cluster,[cstring(cnum),'+']);       % modified on 2/14/2016
        cnum = mod(cnum,length(cstring)) + 1;
    end
    text(R(1,1),R(1,2),['C',num2str(i)],'fontweight','bold','fontsize',16,'color',textcolor);
    drawnow;
