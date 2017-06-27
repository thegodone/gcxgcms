function N = resetfigure(ch,L,M,shift)
    global File;
    global Period;
    global Saturation;
    global slideEnable;
    global labelEnable;
    
    if (Period>0)
        N = fold(ch,Period,shift);
        show2d(ch,N);
        proj(ch,N,0,Period);
        slideEnable = 0;                        % added on 11/30/2015
        labelEnable = 0;                        % added on 1/21/2015
    else
        N = [];
        figure(1);
        colorgram(ch,N,L,M,ch(1,1),ch(end,1));
    end

    if (exist(File,'dir')==0)
        mkdir(File);
    end
    
    h = get(2,'userdata');
    csvwrite([File,filesep,'visual_setting.dat'],[shift,Saturation,Period,h.colorscheme]);
