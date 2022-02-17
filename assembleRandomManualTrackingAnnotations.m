function assembleRandomManualTrackingAnnotations(prerandomizedAnnotationFilepath, baseDirectory, saveFilepath, topOrigin, topSize, botOrigin, botSize, topROINum)
% Takes a file containing video names and a corresponding random selection 
%   of frame numbers to annotate, and generates a video file composed of
%   the randomly selected frames, as well as an ROI .mat file composed of
%   the corresponding ROI annotations

% prerandomizedAnnotationFilepath:  File containing randomized video and frame
%                                       number selections
% baseDirectory:                    Base directory in which to recursively search for videos
% saveFilepath:                     File path to use to save collected randomized
%                                       frames and ROI annotations. An
%                                       extension is not required.
% topOrigin:                        1x2 array of xy coordinates specifying
%                                   the location of the top left corner of 
%                                   the top mask in video coordinates.
% topSize:                          1x2 array representing the size of the
%                                   top mask in pixels
% botOrigin:                        1x2 array of xy coordinates specifying
%                                   the location of the top left corner of 
%                                   the bottom mask in video coordinates.
% botSize:                          1x2 array representing the size of the
%                                   bottom mask in pixels
% topROINum:                        Either 1 or 2 - which ROI number
%                                   represents the top mask.
%
% Written by Brian Kardon bmk27@cornell.edu 2018

if ~exist('topOrigin', 'var') || ~exist('topSize', 'var') || ~exist('botOrigin', 'var') || ~exist('botSize', 'var') || ~exist('topROINum', 'var')
    makeTrainingFile = false;
    fprintf('Mask information not provided - not creating final training file.\n');
else
    makeTrainingFile = true;
end

[saveFiledir, ~, ~] = fileparts(saveFilepath);
if ~exist(saveFiledir, 'dir')
    disp(['Creating save file directory: ', saveFiledir])
    mkdir(saveFiledir);
end

% Load file containing list of video filepaths that were annotated
s = load(prerandomizedAnnotationFilepath);
manualTrackingList = s.manualTrackingList;

% DEBUG
% manualTrackingList = manualTrackingList(1:100);

% Retrieve information about the video files
numVideos = length(manualTrackingList);
numFrames = sum(cellfun(@length, {manualTrackingList.frameNumbers}));

% In case videos are on a network drive and were annotated while the
% network drive was mounted under a different letter, swap out the drive
% letter for the one specified as the base directory:
actualDrive = getDrive(baseDirectory);
%recordedDrive = getDrive(manualTrackingList(1).videoPath);
sampleVideoPath = fullfile(manualTrackingList(1).videoPath, manualTrackingList(1).videoFilename);
sampleVideoPath = switchDrive(sampleVideoPath, actualDrive, false);

videoDataSize = loadVideoDataSize(sampleVideoPath);
numROIs = 2;

% Initialize output data struct
outputStruct.videoFile = 'Assembled from various videos. See originalVideoPaths field for the video that corresponds to each frame';
outputStruct.videoSize = [videoDataSize(1:2), numFrames];
outputStruct.ROIData = [];
outputStruct.manualObjectTrackerVersion = 'Assembled from various ROI files.';
outputStruct.originalFrameNumbers = [];
outputStruct.originalVideoPaths = {};

% Preallocate video data
selectedVideoData = zeros([videoDataSize(1:2), numFrames], 'uint8');
frameNumberCount = 0;

% Loop over each video
for k = 1:numVideos
    disp(['Gathering info from video ', num2str(k), ' of ', num2str(numVideos)]);
    frameNumbers = manualTrackingList(k).frameNumbers;
    videoFilename = manualTrackingList(k).videoFilename;
    videoFilepath = fullfile(manualTrackingList(k).videoPath, manualTrackingList(k).videoFilename);
    videoFilepath = switchDrive(videoFilepath, actualDrive, false);

    % Load video from current video filename
    videoData = loadVideoData(videoFilepath);

    % Extract selected frames from video and add them to the video data
    selectedVideoData(:, :, frameNumberCount+1:frameNumberCount+length(frameNumbers)) = videoData(:, :, frameNumbers);

    % Locate ROI file to load for this video
    ROIRegexp = translateVideoNameToROIRegexp(videoFilename);
    ROIFiles = findFilesByRegex(baseDirectory, ROIRegexp);
    if isempty(ROIFiles)
        disp(['Warning, no ROI file found for video', videoFilename])
        ROIFile = [];
        usersCurrent = {};
    else
        if length(ROIFiles) > 1
            disp(['Warning, multiple ROI files matched video', videoFilename])
        end
        ROIFile = ROIFiles{1};
        % Load current ROI data
        a = load(ROIFile);
        outputStructCurrent = a.outputStruct;
        usersCurrent = fields(outputStructCurrent.ROIData);
    end

    % Check what users are present in the current ROI data, and if they
    %   aren't present in the combined data, preallocate blank data for them
    for j = 1:length(usersCurrent)
        userCurrent = usersCurrent{j};
        if ~isfield(outputStruct.ROIData, userCurrent)
            outputStruct.ROIData.(userCurrent) = createNewUserROIData(numFrames, numROIs);
        end
    end

    % Update the originalFrameNumbers and originalVideoPaths fields with
    %   the new data
    outputStruct.originalFrameNumbers = [outputStruct.originalFrameNumbers, frameNumbers];
    outputStruct.originalVideoPaths = [outputStruct.originalVideoPaths, repmat(videoFilename, [1, length(frameNumbers)])];

    % Extract the ROI annotations for the selected frames from the ROI file
    for j = 1:numel(usersCurrent)
        user = usersCurrent{j};
        outputStruct.ROIData.(user).xPoints(:,frameNumberCount+1:frameNumberCount+length(frameNumbers)) = outputStructCurrent.ROIData.(user).xPoints(:, frameNumbers);
        outputStruct.ROIData.(user).yPoints(:,frameNumberCount+1:frameNumberCount+length(frameNumbers)) = outputStructCurrent.ROIData.(user).yPoints(:, frameNumbers);
        outputStruct.ROIData.(user).xFreehands(:,frameNumberCount+1:frameNumberCount+length(frameNumbers)) = outputStructCurrent.ROIData.(user).xFreehands(:, frameNumbers);
        outputStruct.ROIData.(user).yFreehands(:,frameNumberCount+1:frameNumberCount+length(frameNumbers)) = outputStructCurrent.ROIData.(user).yFreehands(:, frameNumbers);
        outputStruct.ROIData.(user).absent(:,frameNumberCount+1:frameNumberCount+length(frameNumbers)) = outputStructCurrent.ROIData.(user).absent(:, frameNumbers);
    end
    frameNumberCount = frameNumberCount + length(frameNumbers);
end

% Strip extension from saveFilename
[savePath, saveName, ~] = fileparts(saveFilepath);
saveFilepathBase = fullfile(savePath, saveName);

% Save selected video
assembledVideoPath = [saveFilepathBase, '.avi'];
saveVideoData(selectedVideoData, assembledVideoPath);
% Save selected ROI annotations
assembledROIPath = [saveFilepathBase, '_ROI.mat'];
save(assembledROIPath, 'outputStruct');

if makeTrainingFile
    % Save final training .mat file
    assembledTrainingPath = [saveFilepathBase, '_training.mat'];
    createSegmentationTrainingSet(assembledVideoPath, assembledROIPath, assembledTrainingPath, topOrigin, topSize, botOrigin, botSize, topROINum)
end

function ROIregexp = translateVideoNameToROIRegexp(videoFilename)
[~, vname, ~] = fileparts(videoFilename);
% Strip cue and laser info just in case
%vname = regexprep(vname, '(_C[0-9]+L?)', '');
ROIregexp = [regexptranslate('escape', vname), '.*\.mat'];

function userROIData = createNewUserROIData(numFrames, numROIs)
% Create blank data structures to hold user ROI data
[userROIData.xPoints, userROIData.yPoints] = createBlankROIs(numFrames, numROIs);
[userROIData.xFreehands, userROIData.yFreehands] = createBlankROIs(numFrames, numROIs);
[userROIData.xProj, userROIData.zProj] = createBlankROIs(numFrames, 1);
userROIData.absent = createBlankAbsentData(numFrames, numROIs);

function [x, y] = createBlankROIs(numFrames, numROIs)
% Create blank datastructure for holding a set of ROIs
if numFrames > 0
    x{numROIs, numFrames} = [];
    y{numROIs, numFrames} = [];
else
    x = {};
    y = {};
end

function blankAbsentData = createBlankAbsentData(numFrames, numROIs)
% Create blank datastructure for holding ROI absent data
if numFrames > 0
    blankAbsentData(numROIs, numFrames) = false;
else
    blankAbsentData = [];
end
