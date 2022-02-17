function createCombinedSegmentationTrainingSet(pathsToVideos, pathsToROIs, outputPath, topOrigin, topSize, botOrigin, botSize, topROINum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% createCombinedSegmentationTrainingSet: Create a training set for a 
%   segmentation neural network, consisting of video and masks from one or
%   more manually tracked ROI training sets.
% usage:  createCombinedSegmentationTrainingSet(pathsToVideo, pathsToROIs, topOrigin, topSize, botOrigin, botSize, topROINum)
%
% where,
%    pathsToVideo is a cell array containing one or more paths to video 
%       files of a mouse tongue. The video paths must be in corresponding
%       order to the ROI paths in the pathsToROI argument for them to get
%       paired correctly. So, pathsToVideo{k} must correspond to
%       pathsToROI{k}.
%    pathsToROI is a cell array containing one or more paths to video files
%       of a mouse tongue. The ROI paths must be in corresponding
%       order to the video paths in the pathsToVideo argument for them to get
%       paired correctly. So, pathsToROI{k} must correspond to
%       pathsToVideo{k}.
%    outputPath is the path to save the output training sets to.
%    topOrigin is a 1x2 array of values containing the x and y coordinate
%       of the desired top left corner of the output top video in the 
%       coordinate system of the original video.
%    topSize is a 1x2 array of values containing the desired width and
%       height of the output top video.
%    botOrigin is a 1x2 array of values containing the x and y coordinate
%       of the desired top left corner of the output bot video in the 
%       coordinate system of the original video.
%    botSize is a 1x2 array of values containing the desired width and
%       height of the output bot video.
%    topROINum is either 1 or 2, indicating whether ROI #1 or ROI#2 is the
%       top view ROI in the ROI data. If topROINum is 1, botROINUm is
%       assumed to be 2, and vice versa.
%    outputFilePath is an optional char array indicating the file path in
%       which to save the masks to file. If omitted or empty, no files are
%       saved.
%
% This function is designed to take mouse tongue video and corresponding
%   manual tracings of the top and bottom view within the video and create
%   two .mat file training sets for a segmentation neural network. The two
%   output .mat files are for the top and bottom views. They each consist
%   of either the top or bottom half of the video, and the bottom or top
%   mask generated from the manual tracing. This function, unlike it's
%   singular cousin, can take multiple 
%   
%   The output struct has the following structure:
%   
%   trainingSet
%       maskStack = H x W x N logical
%       imageStack = H x W x N double
%
% See also: createSegmentationTrainingSet, convertROIsToMasks, 
%   splitVideoIntoTopAndBottom, manualObjectTracker
%
% Version: 1.0
% Author:  Brian Kardon, concept by Teja Bollu
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(pathsToVideos) ~= length(pathsToROIs)
    error('Found %d video paths, and %d ROI paths. Video and ROI paths must correspond to each other, so there must be the same number of each.\n', length(pathsToVideos), length(pathsToROIs));
end

topVideoData = [];
botVideoData = [];
topMasks = [];
botMasks = [];

for k = 1:length(pathsToVideos)
    pathToVideo = pathsToVideos{k};
    pathToROI = pathsToROIs{k};
    % Split video into top and bottom parts
    [tvd, bvd] = splitVideoIntoTopAndBottom(pathToVideo, topOrigin, topSize, botOrigin, botSize, false);
    % Add in new video data
    topVideoData = [topVideoData; tvd];
    botVideoData = [botVideoData; bvd];
    % Split masks into top and bottom parts
    [tm, bm] = convertROIsToMasks(pathToROI, topOrigin, topSize, botOrigin, botSize, topROINum);
    % Add in new mask data
    topMasks = [topMasks; tm];
    botMasks = [botMasks; bm];
end

% Construct top and bot output paths
[path, name, ~] = fileparts(outputPath);
topOutputPath = [fullfile(path, name), '_top.mat'];
botOutputPath = [fullfile(path, name), '_bot.mat'];

% Save top training set:
maskStack = topMasks;
imageStack = topVideoData;
save(topOutputPath, 'maskStack', 'imageStack');
% Save bot training set:
maskStack = botMasks;
imageStack = botVideoData;
save(botOutputPath, 'maskStack', 'imageStack');
