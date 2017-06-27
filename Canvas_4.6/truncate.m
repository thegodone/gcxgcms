function [ch_cut,spec_cut] = truncate(varargin)
    
    ch = varargin{1};
    spectra = varargin{2};
    if (size(ch)(1)==0)
        ch_cut = [];
        spec_cut = [];
        return;
    end
    
    if (nargin==2)
        t0 = -1;
        while (t0<ch(1,1) || t0>ch(end,1))
            t0 = input(['truncate data from (min): ']);
            if (size(t0)==0)
                t0 = ch(1,1);
                break;
            end
        end
        t1 = t0;
        while (t1<=t0 || t1>ch(end,1))
            t1 = input(['...............end (min): ']);
            if (size(t1)==0)
                t1 = ch(end,1);
                break;
            end
        end
    else
        t0 = varargin{3};
        t1 = varargin{4};
        disp(['truncate data from (min): ',num2str(t0)]); 
        disp(['...............end (min): ',num2str(t1)]); 
    end
    n0 = round((t0-ch(1,1))/(ch(2,1)-ch(1,1)))+1;
    n0 = max(n0,1);
    n1 = round((t1-ch(1,1))/(ch(2,1)-ch(1,1)))+1;
    n1 = min(n1,size(ch)(1));

    if (n0==1 && n1==length(ch))
        ch_cut = ch;
        spec_cut = spectra;
    else
        ch_cut = ch(n0:n1,:);
        if (size(spectra)(1)>0)
            spectra(:,3) = spectra(:,3)-n0+1;
%            spec_cut = spectra(find(spectra(:,3)>=1)(1):find(spectra(:,3)<=n1-n0+1)(end),:);
            spec_cut = spectra;  
        else
            spec_cut = [];
        end
    end