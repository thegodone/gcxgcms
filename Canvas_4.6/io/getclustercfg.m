function [R,exclude] = getclustercfg(filepath,string,GetShared) % modified on 6/22/2016
    
    CurrentDataPath = pwd;
    R = {};
    exclude = [];                           % added on 12/1/2015
    if (size(dir([filepath,filesep,'*.ply']))(2)>0)    % modified on 12/2/2015
        cd(filepath);
    elseif (GetShared==1)
        printf('search for shared clusters...\n');
        [plyfolder,k] = filechooser('.plys',0,0);
        if (size(plyfolder)>0)
            cd(plyfolder.name);
        elseif (strcmp('.D',CurrentDataPath(end-1:end)))
            cd('..');
            [plyfolder,k] = filechooser('.plys',0,0);
            if (size(plyfolder)>0)
                cd(plyfolder.name);
            else
                cd(CurrentDataPath);
                return;
            end
        else
            return;
        end
    end
    
    i = 0;
    while (1)
        i = i + 1;
        [plyfile,i] = filechooser('.ply',i,0);
        if (length(plyfile)>0)
            if (plyfile.name(end-4)=='x')                      % added on 12/1/2015
                num = str2num(plyfile.name(1:end-5));          % .
                exclude(num,1) = 1;                            % .
            else                                               % .
                num = str2num(plyfile.name(1:end-4));          % . 
                exclude(num,1) = 0;                            % . 
            end                                                % .
            R{num} = csvread(plyfile.name);                    % added on 12/1/2015

            if (length(string)>0)
                printf('%s cluster %s...\n',string,plyfile.name(1:end-4));   % modified on 12/1/2015
            end
        else
            break;
        end
    end
    
    cd(CurrentDataPath);

