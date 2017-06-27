function chromz(ch,col,t0,t1,ncolor)
    
    global Saturation;

    [val, n0] = min(abs(ch(:,1)-t0));    
    [val, n1] = min(abs(ch(:,1)-t1));    
    cstring = 'rgbcmyk';
    
    if ncolor == 0
        plot(ch(n0:n1,1),ch(n0:n1,col),'color',[.4 .4 .4]);
    else
        plot(ch(n0:n1,1),ch(n0:n1,col),cstring(ncolor));
    end

    ch_max = max(ch(n0:n1,col));
    ch_min = min(ch(n0:n1,col));
    ymax = (ch_max-ch_min)/(2^Saturation)+ch_min;
    ymin = ch_min - (ymax-ch_min)/10;

    xlim([t0,t1]);
    ylim([ymin,ymax]);


