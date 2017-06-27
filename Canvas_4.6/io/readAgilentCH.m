% filetype=181, 6890 file format
% filetype=179, 7890 file format
function ch = readAgilentCH(file)

mn = metadata(file);

fp = fopen([file],'r','b');
fseek(fp,248,'bof');
filetype = fread(fp,1,'int32');

fseek(fp,282,'bof');
t = fread(fp,[2,1],'float'); % in millisec
t = t/1000;                  % in sec

fseek(fp,318,'bof');
fileheader = fread(fp,1,'int32');

fseek(fp,fileheader,'bof');
signalheader = fread(fp,1,'int32');

datazone = fileheader + signalheader;

if (filetype==181)
    fseek(fp,datazone,'bof');
    [raw,Nsig]=fread(fp,Inf,'int16');
    
    signal = zeros(Nsig,1);
    
    xold = 0;
    dxold = 0;
    n = 1;
    i = 1;
    mx = 65536;
    
    while (n<=Nsig)
        if (raw(n)==32767)
            dx = 0;
            if (raw(n+1)<0)
                raw(n+1) = raw(n+1)+mx;
            end
            if (raw(n+2)<0)
                raw(n+2) = raw(n+2)+mx;
            end
            if (raw(n+3)<0)
                raw(n+3) = raw(n+3)+mx;
            end
            x = (raw(n+1)*mx+raw(n+2))*mx+raw(n+3);
            n = n + 4;
        else
            dx = raw(n) + dxold;
            x = dx + xold;
            n = n + 1;
        end
        
        signal(i) = x;
        xold = x;
        dxold = dx;
        i = i + 1;
    end
    Nsig = i - 1;
end
fclose(fp);

fp = fopen([file],'r','l');
fseek(fp,fileheader+26,'bof');
bp = fread(fp,4,'uchar');

acq_rate = (bp(3)*256+bp(4))/(bp(1)*256+bp(2));

if (filetype==179)
    fseek(fp,datazone,'bof');
    [signal,Nsig] = fread(fp,Inf,'double');
end
fclose(fp);

N = round((t(2)-t(1))*acq_rate)+1;
time = linspace(t(1),t(2),N)'/60;
N = min(Nsig,N);
ch = zeros(N,2);
ch(:,1) = time(1:N);
ch(:,2) = signal(1:N)/mn;

run_time = ch(N,1)-ch(1,1);

acq_rate
run_time
