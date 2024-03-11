function varargout = GUI_3D_BRAIN_VIEW(varargin)
% GUI_3D_BRAIN_VIEW MATLAB code for GUI_3D_BRAIN_VIEW.fig
%      GUI_3D_BRAIN_VIEW, by itself, creates a new GUI_3D_BRAIN_VIEW or raises the existing
%      singleton*.
%
%      H = GUI_3D_BRAIN_VIEW returns the handle to a new GUI_3D_BRAIN_VIEW or the handle to
%      the existing singleton*.
%
%      GUI_3D_BRAIN_VIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_3D_BRAIN_VIEW.M with the given input arguments.
%
%      GUI_3D_BRAIN_VIEW('Property','Value',...) creates a new GUI_3D_BRAIN_VIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_3D_BRAIN_VIEW_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_3D_BRAIN_VIEW_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_3D_BRAIN_VIEW

% Last Modified by GUIDE v2.5 20-May-2020 12:29:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_3D_BRAIN_VIEW_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_3D_BRAIN_VIEW_OutputFcn, ...
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


% --- Executes just before GUI_3D_BRAIN_VIEW is made visible.
function GUI_3D_BRAIN_VIEW_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;


axes(handles.map_3D);
handles.map_3D.XTick=[];
handles.map_3D.YTick=[];

% axes(handles.colorbar);
% handles.colorbar.XTick=[];
% handles.colorbar.YTick=[];

handles.min_T2.Value=0; %[ms]
handles.max_T2.Value=150; %[ms]

handles.colormap.String(1)={'parula'};
handles.colormap.String(2)={'gray'};
handles.colormap.String(3)={'jet'};
handles.colormap.String(4)={'hot'};
handles.colormap.String(5)={'bone'};
handles.colormap.String(6)={'summer'};

handles.curr_colormap='parula';
handles.curr_Plane = 'Axial';
set(handles.Slice_plane,'SelectedObject',handles.Axial_view);
handles.Seg_flag=0;
set(handles.Brain_segments,'SelectedObject',handles.Whole_brain);
handles.seg_choose.Enable='off';
set(handles.Added_segments, 'String', {'---'});


guidata(hObject, handles);


function varargout = GUI_3D_BRAIN_VIEW_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function map_3D_CreateFcn(hObject, eventdata, handles)


%% Load data (qT2_Arr & Seg_vol)

function RootDir_Callback(hObject, eventdata, handles)

function RootDir_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function search_dir_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
[FileName,PathName,FilterIndex] = uigetfile;
RootDir=[PathName FileName];
load (RootDir)
handles.RootDir.String=RootDir;
handles.qT2_Arr=qT2_Arr;
handles.Seg_Vol=Seg_vol;
for i=1:size(qT2_Arr,4)
handles.Scan_ID.String(i)={i};
end
guidata(hObject,handles);


function Scan_ID_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
curr_T2_map=handles.qT2_Arr;
handles.Whole_Brain_T2_map=curr_T2_map(:,:,:,handles.Scan_ID.Value);

disp ('Processing Data')

[handles.ROI_list, handles.Slice_labels , handles.T2_map_3D, handles.Seg_ROI_3D,...
    handles.ROI_list_small, handles.Slice_labels_small , handles.T2_map_3D_small,handles.Seg_ROI_3D_small]...
    = ROI_3D_collector (handles.Seg_Vol, handles.qT2_Arr, handles.Scan_ID.Value);

handles.curr_T2_map=handles.Whole_Brain_T2_map;
guidata(hObject,handles);

% Print 3D map
axes(handles.map_3D);
Print_3D_maps(handles.curr_T2_map, handles.curr_Plane);
caxis ([handles.min_T2.Value handles.max_T2.Value])
axis image
colorbar(handles.map_3D); 
% axes(handles.colorbar);
% axis off;

function Scan_ID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% 2D slices - Plane 

function Slice_plane_CreateFcn(hObject, eventdata, handles)

function Sagittal_view_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
handles.curr_Plane='Sagittal';
guidata(hObject,handles);

% Print 3D map
axes(handles.map_3D);
Print_3D_maps(handles.curr_T2_map, handles.curr_Plane);
caxis ([handles.min_T2.Value handles.max_T2.Value])
axis image
colorbar(handles.map_3D); 
% axes(handles.colorbar);
% axis off;

function Coronal_view_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
handles.curr_Plane='Coronal';
guidata(hObject,handles);

% Print 3D map
axes(handles.map_3D);
Print_3D_maps(handles.curr_T2_map, handles.curr_Plane);
caxis ([handles.min_T2.Value handles.max_T2.Value])
axis image
colorbar(handles.map_3D); 
% axes(handles.colorbar);
% axis off;

function Axial_view_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
handles.curr_Plane='Axial';
guidata(hObject,handles);

% Print 3D map
axes(handles.map_3D);
Print_3D_maps(handles.curr_T2_map, handles.curr_Plane);
caxis ([handles.min_T2.Value handles.max_T2.Value])
axis image
colorbar(handles.map_3D); 
% axes(handles.colorbar);
% axis off;

%% Brain segments
function Brain_segments_CreateFcn(hObject, eventdata, handles)

function Whole_brain_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
set(handles.seg_choose,'Enable', 'off');
if handles.Seg_flag
handles.curr_T2_map=handles.Seg_Vol;
else
handles.curr_T2_map=handles.Whole_Brain_T2_map;
end
guidata(hObject,handles);

% Print 3D map
axes(handles.map_3D);
Print_3D_maps(handles.curr_T2_map, handles.curr_Plane);
axis image
if handles.Seg_flag==0
caxis ([handles.min_T2.Value handles.max_T2.Value])
end
colorbar(handles.map_3D); 
% axes(handles.colorbar);
% axis off;

function Clear_maps_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
handles.curr_T2_map=zeros(size(handles.Seg_ROI_3D_small{1}));
set(handles.Added_segments, 'Enable', 'off');
set(handles.Added_segments, 'String', {'---'});
guidata(hObject,handles);

% Print 3D map
axes(handles.map_3D);
Print_3D_maps(handles.curr_T2_map, handles.curr_Plane);
axis image
colorbar(handles.map_3D); 
% axes(handles.colorbar);
% axis off;

axes(handles.Brain_window);
Print_3D_maps(zeros(size(handles.curr_T2_map)), handles.curr_Plane);
axis off
% set(handles.Brain_window, 'Visible', 'off')


% &&&&&&&&&&&&  show a single slice &&&&&&&&&&&&&&&&&7


function apply_seg_choose_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
handles.seg_choose.String=handles.Slice_labels_small;
set(handles.seg_choose,'Enable', 'on');
handles.curr_T2_map=zeros(size(handles.Seg_ROI_3D_small{1}));
guidata(hObject,handles);

function seg_choose_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
Seg_chro_idx=handles.seg_choose.Value;
if handles.Seg_flag
handles.curr_T2_map=handles.curr_T2_map+handles.Seg_ROI_3D_small{Seg_chro_idx};
handles.mean_T2.String='---';
handles.SD_T2.String='---';
handles.Nvox.String=handles.ROI_list_small(Seg_chro_idx,2);
else
handles.curr_T2_map=handles.curr_T2_map+handles.T2_map_3D_small{Seg_chro_idx};
handles.mean_T2.String=handles.ROI_list_small(Seg_chro_idx,3);
handles.mean_T2.String=handles.mean_T2.String(1:4);
handles.SD_T2.String=handles.ROI_list_small(Seg_chro_idx,4);
handles.SD_T2.String=handles.SD_T2.String(1:4);
handles.Nvox.String=handles.ROI_list_small(Seg_chro_idx,2);
handles.min_T2.Value=0;
% handles.max_T2.Value=max(max(max(handles.curr_T2_map)));
handles.max_T2.Value=2*mean(((handles.curr_T2_map(handles.curr_T2_map~=0))));
end
set(handles.Added_segments, 'Enable', 'on');
handles.Added_segments.String(end+1)={handles.Slice_labels_small(Seg_chro_idx)};
% set(Added_segments, 'String', 'on');

guidata(hObject,handles);

% Print 3D map
axes(handles.map_3D);
Print_3D_maps(handles.curr_T2_map, handles.curr_Plane);
axis image
if handles.Seg_flag==0
caxis ([handles.min_T2.Value handles.max_T2.Value])
end
colorbar(handles.map_3D); 
% axes(handles.colorbar);
% axis off;

function seg_choose_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Added_segments_Callback(hObject, eventdata, handles)

function Added_segments_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Brain_window_CreateFcn(hObject, eventdata, handles)
function Activate_Brain_window_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
% handles.curr_T2_map=handles.Whole_Brain_T2_map;
guidata(hObject,handles);

% Print 3D map
axes(handles.Brain_window);
if handles.Seg_flag==0 %T2 map
Print_3D_maps(handles.Whole_Brain_T2_map, handles.curr_Plane);
caxis ([handles.min_T2.Value handles.max_T2.Value])
else %Seg_vol
    Print_3D_maps(handles.Seg_Vol, handles.curr_Plane);
end
axis image
grid on
xticklabels({});
yticklabels({});
zticklabels({});


%% Visoalization

function min_T2_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
handles.min_T2.Value=(str2num(handles.min_T2.String));
guidata(hObject,handles);

% Print 3D map
axes(handles.map_3D);
Print_3D_maps(handles.curr_T2_map, handles.curr_Plane);
caxis ([handles.min_T2.Value handles.max_T2.Value])
axis image
colorbar(handles.map_3D); 
% axes(handles.colorbar);
% axis off;

function min_T2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function max_T2_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
handles.max_T2.Value=(str2num(handles.max_T2.String));
guidata(hObject,handles);

% Print 3D map
axes(handles.map_3D);
Print_3D_maps(handles.curr_T2_map, handles.curr_Plane);
caxis ([handles.min_T2.Value handles.max_T2.Value])
axis image
colorbar(handles.map_3D); 
% axes(handles.colorbar);
% axis off;

function max_T2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function colormap_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
Color=(handles.colormap.String{handles.colormap.Value});
handles.curr_colormap=Color;
guidata(hObject,handles);

colormap(handles.map_3D,Color)
colormap(handles.Brain_window,Color)

function colormap_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Rotate_Callback(hObject, eventdata, handles)
rotate3d on

function Zoom_Callback(hObject, eventdata, handles)
% handles = guidata(hObject);
% axes(handles.map_3D);
% zoomFactor = get(hObject,'Value');
zoom on
% guidata(hObject,handles);

function Stop_vis_Callback(hObject, eventdata, handles)
zoom off
rotate3d off





%% Map type

function T2_3D_map_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
handles.Seg_flag=0;
handles.curr_T2_map=handles.Whole_Brain_T2_map;
set(handles.Brain_segments,'SelectedObject',handles.Whole_brain);
set(handles.seg_choose,'Enable', 'off');
handles.max_T2.Enable='on';
handles.min_T2.Enable='on';
set(handles.Added_segments, 'Enable', 'off');
set(handles.Added_segments, 'String', {'---'});
guidata(hObject,handles);

% Print 3D map
axes(handles.map_3D);
Print_3D_maps(handles.curr_T2_map, handles.curr_Plane);
caxis ([handles.min_T2.Value handles.max_T2.Value])
axis image
colorbar(handles.map_3D); 
% axes(handles.colorbar);
% axis off;


function Seg_3D_map_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
handles.Seg_flag=1;
handles.curr_T2_map=handles.Seg_Vol;
set(handles.Brain_segments,'SelectedObject',handles.Whole_brain);
set(handles.seg_choose,'Enable', 'off');
handles.max_T2.Enable='off';
handles.min_T2.Enable='off';
set(handles.Added_segments, 'Enable', 'off');
set(handles.Added_segments, 'String', {'---'});
guidata(hObject,handles)

% Print 3D map - FS segments
axes(handles.map_3D);
Print_3D_maps(handles.curr_T2_map, handles.curr_Plane);
axis image
colorbar(handles.map_3D);

% axes(handles.colorbar);
% axis off;

%% Save & Load

function save_map_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
Curr_path=pwd;
Data_dir=find(handles.RootDir.String=='\');
Data_dir=handles.RootDir.String(1:Data_dir(end));
cd (Data_dir);
save ('Figure_3D', handles.map_3D)
cd (Curr_path);
guidata(hObject,handles)


function Load_map_Callback(hObject, eventdata, handles)


% --- Executes on button press in Print_xls.
function Print_xls_Callback(hObject, eventdata, handles)
% hObject    handle to Print_xls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Combined_seg.
function Combined_seg_Callback(hObject, eventdata, handles)
% hObject    handle to Combined_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Combined_seg


% --- Executes on button press in Left_seg.
function Left_seg_Callback(hObject, eventdata, handles)
% hObject    handle to Left_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Left_seg


% --- Executes on button press in Right_seg.
function Right_seg_Callback(hObject, eventdata, handles)
% hObject    handle to Right_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Right_seg
