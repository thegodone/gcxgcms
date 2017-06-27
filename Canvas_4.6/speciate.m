function [L,M,D] = speciate(ch,N,L,M,sk)

global File; 
global Period;
global DotOverlay;

GCGC = (size(N)(1)~=0);
if (GCGC && DotOverlay)
    show2d(ch,N);
end

if (size(ch)(2)>2 && ~issame(ch(:,2),ch(:,3)))  % in ion speciation
    MasterFile = File(1:strfind(File,filesep)(end)-1);
else                                            % in TIC speciation
    MasterFile = File;
end

if (sk==1)                                      % pre-processing parameters changed
    mkdir(File);
    file = [File,filesep,'Mseg.txt'];
    if (exist(file,'file'))
        widths = getcfg(file);
        Mseg = widths(1,:);
        kd = widths(2,:);
    else
        Mseg = [];
        kd = [];
    end

    [L1,cs,Mseg,kd] = check(ch,N,Mseg',kd');
    save([File,filesep,'pks.dat'],'L1');
    
    fp = fopen(file,'w');
    fprintf(fp,'%s\n','% estimated peak widths in data points. must increase from first to last segment'); 
    fprintf(fp,'%d',Mseg(1));
    for i = 2 : length(Mseg),
        fprintf(fp,',%d',Mseg(i));
    end
    fprintf(fp,'\n\n');
    fprintf(fp,'%s\n','% leave following noise widths unchanged');
    fprintf(fp,'%d', kd(1));
    for i = 2 : length(kd),
        fprintf(fp,',%d', kd(i));
    end
    fprintf(fp,'\n');
    fclose(fp);
    
    sk = 2;
elseif (sk==2)
    load([File,filesep,'pks.dat']);
end

file = [File,filesep,'exception.txt'];
exception = [];
joindots = [];
if (exist(file,'file'))
    a = getcfg(file);
    Hrej = a(1,1);
    COARSE = a(1,2);
    if (size(a)(1)>1)
        for i = 2 : size(a)(1),
            if (GCGC && a(i,2)-a(i,1)>Period/60)
                joindots = [joindots;a(i,:)];
            else
                exception = [exception;a(i,:)];
            end
        end
    end
else
    Hrej = 0;
    COARSE = 1;

    fp = fopen(file,'w');
    fprintf(fp,'%s\n','% peak height threshold for reporting and coarse(1)/fine(0) switch for 2D peak merging'); 
    fprintf(fp,'%d,%d\n\n',Hrej,COARSE);
    fprintf(fp,'%s\n','% following lines define exception time windows for baseline correction');
    fprintf(fp,'%s\n','% example: to define a window from 1.05 to 1.12 min, write as follows w/o preceding percentile sign');
    fprintf(fp,'%s\n\n','% 1.05, 1.12'); 
    fprintf(fp,'%s\n','% following lines define pairs of dots to be joined in 2D');
    fprintf(fp,'%s\n','% example: to join a pair of dots, write their raw RTs as follows w/o preceding percentile sign');
    fprintf(fp,'%s\n','% 35.6035, 38.5785'); 
    fclose(fp);
end

if (sk==2)                                    % post-processing parameters changed
    L = postproc(ch,L1,Hrej,exception);
    M = integrate(ch,L);
    sk = 3;
else                                          % D2-shift/cluster changed (sk=3) or recall (sk=4)
    load([File,filesep,'lmd.dat']);
end

if (sk==3 && GCGC)
    [L,D] = merge(ch,N,L,M,COARSE);
    [L,D] = merge2(joindots,ch,L,D);
    printf('%d species merged\n',size(D)(1));

    [R,exclude] = getclustercfg(MasterFile,'retrieve',0);

    num = size(R)(2);
    Cluster = {};
    if (num>0)
        if (GCGC)
            for i = 1 : num,
                if (exclude(i))
                    Cluster{i} = interior(R{i},D,1*Period/60,0.05);  % avoid excluding nearby species
                    D = exterior(Cluster{i},D);
                end
            end
            for i = 1 : num,
                if (~exclude(i))
                    Cluster{i} = interior(R{i},D,2*Period/60,0.1);    % allow RT drifts
                end
            end
        else
            for i = 1 : num,
                L(:,6) = linspace(1,size(L)(1),size(L)(1))'; 
                D = [ch(L(:,2),1),zeros(size(L)(1),1),L(:,6),M(:,1)];
                R{i} = [R{i}(:,1),zeros(size(R{i})(1),1),R{i}(:,2:end)];
                Cluster{i} = interior(R{i},D,0.1,1);                  % larger RT drift for 1D data
            end
        end
    end

    save([File,filesep,'lmd.dat'],'L','M','D');
end
   
nlist = importnames(ch,L,D,MasterFile);

if (sk==3)
    quantify(ch,L,R,exclude,Cluster,nlist,[File,filesep,'target.csv']);
    report(ch,N,L,M,D,nlist);
end

if (GCGC)
    DotOverlay = showdot(D,'r.');
    printf('%d species reported\n',size(D)(1));
else
    colorgram(ch,N,L,M,ch(1,1),ch(end,1));
end
