% Filtered peak list
% column 1 stores index of peak start
% column 2 stores index of peak apex
% column 3 stores index of peak end
% column 4 stores baseline at peak start
% column 5 stores baseline at peak end 
function L = postproc(ch,pklist,Hrej,exception)

pklist = beneath(ch,pklist);

pknum = size(pklist)(1);
num = 0;
L = zeros(2*pknum,5);     % speedup
j = 1;
i = j;
while (i<=pknum)
    m = pklist(j,2); 
    p = pklist(j,3);
    m0 = m; j0 = j;
    if (j<pknum) 
        n = pklist(j+1,2); 
        except = skip(ch(m,1),ch(n,1),exception);
    end

    k = 0;
    shoulders = [];
    while (j<pknum && except>0)                         % peaks to be selectively combined
%        p0 = p;                  % modified on 7/25/2015
        n = m;
        j = j+1; 
        p0 = pklist(j,1);         % modified on 7/25/2015
        m = pklist(j,2); 
        p = pklist(j,3);
        if (ch(m,2)>ch(m0,2)) m0 = m; j0 = j; end

        if (except<2)
            hi = max(ch(m,2),max(ch(p0,2),ch(p,2)));
            lo = min(ch(p0,2),ch(p,2));
            if (skip(ch(m,1),ch(m,1),exception)>1)      % start of selective peaks to be re-combined 
                k = k + 1; 
                shoulders(k,1) = p0;
                shoulders(k,2) = m;
                shoulders(k,3) = p;
            elseif (hi-lo>Hrej && ch(m,2)>(ch(p0,2)*(p-m)+ch(p,2)*(m-p0))/(p-p0))   % selectivity criteria: significant & skimmable 
                k = k +1; 
                shoulders(k,1) = p0;
                shoulders(k,2) = m;
                shoulders(k,3) = p;
            end 
        elseif (k>0)                                    % succesive peaks to be combined
            if (ch(m,2)>ch(n,2)) 
                shoulders(k,2) = m;
            end
            shoulders(k,3) = p;
        end

        if (j<pknum) 
            n = pklist(j+1,2);
            except = skip(ch(m,1),ch(n,1),exception);
        end
    end
           
    base = (pklist(j0,4)*(pklist(j0,3)-m0)+pklist(j0,5)*(m0-pklist(j0,1)))/(pklist(j0,3)-pklist(j0,1));
    if (ch(m0,2)-base>Hrej)
        num = num + 1;
        L(num,1) = pklist(i,1);
        L(num,2) = m0;
        L(num,3) = p;
        L(num,4) = pklist(i,4);
        L(num,5) = pklist(j,5);
    end

    if (k>0 && (shoulders(k,1)~=L(num,1) || shoulders(k,3)~=L(num,3)))
        shoulders = beneath(ch,shoulders);
        L(num+1:num+k,:) = shoulders;     % speedup
        num = num + k;
    end
   
    j = j+1;
    i = j;
end

L = L(1:num,:);    % speedup
printf('%d peaks confirmed\n',num); 


