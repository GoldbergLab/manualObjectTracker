function varargout = generateRandomManualTrackingListGUI(varargin)
% GENERATERANDOMMANUALTRACKINGLISTGUI MATLAB code for generateRandomManualTrackingListGUI.fig
%      GENERATERANDOMMANUALTRACKINGLISTGUI, by itself, creates a new GENERATERANDOMMANUALTRACKINGLISTGUI or raises the existing
%      singleton*.
%
%      H = GENERATERANDOMMANUALTRACKINGLISTGUI returns the handle to a new GENERATERANDOMMANUALTRACKINGLISTGUI or the handle to
%      the existing singleton*.
%
%      GENERATERANDOMMANUALTRACKINGLISTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GENERATERANDOMMANUALTRACKINGLISTGUI.M with the given input arguments.
%
%      GENERATERANDOMMANUALTRACKINGLISTGUI('Property','Value',...) creates a new GENERATERANDOMMANUALTRACKINGLISTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before generateRandomManualTrackingListGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to generateRandomManualTrackingListGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help generateRandomManualTrackingListGUI

% Last Modified by GUIDE v2.5 24-Jun-2021 15:55:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @generateRandomManualTrackingListGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @generateRandomManualTrackingListGUI_OutputFcn, ...
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


% --- Executes just before generateRandomManualTrackingListGUI is made visible.
function generateRandomManualTrackingListGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to generateRandomManualTrackingListGUI (see VARARGIN)

% Choose default command line output for generateRandomManualTrackingListGUI
handles.output = struct.empty();

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes generateRandomManualTrackingListGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = generateRandomManualTrackingListGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.output)
    disp('Closed without running. Please press "RUN" to generate randomized clips.');
else
    % Actually run thingy
    generateRandomManualTrackingList(handles.output);
end

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);

% --- Executes on button press in videoRootDirectoryBrowseButton.
function videoRootDirectoryBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to videoRootDirectoryBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newDir = uigetdir('.', 'Choose directory in which to search for videos to select frames from.');
if newDir == 0
    return
end
currentDirs = get(handles.videoRootDirectories, 'String');
if isempty(currentDirs)
    currentDirs = {};
end
if ischar(currentDirs)
    currentDirs = {currentDirs};
end
if ~any(strcmp(currentDirs, newDir))
    currentDirs = [currentDirs; newDir];
    set(handles.videoRootDirectories, 'String', currentDirs);
    guidata(hObject, handles);
end

function videoRootDirectories_Callback(hObject, eventdata, handles)
% hObject    handle to videoRootDirectories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of videoRootDirectories as text
%        str2double(get(hObject,'String')) returns contents of videoRootDirectories as a double


% --- Executes during object creation, after setting all properties.
function videoRootDirectories_CreateFcn(hObject, eventdata, handles)
% hObject    handle to videoRootDirectories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function videoRegex_Callback(hObject, eventdata, handles)
% hObject    handle to videoRegex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of videoRegex as text
%        str2double(get(hObject,'String')) returns contents of videoRegex as a double


% --- Executes during object creation, after setting all properties.
function videoRegex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to videoRegex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function videoExtensions_Callback(hObject, eventdata, handles)
% hObject    handle to videoExtensions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of videoExtensions as text
%        str2double(get(hObject,'String')) returns contents of videoExtensions as a double


% --- Executes during object creation, after setting all properties.
function videoExtensions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to videoExtensions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numAnnotations_Callback(hObject, eventdata, handles)
% hObject    handle to numAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numAnnotations as text
%        str2double(get(hObject,'String')) returns contents of numAnnotations as a double


% --- Executes during object creation, after setting all properties.
function numAnnotations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function clipDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to clipDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clipDirectory as text
%        str2double(get(hObject,'String')) returns contents of clipDirectory as a double


% --- Executes during object creation, after setting all properties.
function clipDirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clipDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clipDirectoryBrowseButton.
function clipDirectoryBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to clipDirectoryBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newDir = uigetdir('.', 'Choose directory in which to save clip videos.');
if newDir == 0
    return
end
handles.clipDirectory.String = newDir;
guidata(hObject, handles);

function clipRadius_Callback(hObject, eventdata, handles)
% hObject    handle to clipRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clipRadius as text
%        str2double(get(hObject,'String')) returns contents of clipRadius as a double

% --- Executes during object creation, after setting all properties.
function clipRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clipRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function trialAlignment = getTrialAlignment(handles)
video = split2DCharArray(handles.videoAlignmentWithFPGA.String, @(row)str2double(row));
fpga =  split2DCharArray(handles.FPGAAlignmentWithVideo.String, @(row)str2double(row));
trialAlignment = struct();
for k = 1:min([length(video), length(fpga)])
    trialAlignment(k).fpgaStartingFrame = fpga(k);
    trialAlignment(k).videoStartingFrame = video(k);
end

function lickStructFilePaths = getLickStructFilePaths(handles)
lickStructFilePaths = split2DCharArray(handles.lickStructFilePaths.String);

function videoRootDirectories = getVideoRootDirectories(handles)
videoRootDirectories = split2DCharArray(handles.videoRootDirectories.String);

function arr = split2DCharArray(arr, rowConverter)
if ~exist('rowConverter', 'var')
    rowConverter = @(x){strtrim(x)};
end

% It's been output as a 2d space-padded char array eyeroll
numDirs = size(arr, 1);
newArr = cell([1, numDirs]);
for row = 1:numDirs
    if row == 1
        newArr = rowConverter(arr(row, :));
    else
        newArr(row) = rowConverter(arr(row, :));
    end
end
arr = newArr;

% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveFilename = 'randomizedAnnotationList.mat';

output = struct();
output.videoRootDirectories = getVideoRootDirectories(handles);
output.videoRegex = handles.videoRegex.String;
output.videoExtensions = handles.videoExtensions.String;
output.numAnnotations = str2double(handles.numAnnotations.String);
output.clipDirectory = handles.clipDirectory.String;
output.clipRadius = str2double(handles.clipRadius.String);
output.saveFilepath = fullfile(output.clipDirectory, saveFilename);

output.lickStructFilePaths = getLickStructFilePaths(handles);
output.trialAlignment = getTrialAlignment(handles);
output.weights.noTongue = str2double(handles.noTongueWeight.String);
output.weights.spoutContactTongue = str2double(handles.spoutContactWeight.String);
output.weights.noSpoutContactTongue = str2double(handles.tongueNoContactWeight.String);

handles.output = output;
guidata(hObject, handles);
figure1_CloseRequestFcn(handles.figure1, eventdata, handles)

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

function lickStructFilePaths_Callback(hObject, eventdata, handles)
% hObject    handle to lickStructFilePaths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lickStructFilePaths as text
%        str2double(get(hObject,'String')) returns contents of lickStructFilePaths as a double


% --- Executes during object creation, after setting all properties.
function lickStructFilePaths_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lickStructFilePaths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LickStructBrowseButton.
function LickStructBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to LickStructBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function videoAlignmentWithFPGA_Callback(hObject, eventdata, handles)
% hObject    handle to videoAlignmentWithFPGA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of videoAlignmentWithFPGA as text
%        str2double(get(hObject,'String')) returns contents of videoAlignmentWithFPGA as a double


% --- Executes during object creation, after setting all properties.
function videoAlignmentWithFPGA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to videoAlignmentWithFPGA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in alignFPGAWithVideoButton.
function alignFPGAWithVideoButton_Callback(hObject, eventdata, handles)
% hObject    handle to alignFPGAWithVideoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function FPGAAlignmentWithVideo_Callback(hObject, eventdata, handles)
% hObject    handle to FPGAAlignmentWithVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FPGAAlignmentWithVideo as text
%        str2double(get(hObject,'String')) returns contents of FPGAAlignmentWithVideo as a double


% --- Executes during object creation, after setting all properties.
function FPGAAlignmentWithVideo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FPGAAlignmentWithVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noTongueWeight_Callback(hObject, eventdata, handles)
% hObject    handle to noTongueWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noTongueWeight as text
%        str2double(get(hObject,'String')) returns contents of noTongueWeight as a double


% --- Executes during object creation, after setting all properties.
function noTongueWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noTongueWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spoutContactWeight_Callback(hObject, eventdata, handles)
% hObject    handle to spoutContactWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spoutContactWeight as text
%        str2double(get(hObject,'String')) returns contents of spoutContactWeight as a double


% --- Executes during object creation, after setting all properties.
function spoutContactWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spoutContactWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tongueNoContactWeight_Callback(hObject, eventdata, handles)
% hObject    handle to tongueNoContactWeightLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tongueNoContactWeightLabel as text
%        str2double(get(hObject,'String')) returns contents of tongueNoContactWeightLabel as a double


% --- Executes during object creation, after setting all properties.
function tongueNoContactWeightLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tongueNoContactWeightLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function tongueNoContactWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tongueNoContactWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
