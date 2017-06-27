function cross = intersect(P1,Q1,P2,Q2)

if ((P1(1)==P2(1) && P1(2)==P2(2)) || (Q1(1)==Q2(1) && Q1(2)==Q2(2)))
    L1 = sqrt((Q1(1)-P1(1))^2+(Q1(2)-P1(2))^2);    
    L2 = sqrt((Q2(1)-P2(1))^2+(Q2(2)-P2(2))^2);
    if (abs((Q1(1)-P1(1))/L1-(Q2(1)-P2(1))/L2)<1e-10 && abs((Q1(2)-P1(2))/L1-(Q2(2)-P2(2))/L2)<1e-10)
        cross = 1;
    else
        cross = 0;
    end
    return;
end   
    
o1 = orientation(P1, Q1, P2);
o2 = orientation(P1, Q1, Q2);
o3 = orientation(P2, Q2, P1);
o4 = orientation(P2, Q2, Q1);
 
% General case
if (o1 ~= o2 && o3 ~= o4)
    cross = 1;
    return;
end

% P1, Q1 and P2 are colinear and P2 lies on segment P1Q1
if (o1 == 0 && onSegment(P1, P2, Q1))
    cross = 1; 
    return;
end
 
% P1, Q1 and Q2 are colinear and Q2 lies on segment P1Q1
if (o2 == 0 && onSegment(P1, Q2, Q1))
    cross = 1;
    return;
end
 
% P2, Q2 and P1 are colinear and P1 lies on segment P2Q2
if (o3 == 0 && onSegment(P2, P1, Q2))
    cross = 1;
    return;
end
 
% P2, Q2 and Q1 are colinear and Q1 lies on segment P2Q2
if (o4 == 0 && onSegment(P2, Q1, Q2))
    cross = 1;
    return;
end
 
cross = 0; % Doesn't fall in any of the above cases
    

% Given 3 colinear points P, Q, R, check if point Q lies on line segment PR.
function OnSeg = onSegment(P,Q,R)

if (Q(1)<=max(P(1),R(1)) && Q(1)>= min(P(1),R(1)) && Q(2)<=max(P(2),R(2)) && Q(2)>= min(P(2),R(2)))
    OnSeg = 1;
else
    OnSeg = 0;
end

 
% Find orientation of ordered triplet (P,Q,R).
function o = orientation(P,Q,R)

val = (Q(2)-P(2))*(R(1)-Q(1))-(Q(1)-P(1))*(R(2)-Q(2));
 
if (val==0) % colinear
    o = 0;
elseif (val>0)
    o = 1;  % clockwise
else
    o = 2;  % counter-clockwise
end
