% This script puts Canvas into a command-line batch processing mode

global Period;
global Shift;

Period = 4;
Shift = 0;
ions = [];
sk = 1;

    setupNIST;
    
    ch = [];
    spectra = [];
    D = [];
    
          
    
    [file,chrom,spec] = loadfile;
    if (isempty(chrom))
        printf('data NOT loaded in present directory.\n'); % user aborts file selection
        return;
    else
        [ch,spectra] = truncate(chrom,spec);
        L = [];
        M = [];
        D = [];
        File = file;
        
        if (Period>0)
            N = fold(ch,Period,Shift);
        else
            N = [];
        end
        
        if (exist(File,'dir')==0)
            mkdir(File);
        end
        csvwrite([File,filesep,'visual_setting.dat'],[Shift,0,Period]);
        
        disp('running speciation...');
        if (size(ch)(2)>2) % mass-spec data
            n = length(ions);
            if (n>0)
                file = File;
                for i = 1 : n,
                    File = [file,filesep,num2str(ions(i))];
                    ch(:,2) = ch(:,i+3)+rand(size(ch)(1),1);        
                    disp(['processing m/z=',num2str(ions(i)),' ...']);
                    [L,M,D] = speciate(ch,N,[],[],sk);   % only L,M,D of last ion get retained
                    disp(' ');
                end
                File = file;
                ch(:,2) = sum(ch(:,4:length(ions)+3),2);
                return;
            end
        end
            
        [L,M,D] = speciate(ch,N,L,M,sk);





