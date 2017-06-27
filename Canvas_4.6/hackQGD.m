% QGD must have an original spectrum process table size (N0):
% N0 = 217~909 for later adding 57~909 entries;
% N0 = 49~56 for later adding 1~56 entries. 
function hackQGD(ch,L,D)

global File;

nD = size(D)(1);    
if (nD>0)
    printf('\nchoose max 909 species for QGD hack...\n');
    n1 = 0;
    while (n1<1 || n1>nD)
        n1 = input(['  from species #(1~',num2str(nD),'): ']);
    end
    if (size(n1)==0)
        printf('cancelled.\n');
        return;
    end
    n1 = round(n1);
    n2 = 0;
    nmax = min(n1+908,nD);
    while (n2<n1 || n2>nmax)
        n2 = input(['  to species #(',num2str(n1),'~',num2str(nmax),'): ']);
    end
    if (size(n2)(1)==0)
        printf('cancelled.\n');
        return;
    end
    n2 = round(n2);
else
    return;
end

N = n2-n1+1;
if (N>56)
    printf('\nchoose a QGD with a table size >56 ...\n');
else
    printf('\nchoose a QGD with a table size <57 ...\n');
end
    
file = filechooser('.qgd',0,0);
if (size(file)(1) == 0)
    printf('cancelled: QGD file not loaded.\n');
    return;
end

fp = fopen(file.name,'r+','little-endian');
    table_size_addr = 65656;

    fseek(fp,table_size_addr,'bof');
    old_table_size = fread(fp,1,'uint16');
    N0 = (old_table_size-16)/72;
    
    if (N<57 && N0>56)
        printf('cancelled: wrong QGD table size (%d).\n', N0);
        fclose(fp);
        return;
    elseif (N>56 && N0<57)
        printf('cancelled: wrong QGD table size (%d).\n', N0);
        fclose(fp);
        return;
    else
        printf('\nhacking started...\n');
    end

    start_addr = file.bytes - 16;
    while (start_addr > 0)
        fseek(fp,start_addr,'bof');
        a = fread(fp,4,'int32');
        if ((a(1)==N0 ||(N0==1 && a(1)==0)) && a(2)==65536 && a(3)==1 && a(4)==0)
            break;
        else
            start_addr = start_addr - 4;
            if (file.bytes-start_addr > 131072)    % 131072=128k bytes search depth
                printf('cancelled: wrong QGD file format.\n');
                fclose(fp);
                return;
            end
        end
    end    
    fseek(fp,start_addr,'bof');
    fwrite(fp,N,'int32');
    
    new_table_size = 72*N+16;
    fseek(fp,table_size_addr,'bof');
    fwrite(fp, new_table_size, 'uint16');

    species = zeros(N,2);     % scan# in column 1, RT in column 2
    background = zeros(N,2);  % scan# in column 1, RT in column 2                            
    nL = size(L)(1);
    for i = n1 : n2,                                 
        species(i-n1+1,1) = L(D(i,3),2);

        m = D(i,3);                                  
        while (m>1 && L(m,1)==L(m-1,3))            
            m = m - 1;                               
        end                                          
        n = D(i,3);                                    
        while (n<nL && L(n,3)==L(n+1,1))           
            n = n + 1;                                
        end                                          
        if (D(i,3)-m <= n-D(i,3))                    
            background(i-n1+1,1) = L(m,1);
        else                                         
            background(i-n1+1,1) = L(n,3);
        end                                          
    end
    species(:,2) = ch(species(:,1),1)*60000;         % convert to milliseconds
    background(:,2) = ch(background(:,1),1)*60000;   % convert to milliseconds
    
    start_addr = start_addr + 16;
    for n = 1 : N,
        species_addr = start_addr + (n-1) * 72; 
        
        fseek(fp,species_addr,'bof');
        fwrite(fp, species(n,1), 'int32');
        fseek(fp, species_addr + 12, 'bof');
        fwrite(fp, species(n,2), 'int32');

        fseek(fp, species_addr + 24, 'bof');
        fwrite(fp, background(n,1), 'int32');
        fseek(fp, species_addr + 36, 'bof');
        fwrite(fp, background(n,2), 'int32');

        fseek(fp, species_addr + 48, 'bof');
        fwrite(fp, 65536, 'int32');
        fseek(fp, species_addr + 60, 'bof');
        fwrite(fp, 1, 'int32');
        fseek(fp, species_addr + 68, 'bof');
        fwrite(fp, 1, 'int32');
    end
fclose(fp);
printf('QGD hack succeeded.\n');