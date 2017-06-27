function [L,cs,Mseg,kd] = check(ch,N,Mseg,kd)     % modified on 3/22/2016

    if (isempty(Mseg))
        [Mseg,kd,base,peak] = showpkwidth(ch,N,11);                          % modified on 3/22/2016
        if (max(Mseg)==0) [Mseg,kd,base,peak] = showpkwidth(ch,N,7); end     % .
        if (max(Mseg)==0) [Mseg,kd,base,peak] = showpkwidth(ch,N,3); end     % modified on 3/22/2016
        if (max(Mseg)==0) 
            printf('Well-defined peak NOT found!\n');
            Mseg = kd*3;
        end
    end

    for i = 1 : length(Mseg)-1,
        printf('%3d,',Mseg(i));
    end
    printf('%3d\n',Mseg(end));
    
    k = ceil(min(Mseg)/8);              
    ch = ch(1:k:end,:);          
    M = round(Mseg/k);
    
    cs = dervs(ch,M);
    seed = [1,1+10*M(1)];
    if (size(N)(1)==0)                           
        hop = 0;
    else                               
        hop = round(min(M)/min(kd))-1;  
    end;
    L = pkfind2(ch,cs,M,seed,hop);      
    
    L = (L-1)*k+1;
    
    
  