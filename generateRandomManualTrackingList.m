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
disp('...done finding matching files with correct extension.');

if isempty(videoFilePaths)
    disp(strjoin([{'Warning, no files found for video identifier'}, extensions], ' '))
end

sessionIdxToDelete = [];

fprintf('Trimming videos and lick_structs so their start times match...\n');
numSessions = min([length(videoFilePaths), length(lickStructFilePaths), length(trialAlignment)]);
for sessionNum = 1:numSessions
    displayProgress('%d of %d sessions trimmed...\n', sessionNum, numSessions, 10);
    % Trim lick_struct and video list starts so they start on the corresponding
    % trial (as identified by user) and ends so they have the same # of
    % elements
    videoFilePaths{sessionNum} = videoFilePaths{sessionNum}(trialAlignment(sessionNum).videoStartingFrame:end);
    lickStructs(sessionNum).lick_struct = lickStructs(sessionNum).lick_struct(trialAlignment(sessionNum).fpgaStartingFrame:end);

    numTrials = min([length(videoFilePaths{sessionNum}), length(lickStructs(sessionNum).lick_struct)]);
    videoFilePaths{sessionNum} = videoFilePaths{sessionNum}(1:numTrials);
    lickStructs(sessionNum).lick_struct = lickStructs(sessionNum).lick_struct(1:numTrials);

    % Fix or eliminate lick_structs that lack necessary fields or have
    % extra ones.
    [lickStructs(sessionNum).lick_struct, valid] = prepareLickStruct(lickStructs(sessionNum).lick_struct);
    
    if ~valid
        sessionIdxToDelete(end+1) = sessionNum;
    end
end
fprintf('...done trimming videos and lick_structs so their start times match\n');

fprintf('Deleting %d sessions due to missing lick_struct fields.\n', length(sessionIdxToDelete));
lickStructs(sessionIdxToDelete) = [];
videoFilePaths(sessionIdxToDelete) = [];

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
videoLengths = zeros(1, length(videoFilePaths));

invalidIndices = [];
% Build up database of how long videos are in each session, for speed
fprintf('Determining length of videos in each session...\n');
sessionVideoLengths = cell(1, length(videoBaseDirectories));
for videoNum = 1:length(videoFilePaths)
    displayProgress('%d of %d video lengths found...\n', videoNum, length(videoFilePaths), 10);
    [videoBaseDirectory, ~, ~] = fileparts(videoFilePaths{videoNum});
    sessionNum = find(strcmp(videoBaseDirectories, videoBaseDirectory));
    if isempty(sessionNum)
        error('Identified video does not come from one of the provided paths. Something has gone wrong.');
    end
    
    fprintf('Determining length of video #%d of %d\n', videoNum, length(videoFilePaths));
    fprintf('\t%s\n', videoFilePaths{videoNum});
    videoFilePath = videoFilePaths{videoNum};
    try
        if isempty(sessionVideoLengths{sessionNum})
            videoSize = loadVideoDataSize(videoFilePath);        
            sessionVideoLengths{sessionNum} = videoSize;
        else
            videoSize = sessionVideoLengths{sessionNum};
        end
        
        if videoSize(3) <= 2*clipRadius
            invalidIndices(end+1) = videoNum;
        end
    catch ME
        invalidIndices(end+1) = videoNum;
    end
    fprintf('\tVideo length = %d\n', videoSize(3));
    videoLengths(videoNum) = videoSize(3); % - 2*clipRadius;
end
fprintf('...done determining length of videos in each session.\n');

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
    displayProgress('%d of %d cue times found...\n', videoNum, length(videoFilePaths), 10);
    videoName = videoFilePaths{videoNum};
    out = regexp(videoName, '_C([0-9]+)L?\.[aA][vV][iI]$', 'tokens');
    try
        cueTimes(videoNum) = str2double(out{1}{1});
    catch ME
        warning('Could not determine cue time for video %s based on filename. Defaulting to %d.', videoName, defaultCueTime);
        cueTimes(videoNum) = defaultCueTime;
    end
end
fprintf('...done getting cue times.\n');

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

% Create corresponding vectors of video numbers, frame numbers, etc
numFrames = sum(videoLengths);
overallIdx = 1:numFrames;
frameIdx = zeros(1, numFrames);
videoIdx = zeros(1, numFrames);

% Loop over videos and create corresponding lists of spout positions
tongueTypeMasks.spoutContactTongue = zeros(1, numFrames, 'logical');
tongueTypeMasks.noSpoutContactTongue = zeros(1, numFrames, 'logical');
tongueTypeMasks.noTongue = zeros(1, numFrames, 'logical');
spoutPos = nan(1, numFrames);
startFrame = 1;
fprintf('Constructing frame type vectors...\n');
for videoNum = 1:length(videoFilePaths)
    displayProgress('%d of %d trials analyzed...\n', videoNum, length(videoFilePaths), 50);
    yes = ones(1, videoLengths(videoNum));
    no = zeros(1, videoLengths(videoNum));
    mu = nan(1, videoLengths(videoNum));
    
    idx = 1:videoLengths(videoNum);
    currentSpoutIdx = lick_struct(videoNum).spoutPosition;
    currentSpoutIdx = [currentSpoutIdx(1)*ones(1, cueTimes(videoNum)), currentSpoutIdx];
    currentSpoutIdx = [currentSpoutIdx, currentSpoutIdx(end)*ones(1, videoLengths(videoNum) - length(currentSpoutIdx))];
    if any(isnan(currentSpoutIdx))
        badPos = unique(currentSpoutIdx(isnan(currentSpoutIdx)));
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
fprintf('...done constructing frame type vectors.\n');

spoutTargets = unique(spoutPos);
if length(spoutTargets) ~= 3
    warning('Expected three spout positions, instead found %d.', length(spoutTargets));
end

% Determine how many frame types we're balancing the randomization across
numGroups = length(spoutTargets) * 3; % (spout L, spout C, spout R) x (tongue w/o contact, tongue w/ contact, no tongue)
groupSize = numAnnotations/numGroups;
tongueTypes = fieldnames(tongueTypeMasks);
numTongueTypes = length(tongueTypes);

chosenIdx = [];

% Pick random frame numbers, balanced by frame type according to weights
fprintf('Choosing random frames...\n');
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
fprintf('...done choosing random frames.\n');
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

fprintf('Creating clips...\n');
for k = 1:length(chosenVideoIdx)
    displayProgress('%d of %d clips created...\n', k, length(chosenVideoIdx), 10);
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
fprintf('...done creating clips.\n');

if ~isempty(saveFilepath)
    save(saveFilepath, 'manualTrackingList');
end

function bestDivisions = fairestDivision(num, divisor)
% Divide up num into divisor groups that are as equal as possible, with the
% requirement that the sum of the resulting divisions must be num.
bestDivisions = ones(1, divisor) * floor(num/divisor);
remainder = mod(num, divisor);
bestDivisions(1:remainder) = bestDivisions(1:remainder) + 1;

function [lick_struct, valid] = prepareLickStruct(lick_struct)

fns = fieldnames(lick_struct);

% Create list of ML targets
if any(strcmp('actuator1_ML', fns))
    % Targets exist, get a list of them
    MLTargets = sort(unique([lick_struct.actuator1_ML]));
    if ~any(strcmp('actuator1_ML_command', fns))
        % No command vectors - create dummy constant command ones
        for k = 1:length(lick_struct)
            lick_struct(k).actuator1_ML_command = repmat(lick_struct(k).actuator1_ML, [1, diff(lick_struct(k).rw_cue)+1]);
        end
    end
else
    % Targets do not exist, let's infer them
    if any(strcmp('actuator1_ML_command', fns))
        % Commands exist - get targets from command vectors instead
        MLTargets = sort(unique([lick_struct.actuator1_ML_command]));
        % Infer actuator targets
        for k = 1:length(lick_struct)
            lick_struct(k).actuator1_ML = lick_struct(k).actuator1_ML_command(end);
        end
    else
        % No targets or commands - create dummy ones
        MLTargets = 0;
        for k = 1:length(lick_struct)
            lick_struct(k).actuator1_ML_command = repmat(0, [1, diff(lick_struct(k).rw_cue)+1]);
        end
    end
end
if length(MLTargets) == 1
    disp('Warning, session found with only one unique ML actuator.');
    MLTargets = [NaN, MLTargets, NaN];
elseif length(MLTargets) == 2
    disp('Warning, session found with only two unique ML actuator targets.');
    MLTargets = [MLTargets(1), MLTargets(2), NaN];
end

% Convert actuator commands to target indices
for k = 1:length(lick_struct)
    lick_struct(k).spoutPosition = arrayfun(@(ML)find(MLTargets==ML), lick_struct(k).actuator1_ML_command);
end

if ~any(strcmp('analog_lick', fns))
    % Add dummy analog lick field
    for k = 1:length(lick_struct)
        lick_struct(k).analog_lick = repmat(NaN, [1, diff(lick_struct(k).rw_cue)+1]);
    end
end

allowedLickStructFields = {'spoutPosition', 'analog_lick', 'rw_cue'};
valid = true;

% Trim lick_struct down to the necessary fields
fns = fieldnames(lick_struct);
for k = 1:length(fns)
    if ~any(strcmp(fns{k}, allowedLickStructFields)) 
        lick_struct = rmfield(lick_struct, fns{k}); 
    end
end

fns = fieldnames(lick_struct);
for k = 1:length(allowedLickStructFields)
    if ~any(strcmp(allowedLickStructFields{k}, fns))
        % Lick struct lacks a necessary field. Mark this session for
        % elimination
        disp([allowedLickStructFields{k}, ' missing']);
        valid = false;
        break;
    end
end