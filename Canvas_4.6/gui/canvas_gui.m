function canvas_gui(varargin)

    global File;
    global NISTroot;
    global NISTsecond;
    global DotOverlay;
    global slideEnable;
    global labelEnable;
    global Period;
    global Saturation;
    global ColorScheme;
    global shift;
    global ch;
    global spectra;
    global N;
    global L;
    global M;
    global D;

    setupNIST;
    
    if isempty(varargin)
        
        ch = [];
        spectra = [];
        D = [];

        setupfigs(0);  % start with saved figure sizes and colorscheme
        figure(2);
        handles = struct('figure2',gcf);
        
        % create the other uicontrol objects in the figure
        load_button = uicontrol('style','pushbutton',...
            'parent',handles.figure2,'string','load data',...
            'callback','canvas_gui(''load_button_Callback'')',...
            'position',[5 0 100 20]);
        handles.load_button = load_button;
    
        reset_button = uicontrol('style','pushbutton',...
            'parent',handles.figure2,'string','reset figure',...
            'callback','canvas_gui(''reset_button_Callback'')',...
            'position',[103 0 100 20]);
        handles.reset_button = reset_button;
        
        speciate_button = uicontrol('style','pushbutton',...
            'parent',handles.figure2,'string','speciate',...
            'callback','canvas_gui(''speciate_button_Callback'')',...
            'position',[201 0 100 20]);
        handles.speciate_button = speciate_button;
        
        cluster_button = uicontrol('style','pushbutton',...
            'parent',handles.figure2,'string','cluster',...
            'callback','canvas_gui(''cluster_button_Callback'')',...
            'position',[299 0 100 20]);
        handles.cluster_button = cluster_button;

        compare_button = uicontrol('style','pushbutton',...
            'parent',handles.figure2,'string','compare',...
            'callback','canvas_gui(''compare_button_Callback'')',...
            'position',[397 0 100 20]);
        handles.compare_button = compare_button;

        customize_button = uicontrol('style','pushbutton',...
            'parent',handles.figure2,'string','report',...
            'callback','canvas_gui(''customize_button_Callback'')',...
            'position',[495 0 100 20]);
        handles.customize_button = customize_button;

        pinpoint_button = uicontrol('style','pushbutton',...
            'parent',handles.figure2,'string','P',...
            'callback','canvas_gui(''pinpoint_button_Callback'')',...
            'position',[830 0 30 20],'tooltipstring','pinpoint a 2D spot');
        handles.pinpoint_button = pinpoint_button;
    
        last_button = uicontrol('style','pushbutton',...
            'parent',handles.figure2,'string','<-',...
            'callback','canvas_gui(''last_button_Callback'')',...
            'position',[860 0 30 20],'tooltipstring','move a period backward');
        handles.last_button = last_button;
        
        next_button = uicontrol('style','pushbutton',...
            'parent',handles.figure2,'string','->',...
            'callback','canvas_gui(''next_button_Callback'')',...
            'position',[890 0 30 20],'tooltipstring','move a period forward');
        handles.next_button = next_button;
  
        lookfor_button = uicontrol('style','pushbutton',...
            'parent',handles.figure2,'string','L',...
            'callback','canvas_gui(''lookfor_button_Callback'')',...
            'position',[920 0 30 20],'tooltipstring','look for a species');
        handles.lookfor_button = lookfor_button;
        
       
        set(gcf,'userdata',handles);
    else
%        disp(['Running function: ' varargin{1}]);
        handles = get(2,'userdata');
        if ischar(varargin{1})
            feval(varargin{1},handles);
        end
    end

function load_button_Callback(handles)
    global File;
    global Period;
    global Saturation;
    global ColorScheme;
    global shift;
    global ch;
    global spectra;
    global N;
    global L;
    global M;
    global D;

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
            
            if (exist([File,filesep,'visual_setting.dat'],'file'))
                settings = csvread([File,filesep,'visual_setting.dat']);
                shift = settings(1);
                Saturation = settings(2);
                if (length(settings)>2)      % old visual_setting.dat may not have the 3rd parameter 
                    Period = settings(3);
                    printf('period:     %5.1f sec\n',Period);
                else
                    Period = pickperiod(ch,0.5);
                end
                if (length(settings)>3)      % old visual_setting.dat may not have the 4th parameter
                    colorscheme = settings(4);
                else
                    colorscheme = ColorScheme;
                end
            else
                shift = 0;
                Saturation  = 0;
                Period = pickperiod(ch,0.5);
                colorscheme = ColorScheme;
            end
            h = get(2,'userdata');
            h.colorscheme = colorscheme;
            set(2,'userdata',h);

            set(1,'userdata',[]);
            if (size(ch)(2)>2)
                h = get(1,'userdata');
                h.ions = [];
                h.ion_max = round(max(spectra(:,1)));
                h.ion_min = round(min(spectra(:,1)));
                
                i = h.ion_min + 1;
                n = 1;
                while (n<3 && i<=h.ion_max)
                    if (isempty(find(spectra(:,1)==i)))
                        n = 0;
                    else
                        n = n + 1;
                    end
                    i = i + 1;
                end
                if (n<3)
                    h.sim = unique(spectra(:,1));
                else
                    h.sim = [];
                end

                set(1,'userdata',h);
            end

            N = resetfigure(ch,L,M,shift);
        end
 
function reset_button_Callback(handles)
    global ColorScheme;
    global ch;

    if (size(ch)(1)==0) return; end
    resetfigure_gui;
    setupfigs(1);

function speciate_button_Callback(handles)
    global ch;

    if (size(ch)(1)==0) return; end
    speciate_gui;

function cluster_button_Callback(handles)
    global ch;

    if (size(ch)(1)==0) return; end
    disp('running cluster...');    
    clustermenu_gui;
        

function compare_button_Callback(handles)
    global ch;

    if (size(ch)(1)==0) return; end
    compare_gui;

function customize_button_Callback(handles)
    global File;

    if (isempty(File))
        return;
    end
    customize_gui;

function pinpoint_button_Callback(handles)
    global ch;
    global spectra;
    global N;
    global L;
    global M;
    global D;

    if (isempty(ch)) 
        return; 
    end
    spotview(ch,spectra,N,L,M,D,1);

function lookfor_button_Callback(handles)
    global ch;
    global spectra;
    global N;
    global L;
    global M;
    global D;

    if (isempty(ch)) 
        return; 
    end
    spotview(ch,spectra,N,L,M,D,5);

function last_button_Callback(handles)
    global slideEnable;
    global ch;
    global spectra;
    global N;
    global L;
    global M;
    global D;

    if (isempty(ch) || ~slideEnable) 
        return; 
    end
    spotview(ch,spectra,N,L,M,D,3);

function next_button_Callback(handles)
    global slideEnable;
    global ch;
    global spectra;
    global N;
    global L;
    global M;
    global D;

    if (isempty(ch) || ~slideEnable) 
        return; 
    end
    spotview(ch,spectra,N,L,M,D,4);

    