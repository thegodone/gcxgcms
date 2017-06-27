function cs = dervs(ch,m)

    N = length(ch);
    cs = zeros(N,4);
    cs(:,1) = ch(:,1);  % copy the time column
    m = round(m/2);     % optimal Savitsky-Golay window size is about half peak width

    printf('1st derivative...\n');
    cs(:,2) = derv(ch(:,2),m,2,1);
    
    printf('2nd derivative...\n');
    cs(:,3) = derv(ch(:,2),m,2,2);  % may miss small and wide peaks particularly out-of-order
%    cs(:,3) = derv(cs(:,2),m,2,1); % may miss closely co-eluted peaks
    
    printf('4th derivative...\n');
    cs(:,4) = derv(cs(:,3),m,2,2);
