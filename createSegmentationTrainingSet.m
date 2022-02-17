function createSegmentationTrainingSet(pathToVideo, pathToROIs, outputPath, topOrigin, topSize, botOrigin, botSize, topROINum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% createSegmentationTrainingSet: Create a training set for a segmentation
%   neural network, consisting of video and masks.
% usage:  createSegmentationTrainingSet(pathToVideo, pathToROIs, topOrigin, topSize, botOrigin, botSize, topROINum)
%
% where,
%    pathToVideo is the path to a video file of a mouse tongue. If
%       something other than a char array is provided, it is assumed to be
%       the raw 
%    pathToROI is the path to a video file of a mouse tongue
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
%   mask generated from the manual tracing.
%   
%   The output struct has the following structure:
%   
%   trainingSet
%       maskStack = H x W x N logical
%       imageStack = H x W x N double
%
% See also: convertROIsToMasks, splitVideoIntoTopAndBottom, 
%           manualObjectTracker
%
% Version: 1.0
% Author:  Brian Kardon, concept by Teja Bollu
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Split video into top and bottom parts
[topVideoData, botVideoData] = splitVideoIntoTopAndBottom(pathToVideo, topOrigin, topSize, botOrigin, botSize, false);
% Split masks into top and bottom parts
[topMasks, botMasks] = convertROIsToMasks(pathToROIs, topOrigin, topSize, botOrigin, botSize, topROINum);

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

