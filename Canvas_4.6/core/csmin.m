function [i,j,FOUND] = csmin(cs,j0,NOISE,RISE,LEVEL,RISE2,LEVEL2)
    i0 = j0;
    countdown = 2;
    N = length(cs);
    while (j0 < N)
        if (cs(j0,3) < cs(j0+1,3)) 
            j0 = j0 + 1;
        elseif (i0 == j0)
            j0 = j0+1;
            i0 = j0;
        elseif (cs(j0,3)-cs(i0,3) < NOISE)
            if (cs(i0,3) >= cs(j0+1,3))
                i0 = j0+1;
                j0 = i0;
            else
                j0 = j0+1;
            end
%            if (abs(cs(j0,3)-LEVEL2)<RISE2 && (abs(cs(j0,2)-LEVEL)<RISE || abs(cs(j0,2))<RISE))
            if (abs(cs(j0,3)-LEVEL2)<RISE2/2)  % modified on 7/14/2015
                countdown = countdown - 1; 
%                printf('countdown = %d @ %f min\n',countdown,cs(j0,1));
                if (countdown == 0)
                    i = j0;
                    j = j0;
                    FOUND = 0;
%                    printf('baseline found\n');
                    return;
                end
            end
        else
            i = i0;
            j = j0+1;
            FOUND = 1;
%            printf('min at %f min, ',cs(i0,1));
%            printf('now at %f min\n',cs(j0+1,1));
            return;
        end
    end
        
    i = i0;
    j = j0;
    FOUND = 2; % end of data
    
    