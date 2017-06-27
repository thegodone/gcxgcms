function [ch,spectra] = readAgilentMS(file)

% Variables
file = fopen(file,'r','b');

% Read directory offset
fseek(file, 260, 'bof');
offset_tic = fread(file, 1, 'int32') .* 2 - 2;

% Read number of scans
fseek(file, 278, 'bof');
scans = fread(file, 1, 'uint32');

% Read data offset, time values and TIC intensities
offset_xic = zeros(scans,1);
ch = zeros(scans,3);                  % modified on 6/20/2016
triplets = zeros(3*scans,1);

fseek(file, offset_tic, 'bof');
triplets = fread(file,3*scans,'int32');

offset_xic = triplets(1:3:end);
ch(:,1) = triplets(2:3:end);
ch(:,2) = triplets(3:3:end);

offset_xic = (offset_xic .* 2) - 2;
ch(:,1) = ch(:,1)/60000;

N = size(ch,1);
run_time = ch(end,1)-ch(1,1);
acq_rate = (N-1)/run_time/60;
n = floor(ch(1,1)*60*acq_rate);
t0 = ch(1,1) - n/acq_rate/60;
run_time = ch(end,1)-t0;

ch(:,1) = linspace(ch(1,1),ch(end,1),N);

acq_rate
run_time

    
% Variables
mz = [];
xic = [];
sindex = [];
doublets = [];
len = 0;
progress = 0;
for i = 1:scans
    % Read scan size
    fseek(file, offset_xic(i), 'bof');
    n = fread(file, 1, 'int16') - 18;
    n = (n/2) + 2;
    
    m = len + 1;
    len = len + n;
    
    % Read mass values & intensities
    fseek(file, offset_xic(i)+18, 'bof');
    doublets(2*len-2*n+1:2*len) = fread(file,n*2,'uint16');
    sindex(m:len) = i;
    
    if (i>(progress+1)/10*scans)
        progress = progress + 1;
        %cprintf('%d%s\r',progress*10,'%');
    end
end
%cprintf('%s\r','100%');

fclose(file);

sindex = sindex(1:len);
doublets = doublets(1:2*len);

mz = doublets(1:2:end);
xic = doublets(2:2:end);

% Convert intensity values to abundance
%xic = bitand(xic, 16383, 'int16') .* (8 .^ bitshift(xic, -14, 'int16'));
xic = double(bitand(uint16(xic), uint16(16383))) .* double(8 .^ (bitand(uint16(xic),uint16(49152))/2^14));

% Convert mass values to m/z
mz = mz/20;

spectra = zeros(length(mz),3);
spectra(:,1) = mz';
spectra(:,2) = xic';
spectra(:,3) = sindex';

% Make a copy of TIC
ch(:,3) = ch(:,2);

