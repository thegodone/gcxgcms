function read2Dlocal()


%%%% part one read the FID signal this is the signal store in FID1A.ch file
%%%% it's a one dimensional signal in time and accumulate bands (of y) 
%%%% we need to cut it in bands (of a certain Period using the fold method)
close all

addpath(genpath('Canvas_4.6'))

tic
ch = readAgilentCH('C6_50ppm_090516.D/FID1A.ch');
toc
sampling_rate=100;
modulation_period=5;
Chrom=ch(:,2);
Chromato2 = reshape(Chrom(1:end-mod(length(ch),...
                modulation_period*sampling_rate)),...
                modulation_period*sampling_rate,[]);
% align the signal 1D to the 2D matrix using the Period and Fold it
Period = pickperiod(ch,0.5);
N = fold(ch,Period,0);
ch2=ch(:,2);
Ref=ch2(N);


figure
imagesc(Ref)

% x,y values
nr = size(N,1);
nc = size(N,2);
ch2=ch(:,2);

Ax=ch2(N);
Ax(Ax==0)=NaN;
A=inpaint_nans(Ax);
baseline = ones(nr,1)*min(ch2(N));
A = ch2(N) - baseline;
A(A==0)=NaN;
A=inpaint_nans(A);
A = log(max(1,A));
dt1 = Period/60;
dt2 = (ch(2,1)-ch(1,1))*60;
x0 = ch(N(1,1),1)-dt1/2;
x1 = ch(N(1,end),1)+dt1/2;
y0 = -dt2-dt2/2;
y1 = (nr-1)*dt2+dt2/2;
x = ch(N(1,:),1)-dt1/2;
y=linspace(y0,y1,nr);

f=figure;
imagesc(A)

%surfc(x,y,A)
%colormap(f,jet);

% we need to inverse the matrix cause the time is wrong (start in lower
% left corner not the top left corner.... but the value on the y axis is
% still wrong!
% threre is also some denoise and rescaling process there.
Bcut=A(:,35:end);
Bcut=flipud(Bcut);
x0=    ch(N(35,1),1)-dt1/2;
figure,
p=imagesc([x0 x1],[y0 y1],[Bcut;Bcut(1,:)]);
% show colum one
figure
plot(sum(Bcut,1))

 figure
 imagesc(Bcut)


% x = ch(N(35,35:end),1)-dt1/2;
% y=linspace(y0,y1,nr);
% 
% f=figure;
% surfc(x,y,Bcut)
% colormap(f,jet);

% 
% colormap(flame);
% h.max=max(max(A))
% h.linecolor = 'r';
% h.textcolor = 'k';
% h.markercolor = 'k';
% h.antimarkercolor = 'w';
% h.cstring = 'rkgmb';
% 
% colormap(scent);
% h.linecolor = 'y';
% h.textcolor = 'w';
% h.markercolor = 'w';
% h.antimarkercolor = 'b';
% h.cstring = 'rkymc';
% 
% colormap(fluorescence);
% h.linecolor = 'c';
% h.textcolor = 'c';
% h.markercolor = 'y';
% h.antimarkercolor = 'k';
% h.cstring = 'rwmbc';

% 
% % ?
% proj(ch,N,0,Period);
% % to do
% L=[];
% M=[];
% colorgram(ch,N,L,M,ch(1,1),ch(end,1));
% x = ch(N(1,:),1)-dt1/2;
% dt1 = Period/60;
% dt2 = (ch(2,1)-ch(1,1))*60;
% y0 = -dt2-dt2/2;
% y1 = (nr-1)*dt2+dt2/2;
% y=linspace(y0,y1,nr);
% 
% %%%
% 
% figure
% surfc(x,y,A)

% %%% denoise
% K=mat2gray(A);
% Ja= filter2(fspecial('sobel'),A); % on the y dimension
% Jb= filter2(fspecial('sobel')',A); % on the y dimension
% 
% close all
% figure
% subplot(2,2,1)
% imagesc(x,y,K)
% subplot(2,2,2)
% imagesc(x,y,Ja-A)
% subplot(2,2,3)
% imagesc(x,y,A-Jb-A)
% subplot(2,2,4)
% imagesc(x,y,A);
% 
% figure
% surf(x,y,A-Ja)

%%% why the signal is so diff using readfiles and python or cpp codes ???
% % adding tangentelri option not implementer in the current version
% tic
% [time,ric,point,mass,inte,pycode,LRIval,rtval ]= localconversion_c_or_py(char('/Users/GVALMTGG/Documents/gcxgc/C6_50ppm_090516.D'), char('DATA.MS'),1);
% toc
% chmsa=[time',ric',ric'];

%%%% I have a very different result using the readAgilentMS vs Python code
tic
[chms,spectra] = readAgilentMS('C6_50ppm_090516.D/DATA.MS');
toc
 
%%% look like the period in MS is wrong ... use the FID previous period!
% issue there
%Period = pickperiod(chms,0.5)
% using xcorr is better but slower... 
k=xcorr(Chrom);
[p,xi]=min(k);
% manually fix for the moment.... need to fix this
k=145/26.7851;

sampling_rate=26.7851;
modulation_period=5.4135;
Chrom=chms(:,2);
% the reshape is working better than the fold method after... ???
Chromato = reshape(Chrom(1:end-mod(length(chms),...
                round(modulation_period*sampling_rate))),...
                round(modulation_period*sampling_rate),[]);

%% start point are on top left on both subplot which is wrong!!!
figure
subplot(2,1,1)
imagesc(A)
subplot(2,1,2)
imagesc(Chromato)


%%% the two signal are not starting in the same time (FID start at 0 while MS start after... so the MS image is delay on right)
%%% resolution of the signal is slower in MS (2D signal are recorded) vs
%%% FID so the frequence is slower and number of points too
%             
% % freq = 25 Hz 
% % 4 less points than in ch!
% Period=5.4135;
% % issue there
% %Period = pickperiod(chms,0.5);
% N = fold(chms,5,0);
% chms2=chms(:,2);
% nr = size(N,1);
% nc = size(N,2);
% ch2=chms(:,2);
% Ax=ch2(N);
% Ax(Ax==0)=NaN;
% A=inpaint_nans(Ax);
% baseline = ones(nr,1)*min(ch2(N));
% A = chms2(N) - baseline;
% A(A==0)=NaN;
% A=inpaint_nans(A);
% A = log(max(1,A));
% 
% dt1 = Period/60;
% dt2 = (chms(2,1)-chms(1,1))*60;
% x0ms = ch2(N(1,1),1)-dt1/2;
% x1ms = ch2(N(1,end),1)+dt1/2;
% y0ms= -dt2-dt2/2;
% y1ms = (nr-1)*dt2+dt2/2;
% xms = ch2(N(1,:),1)-dt1/2;
% yms=linspace(y0,y1,nr);
% 
% 
% figure
% imagesc(A)
% 
% %J = filter2(fspecial('sobel')',A);
% figure,
% surf(xms,yms,A);
% 
% 
% 
% 
% colormap(flame);
% h.max
% h.linecolor = 'r';
% h.textcolor = 'k';
% h.markercolor = 'k';
% h.antimarkercolor = 'w';
% h.cstring = 'rkgmb';
% 
% colormap(scent);
% h.linecolor = 'y';
% h.textcolor = 'w';
% h.markercolor = 'w';
% h.antimarkercolor = 'b';
% h.cstring = 'rkymc';
% 
% colormap(fluorescence);
% h.linecolor = 'c';
% h.textcolor = 'c';
% h.markercolor = 'y';
% h.antimarkercolor = 'k';
% h.cstring = 'rwmbc';
% 
% 
% 
% 
% 
% % ?
% proj(ch,N,0,Period);
% % to do
% L=[];
% M=[];
% colorgram(chms,N,L,M,chms(1,1),chms(end,1));
% x = ch(N(1,:),1)-dt1/2;
% dt1 = Period/60;
% dt2 = (ch(2,1)-ch(1,1))*60;
% y0 = -dt2-dt2/2;
% y1 = (nr-1)*dt2+dt2/2;
% y=linspace(y0,y1,nr);
% 
% %%%
% 
% figure
% surfc(x,y,A)
% 
% figure
% imagesc(A)
% 
% %%% denoise
% K=mat2gray(A);
% Ja= filter2(fspecial('sobel'),A); % on the y dimension
% Jb= filter2(fspecial('sobel')',A); % on the y dimension
% 
% close all
% figure
% subplot(2,2,1)
% imagesc(x,y,K)
% subplot(2,2,2)
% imagesc(x,y,Ja-A)
% subplot(2,2,3)
% imagesc(x,y,A-Jb-A)
% subplot(2,2,4)
% imagesc(x,y,A);
% 
% figure
% surf(x,y,A-Ja)





