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

% Last Modified by GUIDE v2.5 02-Mar-2022 14:28:11

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
if isempty(handles.videoAlignmentWithFPGA.String)
    % We got nada.
    video = [];
    fpga = [];
else
    if ischar(handles.videoAlignmentWithFPGA.String)
        % We got a char array. This is either a single alignment number, or
        % a stupid 2D char array
        if isvector(handles.videoAlignmentWithFPGA.String)
            % It's a single
            video = str2double(handles.videoAlignmentWithFPGA.String);
        else
            % It's a stupid 2D char array
            video = split2DCharArray(handles.videoAlignmentWithFPGA.String, @(row)str2double(row));
        end
    else
        % We got a cell array
        video = cellfun(@str2double, handles.videoAlignmentWithFPGA.String);
    end
    if ischar(handles.FPGAAlignmentWithVideo.String)
        if isvector(handles.FPGAAlignmentWithVideo.String)
            fpga = str2double(handles.FPGAAlignmentWithVideo.String);
        else
            fpga = split2DCharArray(handles.FPGAAlignmentWithVideo.String, @(row)str2double(row));
        end
    else
        fpga = cellfun(@str2double, handles.FPGAAlignmentWithVideo.String);
    end
end
trialAlignment = struct();
for k = 1:min([length(video), length(fpga)])
    trialAlignment(k).fpgaStartingFrame = fpga(k);
    trialAlignment(k).videoStartingFrame = video(k);
end

function handles = setTrialAlignment(handles, trialAlignment)
if isempty(trialAlignment) || isempty(fieldnames(trialAlignment))
    return
end
videoStartingFrames = {};
fpgaStartingFrames = {};
for k = 1:length(trialAlignment)
    videoStartingFrames{k} = num2str(trialAlignment(k).videoStartingFrame);
    fpgaStartingFrames{k} = num2str(trialAlignment(k).fpgaStartingFrame);
end
handles.videoAlignmentWithFPGA.String = videoStartingFrames;
handles.FPGAAlignmentWithVideo.String = fpgaStartingFrames;

function weightingFilePaths = getWeightingFilePaths(handles)
if ischar(handles.weightingFilePaths.String) && ~isvector(handles.weightingFilePaths.String)
    weightingFilePaths = split2DCharArray(handles.weightingFilePaths.String);
else
    weightingFilePaths = handles.weightingFilePaths.String;
end
weightingFilePaths = strtrim(weightingFilePaths);

function handles = setWeightingFilePaths(handles, weightingFilePaths)
handles.weightingFilePaths.String = weightingFilePaths;

function videoRootDirectories = getVideoRootDirectories(handles)
if ischar(handles.videoRootDirectories.String) && ~isvector(handles.videoRootDirectories.String)
    % MATLAB is giving it to us as a 2D char array. Convert to cell array
    videoRootDirectories = split2DCharArray(handles.videoRootDirectories.String);
else
    % MATLAB is giving it to us as a cell array
    videoRootDirectories = handles.videoRootDirectories.String;
end
videoRootDirectories = strtrim(videoRootDirectories);

function handles = setVideoRootDirectories(handles, videoRootDirectories)
handles.videoRootDirectories.String = videoRootDirectories;

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

function params = gatherParams(handles)
saveFilename = 'randomizedAnnotationList.mat';

params = struct();
params.videoRootDirectories = getVideoRootDirectories(handles);
params.videoRegex = handles.videoRegex.String;
params.videoExtensions = handles.videoExtensions.String;
params.numAnnotations = str2double(handles.numAnnotations.String);
params.clipDirectory = handles.clipDirectory.String;
params.clipRadius = str2double(handles.clipRadius.String);
params.saveFilepath = fullfile(params.clipDirectory, saveFilename);

params.weightingFilePaths = getWeightingFilePaths(handles);
if handles.weightedRandomizationCheckbox.Value
    params.trialAlignment = getTrialAlignment(handles);
else
    params.trialAlignment = struct();
end
params.enableWeighting = handles.weightedRandomizationCheckbox.Value;
params.weights.noTongue = str2double(handles.noTongueWeight.String);
params.weights.spoutContactTongue = str2double(handles.spoutContactWeight.String);
params.weights.noSpoutContactTongue = str2double(handles.tongueNoContactWeight.String);
params.weights.smallTongue = str2double(handles.smallTongueWeight.String);
params.allVideosSameLength = handles.allVideosSameLength.Value;

function handles = loadParams(handles, params)
handles = setVideoRootDirectories(handles, params.videoRootDirectories);
handles.videoRegex.String = params.videoRegex;
handles.videoExtensions.String = params.videoExtensions;
handles.numAnnotations.String = num2str(params.numAnnotations);
handles.clipDirectory.String = params.clipDirectory;
handles.clipRadius.String = num2str(params.clipRadius);

handles.weightedRandomizationCheckbox.Value = params.enableWeighting;
handles = updateWeightedRandomizationState(handles, params.enableWeighting);

handles = setWeightingFilePaths(handles, params.weightingFilePaths);
handles = setTrialAlignment(handles, params.trialAlignment);

handles.noTongueWeight.String = num2str(params.weights.noTongue);
handles.spoutContactWeight.String = num2str(params.weights.spoutContactTongue);
handles.tongueNoContactWeight.String = num2str(params.weights.noSpoutContactTongue);
handles.smallTongueWeight.String = num2str(params.weights.smallTongue);

if ~isfield(params, 'allVideosSameLength')
    % Legacy file type
    params.allVideosSameLength = 1;
end
handles.allVideosSameLength.Value = params.allVideosSameLength;

if ~isfield(params, 'enableWeighting')
    % Legacy file type
    params.enableWeighting = 1;
end
handles.weightedRandomizationCheckbox.Value = params.enableWeighting;
handles = updateWeightedRandomizationState(handles, params.enableWeighting);

% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = gatherParams(handles);
handles.output = params;
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

function weightingFilePaths_Callback(hObject, eventdata, handles)
% hObject    handle to weightingFilePaths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of weightingFilePaths as text
%        str2double(get(hObject,'String')) returns contents of weightingFilePaths as a double


% --- Executes during object creation, after setting all properties.
function weightingFilePaths_CreateFcn(hObject, eventdata, handles)
% hObject    handle to weightingFilePaths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in WeightingFileBrowseButton.
function WeightingFileBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to WeightingFileBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[newFile, newDir] = uigetfile('*.mat', ['Locate a data file (lick_struct or t_stats) to add to the list for classifying frames and weighting their random selection.']);
disp(newFile)
disp(newDir)
if newFile == 0
    return
end
newPath = fullfile(newDir, newFile);
currentFiles = get(handles.weightingFilePaths, 'String');
if isempty(currentFiles)
    currentFiles = {};
end
if ischar(currentFiles)
    currentFiles = {currentFiles};
end
if ~any(strcmp(currentFiles, newPath))
    currentFiles = [currentFiles; newPath];
    set(handles.weightingFilePaths, 'String', currentFiles);
    guidata(hObject, handles);
end


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

videoRootDirectories = getVideoRootDirectories(handles);
FPGARootDirectories = getWeightingFilePaths(handles);

alignment = alignVideoAndFPGAData(videoRootDirectories, FPGARootDirectories);

if ~isempty(alignment)
    % Gotta change field names for legacy reasons.
    for k = 1:length(alignment)
        startingTrialNums(k).fpgaStartingFrame = alignment(k).FPGA;
        startingTrialNums(k).videoStartingFrame = alignment(k).Video;
    end

    handles = setTrialAlignment(handles, startingTrialNums);
end

guidata(hObject, handles);

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


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

params = gatherParams(handles);
[name, path] = uiputfile();
if ~isempty(name) || name == 0
    filepath = fullfile(path, name);
    save(filepath, 'params');
    fprintf('Saved params to file: %s\n', filepath); 
else
    disp('Cancelled - parameters were not saved.');
end

% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[name, path] = uigetfile();
if ~isempty(name) & name ~= 0
    filepath = fullfile(path, name);
    S = load(filepath);
    handles = loadParams(handles, S.params);
else
    disp('Cancelled - parameters not loaded.');
end
guidata(hObject, handles);

function handles = updateWeightedRandomizationState(handles, state)
if state
    enableState = 'on';
else
    enableState = 'off';
end
handles.weightingFilePaths.Enable = enableState;
handles.WeightingFileBrowseButton.Enable = enableState;
handles.alignFPGAWithVideoButton.Enable = enableState;
handles.FPGAAlignmentWithVideo.Enable = enableState;
handles.videoAlignmentWithFPGA.Enable = enableState;
handles.tongueNoContactWeight.Enable = enableState;
handles.smallTongueWeight.Enable = enableState;
handles.noTongueWeight.Enable = enableState;
handles.spoutContactWeight.Enable = enableState;

% --- Executes on button press in weightedRandomizationCheckbox.
function weightedRandomizationCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to weightedRandomizationCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of weightedRandomizationCheckbox
handles = updateWeightedRandomizationState(handles, handles.weightedRandomizationCheckbox.Value);
guidata(hObject, handles);


% --- Executes on button press in allVideosSameLength.
function allVideosSameLength_Callback(hObject, eventdata, handles)
% hObject    handle to allVideosSameLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of allVideosSameLength

function smallTongueWeight_Callback(hObject, eventdata, handles)
% hObject    handle to smallTongueWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smallTongueWeight as text
%        str2double(get(hObject,'String')) returns contents of smallTongueWeight as a double


% --- Executes during object creation, after setting all properties.
function smallTongueWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smallTongueWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in videoPathSwapButton.
function videoPathSwapButton_Callback(hObject, eventdata, handles)
% hObject    handle to videoPathSwapButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
newVideoRootDirectories = PathSwap(handles.videoRootDirectories.String);
if iscell(newVideoRootDirectories)
    handles.videoRootDirectories.String = newVideoRootDirectories;
end
guidata(hObject, handles);

% --- Executes on button press in dataPathSwapButton.
function dataPathSwapButton_Callback(hObject, eventdata, handles)
% hObject    handle to dataPathSwapButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
newWeightingFilePaths = PathSwap(handles.weightingFilePaths.String);
if iscell(newWeightingFilePaths)
    handles.weightingFilePaths.String = newWeightingFilePaths;
end
guidata(hObject, handles);
