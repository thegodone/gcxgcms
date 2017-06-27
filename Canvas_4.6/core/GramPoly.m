% GramPoly calculates the Gram Polynomial (s=0), or its s'th derivative
% evaluated at i, order k, over 2m+1 points.

% Following recursive implementation is replaced due to Freemat bug. 
%
% function y = GramPoly(i,m,k,s)
% if (k>0)
%     y = (4*k-2)/(k*(2*m-k+1))*(i*GramPoly(i,m,k-1,s)+s*GramPoly(i,m,k-1,s-1))-((k-1)*(2*m+k))/(k*(2*m-k+1))*GramPoly(i,m,k-2,s);
% else
%     if (k==0 && s==0)
%         y = 1;
%     else
%         y = 0;
%     end
% end

function y = GramPoly(i,m,k,s)
    if (k==0)
        y = Gramk0(s);
    elseif (k==1)
        y = Gramk1(i,m,s);
    elseif (k==2)
        y = Gramk2(i,m,s);
    end

function y = Gramk2(i,m,s)
    k = 2;
    y = (4*k-2)/(k*(2*m-k+1))*(i*Gramk1(i,m,s)+s*Gramk1(i,m,s-1))-((k-1)*(2*m+k))/(k*(2*m-k+1))*Gramk0(s);

function y = Gramk1(i,m,s)
    k = 1;
    y = (4*k-2)/(k*(2*m-k+1))*(i*Gramk0(s)+s*Gramk0(s-1));

function y = Gramk0(s)
    if (s==0)
        y = 1;
    else
        y = 0;
    end
    
       


    
    
