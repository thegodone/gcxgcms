function ch = readCleanCSV(file)
    
    ch = csvread([file,'.csv'],0,0); 
    ch = real(ch);
    
    N = size(ch)(1);
    run_time = ch(end,1)-ch(1,1);
    acq_rate = (N-1)/run_time/60;
    ch(:,1) = linspace(ch(1,1),ch(end,1),N);
    
    % code for Mustang, added on 10/1/2015 at Dow
    n = floor(ch(1,1)*60*acq_rate);
    t0 = ch(1,1) - n/acq_rate/60;
    run_time = ch(end,1)-t0;
    
    printf('acq_rate: %7.3f hz\n', acq_rate);
    printf('run_time: %7.3f min\n', run_time);

    ch = ch(:,1:2); 