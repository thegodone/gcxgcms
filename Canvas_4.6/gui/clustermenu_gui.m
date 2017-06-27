function clustermenu_gui(varargin)
    global File; 
    global DotOverlay;
    global Period;
    global slideEnable;
    global ch;
    global N;
    global L;
    global M;
    global D;
    
    if isempty(varargin)
        show2d(ch,N); 

        [R,exclude] = getclustercfg(File,'display',1);   % modified on 6/22/2016
        num = size(R)(2);
        Cluster = {};
        
        if (num>0)
            for i = 1 : num,
                if (exclude(i))
                    Cluster{i} = [];
                else
                    Cluster{i} = interior(R{i},D,2*Period/60,0.1);
                end
            end
        end

        h = get(2,'userdata');
        cstring = h.cstring;
        cnum = 1;
        for i = 1 : num,
            cnum = drawcluster(i,R{i},Cluster{i},cstring,cnum);
        end
        slideEnable = 0;

        figure(3);clf
        set(3,'color',[0.94,0.94,0.92]);
        handles = struct('figure3',gcf);
        sizefig(360,180);
 
        handles.R = R;
        handles.exclude = exclude;
        handles.Cluster = Cluster;
        handles.cnum = cnum;        
        handles.hide = zeros(num,1);
        handles.cstring = cstring;
   
        % create the other uicontrol objects in the figure
        confirm_button = uicontrol('style','pushbutton',...
            'parent',handles.figure3,'string','confirm',...
            'callback','clustermenu_gui(''confirm_button_Callback'')',...
            'position',[130 140 100 20]);
        handles.confirm_button = confirm_button;
    
        create_button = uicontrol('style','radiobutton',...
            'parent',handles.figure3,'string','create',...
            'max',1,'min',0,'value',0,'position',[30 10 100 20],...
            'callback','clustermenu_gui(''create_button_Callback'')');
        handles.create_button = create_button;
        
        exclude_checkbox = uicontrol('style','checkbox',...
            'parent',handles.figure3,'string','exclude',...
            'max',1,'min',0,'value',0,'position',[90 10 80 20]);
        handles.exclude_checkbox = exclude_checkbox;
        

        delete_button = uicontrol('style','radiobutton',...
            'parent',handles.figure3,'string','delete',...
            'max',1,'min',0,'value',0,'position',[30 40 100 20],...
            'callback','clustermenu_gui(''delete_button_Callback'')');
        handles.delete_button = delete_button;

        show_button = uicontrol('style','radiobutton',...
            'parent',handles.figure3,'string','show',...
            'max',1,'min',0,'value',0,'position',[30 70 100 20],...
            'callback','clustermenu_gui(''show_button_Callback'')');
        handles.show_button = show_button;

        edit1 = uicontrol('style','edit','parent',handles.figure3,...
            'string','','position',[90 38 60 20]);
        handles.edit1 = edit1;
                
        edit2 = uicontrol('style','edit','parent',handles.figure3,...
            'string','','position',[90 68 60 20]);
        handles.edit2 = edit2;


        save_button = uicontrol('style','radiobutton',...
            'parent',handles.figure3,'string','save',...
            'max',1,'min',0,'value',1,'position',[190 70 150 20],...
            'callback','clustermenu_gui(''save_button_Callback'')');
        handles.save_button = save_button;

        inter_button = uicontrol('style','radiobutton',...
            'parent',handles.figure3,'string','inter-ratio',...
            'max',1,'min',0,'value',0,'position',[190 10 150 20],...
            'callback','clustermenu_gui(''inter_button_Callback'')');
        handles.inter_button = inter_button;
        
        intra_button = uicontrol('style','radiobutton',...
            'parent',handles.figure3,'string','intra-ratio @      min',...
            'max',1,'min',0,'value',0,'position',[190 40 160 20],...
            'callback','clustermenu_gui(''intra_button_Callback'')');
        handles.intra_button = intra_button;
        
        edit3 = uicontrol('style','edit','parent',handles.figure3,...
            'string','','position',[290 38 30 20],'horizontalalignment','right');
        handles.edit3 = edit3;

        set(gcf,'userdata',handles);
    else
        handles = get(3,'userdata');
        if ischar(varargin{1})
            feval(varargin{1},handles);
        end
    end

    

function confirm_button_Callback(handles)
    global ch;
    global N;
    global L;
    global M;
    global D;

    if (get(handles.create_button,'value'))
        pk = 1;
        params = get(handles.exclude_checkbox,'value');
    elseif (get(handles.delete_button,'value'))
        pk = 2;
        params = str2num(get(handles.edit1,'string'));        
    elseif (get(handles.save_button,'value'))
        pk = 3;
        params = 1;
    elseif (get(handles.show_button,'value'))
        pk = 4;
        params = str2num(get(handles.edit2,'string'));        
    elseif (get(handles.inter_button,'value'))
        pk = 5;
        params = 1;
    elseif (get(handles.intra_button,'value'))
        pk = 6;
        params = str2num(get(handles.edit3,'string'));        
    end
    
    clustermenu(ch,N,L,M,D,pk,params);

    set(handles.edit1,'string','');
    set(handles.edit2,'string','');
    set(handles.edit3,'string','');

    
function create_button_Callback(handles)
    set(handles.create_button,'value',1);
    set(handles.delete_button,'value',0);
    set(handles.show_button,'value',0);
    set(handles.save_button,'value',0);
    set(handles.inter_button,'value',0);
    set(handles.intra_button,'value',0);

function delete_button_Callback(handles)
    set(handles.create_button,'value',0);
    set(handles.delete_button,'value',1);
    set(handles.show_button,'value',0);
    set(handles.save_button,'value',0);
    set(handles.inter_button,'value',0);
    set(handles.intra_button,'value',0);

function save_button_Callback(handles)
    set(handles.create_button,'value',0);
    set(handles.delete_button,'value',0);
    set(handles.show_button,'value',0);
    set(handles.save_button,'value',1);
    set(handles.inter_button,'value',0);
    set(handles.intra_button,'value',0);

function show_button_Callback(handles)
    set(handles.create_button,'value',0);
    set(handles.delete_button,'value',0);
    set(handles.show_button,'value',1);
    set(handles.save_button,'value',0);
    set(handles.inter_button,'value',0);
    set(handles.intra_button,'value',0);
    
function inter_button_Callback(handles)
    set(handles.create_button,'value',0);
    set(handles.delete_button,'value',0);
    set(handles.show_button,'value',0);
    set(handles.save_button,'value',0);
    set(handles.inter_button,'value',1);
    set(handles.intra_button,'value',0);

function intra_button_Callback(handles)
    set(handles.create_button,'value',0);
    set(handles.delete_button,'value',0);
    set(handles.show_button,'value',0);
    set(handles.save_button,'value',0);
    set(handles.inter_button,'value',0);
    set(handles.intra_button,'value',1);
    
    
    