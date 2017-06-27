function [file,ch,spectra] = loadfile()
    
    printf('search D/CH/MS/CSV in present directory...\n');
    
    [csv_files,i] = filechooser('.csv',-1,0);
    n1 = size(csv_files)(2);
    
    [ch_files,i] = filechooser('.ch',-1,n1);
    n2 = size(ch_files)(2);
    
    [ms_files,i] = filechooser('.ms',-1,n1+n2);
    n3 = size(ms_files)(2);

    [D_files,i] = filechooser('.D',-1,n1+n2+n3);
    n4 = size(D_files)(2);

    nfiles = n1 + n2 + n3 + n4;
    
    if (nfiles==0)
        ch = [];
        spectra = [];
        file = []; 
    else
        if (nfiles==1)
            k = 1;
        else
            k = 0;
            while (k<1 || k>nfiles)
                k = input('Your choice: ');
            end
        end
    
        if (size(k)(1)==0)
            ch = [];
            spectra = [];
            file = [];
        elseif (k<=n1)
            file = [pwd,filesep,csv_files(k).name(1:end-length('.csv'))];
            ch = readCleanCSV(file);
            spectra = [];
        elseif (k<=n1+n2)
            file = [pwd,filesep,ch_files(k-n1).name(1:end-length('.ch'))];
            ch = readAgilentCH(file);
            spectra = [];
        elseif (k<=n1+n2+n3)
            file = [pwd,filesep,ms_files(k-n1-n2).name(1:end-length('.ms'))];
            [ch,spectra] = readAgilentMS(file);
        else
            cd([pwd,filesep,D_files(k-n1-n2-n3).name]);
            [file,ch,spectra] = loadfile;
            cd('..');
        end
    end 
    


