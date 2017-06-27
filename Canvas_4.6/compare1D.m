function compare1D(ch0,ch1)
    
while (1)
    printf('\nMain->Compare\n');
    printf('-------------------------------------------\n');
    printf(' 1) overlay\n');
    printf(' 2) mirror\n');
    printf('-------------------------------------------\n');
    kmax = 2;
        
    k = 0;
    while (k<1 || k>kmax)
        k = input('Your choice: ');
        if (size(k)(1)==0)
            return;
        end
    end
        
    if (k==1)
        c = ch1(:,2)-min(ch1(:,2))+min(ch0(:,2));
    elseif (k==2)
        c = -ch1(:,2) + min(ch0(:,2))+min(ch1(:,2));
    end
        
    figure(2);
    plot(ch0(:,1),ch0(:,2),'b-',ch1(:,1),c,'r-');
    legend('current','target');
    legend('boxoff');
    grid on;
    xlim([min(ch0(1,1),ch1(1,1)),max(ch0(end,1),ch1(end,1))]);
end
