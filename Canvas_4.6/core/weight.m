% weight.m calculates the weights for the t'th (from -m to m)
% Least-Square point of the s'th derivative, over 2m+1 points, 
% order n.

function y = weight(t,m,n,s)
y = zeros(2*m+1,1);
p = zeros(n+1,1);
for k = 0 : n,
    p(k+1) = prod(2*m-k+1:2*m)/prod(2*m+1:2*m+k+1); % prod(n:n+k) = n*(n+1)*(n+2)*...*(n+k)
    G(k+1) = GramPoly(t,m,k,s);
end

for i = -m : m,
   a = 0;
   for k = 0 : n,
      a = a + (2*k+1)*p(k+1)*GramPoly(i,m,k,0)*G(k+1);
   end
   y(i+m+1) = a;
end

