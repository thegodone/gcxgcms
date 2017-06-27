function customize_gui(varargin)
global File;
global ch;
    
if isempty(varargin)
    file = File;
    if (size(ch)(2)>2) 
        h = get(1,'userdata');
        if (~isempty(h.ions))
            file = [File,filesep,num2str(h.ions(end))];
        end
    end
         
    figure(3);clf
    set(3,'color',[0.94,0.94,0.92]);
    handles = struct('figure3',gcf);
    sizefig(360,210);
    
    handles.file = file;
    % create the other uicontrol objects in the figure
    confirm_button = uicontrol('style','pushbutton',...
        'parent',handles.figure3,'string','confirm',...
        'callback','customize_gui(''confirm_button_Callback'')',...
        'position',[130 170 100 20]);
    handles.confirm_button = confirm_button;
    
    if (exist([File,filesep,'qual.csv'],'file'))
        qual_checkbox = uicontrol('style','checkbox',...
            'parent',handles.figure3,'string','qualitative table in qual.csv',...
            'max',1,'min',0,'value',0,'position',[80 20 220 20]);
        handles.qual_checkbox = qual_checkbox;
    end

    if (exist([file,filesep,'report.csv'],'file'))
        report_checkbox = uicontrol('style','checkbox',...
            'parent',handles.figure3,'string','all species in report.csv',...
            'max',1,'min',0,'value',0,'position',[80 50 220 20]);
        handles.report_checkbox = report_checkbox;
    end

    if (exist([file,filesep,'target.csv'],'file'))
        target_checkbox = uicontrol('style','checkbox',...
            'parent',handles.figure3,'string','target species in target.csv',...
            'max',1,'min',0,'value',0,'position',[80 80 220 20]);
        handles.target_checkbox = target_checkbox;
    end
    
    if (isempty(dir([file,filesep,'*.csv'])))
        mesg_text = uicontrol('style','text','parent',handles.figure3,...
                'string','No available reports found!','position',[110 50 220 20]);
        handles.mesg_text = mesg_text;
    end  

    set(gcf,'userdata',handles);
else
    handles = get(gcf,'userdata');
    if ischar(varargin{1})
        feval(varargin{1},handles);
    end
end

function confirm_button_Callback(handles)
global File;
    
if (isfield(handles,'report_checkbox') && get(handles.report_checkbox,'value'))
    system(['start excel "',handles.file,filesep,'report.csv"']); 
end
    
if (isfield(handles,'target_checkbox') && get(handles.target_checkbox,'value'))
    system(['start excel "',handles.file,filesep,'target.csv"']); 
end
    
if (isfield(handles,'qual_checkbox') && get(handles.qual_checkbox,'value'))
    system(['start excel "',File,filesep,'qual.csv"']); 
end
    
close(3);
    
    
    
    