function drawpolygon(R)
    
    h = get(2,'userdata');
    linecolor = h.linecolor;
    
    n = size(R)(1);
    figure(2);
    for i = 1 : n-1,
        hline = line([R(i,1),R(i+1,1)],[R(i,2),R(i+1,2)]);
        set(hline,'color',linecolor);
    end