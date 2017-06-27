function resetfigure_gui(varargin)
    global File;
    global Period;
    global shift;
    global Saturation;
    global ColorScheme;
    global slideEnable;
    global labelEnable;
    global ch;
    global spectra;
    global N;
    global L;
    global M;
    global D;
    
    
    if isempty(varargin)
        figure(3);clf;
        set(3,'color',[0.94,0.94,0.92]);
        handles = struct('figure3',gcf);
        sizefig(360,210);
    
        % create the other uicontrol objects in the figure
        if (size(ch)(2)>2)
            h = get(1,'userdata');
            if (isempty(h.ions))
                ions_text = 'tic';
            else
                ions_text = num2str(h.ions(1));
                for i = 2 : length(h.ions),
                    ions_text = [ions_text,',',num2str(h.ions(i))];
                end
            end

            ion_max = h.ion_max;
            ion_min = h.ion_min;
            ions_label = uicontrol('style','text','parent',handles.figure3,...
                'string',['ions:(',num2str(ion_min),'-',num2str(ion_max),')          m/z'],...
                'position',[110 130 200 20]);
            handles.ions_label = ions_label;    
            handles.ion_min = ion_min;
            handles.ion_max = ion_max;
            handles.sim = h.sim;

            ions_edit = uicontrol('style','edit','parent',handles.figure3,...
                'string',ions_text,'position',[190 130 50 20]);
            handles.ions_edit = ions_edit; 
            handles.ions = h.ions;
            
            if (~isempty(h.sim))
                n = length(h.sim);
                printf('SIM data including %d ions:\n',n);
                i = 1;
                while (i<=n)
                    if (i+5<=n)
                        printf('%5.1f %5.1f %5.1f %5.1f %5.1f %5.1f\n',h.sim(i:i+5));
                        i = i + 6;
                    else
                        for j = i : n,
                            printf('%5.1f ',h.sim(j));
                        end
                        printf('\n');
                        i = n + 1;
                    end
                end
            end
        end
        
        confirm_button = uicontrol('style','pushbutton',...
            'parent',handles.figure3,'string','confirm',...
            'callback','resetfigure_gui(''confirm_button_Callback'')',...
            'position',[130 170 100 20]);
        handles.confirm_button = confirm_button;

        period_text = uicontrol('style','text','parent',handles.figure3,...
            'string','period:               s','position',[110 10 200 20]);%,...
        handles.period_text = period_text;
            
        period_edit = uicontrol('style','edit','parent',handles.figure3,...
            'string',num2str(Period),'position',[190 10 50 20]);
        handles.period_edit = period_edit;
        
        shift_text = uicontrol('style','text','parent',handles.figure3,...
            'string','D2-shift:             s','position',[110 40 200 20]);%,...
        handles.shift_text = shift_text;
            
        shift_edit = uicontrol('style','edit','parent',handles.figure3,...
            'string',num2str(shift),'position',[190 40 50 20]);
        handles.shift_edit = shift_edit;
        
        saturation_text = uicontrol('style','text','parent',handles.figure3,...
            'string','saturation:           (-5~5)','position',[110 70 200 20]);%,...
        handles.saturation_text = saturation_text;
            
        saturation_edit = uicontrol('style','edit','parent',handles.figure3,...
            'string',num2str(Saturation),'position',[190 70 50 20]);
        handles.saturation_edit = saturation_edit;
    
        h = get(2,'userdata');
        colorscheme = h.colorscheme;
        
        colorscheme_text = uicontrol('style','text','parent',handles.figure3,...
            'string','colormap:             (1~3)','position',[110 100 200 20]);%,...
        handles.colorscheme_text = colorscheme_text;
                    
        colorscheme_edit = uicontrol('style','edit','parent',handles.figure3,...
            'string',num2str(colorscheme),'position',[190 100 50 20]);
        handles.colorscheme_edit = colorscheme_edit;
    
        set(gcf,'userdata',handles);
    else
%        disp(['Running function: ' varargin{1}]);
        handles = get(3,'userdata');
        if ischar(varargin{1})
            feval(varargin{1},handles);
        end
    end

function confirm_button_Callback(handles)
    global File;
    global Period;
    global shift;
    global Saturation;
    global ColorScheme;
    global slideEnable;
    global labelEnable;
    global ch;
    global spectra;
    global N;
    global L;
    global M;
    global D;
    
    period = get(handles.period_edit,'string');
    period = str2num(period);
    if (isempty(period) || period<0)
        set(handles.period_edit,'String','INVALID');
        return;
    else
        Period = period;
    end

    tshift = get(handles.shift_edit,'string');
    tshift = str2num(tshift);
    if isempty(tshift)
        set(handles.shift_edit,'String','INVALID');
        return;
    else
        shift = tshift;
    end

    saturation = get(handles.saturation_edit,'string');
    saturation = str2num(saturation);
    if (isempty(saturation) || saturation<-5 || saturation>5)
        set(handles.saturation_edit,'String','INVALID');
        return;
    else
        Saturation = saturation;
    end

    colorscheme = get(handles.colorscheme_edit,'string');
    colorscheme = str2num(colorscheme);
    if (isempty(colorscheme) || colorscheme<1 || colorscheme>3)
        set(handles.colorscheme_edit,'String','INVALID');
        return;
    else
        h = get(2,'userdata');
        if (colorscheme ~= h.colorscheme)
            ColorScheme = colorscheme;
        end
        h.colorscheme = colorscheme;
        set(2,'userdata',h);
    end

    set(1,'userdata',[]);
    
    if (size(ch)(2)>2)
        NoChange = 0;
        ions = get(handles.ions_edit,'string');
        if (strcmp(ions,'tic'))
            ions = [];
            if (isempty(handles.ions))
                NoChange = 1;
            else
                ch(:,2) = ch(:,3);                 % retrieve copy of TIC
                file = [File,filesep,'lmd.dat'];
            end
        else
            ions = str2num(ions);
            if (isempty(ions) || min(ions)<handles.ion_min || max(ions)>handles.ion_max)
                set(handles.ions_edit,'String','INVALID');
                return;
            else
                uions = unique(ions);
                for i = 1 : length(uions),
                    sions(find(ions==uions(i),1)) = uions(i);
                end
                ions = sions;
                for i = 1 : length(ions),
                    ch(:,i+3) = geteic(ions(i),ch,spectra)(:,2);
                end
                ch(:,2) = sum(ch(:,4:length(ions)+3),2);
            end
            if (~isempty(handles.ions) && handles.ions(end)==ions(end))
                NoChange = 1;
            else
                file = [File,filesep,num2str(ions(end)),filesep,'lmd.dat'];  % last ion has priority
            end
        end
        if (~NoChange)
            if (exist(file,'file'))
                load(file);                        % reload L,M,D
                importnames(ch,L,D,File);          % re-associate cmpd-number with cmpd-names
            else
                L = [];
                M = [];
                D = [];
            end
        end

        h = get(1,'userdata');
        h.ions = ions;
        h.ion_max = handles.ion_max;
        h.ion_min = handles.ion_min;
        h.sim = handles.sim;
        set(1,'userdata',h);
    end

    close(3);
    N = resetfigure(ch,L,M,shift);
