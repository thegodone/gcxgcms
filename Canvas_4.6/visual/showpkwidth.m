function [Mseg,kd,base,peak] = showpkwidth(ch,N,Nseg)
    global Period;

    GCGC = (size(N)(1)>0);
    [Mseg,kd,base,peak] = pkwidth(ch,Nseg,GCGC);
    segLen = round(length(ch)/Nseg)-1; % divide chromatogram into Nseg segments for search of major peaks

    if (~GCGC)
        figure(1);
        clf;
        chromz(ch,2,ch(1,1),ch(end,1),0);
        hold on;

        for i = 1 : size(base)(1),
            plot(ch(base(i,1):base(i,2),1),ch(base(i,1):base(i,2),2),'b-','linewidth',2);
        end
        for i = 1 : size(peak)(1),
            plot(ch(peak(i,1):peak(i,2),1),ch(peak(i,1):peak(i,2),2),'r-');
        end
        hold off;

        h=gca; y=get(h,'ylim');ylim([0,y(2)]);
        for i = 2 : Nseg,
            segStart =(i-1)*segLen+1;
            line([ch(segStart,1),ch(segStart,1)],[0,y(2)]);
        end
    else
        show2d(ch,N);
        for i = 2 : Nseg,
            segStart =(i-1)*segLen+1;
            line([ch(segStart,1),ch(segStart,1)],[0,Period]);
        end
        for i = 1 : size(peak)(1),
            n = ceil((ch(peak(i,1),1)-ch(N(1,1),1))*60/Period);
            t0 = (ch(peak(i,1),1)-ch(N(1,n),1))*60;
            t1 = (ch(peak(i,2),1)-ch(N(1,n),1))*60;
            D(i,1) = ch(N(1,n),1);
            D(i,2) = (t0+t1)/2;
            labels{i} = num2str(peak(i,2)-peak(i,1));
        end
        showdot(D,'ro');
        text(D(:,1)+6*Period/60,D(:,2),labels);
    end