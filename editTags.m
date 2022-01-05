function varargout = editTags(varargin)
% EDITTAGS MATLAB code for editTags.fig
%      EDITTAGS, by itself, creates a new EDITTAGS or raises the existing
%      singleton*.
%
%      H = EDITTAGS returns the handle to a new EDITTAGS or the handle to
%      the existing singleton*.
%
%      EDITTAGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITTAGS.M with the given input arguments.
%
%      EDITTAGS('Property','Value',...) creates a new EDITTAGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before editTags_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to editTags_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help editTags

% Last Modified by GUIDE v2.5 05-Jan-2022 11:37:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @editTags_OpeningFcn, ...
                   'gui_OutputFcn',  @editTags_OutputFcn, ...
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


% --- Executes just before editTags is made visible.
function editTags_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to editTags (see VARARGIN)

if length(varargin) == 0
    handles.oldTags = {};
else
    handles.oldTags = varargin{1};
end

if length(varargin) > 1
    handles.tagContext = varargin{2};
else
    handles.tagContext = '';
end

set(handles.infoText, 'String', handles.tagContext);

handles.newTags = handles.oldTags;

% Choose default command line output for editTags
handles.output = handles.oldTags;

% Populate existing tags listbox
handles = updateExistingTagsListbox(handles);

set(hObject, 'WindowKeyPressFcn', @handleKeyPress)

handles.returnPressed = false;

uicontrol(handles.newTagEntry);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes editTags wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = editTags_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

handles = guidata(hObject);
varargout{1} = handles.newTags;
delete(handles.figure1);

function handleKeyPress(hObject, EventData)
% Handle various key press events
handles = guidata(hObject);

handles.returnPressed = false;
switch EventData.Key
    case 'return'
        handles.returnPressed = true;
end

guidata(hObject, handles);


function newTagEntry_Callback(hObject, eventdata, handles)
% hObject    handle to newTagEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newTagEntry as text
%        str2double(get(hObject,'String')) returns contents of newTagEntry as a double

handles = guidata(hObject);
if handles.returnPressed
    handles = createTag(handles);
    guidata(hObject, handles);
    figure1_CloseRequestFcn(handles.figure1, [], handles);
end

% --- Executes during object creation, after setting all properties.
function newTagEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newTagEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = createTag(handles, newTag)
if ~exist('newTag', 'var') || isempty(newTag)
    newTag = get(handles.newTagEntry, 'String');
end

if ~isempty(newTag)
    if ~any(strcmp(newTag, handles.newTags))
        % Tag doesn't already exists
        % Add on new tag
        handles.newTags{end+1} = newTag;
        % Clear tag entry box
        set(handles.newTagEntry, 'String', '');
        % Update tag display
        handles = updateExistingTagsListbox(handles);
    end
end

% --- Executes on button press in createTagButton.
function createTagButton_Callback(hObject, eventdata, handles)
% hObject    handle to createTagButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = createTag(handles);
guidata(hObject, handles);

function handles = updateExistingTagsListbox(handles)
set(handles.existingTagsListbox, 'String', handles.newTags);
set(handles.existingTagsListbox, 'Value', 1);

function [selectedTags, selectedIndices] = getSelectedTags(handles)
contents = get(handles.existingTagsListbox, 'String');
if isempty(contents)
    selectedIndices = [];
    selectedTags = {};
else
    selectedIndices = get(handles.existingTagsListbox, 'Value');
    selectedTags = contents(selectedIndices);
end

% --- Executes on selection change in existingTagsListbox.
function existingTagsListbox_Callback(hObject, eventdata, handles)
% hObject    handle to existingTagsListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns existingTagsListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from existingTagsListbox


% --- Executes during object creation, after setting all properties.
function existingTagsListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to existingTagsListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in deleteSelectedTagsButton.
function deleteSelectedTagsButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteSelectedTagsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[~, selectedIndices] = getSelectedTags(handles);
handles.newTags(selectedIndices) = [];
handles = updateExistingTagsListbox(handles);
guidata(hObject, handles);

% --- Executes on button press in clearTagsButton.
function clearTagsButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearTagsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear tags
handles.newTags = {};

% Update listbox
handles = updateExistingTagsListbox(handles);

guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    uiresume(hObject);
else
    delete(hObject);
end


% --- Executes on button press in doneButton.
function doneButton_Callback(hObject, eventdata, handles)
% hObject    handle to doneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure1_CloseRequestFcn(handles.figure1, [], handles);