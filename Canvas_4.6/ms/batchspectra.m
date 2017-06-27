function batchspectra(ch,L,spectra,D)
    global File;
    
    threshold = [];
    while (isempty(threshold) || threshold<600 || threshold>999)
        threshold = str2num(deblank(input('minimum match factor (600-999): ','s')));
    end  
    
    QUIET = [];
    while (isempty(QUIET)) 
        QUIET = deblank(input('display progress? (y/n): ','s'));
        if (strcmpi(QUIET,'y') || strcmpi(QUIET,'y'))
            break;
        end
    end
    
    printf('Search NIST...\n');

    nD = size(D)(1);
    nS = size(spectra)(1);
    nL = size(L)(1);
    if (nD>0 && nS>0)
        time = D(:,1)+D(:,2)/60;
        dlt = ch(2,1)-ch(1,1);
        scan = round((time-ch(1,1))/dlt)+1;
        scan_bgrd = zeros(nD,1);
        
        for i = 1 : nD,
            m = D(i,3);                                  
            while (m>1 && L(m,1)==L(m-1,3))            
                m = m - 1;                               
            end                                          
            n = D(i,3);                                    
            while (n<nL && L(n,3)==L(n+1,1))           
                n = n + 1;                                
            end                                          
            if (D(i,3)-m <= n-D(i,3))                    
                scan_bgrd(i) = L(m,1);
            else                                         
                scan_bgrd(i) = L(n,3);
            end
        end 

        if (strcmpi(QUIET,'n'))
            getspectrum(scan,scan_bgrd,time,spectra);
            qual = getnist;
            for i = 1 : nD,
                if (qual(i,1).MF<threshold)
                    qual(i,1).name = '';
                end
            end
        else
            for i = 1 : nD,
                getspectrum(scan(i),scan_bgrd(i),time(i),spectra);
                qual(i,:) = getnist;
                if (qual(i,1).MF<threshold)
                    qual(i,1).name = '';
                end
                printf('%d/%d: %s\n',i,nD,qual(i,1).name);
            end
        end
       
        printf('search results saved to qual.csv\n'); 
        fp = fopen([File,filesep,'qual.csv'],'w');
        fprintf(fp,'%s,%s\n','Ret.Time','Name');
        for i = 1 : nD,
            fprintf(fp,'%8.4f,"%s"\n',time(i),qual(i,1).name);
        end
        fclose(fp);
    end
        
