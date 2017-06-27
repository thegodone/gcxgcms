function A=show2d(varargin)

    global Period;
    global Saturation;
    global DotOverlay;
    
    ch = varargin{1};
    N = varargin{2};
    
    nr = size(N,1);
    nc = size(N,2);
    ch2=ch(:,2);

    Ax=ch2(N);
    Ax(Ax==0)=NaN;
    A=inpaint_nans(Ax);
    baseline = ones(nr,1)*min(ch2(N));
    A = ch2(N) - baseline;
    A(A==0)=NaN;
    A=inpaint_nans(A);
    A = log(max(1,A));
    %J = filter2(fspecial('sobel')',A);
    %figure,
    %surf(x,y,J);
    
   % K=ind2rgb(J,jet(256));
   % figure,imshow(K)
    
     dt1 = Period/60;
     dt2 = (ch(2,1)-ch(1,1))*60;
     x0 = ch(N(1,1),1)-dt1/2;
     x1 = ch(N(1,end),1)+dt1/2;
     y0 = -dt2-dt2/2;
     y1 = (nr-1)*dt2+dt2/2;
    
    % cutting the solvant

    Bcut=B(:,1:end);
    Bcut=flipud(Bcut);
    x0=    ch(N(1,1),1)-dt1/2;
    figure,
    p=imagesc([x0 x1],[y0 y1],[Bcut;Bcut(1,:)]);
    % show colum one
    figure
    plot(sum(Bcut,1))
      
        colormap(flame);
         h.max
         h.linecolor = 'r';
         h.textcolor = 'k';
         h.markercolor = 'k';
         h.antimarkercolor = 'w';
         h.cstring = 'rkgmb';
    
        colormap(scent);
        h.linecolor = 'y';
        h.textcolor = 'w';
        h.markercolor = 'w';
        h.antimarkercolor = 'b';
        h.cstring = 'rkymc';
    
        colormap(fluorescence);
        h.linecolor = 'c';
        h.textcolor = 'c';
        h.markercolor = 'y';
        h.antimarkercolor = 'k';
        h.cstring = 'rwmbc';
        
        
% 
%     
%     
%    figure(1);
     if (nargin==2 || varargin{3}==1)   % refresh h.max
         h.max  = max(max(A));
     end
     A_max = h.max;
     A_min = min(min(A));
     
     if (Saturation>=0)
         A_max = (A_max-A_min)*max(0.01,5-Saturation)/5+A_min;
         B = min(A,A_max);
     else
         A_min = A_max - (A_max-A_min)*max(0.01,5+Saturation)/5;
         B = min(A_max,max(A,A_min));
         max(max(B))
%     end
    B(1,1) = A_max;
    
    B_min=min(min(B))
    B_max=max(max(B))
    B(B<0.5*(B_max-B_min))=0;
    
%     
%     figure(2);legend('off');
%     dt1 = Period/60;
%     dt2 = (ch(2,1)-ch(1,1))*60;
%     x0 = ch(N(1,1),1)-dt1/2;
%     x1 = ch(N(1,end),1)+dt1/2;
%     y0 = -dt2-dt2/2;
%     y1 = (nr-1)*dt2+dt2/2;
%     image([x0,x1], [y0,y1], [B;B(1,:)]);   % y0,y1,and B augmentation fixes Freemat bug
%     
%     if (h.colorscheme==1)
%         colormap(flame);
%         h.linecolor = 'r';
%         h.textcolor = 'k';
%         h.markercolor = 'k';
%         h.antimarkercolor = 'w';
%         h.cstring = 'rkgmb';
%     elseif (h.colorscheme==2)
%         colormap(fluorescence);
%         h.linecolor = 'c';
%         h.textcolor = 'c';
%         h.markercolor = 'y';
%         h.antimarkercolor = 'k';
%         h.cstring = 'rwmbc';
%     elseif (h.colorscheme==3)
%         colormap(scent);
%         h.linecolor = 'y';
%         h.textcolor = 'w';
%         h.markercolor = 'w';
%         h.antimarkercolor = 'b';
%         h.cstring = 'rkymc';
%     end 
%     set(2,'userdata',h);
%     
% %    axis tight;
%     xlim([x0,x1]);
%     ylim([-Period/500,Period]);    
% 
%     mycolorbar;
%     
%     DotOverlay = 0;
%     drawnow;
%     