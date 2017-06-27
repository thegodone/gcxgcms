function eic = geteic(ion,ch,spectra)
    
    eic = zeros(size(ch)(1),2);
    eic(:,1) = ch(:,1);
    
    index = find(abs(spectra(:,1)-ion)<=0.2);
    if (~isempty(index))
        eic(spectra(index,3),2) = spectra(index,2);
    end
    
