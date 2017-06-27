function compare_gui(varargin)
    global Period;
    global slideEnable;
    global ch;
    global spectra;
    global N;
    global L;
    global D;
    
    if isempty(varargin)
        [file,chrom,spec] = loadfile;
        if (isempty(chrom))             % user aborted data selection
            return;
        else
            if (size(chrom)(2)>2)
                h = get(1,'userdata');
                if (isfield(h,'ions') && ~isempty(h.ions))
                    for i = 1 : length(h.ions),
                        chrom(:,i+3) = geteic(h.ions(i),chrom,spec)(:,2);
                    end
                    chrom(:,2) = sum(ch(:,4:length(h.ions)+3),2);
                end
            end
            [chrom,spec] = truncate(chrom,spec,ch(1,1),ch(end,1));
            
            if (Period>0)
                if (abs(ch(end,1)-chrom(end,1))>Period/60 || abs(ch(1,1)-chrom(1,1))>Period/60)
                    printf('Sorry, disparate 2D data cannot compare!\n');
                    return;
                else
                    nr = size(N)(1);
                    
                    handles = get(1,'userdata');
                    handles.N0 = N;
                    handles.N1 = N;
                    handles.A0 = ch(:,2)(N) - ones(nr,1)*min(ch(:,2)(N));
                    handles.A1 = chrom(:,2)(N) - ones(nr,1)*min(chrom(:,2)(N));
                    handles.D1 = [];
                    handles.D2 = [];
                    
                    set(1,'userdata',handles);
                end
            else
                compare1D(ch,chrom);
                return;
            end
        end
        slideEnable = 0;
      
        figure(3);clf;
        set(3,'color',[0.94,0.94,0.92]);
        handles = struct('figure3',gcf);
        sizefig(360,180);
    
        handles.file = file;
        handles.chrom = chrom;

        % create the other uicontrol objects in the figure
        confirm_button = uicontrol('style','pushbutton',...
            'parent',handles.figure3,'string','confirm',...
            'callback','compare_gui(''confirm_button_Callback'')',...
            'position',[130 140 100 20]);
        handles.confirm_button = confirm_button;
    
        current_button = uicontrol('style','radiobutton',...
            'parent',handles.figure3,'string','show current',...
            'max',1,'min',0,'value',0,'position',[60 10 100 20],...
            'callback','compare_gui(''current_button_Callback'')');
        handles.current_button = current_button;
        
        target_button = uicontrol('style','radiobutton',...
            'parent',handles.figure3,'string','show target',...
            'max',1,'min',0,'value',0,'position',[60 40 100 20],...
            'callback','compare_gui(''target_button_Callback'')');
        handles.target_button = target_button;

        difference_button = uicontrol('style','radiobutton',...
            'parent',handles.figure3,'string','show difference',...
            'max',1,'min',0,'value',1,'position',[60 70 110 20],...
            'tooltipstring','target - current',...
            'callback','compare_gui(''difference_button_Callback'')');
        handles.difference_button = difference_button;

        save_button = uicontrol('style','radiobutton',...
            'parent',handles.figure3,'string','save',...
            'max',1,'min',0,'value',0,'position',[60 100 100 20],...
            'callback','compare_gui(''save_button_Callback'')');
        handles.save_button = save_button;

        offset = uicontrol('style','edit','parent',handles.figure3,...
            'string','0','position',[190 63 50 20]);
        handles.offset = offset;
                
        text1 = uicontrol('style','text','parent',handles.figure3,...
            'string','offset to current','position',[245 65 120 20]);
        handles.text1 = text1;

        sensitivity = uicontrol('style','edit','parent',handles.figure3,...
            'string','5','position',[190 83 50 20]);
        handles.sensitivity = sensitivity;

        text2 = uicontrol('style','text','parent',handles.figure3,...
            'string','sensitivity (0~5)','position',[245 85 120 20]);
        handles.text2 = text2;

        set(gcf,'userdata',handles);
    else
        handles = get(3,'userdata');
        if ischar(varargin{1})
            feval(varargin{1},handles);
        end
    end

    

function confirm_button_Callback(handles)
    global ch;
    global spectra;
    global N;
    global L;
    global D;

    if (get(handles.current_button,'value'))
        pk = 1;
        params = 0;
    elseif (get(handles.target_button,'value'))
        pk = 2;
        params = 0;        
    elseif (get(handles.difference_button,'value'))
        pk = 3;
        offset = str2num(get(handles.offset,'string'));
        if (size(offset)(1)==0)
            offset = 0;
        end
        sensitivity = str2num(get(handles.sensitivity,'string'));
        if (size(sensitivity)(1)==0)
            sensitivity = 5;
        end
        params = [offset,sensitivity];
    elseif (get(handles.save_button,'value'))
        pk = 4;
        params = handles.file;        
    end
    
    chrom = handles.chrom;
    compare2D(ch,chrom,N,L,D,pk,params);

    
function current_button_Callback(handles)
    set(handles.current_button,'value',1);
    set(handles.target_button,'value',0);
    set(handles.difference_button,'value',0);
    set(handles.save_button,'value',0);

function target_button_Callback(handles)
    set(handles.current_button,'value',0);
    set(handles.target_button,'value',1);
    set(handles.difference_button,'value',0);
    set(handles.save_button,'value',0);

function difference_button_Callback(handles)
    set(handles.current_button,'value',0);
    set(handles.target_button,'value',0);
    set(handles.difference_button,'value',1);
    set(handles.save_button,'value',0);

function save_button_Callback(handles)
    set(handles.current_button,'value',0);
    set(handles.target_button,'value',0);
    set(handles.difference_button,'value',0);
    set(handles.save_button,'value',1);

    