function assembleRandomManualTrackingAnnotations(prerandomizedAnnotationFilepath, baseDirectory, saveFilepath, topOrigin, topSize, botOrigin, botSize, topROINum, skipUnlabeled)
% Takes a file containing video names and a corresponding random selection 
%   of frame numbers to annotate, and generates a video file composed of
%   the randomly selected frames, as well as an ROI .mat file composed of
%   the corresponding ROI annotations
%
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
% skipUnlabeled:                    Optional boolean flag indicating
%                                   whether or not to skip frames that are
%                                   unlabeled. Default is true.
%
% Written by Brian Kardon bmk27@cornell.edu 2018

if ~exist('topOrigin', 'var') || ~exist('topSize', 'var') || ~exist('botOrigin', 'var') || ~exist('botSize', 'var') || ~exist('topROINum', 'var')
    makeTrainingFile = false;
    fprintf('Mask information not provided - not creating final training file.\n');
else
    makeTrainingFile = true;
end

if ~exist('skipUnlabeled', 'var') || isempty(skipUnlabeled)
    skipUnlabeled = true;
end

[saveFiledir, ~, ~] = fileparts(saveFilepath);
if ~exist(saveFiledir, 'dir') && ~isempty(saveFiledir)
    fprintf('Creating save file directory: %s\n', saveFiledir)
    mkdir(saveFiledir);
end

% Load file containing list of video filepaths that were annotated
s = load(prerandomizedAnnotationFilepath);
manualTrackingList = s.manualTrackingList;

% DEBUG
% manualTrackingList = manualTrackingList(1:100);

% Retrieve information about the video files
numVideos = length(manualTrackingList);

% Num frames is the number of frames in the manual tracking list. However,
%   if "skipUnlabeled" is true, this may not be the number of frames in the
%   output files.
numFrames = sum(cellfun(@length, {manualTrackingList.frameNumbers}));

numLabeledFrames = 0;

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
outputStruct.ROIData = [];
outputStruct.manualObjectTrackerVersion = 'Assembled from various ROI files.';
outputStruct.originalFrameNumbers = [];
outputStruct.originalVideoPaths = {};

% Preallocate video data
selectedVideoData = zeros([videoDataSize(1:2), 1], 'uint8');
frameNumberCount = 0;

% Loop over each video
for k = 1:numVideos
    fprintf('Gathering info from video %d of %d\n', k, numVideos);
    frameNumbers = manualTrackingList(k).frameNumbers;
    videoFilename = manualTrackingList(k).videoFilename;
    videoFilepath = fullfile(manualTrackingList(k).videoPath, manualTrackingList(k).videoFilename);
    videoFilepath = switchDrive(videoFilepath, actualDrive, false);
    videoData = [];

    % Locate ROI file to load for this video
    ROIRegexp = translateVideoNameToROIRegexp(videoFilename);
    ROIFiles = findFilesByRegex(baseDirectory, ROIRegexp, false, 1);
    if isempty(ROIFiles)
        fprintf('Warning, no ROI file found for video %s\n', videoFilename);
        ROIFile = [];
        usersCurrent = {};
    else
        if length(ROIFiles) > 1
            fprintf('Warning, multiple ROI files matched video %s\n', videoFilename);
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
            outputStruct.ROIData.(userCurrent) = createNewUserROIData(1, numROIs);
        end
    end

    % Loop over the frames annoted in this video
    for frameNumber = frameNumbers
        % Extract the ROI annotations for the selected frame from the ROI file
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
            % If there are no labels of any kind, and the user requested
            %   that unlabeled frames not be included, don't record this 
            %   frame, just skip to the next one
            fprintf('    No labeling found - skipping frame %d\n', frameNumber);
            continue;
        end

        % Store the extracted ROI data from the selected frame
        for j = 1:numel(usersCurrent)
            outputStruct.ROIData.(user).xPoints(:,frameNumberCount+1) = newXPoints{j};
            outputStruct.ROIData.(user).yPoints(:,frameNumberCount+1) = newYPoints{j};
            outputStruct.ROIData.(user).xFreehands(:,frameNumberCount+1) = newXFreehands{j};
            outputStruct.ROIData.(user).yFreehands(:,frameNumberCount+1) = newYFreehands{j};
            outputStruct.ROIData.(user).absent(:,frameNumberCount+1) = newAbsent{j};
        end
    
        % Load video from current video filename if it hasn't been loaded
        % already
        if isempty(videoData)
            videoData = loadVideoData(videoFilepath);
        end
    
        % Extract selected frame from video and add it to the video data
        selectedVideoData(:, :, frameNumberCount+1) = videoData(:, :, frameNumber);

        % Update the originalFrameNumbers and originalVideoPaths fields with
        %   the new data
        outputStruct.originalFrameNumbers = [outputStruct.originalFrameNumbers, frameNumber];
        outputStruct.originalVideoPaths = [outputStruct.originalVideoPaths, videoFilename];

        frameNumberCount = frameNumberCount + 1;
    end
end

fprintf('\n')
fprintf('Number of frames processed: %d\n', numFrames);
fprintf('Number of frames labeled:   %d\n', numLabeledFrames);
fprintf('\n')

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
