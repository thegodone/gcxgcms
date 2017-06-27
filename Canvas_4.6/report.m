function report(ch,N,L,M,D,nlist)

global File;
    
printf('species list saved to report.csv\n');
fp = fopen([File,filesep,'report.csv'],'w');
if (size(N)(1)==0) % 1DGC
    % RT, Area, PWHM, Height, Start, End 
    R = [ch(L(:,2),1),M(:,1),60*(M(:,4)-M(:,3)),M(:,2),ch(L(:,1),1),ch(L(:,3),1)];

    fprintf(fp,'%s,%s,%s,%s,%s,%s,%s\n','Cmpd#','RT','Area','PWHM','Height','Start','End'); 
    for i = 1 : size(R)(1),
        fprintf(fp,'%d,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f\n',i,R(i,:));
    end
else               % GCxGC
    % ID#, RT1, RT2, RT-raw, Area, Name
    R = [L(D(:,3),6),D(:,1),D(:,2),ch(L(D(:,3),2),1),D(:,4)];
    fprintf(fp,'%s,%s,%s,%s,%s,%s\n','Cmpd#','RT1','RT2','RT_raw','Area','Name');
    for i = 1 : size(R)(1),
        fprintf(fp,'%d,%8.4f,%8.4f,%8.4f,%8.4f,"%s"\n',R(i,:),nlist{L(D(i,3),6)});
    end
end
fclose(fp);
