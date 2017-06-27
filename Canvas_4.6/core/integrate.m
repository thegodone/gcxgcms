% Measurements made on peaks
% column 1 stores peak area
% column 2 stores peak half height
% column 3 stores start time at peak half height
% column 4 stores end time at peak half height
function M = integrate(ch,L)

n = size(L)(1);
M = zeros(n,4);
for i = 1 : n,
    Ab = (L(i,4)+L(i,5))*(L(i,3)-L(i,1))/2;
    M(i,1) = sum(ch(L(i,1):L(i,3),2))-(ch(L(i,1),2)+ch(L(i,3),2))/2; % trapezoidal rule
    M(i,1) = M(i,1)-Ab;
    
    base = (L(i,4)*(L(i,3)-L(i,2))+L(i,5)*(L(i,2)-L(i,1)))/(L(i,3)-L(i,1));
    half_height = 0.5*(ch(L(i,2),2)+base);
    if (ch(L(i,1),2)<half_height && ch(L(i,3),2)<half_height)
        for j = L(i,2) : - 1 : L(i,1),
            if (ch(j,2)<=half_height)
                t0 = ch(j,1)+(half_height-ch(j,2))/(ch(j+1,2)-ch(j,2))*(ch(j+1,1)-ch(j,1));
                break;
            end
        end
        for j = L(i,2) : L(i,3),
            if (ch(j,2)<=half_height)
                t1 = ch(j,1)+(half_height-ch(j,2))/(ch(j-1,2)-ch(j,2))*(ch(j-1,1)-ch(j,1));
                break;
            end
        end
        M(i,2) = half_height;
        M(i,3) = t0;
        M(i,4) = t1;
    end
end

if (n>0) Lmax = L(1,3); end
for i = 2 : n,
    if (L(i,3)<=Lmax)  
        if (L(i,3)<=L(i-1,3))
            i0 = i - 1;
        end    
        M(i0,1) = M(i0,1) - M(i,1); % take out shoulder peak areas from abnormal peaks
    end
    Lmax = max(Lmax,L(i,3));
end
dt = ch(2,1)-ch(1,1);
M(:,1) = M(:,1)*dt;

