function setupfigs(k)

global ColorScheme;

canvas_path = getpath;    
indices = strfind(canvas_path,pathsep);   
if (size(indices)(2)>0)
    canvas_path = canvas_path(1:indices(1)-1);
end

if (k==0)
    fsize = csvread([canvas_path,filesep,'figsize.ini']);
    figure(1);
    sizefig(fsize(1,1),fsize(1,2));
    set(1,'userdata',[]);
    figure(2);
    sizefig(fsize(2,1),fsize(2,2));
    ColorScheme = fsize(3,1);
    showdot([0,0],'w.');
else
    fsize = [get(1,'figsize');get(2,'figsize')];
    csvwrite([canvas_path,filesep,'figsize.ini'],[fsize;ColorScheme,0]);
end

