function manualTrackingList = generateRandomManualTrackingList(videoBaseDirectoriesOrStruct, videoRegex, extensions, numAnnotations, saveFilepath, clipDirectory, clipRadius)
% Searches videoBaseDirectories for videos that match the
%   videoRegex and extensions, and generates a file containing
%   video names and a corresponding random selection of frame numbers to annotate.
% Arguments:
% videoBaseDirectoriesOrStruct: A char array representing a base directory 
%                                   in which to search for videos, 
%                                   OR
%                               A cell array of char arrays represeting
%                                   multiple base directories to search.
%                                   OR
%                               A struct containing all the arguments as
%                                   fields (for convenience from corresponding
%                                   GUI output)
% videoRegex:                   A char array representing a regular expression to use to select video files
%                                   OR 
%                               number indicating how many random videos to select from the directory 
%                                   OR
%                               0 to use all the videos found
% extensions:                   A char array containing a file extension (ex:
%                                   '.avi') or a cell array of char arrays
%                                   containing file extensions.
% numAnnotations:               Total number of random frame numbers to pick from the pool of videos
% saveFilepath:                 File path in which to save annotation data
% clipDirectory (optional):     A directory to save video clips around each frame
% clipRadius (optional):        The # of frames on either side of selected
%                                   frame to include in the clip. Default = 10
%
% Returns:
% manualTrackingList:           The list of video filenames and frame numbers
%                                   that is both returned and saved to file
if isstruct(videoBaseDirectoriesOrStruct)
    p = videoBaseDirectoriesOrStruct;
    % 1st argument is actually a struct containing all the arguments
    videoBaseDirectories = p.videoRootDirectories;
    videoRegex = p.videoRegex;
    extensions = p.videoExtensions;
    numAnnotations = p.numAnnotations;
    saveFilepath = p.saveFilepath;
    clipDirectory = p.clipDirectory;
    clipRadius = p.clipRadius;

    lickStructFilePaths = p.lickStructFilePaths;
    trialAlignment = p.trialAlignment;
    weights = p.weights;
end

if ~exist('clipDirectory', 'var')
    clipDirectory = '';
end
if ~exist('clipRadius', 'var')
    clipRadius = 10;
end

if ischar(videoBaseDirectories)
    videoBaseDirectories = {videoBaseDirectories};
end
if ischar(lickStructFilePaths)
    lickStructFilePaths = {lickStructFilePaths};
end

plotFlag = true;

periContactTongueFrameMargin = 50;

% Find files that match extension and regex
disp('Finding matching files with correct extension...');
videoFilePaths = cellfun(@(videoBaseDirectory)findFilesByExtension(videoBaseDirectory, extensions, false), videoBaseDirectories, 'UniformOutput', false);
lickStructs = cellfun(@(lickStructFilePath)load(lickStructFilePath), lickStructFilePaths, 'UniformOutput', true);

if isempty(videoFilePaths)
    disp(strjoin([{'Warning, no files found for video identifier'}, extensions], ' '))
end

% Trim lick_struct and video list starts so they start on the corresponding
% trial (as identified by user) and ends so they have the same # of
% elements
numSessions = min([length(videoFilePaths), length(lickStructFilePaths), length(trialAlignment)]);
for videoNum = 1:numSessions
    videoFilePaths{videoNum} = videoFilePaths{videoNum}(trialAlignment(videoNum).videoStartingFrame:end);
    lickStructs(videoNum).lick_struct = lickStructs(videoNum).lick_struct(trialAlignment(videoNum).fpgaStartingFrame:end);

    numTrials = min([length(videoFilePaths{videoNum}), length(lickStructs(videoNum).lick_struct)]);
    videoFilePaths{videoNum} = videoFilePaths{videoNum}(1:numTrials);
    lickStructs(videoNum).lick_struct = lickStructs(videoNum).lick_struct(1:numTrials);
end

% Concatenate video paths and lick structs into one long list
videoFilePaths = horzcat(videoFilePaths{:});
lick_struct = horzcat(lickStructs.lick_struct);

% Add in spout contact onset/offsets:
lick_struct = getContactDur(lick_struct);

if length(videoFilePaths) ~= length(lick_struct)
    error('Failed to match up lick_struct rows and video paths.');
end

if ischar(videoRegex)
    % Find files that match one or more of the videoRegex
    regexFilterIdx = 1:length(videoFilePaths);
    regexFilterIdx = regexFilterIdx(~cellfun(@isempty, regexp(videoFilePaths, videoRegex)));
    videoFilePaths = videoFilePaths(regexFilterIdx);
    lick_struct = lick_struct(regexFilterIdx);
elseif isnumeric(videoRegex)
    % Number rather than regex is passed as videoRegex
    sampleNum = videoRegex;
    if sampleNum > 0
        % If number is not 0, randomly sample that # of videos and lick
        % struct trials
        [videoFilePaths, randomIdx] = datasample(videoFilePaths, sampleNum, 'Replace',false);
        lick_struct = lick_struct(randomIdx);
    end
else
    error('Warning, invalid videoRegex provided.');
end
disp(['...done. Found ', num2str(length(videoFilePaths)), ' files.']);

% Determine the length of (# of frames in) each video
disp('Determining video lengths...');
videoLengths = zeros(1, length(videoFilePaths));

invalidIndices = [];
for videoNum = 1:length(videoFilePaths)
    disp(['Determining length of video #', num2str(videoNum), ' of ', num2str(length(videoFilePaths))])
    videoFilePath = videoFilePaths{videoNum};
    try
        videoSize = loadVideoDataSize(videoFilePath);
        if videoSize(3) <= 2*clipRadius
            invalidIndices(end+1) = videoNum;
        end
    catch ME
        invalidIndices(end+1) = videoNum;
    end
    videoLengths(videoNum) = videoSize(3); % - 2*clipRadius;
end

if ~isempty(invalidIndices)
    disp(['Warning: Could not find any readable data for the following ', num2str(length(invalidIndices)), ' videos:']);
    disp(videoFilePaths(invalidIndices)');
    videoLengths(invalidIndices) = [];
    videoFilePaths(invalidIndices) = [];
    lick_struct(invalidIndices) = [];
end
if isempty(videoFilePaths)
    error('Error - no valid videos found with those parameters. Check the root directory, try changing the file regex, and make sure the extension is valid - it should include a ''.''.')
end

fprintf('Getting cue times...\n');
defaultCueTime = 1001;
cueTimes = [];
for videoNum = 1:length(videoFilePaths)
    videoName = videoFilePaths{videoNum};
    out = regexp(videoName, '_C([0-9]+)L?\.[aA][vV][iI]$', 'tokens');
    try
        cueTimes(videoNum) = str2double(out{1}{1});
    catch ME
        warning('Could not determine cue time for video %s based on filename. Defaulting to %d.', videoName, defaultCueTime);
        cueTimes(videoNum) = defaultCueTime;
    end
end

frameTypes = fieldnames(weights);
frameTypeIndices = 1:length(frameTypes);
% Calculate cumulative weight for each frame type
totalWeight = 0;
for videoNum = frameTypeIndices
    frameType = frameTypes{videoNum};
    totalWeight = totalWeight + weights.(frameType);
end
for videoNum = frameTypeIndices
    frameType = frameTypes{videoNum};
    weights.(frameType) = weights.(frameType) / totalWeight;
end

getSpoutPos = @(ML, AP)ML+1i*AP;

% Create list of unique spout target positions as complex numbers
spoutTargets = unique(getSpoutPos([lick_struct.actuator1_ML]', [lick_struct.actuator2_AP]'));
if length(spoutTargets) ~= 3
    warning('Expected 3 spout positions, instead found %d.', length(spoutTargets));
end

% Create corresponding vectors of video numbers, frame numbers, etc
numFrames = sum(videoLengths);
overallIdx = 1:numFrames;
frameIdx = zeros(1, numFrames);
videoIdx = zeros(1, numFrames);

tongueTypeMasks.spoutContactTongue = zeros(1, numFrames, 'logical');
tongueTypeMasks.noSpoutContactTongue = zeros(1, numFrames, 'logical');
tongueTypeMasks.noTongue = zeros(1, numFrames, 'logical');
spoutPos = nan(1, numFrames);
startFrame = 1;
for videoNum = 1:length(videoFilePaths)
    yes = ones(1, videoLengths(videoNum));
    no = zeros(1, videoLengths(videoNum));
    mu = nan(1, videoLengths(videoNum));
    
    idx = 1:videoLengths(videoNum);
    currentSpoutPos = getSpoutPos(lick_struct(videoNum).actuator1_ML_command, lick_struct(videoNum).actuator2_AP_command);
    currentSpoutPos = [currentSpoutPos(1)*ones(1, cueTimes(videoNum)), currentSpoutPos];
    currentSpoutPos = [currentSpoutPos, currentSpoutPos(end)*ones(1, videoLengths(videoNum) - length(currentSpoutPos))];
    currentSpoutIdx = mu;  % Vector containing the spout target number for each frame.
    for p = 1:length(spoutTargets)
        currentSpoutIdx(currentSpoutPos == spoutTargets(p)) = p;
    end
    if any(isnan(currentSpoutPos))
        badPos = unique(currentSpoutPos(isnan(currentSpoutIdx)));
        error('Could not find some of this trial''s spout positions in list - %s. Something went wrong.', num2str(badPos));
    end

    endFrame = startFrame + videoLengths(videoNum) - 1;
    spoutPos(startFrame:endFrame) = currentSpoutIdx;
    videoIdx(startFrame:endFrame) = videoNum * yes;
    frameIdx(startFrame:endFrame) = idx;
    
    for spoutContactNum = 1:length(lick_struct(videoNum).sp_contact_onset)
        onset = lick_struct(videoNum).sp_contact_onset(spoutContactNum) + cueTimes(videoNum);
        offset = lick_struct(videoNum).sp_contact_offset(spoutContactNum) + cueTimes(videoNum);
        tongueTypeMasks.noSpoutContactTongue(startFrame:endFrame) = ...
            (((onset - idx) < periContactTongueFrameMargin) & ((onset - idx) > 0)) | ...
            (((idx - offset) < periContactTongueFrameMargin) & ((idx - offset > 0)));
        tongueTypeMasks.spoutContactTongue(startFrame:endFrame) = ...
            ((idx - onset) >= 0) & ((offset - idx) >= 0);
        tongueTypeMasks.noTongue = ~tongueTypeMasks.noSpoutContactTongue & ~tongueTypeMasks.spoutContactTongue;
    end
    
    startFrame = endFrame + 1;
end

% Determine how many frame types we're balancing the randomization across
numGroups = length(spoutTargets) * 3; % (spout L, spout C, spout R) x (tongue w/o contact, tongue w/ contact, no tongue)
groupSize = numAnnotations/numGroups;
tongueTypes = fieldnames(tongueTypeMasks);
numTongueTypes = length(tongueTypes);

chosenIdx = [];

% Pick random frame numbers, balanced by frame type according to weights
for spoutIdx = 1:length(spoutTargets)
    for tongueTypeIdx = 1:numTongueTypes
        % get tongue type of this group (no tongue / no contact tongue / tongue with spout contact
        tongueType = tongueTypes{tongueTypeIdx};
        % Determine size of this group based on weights
        groupSize = round(groupSize * weights.(tongueType) * numTongueTypes);
        % Create mask for which indices satisfy this group's criteria
        groupMask = (spoutPos == spoutIdx) & tongueTypeMasks.(tongueType);
        % Map mask onto actual indices for this group
        groupIdx = overallIdx(groupMask);
        % Choose a random subset of this group's indices
        newChosenIdx = datasample(groupIdx, groupSize, 'Replace', false);
        % Add on to previous group's chosen indices
        chosenIdx = [chosenIdx, newChosenIdx];
    end
end
% Due to rounding errors, we don't get quite the number of annotations we
% want. Just randomly choose the rest.
numAnnotationsRemaining = numAnnotations - length(chosenIdx);
remainingChosenIdx = datasample(setdiff(overallIdx, chosenIdx), numAnnotationsRemaining, 'Replace', false);
chosenIdx = [chosenIdx, remainingChosenIdx];

chosenFrames = overallIdx(chosenIdx);  % Chosen frames, numbered in the overall system
chosenVideoIdx = videoIdx(chosenIdx);  % Chosen video indexes
chosenFrameIdx = frameIdx(chosenIdx);  % Chosen frame indices, numbered within each video


if plotFlag
    figure; hold on;
    plot(tongueTypeMasks.spoutContactTongue, 'DisplayName', 'Spout contact')
    plot(tongueTypeMasks.noSpoutContactTongue + 1.5, 'DisplayName', 'Tongue but no contact')
    plot(tongueTypeMasks.noTongue + 3, 'DisplayName', 'No tongue')
    plot(diff(videoIdx)* 7, 'k:', 'DisplayName', 'Trial number')
    plot(spoutPos+3.5, 'DisplayName', 'Spout position index')
    x = zeros(size(overallIdx));
    x(chosenFrames) = 1;
    plot(x-1.2, '*', 'DisplayName', 'chosen');
    legend
end

disp('Extracting data...');
for k = 1:length(chosenVideoIdx)
    fprintf('Completed frame %d of %d\n', k, length(chosenVideoIdx));
    % Get info about selected frame
    videoFilePath = videoFilePaths{chosenVideoIdx(k)};
    videoLength = videoLengths(chosenVideoIdx(k));
    [~, videoName, videoExt] = fileparts(videoFilePath);
    frameNumber = chosenFrameIdx(k);

    % Determine clip start/end frames, and the location of the target frame
    % within the clip
    clipStartFrame = frameNumber - clipRadius;
    clipEndFrame = frameNumber + clipRadius;
    if clipStartFrame < 1
        % Requested frame is too close video start for full clip radius
        clipStartFrame = 1;
        clipCenterFrame = frameNumber;
    elseif clipEndFrame > videoLength
        % Requested frame is too close video end for full clip radius
        clipEndFrame = videoLength;
        clipCenterFrame = clipRadius + 1;
    else
        clipCenterFrame = clipRadius + 1;
    end
    
    % Load clip data
    videoClipData = loadVideoClip(videoFilePath, clipStartFrame, clipEndFrame);

    % Prepare location to save clip
    clipPath = clipDirectory;
    clipName = sprintf('%s_clipF%dR%d%s', videoName, frameNumber, clipRadius, videoExt);
    clipFilePath = fullfile(clipPath, clipName);
    % Save clip to disk
    disp(['Saving clip as ', clipFilePath]);
    saveVideoData(uint8(videoClipData), clipFilePath);
    
    % Record clip in manualTrackingList
    manualTrackingList(k).videoFilename = clipName;
    manualTrackingList(k).videoPath = clipPath;
    manualTrackingList(k).frameNumbers = clipCenterFrame;
    manualTrackingList(k).originalPath = videoFilePath;
    manualTrackingList(k).origianlFrameNumber = frameNumber;
end

if ~isempty(saveFilepath)
    save(saveFilepath, 'manualTrackingList');
end

function bestDivisions = fairestDivision(num, divisor)
% Divide up num into divisor groups that are as equal as possible, with the
% requirement that the sum of the resulting divisions must be num.
bestDivisions = ones(1, divisor) * floor(num/divisor);
remainder = mod(num, divisor);
bestDivisions(1:remainder) = bestDivisions(1:remainder) + 1;