function setupNIST
    global NISTroot;
    global NISTsecond;  % 2nd locator file specified in autoimp.msd
    
    NISTroot = [];
    NISTsecond = [];
    fp = fopen('C:\Windows\win.ini','r');
    while(~feof(fp))
        s = fgetline(fp);
        if (strstr(s,'[NISTMS]'))
            while (~strstr(s,'Path32='))
                s = fgetline(fp);
            end
            NISTroot = s(strfind(s,'=')+1:strfind(s,filesep)(end));
            firstlocator = [NISTroot,'autoimp.msd'];
            if (exist(firstlocator,'file'))
                fp1 = fopen(firstlocator,'r');
                NISTsecond = deblank(fgetline(fp1));
                fclose(fp1);
            else
                NISTsecond = [NISTroot,'canvas.msd'];
                fp1 = fopen(firstlocator,'w');
                fprintf(fp1,'%s\n',NISTsecond);
                fclose(fp1);
            end
            break;
        end
    end
    fclose(fp);
  