% re-implemented on 8/03/2016
function compare2D(ch0,ch1,N,L,D,k,params)
    
global File;    
global Period;  
global slideEnable;

handles = get(1,'userdata');

if (k==1)
    show2d(ch0,handles.N0);
    proj(ch0,handles.N0,0,Period);
elseif (k==2)
    show2d(ch1,handles.N1,0);
    proj(ch1,handles.N1,0,Period);
elseif (k==3)
    offset = params(1);
    sensitivity = params(2);

    nr = size(N)(1);
    nc = size(N)(2);
        
    dn = round(-offset/(ch0(2,1)-ch0(1,1))/60);                    
    if (dn+N(1,1)<1 && N(nr,nc)+nr<=size(ch0)(1))
        N0 = N + nr;
    elseif (dn+N(nr,nc)>size(ch1)(1) && N(1,1)-nr>=1)
        N0 = N - nr;
    else
        N0 = N;
    end
    A0 = ch0(:,2)(N0) - ones(nr,1)*min(ch0(:,2)(N0));
            
    dn_limit = min(size(ch1)(1)-N0(nr,nc),max(dn,1-N0(1,1))); 
    if (dn_limit>dn)
        disp('offset limited: try smaller one!');
    elseif (dn_limit<dn)
        disp('offset limited: try larger one!');
    end
            
    dn = dn_limit;
    N1 = N0 + dn;
    A1 = ch1(:,2)(N1) - ones(nr,1)*min(ch1(:,2)(N1));
            
    A_diff = A1 - A0;
    A = show2dd(A_diff,ch0(N0(1,1),1),ch0(N0(1,nc),1),sensitivity);
        
    figure(1);
    t = ch0(:,1)(N0(1,:));
    plot(t,sum(A_diff,1));
    grid on;
    xlim([t(1),t(end)]);
    drawnow;
            
    nD = size(D)(1);
    D1 = zeros(nD,size(D)(2));
    D2 = zeros(nD,size(D)(2));
    n_up = 0;
    n_dn = 0;
    for i = 1 : nD,
        if (A(D(i,6),D(i,5))>1e-10)
            n_up = n_up + 1;
            D1(n_up,:) = D(i,:);
        elseif (A(D(i,6),D(i,5))<-1e-10)
            n_dn = n_dn + 1;
            D2(n_dn,:) = D(i,:);
        end
    end
    D1 = D1(1:n_up,:);        
    D2 = D2(1:n_dn,:);        

    handles.N0 = N0;
    handles.N1 = N1;
    handles.A0 = A0;
    handles.A1 = A1;
    handles.D1 = D1;
    handles.D2 = D2;
    set(1,'userdata',handles);
elseif (k==4)
    file = params;
    file = file(strfind(file,filesep)(end)+1:end);
    diff_folder = [File,filesep,'diff_to_',file];
    mkdir(diff_folder);
            
    D1 = handles.D1;
    D2 = handles.D2;
    nlist = get(2,'userdata').nlist;
            
    printf('\n');
    if (size(D1)(1)>0)
        quantify(ch0,L,{D1(:,1:2)},[0],{D1},nlist,[diff_folder,filesep,'up_regulated.csv']);
    end
    if (size(D2)(1)>0)
        quantify(ch0,L,{D2(:,1:2)},[0],{D2},nlist,[diff_folder,filesep,'down_regulated.csv']);
    end

    return;
elseif (k==5)
    [R, exclude] = getclustercfg(File,'',1);
            
    if (size(R)(1)>0)
        cstring = 'rgbk';
        cnum = 1;
        num = size(R)(2);
        for i = 1 : num,
            if (~exclude(i))
                cnum = drawcluster(i,R{i},{},cstring,cnum);
            end
        end
    else
        printf('private clusters not found!\n');
    end
end
        
cluster_size = size(handles.D1)(1)+size(handles.D2)(1);
if (cluster_size<1000)
    showdot(handles.D1,'r+');
    showdot(handles.D2,'y+');
end
