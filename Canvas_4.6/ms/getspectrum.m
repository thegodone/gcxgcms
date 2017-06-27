function spectrum = getspectrum(scan,scan_bgrd,time,spectra)

global File;
global NISTroot;
global NISTsecond;

Nscan = length(scan);
fp = fopen([File,filesep,'spectrum.msp'],'w');
for k = 1 : Nscan,
    mn = find(spectra(:,3)==scan(k));
    if (length(mn)==0)
        spectrum = [];
        base = 0;
        m = 1;
        n = 0;
    else
        m = mn(1);
        n = mn(end);
        spectrum = spectra(m:n,:);
        
        if (scan_bgrd(k)>0)
            % get background scan spectrum
            mn_bgrd = find(spectra(:,3)==scan_bgrd(k));
            if (isempty(mn_bgrd))
                spectrum_bgrd = [];
            else
                spectrum_bgrd = spectra(mn_bgrd(1):mn_bgrd(end),:);
            end
            
            % subtract background scan
            for i = 1 : n-m+1,
                j = find(abs(spectrum_bgrd(:,1)-spectrum(i,1))<=0.3);
                if (length(j)>0)
                    spectrum(i,2) = max(0,spectrum(i,2)-spectrum_bgrd(j,2));
                end
            end
        end
    end
    
    fprintf(fp,'%s%s%d\n','NAME: ','scan ',scan(k));
    fprintf(fp,'%s%d\n','Num Peaks: ',n-m+1);
    for i = 1 : n-m+1,
        fprintf(fp,'%d,%d\n',round(spectrum(i,1)),spectrum(i,2));
    end
end
fclose(fp);

if (isempty(NISTroot))
    time = time(end);   % draw only last scan
    figure(4);clf;
    label = {};
    loc = [];
    num = 0;
    if (~isempty(spectrum))
        base = max(spectrum(:,2));
        spectrum(:,2) = spectrum(:,2)/base*100;
    end
    for i = 1 : n-m+1,
        line([spectrum(i,1),spectrum(i,1)],[0,spectrum(i,2)]);

        if (i>8 || i<n-m-6)
            index = find(abs(spectrum(:,1)-spectrum(i,1))<7);
            if (length(index)==1 || max(spectrum(min(index):max(index),2))==spectrum(i,2))
                num = num + 1;
                label{num} = num2str(round(spectrum(i,1)));
                loc(num,1) = spectrum(i,1)-1;
                loc(num,2) = spectrum(i,2)+5;
            end
        end
    end    
    text(loc(:,1),loc(:,2),label);
    x0 = min(spectra(:,1))-3;
    if (n>m)
        x1 = max(spectrum(:,1))+3;
    else
        x1 = max(spectra(:,1))+3;
    end
    xlim([x0,x1]);
    ylim([0,110]);
    title(['scan ',num2str(scan),' (',num2str(time),'min) abundance [',num2str(base/100),']']);
    h=gca;set(h,'tickdirmode','manual','tickdir','out');
end
