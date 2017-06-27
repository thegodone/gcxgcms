% Input:
%    suffix: file suffix inlcuding '.'
%    k: kth file, 0 for choice, negative value for no choice but printing all
%    i0: starting index for printing
% Output:
%    file: selected file (k>=0) or files (k<0)
%    k: index of file
function [file,k] = filechooser(suffix,k,i0)
    
    global File;
    
    files = dir(['*',suffix]);
    nfiles = size(files)(2);
    
    if (nfiles>0)
        if (k>nfiles)
            file = [];
            return;
        elseif (k>0)
            file = files(k);
            return;
        end
        
        suffix_len = length(suffix);
        CurrentDataPath = pwd;
        for i = 1 : nfiles,
            ThisFile = [CurrentDataPath,filesep,files(i).name(1:end-suffix_len)];
            if (length(File)>0 && strstr(File,ThisFile))         % 2016/3/11
                printf('*%2d) %s\n',i+i0,files(i).name);
            else
                printf(' %2d) %s\n',i+i0,files(i).name);
            end
        end
        printf('-------------------------------------------\n');
    else
        file = [];
        return;
    end
    
    if (k<0)
        file = files;
        return;
    end
    
    while (k<1 || k>nfiles)
        k = input('Your choice: ');
    end
    
    if (size(k)(1)==0)
        file = [];
    else
        file = files(k);
    end

