function qual = getnist

global File;    
global NISTroot;
global NISTsecond;

if (isempty(NISTroot))
    qual = [];
    return;
end

system(['del ',NISTroot,'SRCREADY.TXT']);

fp = fopen(NISTsecond,'w');   % 2nd locator file specified in autoimp.msd
    fprintf(fp,'%s\n',[File,filesep,'spectrum.msp OVERWRITE']);
fclose(fp);

system([NISTroot,'nistms$.exe /instrument /par=2']);
num_hit = 2;   % this number must be set the same as in nistms$.exe

while (~exist([NISTroot,'SRCREADY.TXT'],'file'))
    pause(0.1);
end

fp = fopen([NISTroot,'SRCRESLT.TXT'],'r');
y = struct('scan',0,'name',[],'formula',[],'MF',0,'RMF',0,'Prob',0,'CAS',[],'Mw',0,'Lib',[],'Id',0);
k = 0;
while (~feof(fp))
    s = fgetline(fp);
    y.scan = str2num(s(strfind(s,' scan ')+6:strfind(s,'Compound in Library Factor')-2));
    k = k + 1;
    for i = 1 : num_hit,
        s = fgetline(fp);
        y.name = s(strfind(s,'<<')(1)+2:strfind(s,'>>')(1)-1);
        y.formula = s(strfind(s,'<<')(2)+2:strfind(s,'>>')(2)-1);
        y.MF = str2num(s(strfind(s,' MF:')+4:strfind(s,' RMF:')-2));
        y.RMF = str2num(s(strfind(s,' RMF:')+5:strfind(s,' Prob:')-2));
        y.Prob = str2num(s(strfind(s,' Prob:')+6:strfind(s,' CAS:')-2));
        y.CAS = s(strfind(s,' CAS:')+5:strfind(s,' Mw:')-2);
        y.Mw = str2num(s(strfind(s,' Mw:')+4:strfind(s,' Lib:')-2));
        y.Lib = s(strfind(s,'<<')(3)+2:strfind(s,'>>')(3)-1);
        y.Id = str2num(s(strfind(s,' Id:')+4:end-1));
        qual(k,i) = y;
    end
end
fclose(fp);

