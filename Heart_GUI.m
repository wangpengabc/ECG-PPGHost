function varargout = Heart_GUI(varargin)
% HEART_GUI MATLAB code for Heart_GUI.fig
%      HEART_GUI, by itself, creates a new HEART_GUI or raises the existing
%      singleton*.
%
%      H = HEART_GUI returns the handle to a new HEART_GUI or the handle to
%      the existing singleton*.
%
%      HEART_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HEART_GUI.M with the given input arguments.
%
%      HEART_GUI('Property','Value',...) creates a new HEART_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Heart_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Heart_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Heart_GUI

% Last Modified by GUIDE v2.5 05-Dec-2018 14:22:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Heart_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Heart_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before Heart_GUI is made visible.
function Heart_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Heart_GUI (see VARARGIN)
global timer1;
global uart_taken;
global fs;
global fp;
global temp_data;
global temp_data1;
global h_figure;
global h_figure1;

% Choose default command line output for Heart_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using Heart_GUI.

com_number=0;
comlist='NO COM'
for n=1:25
    com_name=sprintf('COM%d',n);
    disp('scaning comport.')
    disp(com_name)
    fs=serial(com_name);
    valid=1;
    try
        fopen(fs);
    catch exception
        valid=0;
    end    % end tr
    if valid==1
        fclose(fs);
        for tl=length(com_name)+1:6
            com_name(tl)=' ';
        end
        if com_number==0
            comlist=com_name;
        else
            comlist=[comlist;com_name];
        end
        com_number=com_number+1;
    end
end
set(handles.p_com, 'String', comlist);
timer1=timer('StartDelay', 1, 'Period',0.2, 'ExecutionMode', 'fixedRate');
timer1.TimerFcn = {@timer_callback, handles};
stop(timer1);
uart_taken=0;
set(handles.p_start,'Enable','on');
set(handles.p_stop,'Enable','off');
temp_data=zeros(1,1500);
temp_data1=zeros(1,1500);
axes(handles.axes1);
cla;

h_figure=plot(temp_data);

axes(handles.axes1);hold on;
axis([0 1500 -1000 5000])

axes(handles.axes2);
cla;

h_figure1=plot(temp_data1);

axes(handles.axes2);hold on;
axis([0 1500 0 5000])








% UIWAIT makes Heart_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Heart_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in p_start.
function p_start_Callback(hObject, eventdata, handles)
% hObject    handle to p_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timer1;
global uart_taken;
global fs;
global fp;
global temp_data;
global temp_data1;
global data_length;
global h_figure;
global h_figure1;
global find_index;
set(hObject,'Enable','off');
com_names=get(handles.p_com, 'String');
com_value=get(handles.p_com, 'Value');
com_name=com_names(com_value,:);
for n=2:length(com_name)
    if com_name(n)==' '
        break;
    end
end
com_name=com_name(1:n-1);
if fs.Status(1)=='o'
    uart_taken=0;
    fclose(fs);
    fclose(fp);
end
filename=datestr(clock);
for n=1:length(filename)
    if filename(n)=='-' || filename(n)==':' || filename(n)==' '
        filename(n)='_';
    end
end
filename=['HEART_',filename,'.txt'];
fp=fopen(filename,'w');
fs=serial(com_name,'BaudRate',115200,'InputBufferSize',2^18,'OutputBufferSize',2^18,'Timeout',7);
fopen(fs);
uart_taken=1;
find_index=1;
start(timer1);
set(handles.p_stop,'Enable','on');


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in p_com.
function p_com_Callback(hObject, eventdata, handles)
% hObject    handle to p_com (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns p_com contents as cell array
%        contents{get(hObject,'Value')} returns selected item from p_com


% --- Executes during object creation, after setting all properties.
function p_com_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_com (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in p_stop.
function p_stop_Callback(hObject, eventdata, handles)
% hObject    handle to p_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timer1;
global uart_taken;
global fs;
global fp;
set(handles.p_stop,'Enable','off');
uart_taken=0;
fclose(fs);
fclose(fp);
stop(timer1);
set(handles.p_start,'Enable','on');

function timer_callback(obj, event, handles)
global timer1;
global uart_taken;
global fs;
global fp;
global temp_data;
global temp_data1;
global data_length;
global h_figure;
global h_figure1;
global find_index;

if fs.Status(1)=='o'
    if find_index ~=0 
        while fs.BytesAvailable>0
            buf=fread(fs,[1,1],'uint8');
            if buf ==hex2dec('AA');
                buf=fread(fs,[1,7],'uint8');
                find_index=0;
                break;
            end
        end
    end
end
if fs.Status(1)=='o'
    if fs.BytesAvailable>8
        len=floor(fs.BytesAvailable/8);
        temp=fread(fs,[1,len*8],'uint8');
        temp2=zeros(1,len);
        temp3=zeros(1,len);
        for n=1:len
            temp2(n)=temp((n-1)*8+4)*256+temp((n-1)*8+3);
            temp3(n)=temp((n-1)*8+6)*256+temp((n-1)*8+5);
        end
        fprintf(fp,'%d,%d\r\n',temp2,temp3);
        if len>=1500
            temp_data=temp2(end-1499:end);
            temp_data1=temp3(end-1499:end);
        else
            temp_data=[temp_data(1+len:end),temp2];
            temp_data1=[temp_data1(1+len:end),temp3];
        end
        axes(handles.axes1);
        set(h_figure,'YData',temp_data,'Color','red');
        axes(handles.axes2);
        set(h_figure1,'YData',temp_data1,'Color','blue');
    end
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fs;
global fp;
fclose(fs);
fclose(fp);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
