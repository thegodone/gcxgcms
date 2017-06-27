function spotview(ch,spectra,N,L,M,D,pk)
    
global DotOverlay; 
global Period;
global slideEnable;
global labelEnable;

Compare = 0;            % spotview has different behaviors between normal and compare modes
nlist = [];

h1 = get(1,'userdata'); % check if it is in compare mode
if (isfield(h1,'A1'))
    Compare = 1;
    N = h1.N0;
    D = [h1.D1; h1.D2];
    A0 = h1.A0;
    A1 = h1.A1;
end

handles = get(2,'userdata');
if (~isfield(handles,'text_handle') || ~ishandle(handles.text_handle,'text'))
    handles.text_handle = [];
end
if (isfield(handles,'line_handle') && ishandle(handles.line_handle,'line'))
    set(handles.line_handle,'visible','off');
end
if (isfield(handles,'nlist'))
    nlist = handles.nlist;
end
linecolor = handles.linecolor;        % vertical line on fig.2 for specific modulation period
textcolor = handles.textcolor;

figure(2);               % get window scale for restoration when fig.2 is in zoom mode 
h = gca;
x = get(h,'xlim');
y = get(h,'ylim');

if (pk==1 || pk==5)      
    if (pk==1)                                % pinpoint a spot
        if (DotOverlay==0 && Compare==0) 
            DotOverlay = showdot(D,'r.');     % show dots for user picking
        end
        [i0,Dot] = pickdot(ch,N,L,M,D);
        if (i0<0)                             % user clicking outside of 2D window
            return;
        elseif (i0>0)                         % user picked a species
            j = D(i0,3);
            compound_num = L(j,6);
        end
    else                                      % look for a spot
        if (isempty(D))
            return;
        else
            printf('\n');
            compound_num = str2num(input('Compund number: ','s'));
            if (compound_num>0 && compound_num<=L(D(end,3),6))
                i0 = find(L(D(:,3),6)==compound_num);
                if (isempty(i0))
                    printf('this compound is excluded.\n');
                    return;
                end
                j = D(i0,3);
                Dot = D(i0,1:2);
            else
                printf('invalid input or out-of-range.\n');
                return;
            end
        end
    end
        
    t0 = Dot(1); 
    t1 = t0 + Period/60;
    
    if (size(ch)(2)>2)
        tloc = Dot(1)+Dot(2)/60;
        scan = round((tloc-ch(1,1))/(ch(2,1)-ch(1,1)))+1;
        
        if (i0>0)
            m = j;                                  
            while (m>1 && L(m,1)==L(m-1,3))            
                m = m - 1;                               
            end                                          
            n = j;                                    
            while (n<size(L)(1) && L(n,3)==L(n+1,1))           
                n = n + 1;                                
            end                                          
            if (j-m <= n-j)                    
                scan_bgrd = L(m,1);
            else                                         
                scan_bgrd = L(n,3);
            end 
        else
            scan_bgrd = 0;
        end            
        
        disp(['spectrum at ',num2str(tloc),'min (#1 hit)']);
        spectrum = getspectrum(scan,scan_bgrd,tloc,spectra);
        if (~isempty(spectrum))
            qual = getnist;
            if (~isempty(qual))
                disp(qual(1,1));         % show only first hit from NIST search
                printf('\n');
            end
        end 
    end
    
    if (i0>0)                            % a species was picked
        if (Compare)
            offset = 0;                  % right on the most significant slice
        else
            showdot(Dot,'ro');           
        end
        
        if (isempty(nlist))
            compound_name = [];
        else
            compound_name = nlist{compound_num};    % compound might not have a name even in nlist
        end
        
        if (isempty(compound_name))
            text_handle = text(t0+Period/60,Dot(2),num2str(compound_num),'color',textcolor);
        else
            text_handle = text(t0+Period/60,Dot(2),compound_name,'color',textcolor);
        end

        handles.text_handle = [handles.text_handle, text_handle];    % collective text lables
    elseif (Compare)                      % a spot was picked not on a species
        offset = 1;                       
        j = 0;
        compound_num = 0;
    end
    slideEnable = 1;
elseif (pk==2)                            % disabled by canvas_gui.m
    labelEnable = ~labelEnable;         
    if (~labelEnable)
        tn = size(handles.text_handle)(2);
        for i = 1 : tn,
            set(handles.text_handle(i),'visible','off');
        end
        handles.text_handle = [];
    else
        labels = {};
        cords = [];
        num = 0;
        for i = 1 : size(D)(1),                                 
            if (D(i,1)>x(1) && D(i,1)<x(2) && D(i,2)>y(1) && D(i,2)<y(2)) 
               num = num + 1;
               cords(num,1) = D(i,1);
               cords(num,2) = D(i,2);
               labels{num,1} = num2str(L(D(i,3),6));        
            end                                                   
        end
        if (~Compare)
            DotOverlay = showdot(D,'ro');
        end
        if (num>0 && num<100)
            text_handle = text(cords(:,1)+Period/60,cords(:,2),labels);          
            handles.text_handle = [handles.text_handle, text_handle];
        end
    end
    set(2,'userdata',handles);       
    return;
else
    t0 = h1.t0;                      
    if (Compare)
        offset = h1.offset;
        compound_num = h1.compound_num;
        j = h1.j;
    end
    
    if (pk==3)             
        t1 = t0;
        t0 = t0 - Period/60;
        if (Compare && compound_num>0)
            if (offset==0 && L(j,7)~=0)
                j = L(j,7);
            else 
                offset = offset - 1;
            end
        end
    elseif (pk==4)
        t0 = t0 + Period/60;
        t1 = t0 + Period/60;
        if (Compare && compound_num>0)
            if (offset==0 && L(j,8)~=0)
                j = L(j,8);
            else 
                offset = offset + 1;
            end
        end
    end
end

if (Compare)               % fig.1 behavior in compare mode
    figure(1);
    nc = round((t0-ch(N(1,1),1))*60/Period)+1;
    plot(ch(N(:,nc),1),A0(:,nc),'k:',ch(N(:,nc),1),A1(:,nc),'b-');
    if (compound_num>0 && offset==0)
        text(ch(L(j,2),1),ch(L(j,2),2),['#',num2str(compound_num),' ',nlist{compound_num}]);
    end    
    legend('current','target');
    legend('boxoff');
    grid on;
    xlim([t0,t1]);
else                       % fig.1 behavior in normal mode
    colorgram(ch,N,L,M,t0,t1);
end

h1.t0 = t0;                  
if (Compare)
    h1.offset = offset;
    h1.compound_num = compound_num;
    h1.j = j;
end
set(1,'userdata',h1);
    
figure(2);                 % restore original window scale 
xlim([x(1),x(2)]);
ylim([y(1),y(2)]);

line_handle = line([t0,t0],[0,Period]);
set(line_handle,'color',linecolor,'visible','on');
handles.line_handle = line_handle;
set(2,'userdata',handles);
