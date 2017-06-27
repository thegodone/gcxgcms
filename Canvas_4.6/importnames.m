function nlist = importnames(ch,L,D,filepath)
    
nlist = {};
if (~isempty(D))
    RT_raw = [];
    name = {};
    i = 0;

    qualfile = [filepath,filesep,'qual.csv'];
    if (exist(qualfile,'file'))
        fp = fopen(qualfile,'r');
        s = fgetline(fp);   % read header
        while (~feof(fp))
            s = fgetline(fp);
            i = i + 1;
            index1 = strfind(s,',');
            RT_raw(i) = str2num(s(1:index1(1)-1));          % get RT-raw
            index2 = strfind(s,'"');
            if (isempty(index2))
                name{i} = deblank(s(index1(1)+1:end));      % get name string generated from GCMSSolution
            else 
                name{i} = s(index2(1)+1:index2(2)-1);       % get name string generated from Canvas
            end
        end
        fclose(fp);
    end

    for i = 1 : size(D)(1),
        j = find(abs(RT_raw-ch(L(D(i,3),2),1))<=0.001);
        if (length(j)==0)
            nlist{L(D(i,3),6)} = '';
        else
            nlist{L(D(i,3),6)} = name{j(1)};
        end
    end
end    
handles = get(2,'userdata');
handles.nlist = nlist;
set(2,'userdata',handles);



    
