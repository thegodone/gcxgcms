function clustermenu(ch,N,L,M,D,k,params)

    global File;
    global DotOverlay;
    global Period;
    
    handles = get(3,'userdata');

    R = handles.R;
    exclude = handles.exclude;
    Cluster = handles.Cluster;
    cnum = handles.cnum;        
    hide = handles.hide;
    cstring = handles.cstring;

    h = get(2,'userdata');
    marker = [h.markercolor,'o'];
    antimarker = [h.antimarkercolor,'o'];
    textcolor = h.textcolor;

    num = size(R)(2);
    
    if (k==1)
        if (~DotOverlay)
            DotOverlay = showdot(D,'r.');
        end

        figure(2);
        h = gca;
        x = get(h,'xlim');
        y = get(h,'ylim');
            
        [i0,Dot] = pickdot(ch,N,L,M,D);         % this is first point user clicked
        if (i0<0)                               % not a point inside field, so cancel
            return;
        end
        num = num + 1;
        exclude(num) = params;
        hide(num) = 0;
        if (i0==0)                              % first point not on a red dot, so it is a polygon
            showdot(Dot,marker);                % show the first point as a circle for easy closing
            xlim([x(1),x(2)]);
            ylim([y(1),y(2)]);

            R{num} = polygon(Dot);              % create a polygon
            if (isempty(R{num}))                % polygon was not built 
                showdot(Dot,antimarker);        % clear the first point
                return;
            else
                Cluster{num} = interior(R{num},D,2*Period/60,0.1);   % get all compounds inside polygon
            end
        elseif (i0>0)                           % first point is on a red dot, so it is a point-cluster
            R{num} = [];
            Cluster{num} = [];
            while (i0>0)                        % keep adding new dots until clicked off-field
                printf('click target again to UNDO selection.\n');
                printf('click off-field to END creation.\n'); 

                NEWPOINT = 1;                   % check if the dot was already selected  
                for i = 1 : size(R{num})(1),
                    if (max(abs(Dot-R{num}(i,:)))<1e-5)
                        NEWPOINT = 0;
                        break;
                    end
                end

                if (NEWPOINT)                   % if not already selected, it is a new dot
                    showdot(Dot,[cstring(cnum),'o']);
                    R{num} = [R{num};Dot];
                    Cluster{num} = [Cluster{num};D(i0,:)];
                else                            % if already selected, it is deleted
                    showdot(Dot,antimarker);
                    R{num} = exterior(Dot,R{num});
                    Cluster{num} = exterior(D(i0,:),Cluster{num});
                end
                xlim([x(1),x(2)]);
                ylim([y(1),y(2)]);
            
                i0 = 0;
                while (i0==0)                   % keep clicking if not on target
                    [i0,Dot] = pickdot(ch,N,L,M,D);
                end
                if (i0<0 && isempty(R{num}))    % if clicked off-field and all points were deleted, abort.
                    return;
                end
            end
            cnum = mod(cnum,length(cstring)) + 1;
        end

        text(R{num}(1,1),R{num}(1,2),['C',num2str(num)],'fontweight','bold','fontsize',16,'color',textcolor);
        printf('new cluster C%d is created.\n',num);
        xlim([x(1),x(2)]);
        ylim([y(1),y(2)]);
    elseif (k==2)
        if (num==0 || size(params)(1)==0) return; end
        j = sort(params,2,'descend');
        for kk = 1 : length(j),
            jj = j(kk);
            if (jj>=1 && jj<=num)
                for i = jj : num-1,
                    exclude(i) = exclude(i+1);    % added on 12/1/2015
                    hide(i) = hide(i+1);          % added on 3/24/2016
                    R{i} = R{i+1};
                    Cluster{i} = Cluster{i+1};
                end
                num = num - 1;
                exclude = exclude(1:num);        % added on 12/1/2015
                hide = hide(1:num);              % added on 3/24/2016
            
                R = R(1:num);                    % .
                Cluster = Cluster(1:num);        % added on 12/1/2015
            end
        end
               
        show2d(ch,N);
                
        cnum = 1;
        for i = 1 : num,
            if (~hide(i))
                cnum = drawcluster(i,R{i},Cluster{i},cstring,cnum);
            end
        end
    elseif (k==3)
        CurrentDataPath = pwd;
        cd(File);
        system('del *.ply');
        for i = 1 : num,
            if (exclude(i))                                % added on 12/1/2015
                csvwrite([num2str(i),'x.ply'],R{i});       % .
            else                                           % .
                csvwrite([num2str(i),'.ply'],R{i});        % . 
            end                                            % added on 12/1/2015
        end
        cd(CurrentDataPath);
        disp('clusters saved');
    elseif (k==4)
        j = params;
        hide = ones(num,1);
        if (j>=1 && j<=num)
            hide(j) = 0;
        end    
        show2d(ch,N);
 
        cnum = 1;
        for i = 1 : num,
            if (~hide(i))
                cnum = drawcluster(i,R{i},Cluster{i},cstring,cnum);
            end
        end
    elseif (k==5)
        A = [];
        for i = 1 : num,
            if (~exclude(i) && size(Cluster{i})(2)>0) 
                A(i) = sum(Cluster{i}(:,4));
            else
                A(i) = 0;
            end
        end
        Atot = sum(A);
        if (Atot==0)
            Atot = 1;
        end
        printf('\nclusters components area-percentage\n');
        for i = 1 : num,
            if (~exclude(i) && size(Cluster{i})(2)>0)       
                printf(' #%2d:        %4d        %6.4f\n',i,size(Cluster{i})(1),A(i)/Atot);
            end
        end
    elseif (k==6)
        if (size(params)(1)==0) return; end
        time = params; 
        printf('\nclusters lower-bp upper-bp\n');
        for i = 1 : num,
            if (~exclude(i) && size(Cluster{i})(2)>0)    
                lo = divide(Cluster{i},time);
                printf(' #%2d:      %6.4f   %6.4f\n',i,lo,1-lo);
            end       
        end
        if (size(D)(1)>0)
            lo = divide(D,time);                                 
            printf(' all:      %6.4f   %6.4f\n',lo,1-lo);
        end       
    end

    handles.R = R;
    handles.exclude = exclude;
    handles.Cluster = Cluster;
    handles.cnum = cnum;
    handles.hide = hide;
    handles.cstring = cstring;
    
    set(3,'userdata',handles);


            
            