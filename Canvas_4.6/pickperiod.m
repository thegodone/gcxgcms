function period = pickperiod(ch,step)

M = size(ch,1);
Nseg = 5;

%cprintf('period:');
marray = [1,round([1:Nseg-1]*(M-1)/Nseg+1),M];  % divide chromatogram into Nseg segments
periods = zeros(Nseg,1);
for k = 1 : Nseg,
    periods(k) = findperiod(ch(marray(k):marray(k+1),:),20,step,20);
%    printf('%4.1f ',periods(k));
%    cprintf(' ');
end

period = 0;
count = 0;
while (count<2)
     period = max(periods);
     for k = 1 : Nseg,
         if (periods(k)==period)
             count = count + 1;
             j = k;
         end
     end
     if (count<2)
         periods(j) = 0;
         count = 0;
     end
end
