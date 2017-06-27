function a = getcfg(file)
    
a = [];
fp = fopen(file,'r');
i = 0;
while (~feof(fp))
    s = deblank(fgetline(fp));
    if (isempty(s) || s(1)=='%')
        continue;
    else
        i = i + 1;
        a(i,:) = str2num(s);
    end
end
fclose(fp);
