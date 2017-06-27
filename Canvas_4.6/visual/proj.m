function p = proj(ch,N,s2,e2)

    figure(1);clf;
    T=ch(:,1);
    t=ch(N);
    Y=ch(:,2);
    T1 = t(1,:);
    T2 = t(:,1);
    [val,r0] = min(abs(T2(:,1)-T2(1,1)-s2/60));
    [val,r1] = min(abs(T2(:,1)-T2(1,1)-e2/60));
    A = sum(T(N(r0:r1,:)),1);
    
    plot(T1,A,'b-');
    grid on;
    xlim([T1(1),T1(end)]);    % 2015/12/27

    p = [T1;A]';

    if (size(ch)(2)>2)  % mass-spec data
        h = get(1,'userdata');
        if (~isfield(h,'ions'))
            return;
        end
        
        if (isempty(h.ions))
            text = 'TIC';
        else
            text = num2str(h.ions(1));
            for i = 2 : length(h.ions),
                text = [text,'+',num2str(h.ions(i))];
            end
        end
        legend(text);
        legend('boxoff');
    end
