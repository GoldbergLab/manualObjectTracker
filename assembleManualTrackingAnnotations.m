function assembleManualTrackingAnnotations(videoDirectories, saveFilepath, topOrigin, topSize, botOrigin, botSize, topROINum, skipUnlabeled)
% Takes one or more video directories, searches each for an ROIs
%   subdirectory, identifies labeled frames, and assembles them into a
%   combined video file and ROI .mat file (and optionally a training set),
%   producing output identical in format to
%   assembleRandomManualTrackingAnnotations.
%
% This is intended for use when annotations were created in "normal" mode
%   (as opposed to pre-randomized mode), where a user manually browsed
%   videos and annotated frames without a pre-generated tracking list.
%
% videoDirectories:  A char array or cell array of char arrays, each
%                        containing a path to a directory that contains
%                        video files and an ROIs/ subdirectory with
%                        corresponding ROI .mat files.
% saveFilepath:      File path to use to save collected frames and ROI
%                        annotations. An extension is not required.
% topOrigin:         1x2 array of xy coordinates specifying the location
%                        of the top left corner of the top mask in video
%                        coordinates.
% topSize:           1x2 array representing the size of the top mask in
%                        pixels.
% botOrigin:         1x2 array of xy coordinates specifying the location
%                        of the top left corner of the bottom mask in video
%                        coordinates.
% botSize:           1x2 array representing the size of the bottom mask in
%                        pixels.
% topROINum:         Either 1 or 2 - which ROI number represents the top
%                        mask.
% skipUnlabeled:     Optional boolean flag indicating whether or not to
%                        skip frames that are unlabeled. Default is true.
%
% Written by Brian Kardon bmk27@cornell.edu 2018
% Modified 2026 to support normal-mode annotation assembly

if ~exist('topOrigin', 'var') || ~exist('topSize', 'var') || ~exist('botOrigin', 'var') || ~exist('botSize', 'var') || ~exist('topROINum', 'var')
    makeTrainingFile = false;
    fprintf('Mask information not provided - not creating final training file.\n');
else
    makeTrainingFile = true;
end

if ~exist('skipUnlabeled', 'var') || isempty(skipUnlabeled)
    skipUnlabeled = true;
end

% Normalize videoDirectories to a cell array
if ischar(videoDirectories)
    videoDirectories = {videoDirectories};
end

[saveFiledir, ~, ~] = fileparts(saveFilepath);
if ~exist(saveFiledir, 'dir') && ~isempty(saveFiledir)
    fprintf('Creating save file directory: %s\n', saveFiledir);
    mkdir(saveFiledir);
end

% Discover all ROI files across the provided directories
roiFiles = {};
videoFiles = {};
videoDirs = {};
for d = 1:length(videoDirectories)
    videoDir = videoDirectories{d};
    roiDir = fullfile(videoDir, 'ROIs');
    if ~exist(roiDir, 'dir')
        fprintf('Warning: No ROIs subdirectory found in %s, skipping.\n', videoDir);
        continue;
    end
    % Find all .mat files in the ROIs subdirectory
    matFiles = dir(fullfile(roiDir, '*_ROI.mat'));
    for f = 1:length(matFiles)
        roiFilePath = fullfile(roiDir, matFiles(f).name);
        % Load the ROI file to get the video filename
        a = load(roiFilePath, 'outputStruct');
        if ~isfield(a, 'outputStruct') || ~isfield(a.outputStruct, 'videoFile')
            fprintf('Warning: ROI file %s does not contain expected outputStruct.videoFile field, skipping.\n', roiFilePath);
            continue;
        end
        videoFilename = a.outputStruct.videoFile;
        videoFilePath = fullfile(videoDir, videoFilename);
        if ~exist(videoFilePath, 'file')
            % Legacy ROI files may lack a file extension - try to find a
            %   matching video file in the directory
            matches = dir(fullfile(videoDir, [videoFilename, '.*']));
            if isempty(matches)
                fprintf('Warning: Video file %s not found for ROI file %s, skipping.\n', videoFilePath, roiFilePath);
                continue;
            end
            videoFilename = matches(1).name;
            videoFilePath = fullfile(videoDir, videoFilename);
        end
        roiFiles{end+1} = roiFilePath; %#ok<AGROW>
        videoFiles{end+1} = videoFilePath; %#ok<AGROW>
        videoDirs{end+1} = videoDir; %#ok<AGROW>
    end
end

numVideos = length(roiFiles);
if numVideos == 0
    error('No valid ROI file / video file pairs found in the provided directories.');
end

% Get video dimensions from the first video
videoDataSize = loadVideoDataSize(videoFiles{1});
numROIs = 2;

% Initialize output data struct (same format as assembleRandomManualTrackingAnnotations)
outputStruct.videoFile = 'Assembled from various videos. See originalVideoPaths field for the video that corresponds to each frame';
outputStruct.ROIData = [];
outputStruct.manualObjectTrackerVersion = 'Assembled from various ROI files.';
outputStruct.originalFrameNumbers = [];
outputStruct.originalVideoPaths = {};

% Preallocate video data
selectedVideoData = zeros([videoDataSize(1:2), 1], 'uint8');
frameNumberCount = 0;
numFramesProcessed = 0;
numLabeledFrames = 0;

% Loop over each ROI file
for k = 1:numVideos
    roiFilePath = roiFiles{k};
    videoFilePath = videoFiles{k};
    [~, videoFilename, videoExt] = fileparts(videoFilePath);
    videoFilenameWithExt = [videoFilename, videoExt];

    fprintf('Processing ROI file %d of %d: %s\n', k, numVideos, roiFilePath);

    % Load ROI data
    a = load(roiFilePath);
    outputStructCurrent = a.outputStruct;
    usersCurrent = fieldnames(outputStructCurrent.ROIData);

    % Determine the number of frames in this ROI file
    sampleUser = usersCurrent{1};
    nFrames = size(outputStructCurrent.ROIData.(sampleUser).xFreehands, 2);
    numFramesProcessed = numFramesProcessed + nFrames;

    % Check what users are present in the current ROI data, and if they
    %   aren't present in the combined data, preallocate blank data for them
    for j = 1:length(usersCurrent)
        userCurrent = usersCurrent{j};
        if ~isfield(outputStruct.ROIData, userCurrent)
            outputStruct.ROIData.(userCurrent) = createNewUserROIData(1, numROIs);
        end
    end

    videoData = [];

    % Loop over every frame in this ROI file
    for frameNumber = 1:nFrames
        % Extract the ROI annotations for this frame
        labelingFound = false;
        for j = 1:numel(usersCurrent)
            user = usersCurrent{j};
            newXPoints{j} = outputStructCurrent.ROIData.(user).xPoints(:, frameNumber);
            newYPoints{j} = outputStructCurrent.ROIData.(user).yPoints(:, frameNumber);
            newXFreehands{j} = outputStructCurrent.ROIData.(user).xFreehands(:, frameNumber);
            newYFreehands{j} = outputStructCurrent.ROIData.(user).yFreehands(:, frameNumber);
            newAbsent{j} = outputStructCurrent.ROIData.(user).absent(:, frameNumber);

            % Check if there are any labels of any kind
            pointLabels = any(cellfun(@(x)~isempty(x), newXPoints{j}), 'all');
            freehandLabels = any(cellfun(@(x)~isempty(x), newXFreehands{j}), 'all');
            absentLabels = any(newAbsent{j}, 'all');
            labelingFound = labelingFound || pointLabels || freehandLabels || absentLabels;
        end

        % Update the count of how many frames were found to be labeled
        numLabeledFrames = numLabeledFrames + labelingFound;

        if skipUnlabeled && ~labelingFound
            continue;
        end

        % Store the extracted ROI data from the selected frame
        for j = 1:numel(usersCurrent)
            user = usersCurrent{j};
            outputStruct.ROIData.(user).xPoints(:,frameNumberCount+1) = newXPoints{j};
            outputStruct.ROIData.(user).yPoints(:,frameNumberCount+1) = newYPoints{j};
            outputStruct.ROIData.(user).xFreehands(:,frameNumberCount+1) = newXFreehands{j};
            outputStruct.ROIData.(user).yFreehands(:,frameNumberCount+1) = newYFreehands{j};
            outputStruct.ROIData.(user).absent(:,frameNumberCount+1) = newAbsent{j};
        end

        % Load video data lazily (only if we actually have labeled frames)
        if isempty(videoData)
            videoData = loadVideoData(videoFilePath);
        end

        % Extract selected frame from video and add it to the video data
        selectedVideoData(:, :, frameNumberCount+1) = videoData(:, :, frameNumber);

        % Update the originalFrameNumbers and originalVideoPaths fields
        outputStruct.originalFrameNumbers = [outputStruct.originalFrameNumbers, frameNumber];
        outputStruct.originalVideoPaths = [outputStruct.originalVideoPaths, videoFilenameWithExt];

        frameNumberCount = frameNumberCount + 1;
    end
end

fprintf('\n');
fprintf('Number of frames processed: %d\n', numFramesProcessed);
fprintf('Number of frames labeled:   %d\n', numLabeledFrames);
fprintf('\n');

if frameNumberCount == 0
    fprintf('No labeled frames found. No output files created.\n');
    return;
end

% Strip extension from saveFilename
[savePath, saveName, ~] = fileparts(saveFilepath);
saveFilepathBase = fullfile(savePath, saveName);

% Save selected video
assembledVideoPath = [saveFilepathBase, '.avi'];
saveVideoData(selectedVideoData, assembledVideoPath);

% Note the video size in the ROI struct
outputStruct.videoSize = size(selectedVideoData);

% Save selected ROI annotations
assembledROIPath = [saveFilepathBase, '_ROI.mat'];
save(assembledROIPath, 'outputStruct');

if makeTrainingFile
    % Save final training .mat file
    assembledTrainingPath = [saveFilepathBase, '_training.mat'];
    createSegmentationTrainingSet(assembledVideoPath, assembledROIPath, assembledTrainingPath, topOrigin, topSize, botOrigin, botSize, topROINum);
end

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
