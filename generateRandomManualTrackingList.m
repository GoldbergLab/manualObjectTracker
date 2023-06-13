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
    % 1st argument is actually a struct containing all the arguments, such
    % as one produced by generateRandomManualTrackingListGui
    videoBaseDirectories = p.videoRootDirectories;
    videoRegex = p.videoRegex;
    extensions = p.videoExtensions;
    numAnnotations = p.numAnnotations;
    saveFilepath = p.saveFilepath;
    clipDirectory = p.clipDirectory;
    clipRadius = p.clipRadius;

    dataFilePaths = p.weightingFilePaths;   % Either a lick_struct or a t_stats file (t_stats files contain the lick_struct they were created from)
    trialAlignment = p.trialAlignment;
    weights = p.weights;
    if ~isfield(p, 'enableWeighting')
        enableWeighting = 1;
        disp('No enable weighting field found in params. Enabling weighting by default.');
    else
        enableWeighting = p.enableWeighting;
    end
    if ~isfield(p, 'allVideosSameLength')
        allVideosSameLength = 1;
    else
        allVideosSameLength = p.allVideosSameLength;
    end

    if isfield(p, 't_stats_filter_field_names')
        t_stats_filter_field_names = p.t_stats_filter_field_names;
    else
        t_stats_filter_field_names = {};
    end
    if isfield(p, 't_stats_filters')
        t_stats_filters = p.t_stats_filters;

        % Convert any cell array filters into function filters
        for k = 1:length(t_stats_filters)
            switch class(t_stats_filters{k})
                case 'cell'
                    filter_values = t_stats_filters{k};
                    if all(cellfun(@isnumeric, filter_values))
                        filter_values = cell2mat(filter_values);
                    end
                    t_stats_filters{k} = @(v)ismember(v, filter_values);
            end
        end

    else
        t_stats_filters = {};
    end
    if isfield(p, 't_stats_filter_offsets') && isfield(p, 't_stats_filter_offset_anchors')
        t_stats_filter_offsets = p.t_stats_filter_offsets;
        t_stats_filter_offset_anchors = p.t_stats_filter_offset_anchors;
    else
        t_stats_filter_offsets = {};
        t_stats_filter_offset_anchors = {};
    end
    num_t_stats_filters = min([length(t_stats_filter_field_names), length(t_stats_filters), length(t_stats_filter_offsets)]);
    if length(unique([length(t_stats_filter_field_names), length(t_stats_filters), length(t_stats_filter_offsets)])) > 1
        warning('There should be the same number of t_stats field names, filters, and offsets.')
    end

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
if ischar(dataFilePaths)
    dataFilePaths = {dataFilePaths};
end

plotFlag = true;

periContactTongueFrameMargin = 20;
periProtrusionOnsetFrameMargin = [3, 2];   % For small tongue, how many frames before to how many frames after protrusion onset
periRetractionOffsetFrameMargin = [2, 1];  % For small tongue, how many frames before to how many frames after retraction offset

% Find files that match extension and regex
disp('Finding matching files with correct extension...');
videoFilePaths = cellfun(@(videoBaseDirectory)findFilesByExtension(videoBaseDirectory, extensions, false), videoBaseDirectories, 'UniformOutput', false);
tStatsPresent = false;
if enableWeighting || num_t_stats_filters > 0
    dataStructs = loadDataStructs(dataFilePaths);
    if isfield(dataStructs, 'lick_struct')
        % These must be lick_struct files.
        lickStructs = dataStructs;
    elseif isfield(dataStructs, 'l_sp_struct')
        % These must be t_stats files.
        tStatsPresent = true;
        for sessionNum = 1:length(dataStructs)
            lickStructs(sessionNum).lick_struct = dataStructs(sessionNum).l_sp_struct;
            for trialNum = 1:length(lickStructs(sessionNum).lick_struct)
                t_stats = dataStructs(sessionNum).t_stats;
                lickStructs(sessionNum).lick_struct(trialNum).pairs = {t_stats([t_stats.trial_num] == trialNum).pairs};
                for filter_field_num = 1:num_t_stats_filters
                    % Copy selected t_stats fields/values over to lick_struct to
                    % be used for filtering output frames
                    field_name = t_stats_filter_field_names{filter_field_num};
                    lickStructs(sessionNum).lick_struct(trialNum).t_stats.(field_name) = {t_stats([t_stats.trial_num] == trialNum).(field_name)};
                end
            end
        end
    else
        % No valid fields
        error('FPGA data file provided does not contain either a lick_struct or a l_sp_struct field. Please provide a valid lick_struct or t_stats file.');
    end
end

if ~tStatsPresent
    % smallTongue frames can only be found if t_stats file is provided.
    % lick_struct does not have the required info.
    weights.tongueType = rmfield(weights.tongueType, 'smallTongue');
end


disp('...done finding matching files with correct extension.');

if isempty(videoFilePaths)
    disp(strjoin([{'Warning, no files found for video identifier'}, extensions], ' '))
end

sessionIdxToDelete = [];

fprintf('Trimming videos and lick_structs so their start times match...\n');
if enableWeighting || num_t_stats_filters > 0
    numSessions = min([length(videoFilePaths), length(dataFilePaths), length(trialAlignment)]);
    for sessionNum = 1:numSessions
        displayProgress('%d of %d sessions trimmed...\n', sessionNum, numSessions, 10);
        % Trim lick_struct and video list starts so they start on the corresponding
        % trial (as identified by user) and ends so they have the same # of
        % elements
        videoFilePaths{sessionNum} = videoFilePaths{sessionNum}(trialAlignment(sessionNum).videoStartingFrame:end);
        lickStructs(sessionNum).lick_struct = lickStructs(sessionNum).lick_struct(trialAlignment(sessionNum).fpgaStartingFrame:end);

        % Trim the ends of the session to make sure videos and lick_structs
        % have the same length
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
    
    fprintf('Deleting %d sessions due to missing data fields.\n', length(sessionIdxToDelete));
    lickStructs(sessionIdxToDelete) = [];
    videoFilePaths(sessionIdxToDelete) = [];
end

% Concatenate video paths and lick structs into one long list
videoFilePaths = horzcat(videoFilePaths{:});
if enableWeighting || num_t_stats_filters > 0
    lick_struct = horzcat(lickStructs.lick_struct);

    % Add in spout contact onset/offsets:
    lick_struct = getContactDur(lick_struct);

    if length(videoFilePaths) ~= length(lick_struct)
        error('Failed to match up lick_struct rows and video paths.');
    end
    
end

if ischar(videoRegex)
    % Find files that match one or more of the videoRegex
    regexFilterIdx = 1:length(videoFilePaths);
    regexFilterIdx = regexFilterIdx(~cellfun(@isempty, regexp(videoFilePaths, videoRegex)));
    videoFilePaths = videoFilePaths(regexFilterIdx);
    if enableWeighting || num_t_stats_filters > 0
        lick_struct = lick_struct(regexFilterIdx);
    end
elseif isnumeric(videoRegex)
    % Number rather than regex is passed as videoRegex
    sampleNum = videoRegex;
    if sampleNum > 0
        % If number is not 0, randomly sample that # of videos and lick
        % struct trials
        [videoFilePaths, randomIdx] = datasample(videoFilePaths, sampleNum, 'Replace',false);
        if enableWeighting || num_t_stats_filters > 0
            lick_struct = lick_struct(randomIdx);
        end
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
        if ~allVideosSameLength || isempty(sessionVideoLengths{sessionNum})
            % Either we're getting each video length individually, or this
            % is the first video we've checked in this session.
            videoSize = loadVideoDataSize(videoFilePath);        
            sessionVideoLengths{sessionNum} = videoSize;
        else
            videoSize = sessionVideoLengths{sessionNum};
        end
        
        if videoSize(3) <= 2*clipRadius
            invalidIndices(end+1) = videoNum;
        end
    catch ME
        getReport(ME);
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
    if enableWeighting
        lick_struct(invalidIndices) = [];
    end
end
if isempty(videoFilePaths)
    error('Error - no valid videos found with those parameters. Check the root directory, try changing the file regex, and make sure the extension is valid - it should include a ''.''.')
end


% Create corresponding vectors of video numbers, frame numbers, etc
numFrames = sum(videoLengths);
overallIdx = 1:numFrames;
frameIdx = zeros(1, numFrames);
videoIdx = zeros(1, numFrames);

if enableWeighting
    fprintf('Getting cue times...\n');
    defaultCueTime = 1001;
    cueTimes = [];
    for videoNum = 1:length(videoFilePaths)
        displayProgress('%d of %d cue times found...\n', videoNum, length(videoFilePaths), 10);
        videoName = videoFilePaths{videoNum};
        out = regexp(videoName, '_C([0-9]+)L?\.[aA][vV][iI]$', 'tokens');
        try
            cueTimes(videoNum) = str2double(out{1}{1}); %#ok<*AGROW> 
        catch
            warning('Could not determine cue time for video %s based on filename. Defaulting to %d.', videoName, defaultCueTime);
            cueTimes(videoNum) = defaultCueTime;
        end
    end
    fprintf('...done getting cue times.\n');

    % Normalize weights within each weight category (tongueType,
    % spoutPosition)
    % 
    % Current weight structure is:
    %
    % tongueType
    %   noSpoutContactTongue
    %   spoutContactTongue
    %   noTongue
    %   smallTongue
    % spoutPosition
    %   Position1
    %   Position2
    %   Position3

    weightCategories = fieldnames(weights);
    for weightCategoryIndex = 1:length(weightCategories)
        weightCategory = weightCategories{weightCategoryIndex};
        subWeights = weights.(weightCategory);

        frameTypes = sort(fieldnames(subWeights));
        frameTypeIndices = 1:length(frameTypes);
        % Calculate cumulative weight for each frame type
        totalSubWeight = 0;
        for frameTypeIndex = frameTypeIndices
            frameType = frameTypes{frameTypeIndex};
            totalSubWeight = totalSubWeight + subWeights.(frameType);
        end
        for frameTypeIndex = frameTypeIndices
            frameType = frameTypes{frameTypeIndex};
            weights.(weightCategory).(frameType) = weights.(weightCategory).(frameType) / totalSubWeight;
        end
    
    end
end

% Loop over categories and create blank frame masks for each type of frame
%   (we're using the frame types stored in the weights struct even if
%   weighting is not enabled)
weightCategories = fieldnames(weights);
for weightCategoryIndex = 1:length(weightCategories)
    weightCategory = weightCategories{weightCategoryIndex};
    subWeights = weights.(weightCategory);
    frameTypes = fieldnames(subWeights);
    for frameTypeIndex = 1:length(frameTypes)
        frameType = frameTypes{frameTypeIndex};
        frameTypeMasks.(weightCategory).(frameType) = false(1, numFrames);
    end
end

% Construct a blank spout position mask
spoutPos = nan(1, numFrames);

if tStatsPresent
    if num_t_stats_filters > 0
        % Create a blank t_stats-based mask for filtering based on lick data
        % from t_stats
        tStatsMask = false(1, numFrames);
    else
        % No t_stats filters provided
        tStatsMask = true(1, numFrames);
    end
end

% Loop over videos and create corresponding lists of spout positions
startFrame = 1;
fprintf('Constructing frame masks...\n');
for videoNum = 1:length(videoFilePaths)
    displayProgress('%d of %d trials analyzed...\n', videoNum, length(videoFilePaths), 50);
    yes = ones(1, videoLengths(videoNum));
%     no = zeros(1, videoLengths(videoNum));
%     mu = nan(1, videoLengths(videoNum));
    
    idx = 1:videoLengths(videoNum);

    endFrame = startFrame + videoLengths(videoNum) - 1;
    videoIdx(startFrame:endFrame) = videoNum * yes;
    frameIdx(startFrame:endFrame) = idx;
    if enableWeighting
        % Since spout positions are only defined during the active trial 
        % period (after cue for a set amount of time, extrapolate the spout
        % positions before (and potentially after) the active trial period.
        currentSpoutIdx = lick_struct(videoNum).spoutPosition;
        currentSpoutIdx = [currentSpoutIdx(1)*ones(1, cueTimes(videoNum)), currentSpoutIdx];
        currentSpoutIdx = [currentSpoutIdx, currentSpoutIdx(end)*ones(1, videoLengths(videoNum) - length(currentSpoutIdx))];

        if any(isnan(currentSpoutIdx))
            badPos = unique(currentSpoutIdx(isnan(currentSpoutIdx)));
            error('Could not find some of this trial''s spout positions in list - %s. Something went wrong.', num2str(badPos));
        end
        spoutPos(startFrame:endFrame) = currentSpoutIdx;

        % Update spout position masks for this video
        spoutPositionNames = sort(fieldnames(frameTypeMasks.spoutPosition));
        for spoutPositionIndex = 1:length(spoutPositionNames)
            spoutPositionName = spoutPositionNames{spoutPositionIndex};
            frameTypeMasks.spoutPosition.(spoutPositionName)(startFrame:endFrame) = (spoutPos(startFrame:endFrame) == spoutPositionIndex);
        end

        for spoutContactNum = 1:length(lick_struct(videoNum).sp_contact_onset)
            onset = lick_struct(videoNum).sp_contact_onset(spoutContactNum) + cueTimes(videoNum);
            offset = lick_struct(videoNum).sp_contact_offset(spoutContactNum) + cueTimes(videoNum);
            frameTypeMasks.tongueType.noSpoutContactTongue(startFrame:endFrame) = ...
                (((onset - idx) < periContactTongueFrameMargin) & ((onset - idx) > 0)) | ...
                (((idx - offset) < periContactTongueFrameMargin) & ((idx - offset > 0)));
            frameTypeMasks.tongueType.spoutContactTongue(startFrame:endFrame) = ...
                ((idx - onset) >= 0) & ((offset - idx) >= 0);
            frameTypeMasks.tongueType.noTongue = ~frameTypeMasks.tongueType.noSpoutContactTongue & ~frameTypeMasks.tongueType.spoutContactTongue;
        end
    end
    if tStatsPresent
        pairs = lick_struct(videoNum).pairs;
        disp(videoFilePaths{videoNum})
        for lickNum = 1:length(pairs)
            pair = pairs{lickNum};
            if isnan(pair)
                % Occasionally an onset/offset lick comes up as NaN -
                % not sure why.
                continue;
            end
            protrusionOnset = pair(1);
            retractionOffset = pair(2);
            if enableWeighting
                smallTongueProtruding = ((idx - protrusionOnset  + periProtrusionOnsetFrameMargin(1))  >= 0) & ((idx - protrusionOnset  - periProtrusionOnsetFrameMargin(2))  <= 0);
                smallTongueRetracting = ((idx - retractionOffset + periRetractionOffsetFrameMargin(1)) >= 0) & ((idx - retractionOffset - periRetractionOffsetFrameMargin(2)) <= 0);
                frameTypeMasks.tongueType.smallTongue(startFrame:endFrame) = frameTypeMasks.tongueType.smallTongue(startFrame:endFrame) | smallTongueProtruding | smallTongueRetracting;
            end
            % If present, find matching frame mask for t_stats filters
            % for this lick
            lick_filter_match = true;
            fprintf('  Lick #%d\n', lickNum);
            for filter_field_num = 1:num_t_stats_filters
                field_name = t_stats_filter_field_names{filter_field_num};
                field_value = lick_struct(videoNum).t_stats.(field_name){lickNum};
                lick_filter_match = lick_filter_match & t_stats_filters{filter_field_num}(field_value);
                fprintf('    Checking %s:\n', field_name);
                fprintf('      %d\n\n', t_stats_filters{filter_field_num}(field_value))
            end
            if lick_filter_match
                % This lick matched all filters. Using provided 
                % offsets, mark the corresponding frame ranges as 
                % included in the potential output
                for filter_field_num = 1:num_t_stats_filters
                    offset = t_stats_filter_offsets{filter_field_num};
                    offset_anchors = t_stats_filter_offset_anchors{filter_field_num};
                    switch offset_anchors(1)
                        case 'p'
                            startInclude = protrusionOnset + offset(1);
                        case 'r'
                            startInclude = retractionOffset + offset(1);
                    end
                    switch offset_anchors(2)
                        case 'p'
                            endInclude = protrusionOffset + offset(2);
                        case 'r'
                            endInclude = retractionOffset + offset(2);
                    end
                    this_tStatsMask = (((idx - startInclude) >= 0) & ((idx - endInclude) <= 0));
                    tStatsMask(startFrame:endFrame) = tStatsMask(startFrame:endFrame) | this_tStatsMask;
                end
            end
        end
    end
    
    startFrame = endFrame + 1;
end
fprintf('...done constructing frame masks.\n');

chosenIdx = [];

fprintf('Choosing random frames...\n');
if enableWeighting
    % Get a list of unique spout targets
    spoutTargets = unique(spoutPos);
    if length(spoutTargets) ~= 3
        warning('Expected three spout positions, instead found %d.', length(spoutTargets));
    end

    tongueTypes = fieldnames(frameTypeMasks.tongueType);
    % Determine how many frame types we're balancing the randomization across
    numTongueTypes = length(tongueTypes);

    % Pick random frame numbers, balanced by frame type according to weights
    for spoutTarget = spoutTargets
        spoutPositionName = sprintf('Position%d', spoutTarget);
        for tongueTypeIdx = 1:numTongueTypes
            % get tongue type of this group (no tongue / no contact tongue / tongue with spout contact
            tongueType = tongueTypes{tongueTypeIdx};
            % Determine size of this group based on weights
            groupSize = floor(numAnnotations * weights.tongueType.(tongueType) * weights.spoutPosition.(spoutPositionName));
%            groupSize = floor(equalGroupSize * weights.(tongueType) * numTongueTypes / length(spoutTargets));
            % Create mask for which indices satisfy this group's criteria
            groupMask = frameTypeMasks.spoutPosition.(spoutPositionName) & frameTypeMasks.tongueType.(tongueType) & tStatsMask;
            % Map mask onto actual indices for this group
            groupIdx = overallIdx(groupMask);
            % Make sure we aren't trying to draw more samples than frames
            % for this type
            if length(groupIdx) < groupSize
                groupSize = length(groupIdx);
            end
            if groupSize < 1
                % Zero frames will be chosen from this group
                continue;
            end
            % Choose a random subset of this group's indices
            newChosenIdx = datasample(groupIdx, groupSize, 'Replace', false);
            % Add on to previous group's chosen indices
            chosenIdx = [chosenIdx, newChosenIdx];
        end
    end
    % Due to rounding errors, we don't get quite the number of annotations we
    % want. Just randomly choose the rest.
    numAnnotationsRemaining = numAnnotations - length(chosenIdx);
    if numAnnotationsRemaining > 0
        remainingChosenIdx = datasample(setdiff(overallIdx, chosenIdx), numAnnotationsRemaining, 'Replace', false);
        fprintf('Adding %d extra random samples to counteract rounding errors.\n', length(remainingChosenIdx));
        chosenIdx = [chosenIdx, remainingChosenIdx];
    end
else
    % Filter with t_stats filters, if present
    filteredIdx = overallIdx(tStatsMask);
    % Pick random frame numbers (without weighting)
    chosenIdx = datasample(filteredIdx, numAnnotations, 'Replace', false);
end
fprintf('...done choosing random frames.\n');

chosenFrames = overallIdx(chosenIdx);  % Chosen frames, numbered in the overall system
chosenVideoIdx = videoIdx(chosenIdx);  % Chosen video indexes
chosenFrameIdx = frameIdx(chosenIdx);  % Chosen frame indices, numbered within each video


if enableWeighting && plotFlag
    figure; hold on;
    plot(frameTypeMasks.tongueType.spoutContactTongue, 'DisplayName', 'Spout contact')
    plot(frameTypeMasks.tongueType.noSpoutContactTongue + 1.5, 'DisplayName', 'Tongue but no contact')
    plot(frameTypeMasks.tongueType.noTongue + 3, 'DisplayName', 'No tongue')
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
    manualTrackingList(k).originalFrameNumber = frameNumber;
end
fprintf('...done creating clips.\n');

if ~isempty(saveFilepath)
    save(saveFilepath, 'manualTrackingList');
end

% function bestDivisions = fairestDivision(num, divisor)
% % Divide up num into divisor groups that are as equal as possible, with the
% % requirement that the sum of the resulting divisions must be num.
% bestDivisions = ones(1, divisor) * floor(num/divisor);
% remainder = mod(num, divisor);
% bestDivisions(1:remainder) = bestDivisions(1:remainder) + 1;

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
            lick_struct(k).actuator1_ML_command = zeros([1, diff(lick_struct(k).rw_cue)+1]);
        end
    end
end
if length(MLTargets) == 1
    disp('Warning, session found with only one unique ML actuator.');
    MLTargets = [NaN, MLTargets, NaN];
elseif length(MLTargets) == 2
    disp('Warning, session found with only two unique ML actuator targets.');
    MLTargets = [MLTargets(1), MLTargets(2), NaN];
elseif length(MLTargets) > 3
    disp('Warning, session found with more than two unique ML actuator targets.');
    MLTargets = [MLTargets(1), MLTargets(2), MLTargets(3)];
end

% Convert actuator commands to target indices
for k = 1:length(lick_struct)
    lick_struct(k).spoutPosition = arrayfun(@(ML)find(MLTargets==ML), lick_struct(k).actuator1_ML_command);
end

if ~any(strcmp('analog_lick', fns))
    % Add dummy analog lick field
    for k = 1:length(lick_struct)
        lick_struct(k).analog_lick = nan([1, diff(lick_struct(k).rw_cue)+1]);
    end
end

allowedLickStructFields = {'spoutPosition', 'analog_lick', 'rw_cue', 'pairs', 't_stats'};
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

function dataStructs = loadDataStructs(dataFilePaths)
dataStructs = [];
for sessionNum = 1:length(dataFilePaths)
    s = load(dataFilePaths{sessionNum});
    dataStructs(sessionNum).t_stats = s.t_stats;
    dataStructs(sessionNum).l_sp_struct = s.l_sp_struct;
    dataStructs(sessionNum).vid_index = s.vid_index;
end
