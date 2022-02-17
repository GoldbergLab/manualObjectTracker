function varargout = assembleRandomManualTrackingAnnotationsGUI(varargin)
% ASSEMBLERANDOMMANUALTRACKINGANNOTATIONSGUI MATLAB code for assembleRandomManualTrackingAnnotationsGUI.fig
%      ASSEMBLERANDOMMANUALTRACKINGANNOTATIONSGUI, by itself, creates a new ASSEMBLERANDOMMANUALTRACKINGANNOTATIONSGUI or raises the existing
%      singleton*.
%
%      H = ASSEMBLERANDOMMANUALTRACKINGANNOTATIONSGUI returns the handle to a new ASSEMBLERANDOMMANUALTRACKINGANNOTATIONSGUI or the handle to
%      the existing singleton*.
%
%      ASSEMBLERANDOMMANUALTRACKINGANNOTATIONSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASSEMBLERANDOMMANUALTRACKINGANNOTATIONSGUI.M with the given input arguments.
%
%      ASSEMBLERANDOMMANUALTRACKINGANNOTATIONSGUI('Property','Value',...) creates a new ASSEMBLERANDOMMANUALTRACKINGANNOTATIONSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before assembleRandomManualTrackingAnnotationsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to assembleRandomManualTrackingAnnotationsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help assembleRandomManualTrackingAnnotationsGUI

% Last Modified by GUIDE v2.5 16-Feb-2022 14:26:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @assembleRandomManualTrackingAnnotationsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @assembleRandomManualTrackingAnnotationsGUI_OutputFcn, ...
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


% --- Executes just before assembleRandomManualTrackingAnnotationsGUI is made visible.
function assembleRandomManualTrackingAnnotationsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to assembleRandomManualTrackingAnnotationsGUI (see VARARGIN)

if length(varargin) == 1 && iscell(varargin{1})
    % Defaults have been passsed in
    varargin = varargin{1};

    if length(varargin) >= 1
        baseDirectory = varargin{1};
    else
        baseDirectory = '';
    end
    if length(varargin) >= 2
        saveFilepath = varargin{2};
    else
        saveFilepath = '';
    end
    if length(varargin) >= 3
        prerandomizedAnnotationFilepath = varargin{3};
    else
        prerandomizedAnnotationFilepath = '';
    end
    % Choose default command line output for assembleRandomManualTrackingAnnotationsGUI
    handles.output.prerandomizedAnnotationFilepath = prerandomizedAnnotationFilepath;
    handles.output.baseDirectory = baseDirectory;
    handles.output.saveFilepath = saveFilepath;

    % Set up default field values
    set(handles.baseDirectory, 'String', baseDirectory);
    set(handles.saveFilepath, 'String', saveFilepath);
else
    handles.output.prerandomizedAnnotationFilepath = '';
    handles.output.baseDirectory = '';
    handles.output.saveFilepath = '';
end

handles.output.complete = false;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes assembleRandomManualTrackingAnnotationsGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = assembleRandomManualTrackingAnnotationsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);

function baseDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to baseDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baseDirectory as text
%        str2double(get(hObject,'String')) returns contents of baseDirectory as a double


% --- Executes during object creation, after setting all properties.
function baseDirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in baseDirectoryBrowseButton.
function baseDirectoryBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to baseDirectoryBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newDir = uigetdir('.', 'Choose directory containing the videos, the ROI folder, and the prerandomized .mat file listing.');
if newDir == 0
    return
end
handles.baseDirectory.String = newDir;
guidata(hObject, handles);
% 
% function clipRadius_Callback(hObject, eventdata, handles)
% % hObject    handle to clipRadius (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of clipRadius as text
% %        str2double(get(hObject,'String')) returns contents of clipRadius as a double
% 
% % --- Executes during object creation, after setting all properties.
% function clipRadius_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to clipRadius (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 

% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output.baseDirectory = get(handles.baseDirectory, 'String');
handles.output.saveFilepath = get(handles.saveFilepath, 'String');
if isempty(handles.output.baseDirectory)
    warndlg('Please enter a directory in which to look for videos, ROI files, and random annotation listings.');
end
if isempty(handles.output.prerandomizedAnnotationFilepath)
    % Use default filepath for prerandomized annotation list
    defaultPrerandomizedAnnotationFilename = 'randomizedAnnotationList.mat';
    handles.output.prerandomizedAnnotationFilepath = fullfile(handles.output.baseDirectory, defaultPrerandomizedAnnotationFilename);
end
if handles.makeTrainingFileCheckbox.Value
    % We are making the final training file
    [topOrigin, topSize, botOrigin, botSize, topROINum] = getMaskParameters(handles);
    assembleRandomManualTrackingAnnotations( ...
        handles.output.prerandomizedAnnotationFilepath, ...
        handles.output.baseDirectory, ...
        handles.output.saveFilepath, ...
        topOrigin, topSize, botOrigin, botSize, topROINum);
else
    % We are not making the final training file
    assembleRandomManualTrackingAnnotations( ...
        handles.output.prerandomizedAnnotationFilepath, ...
        handles.output.baseDirectory, ...
        handles.output.saveFilepath);
end
handles.output.complete = true;
guidata(hObject, handles);
figure1_CloseRequestFcn(handles.figure1, eventdata, handles)

function [topOrigin, topSize, botOrigin, botSize, topROINum] = getMaskParameters(handles)
topSize = eval(handles.topMaskSize.String);
botSize = eval(handles.botMaskSize.String);
topOrigin = eval(handles.topMaskOrigin.String);
botOrigin = eval(handles.botMaskOrigin.String);
roiNums = cellstr(handles.topMaskROINum.String);
topROINum = str2double(roiNums{handles.topMaskROINum.Value});

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

function saveFilepath_Callback(hObject, eventdata, handles)
% hObject    handle to saveFilepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saveFilepath as text
%        str2double(get(hObject,'String')) returns contents of saveFilepath as a double


% --- Executes during object creation, after setting all properties.
function saveFilepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveFilepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in saveFilepathBrowseButton.
function saveFilepathBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveFilepathBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uiputfile('*.mat', 'Choose a filename to save ROI annotation file');
if all(file == 0) || all(path == 0)
    return;
end
filepath = fullfile(path, file);
handles.saveFilepath.String = filepath;
guidata(hObject, handles);

function substituteDriveLetter_Callback(hObject, eventdata, handles)
% hObject    handle to substituteDriveLetter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of substituteDriveLetter as text
%        str2double(get(hObject,'String')) returns contents of substituteDriveLetter as a double


% --- Executes during object creation, after setting all properties.
function substituteDriveLetter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to substituteDriveLetter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in helpButton.
function helpButton_Callback(hObject, eventdata, handles)
% hObject    handle to helpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function helpdialog(handles)
% Adapted from https://www.mathworks.com/help/matlab/ref/dialog.html
d = dialog('Position',[10 100 650 650],'Name','Manual Object Tracker help');
helpText = {
    ['manualObjectTracker version ', handles.version], ...
    '', ...
    'assembleRandomManualTrackingAnnotationsGUI is designed to take a set ', ...
    'of prerandomized, annotated videos, and assemble them into a single ', ...
    '.mat file containing images and masks, so they can be used to train', ...
    'a neural network to segment images.', ...
    '', ...
    'Directory to search for annotated videos:', ...
    '    The directory in which the prerandomized video clips are located, ', ...
    '    as well as the ROIs subfolder containing the annotations, and the ', ...
    '    prerandomized annotation listing .mat file', ...
    '', ...
    'Save filename for training data', ...
    '    Path at which the training data .mat file should be stored. This file', ...
    '    will contain the imageStack and maskStack attributes, which are each', ...
    '    3D arrays.', ...
    '', ...
    '  Written by Brian Kardon bmk27@cornell.edu 2018'...
    '', ...
    '', ...
    };
txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[20 -60 600 700],...
           'FontSize', 10,...
           'HorizontalAlignment', 'left',...
           'String',helpText,...
           'FontName','Courier');

btn = uicontrol('Parent',d,...
           'Position',[90 0 470 25],...
           'String','Close',...
           'Callback','delete(gcf)');

function handles = updateTrainingFileState(handles)
% Toggle whether or not the training file creation widgets are greyed out
% or not depending on the state of the 'make training file' checkbox.
if handles.makeTrainingFileCheckbox.Value
    enableState = 'on';
else
    enableState = 'off';
end

handles.topMaskOrigin.Enable = enableState;
handles.botMaskOrigin.Enable = enableState;
handles.topMaskSize.Enable = enableState;
handles.botMaskSize.Enable = enableState;
handles.topMaskROINum.Enable = enableState;

% --- Executes on button press in makeTrainingFileCheckbox.
function makeTrainingFileCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to makeTrainingFileCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of makeTrainingFileCheckbox
handles = updateTrainingFileState(handles);
guidata(hObject, handles);


function topMaskOrigin_Callback(hObject, eventdata, handles)
% hObject    handle to topMaskOrigin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of topMaskOrigin as text
%        str2double(get(hObject,'String')) returns contents of topMaskOrigin as a double


% --- Executes during object creation, after setting all properties.
function topMaskOrigin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to topMaskOrigin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function botMaskOrigin_Callback(hObject, eventdata, handles)
% hObject    handle to botMaskOrigin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of botMaskOrigin as text
%        str2double(get(hObject,'String')) returns contents of botMaskOrigin as a double


% --- Executes during object creation, after setting all properties.
function botMaskOrigin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to botMaskOrigin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function topMaskSize_Callback(hObject, eventdata, handles)
% hObject    handle to topMaskSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of topMaskSize as text
%        str2double(get(hObject,'String')) returns contents of topMaskSize as a double


% --- Executes during object creation, after setting all properties.
function topMaskSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to topMaskSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function botMaskSize_Callback(hObject, eventdata, handles)
% hObject    handle to botMaskSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of botMaskSize as text
%        str2double(get(hObject,'String')) returns contents of botMaskSize as a double


% --- Executes during object creation, after setting all properties.
function botMaskSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to botMaskSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in topMaskROINum.
function topMaskROINum_Callback(hObject, eventdata, handles)
% hObject    handle to topMaskROINum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns topMaskROINum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from topMaskROINum


% --- Executes during object creation, after setting all properties.
function topMaskROINum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to topMaskROINum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
