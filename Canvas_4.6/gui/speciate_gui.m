function speciate_gui(varargin)
    global File; 
    global NISTroot;
    global NISTsecond;
    global ch;
    global spectra;
    global N;
    global L;
    global M;
    global D;
    

    if isempty(varargin)
         
        figure(3);clf
        set(3,'color',[0.94,0.94,0.92]);
        handles = struct('figure3',gcf);
        sizefig(360,180);
    
        % create the other uicontrol objects in the figure
        NoAsk = 0;
        if (size(ch)(2)>2)
            h = get(1,'userdata');
            if (isempty(h.ions))                               % TIC was selected
                if (~exist([File,filesep,'pks.dat'],'file'))
                    NoAsk = 1;
                end
            else                                               % some ions were selected
                if (~exist([File,filesep,num2str(h.ions(end))],'dir'))
                    NoAsk = 1;
                end
            end

            if (~isempty(NISTroot)  && isempty(h.ions) && size(D)(1)>0)        % NIST search only available to TIC
                nist_button = uicontrol('style','pushbutton',...
                    'parent',handles.figure3,'string','NIST search',...
                    'callback','speciate_gui(''nist_button_Callback'')',...
                    'position',[190 140 100 20]);
                handles.nist_button = nist_button;
                confirm_button_xpos = 70;
            else
                confirm_button_xpos = 130;
            end
        else
            if (~exist([File,filesep,'pks.dat'],'file'))
                NoAsk = 1;
            end
            
            if (length(dir('*.qgd')))>0                        % Shimadzu GCMS data found
                nist_button = uicontrol('style','pushbutton',...
                    'parent',handles.figure3,'string','register QGD',...
                    'callback','speciate_gui(''nist_button_Callback'')',...
                    'position',[190 140 100 20]);
                handles.nist_button = nist_button;
                confirm_button_xpos = 70;
            else
                confirm_button_xpos = 130;
            end
        end
        
        confirm_button = uicontrol('style','pushbutton',...
            'parent',handles.figure3,'string','recall',...
            'callback','speciate_gui(''confirm_button_Callback'')',...
            'position',[confirm_button_xpos 140 100 20]);
        handles.confirm_button = confirm_button;
    
        Mseg_checkbox = uicontrol('style','checkbox',...
            'parent',handles.figure3,'string','change pre-processing parameters',...
            'callback','speciate_gui(''Mseg_checkbox_Callback'')',...
            'max',1,'min',0,'value',NoAsk,'position',[80 20 220 20]);
        handles.Mseg_checkbox = Mseg_checkbox;

        exception_checkbox = uicontrol('style','checkbox',...
            'parent',handles.figure3,'string','change post-processing parameters',...
            'callback','speciate_gui(''exception_checkbox_Callback'')',...
            'max',1,'min',0,'position',[80 50 220 20]);
        handles.exception_checkbox = exception_checkbox;

        shift_checkbox = uicontrol('style','checkbox',...
            'parent',handles.figure3,'string','change in D2-shift, clusters, or',...
            'callback','speciate_gui(''shift_checkbox_Callback'')',...
            'max',1,'min',0,'position',[80 80 300 20]);
        handles.shift_checkbox = shift_checkbox;
        
        textline = uicontrol('style','text','parent',handles.figure3,...
            'string','qual.csv, etc.','position',[98 92 300 20]);
        handles.textline = textline;
        

        set(gcf,'userdata',handles);
        if (NoAsk)
            confirm_button_Callback(handles);
        end
    else
        handles = get(gcf,'userdata');
        if ischar(varargin{1})
            feval(varargin{1},handles);
        end
    end

function nist_button_Callback(handles)
    global File;
    global ch;
    global spectra;
    global L;
    global D;
    
    if (strcmp('on',get(handles.nist_button,'enable')))
        close(3);
        
        if (size(ch)(2)>2)
            printf('\n');
            if (exist([File,filesep,'qual.csv'],'file'))
                s = deblank(input('sure to update qual.csv? (y/n): ','s'));
                if (isempty(s) || strcmpi(s,'n'))
                    return;
                end
            end
            batchspectra(ch,L,spectra,D);
        else
            hackQGD(ch,L,D);
        end
    end
   

function confirm_button_Callback(handles)
    global File;
    global ch;
    global spectra;
    global N;
    global L;
    global M;
    global D;
    
    if (get(handles.Mseg_checkbox,'value'))
        sk = 1;
    elseif (get(handles.exception_checkbox,'value'))
        sk = 2;
    elseif (get(handles.shift_checkbox,'value'))
        sk = 3;
    else
        sk = 4;
    end
    close(3);

    disp('running speciation...');
    if (size(ch)(2)>2) % mass-spec data
        h = get(1,'userdata');
        n = length(h.ions);
        if (n>0)
            file = File;
            for i = 1 : n,
                File = [file,filesep,num2str(h.ions(i))];
                ch(:,2) = ch(:,i+3)+rand(size(ch)(1),1);        
                disp(['processing m/z=',num2str(h.ions(i)),' ...']);
                [L,M,D] = speciate(ch,N,[],[],sk);   % only L,M,D of last ion get retained
                disp(' ');
            end
            File = file;
            ch(:,2) = sum(ch(:,4:length(h.ions)+3),2);
            return;
        end
    end
            
    [L,M,D] = speciate(ch,N,L,M,sk);

function Mseg_checkbox_Callback(handles)
    global File;
    global ch;
    
    if (get(handles.Mseg_checkbox,'value'))
        file = File;
        if (size(ch)(2)>2) 
            h = get(1,'userdata');
            if (~isempty(h.ions))
                file = [File,filesep,num2str(h.ions(end))];
            end
        end
            
        currentpath = pwd;
        cd(file);
        if (exist('Mseg.txt','file'))
            edit Mseg.txt;
        end
        cd(currentpath);
        this_checked = 1;
    else
        this_checked = 0;
    end
    
    if (this_checked || get(handles.exception_checkbox,'value') || ...
        get(handles.shift_checkbox,'value'))
        set(handles.confirm_button,'string','confirm');
        if (isfield(handles,'nist_button'))
            set(handles.nist_button,'enable','off','position',[390 140 100 20]);
            set(handles.confirm_button,'position',[130 140 100 20]);
        end
    else
        set(handles.confirm_button,'string','recall');
        if (isfield(handles,'nist_button'))
            set(handles.nist_button,'enable','on','position',[190 140 100 20]);
            set(handles.confirm_button,'position',[70 140 100 20]);
        end
    end

function exception_checkbox_Callback(handles)
    global File;
    global ch;
    
    if (get(handles.exception_checkbox,'value'))
        file = File;
        if (size(ch)(2)>2) 
            h = get(1,'userdata');
            if (~isempty(h.ions))
                file = [File,filesep,num2str(h.ions(end))];
            end
        end
            
        currentpath = pwd;
        cd(file); 
        edit exception.txt;
        cd(currentpath);
        this_checked = 1;
    else
        this_checked = 0;
    end
    
    if (get(handles.Mseg_checkbox,'value') || this_checked || ...
        get(handles.shift_checkbox,'value'))
        set(handles.confirm_button,'string','confirm');
        if (isfield(handles,'nist_button'))
            set(handles.nist_button,'enable','off','position',[390 140 100 20]);
            set(handles.confirm_button,'position',[130 140 100 20]);
        end
    else
        set(handles.confirm_button,'string','recall');
        if (isfield(handles,'nist_button'))
            set(handles.nist_button,'enable','on','position',[190 140 100 20]);
            set(handles.confirm_button,'position',[70 140 100 20]);
        end
    end

function shift_checkbox_Callback(handles)
    if (get(handles.Mseg_checkbox,'value') || get(handles.exception_checkbox,'value') || ...
        get(handles.shift_checkbox,'value'))
        set(handles.confirm_button,'string','confirm');
        if (isfield(handles,'nist_button'))
            set(handles.nist_button,'enable','off','position',[390 140 100 20]);
            set(handles.confirm_button,'position',[130 140 100 20]);
        end
    else
        set(handles.confirm_button,'string','recall');
        if (isfield(handles,'nist_button'))
            set(handles.nist_button,'enable','on','position',[190 140 100 20]);
            set(handles.confirm_button,'position',[70 140 100 20]);
        end
    end


