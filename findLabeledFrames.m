function [topLabeled, botLabeled]= findLabeledFrames(pathToROI, topROINum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convertROIsToMasks: Convert ROI polygon data into binary masks
% usage:  convertROIsToMasks(pathToROI, topOrigin, topSize, botOrigin, 
%                            botSize, topROINum, outputFilepath)
%
% where,
%    pathToROI is the path to a manualObjectTracker .mat file containing
%       manually created ROIs.
%    topROINum is either 1 or 2, indicating whether ROI #1 or ROI#2 is the
%       top view ROI in the ROI data. If topROINum is 1, botROINUm is
%       assumed to be 2, and vice versa.
%    topLabeled is a 1xN boolean vector, where N is the number of frames in 
%       the video that was labeled with manualObjectTracker, indicating 
%       whether each frame has been labeled with the top ROI. 
%    botLabeled is a 1xN boolean vector, where N is the number of frames in 
%       the video that was labeled with manualObjectTracker, indicating 
%       whether each frame has been labeled with the bottom ROI. 
%
% This function is designed to take manually tracings of mouse tongue ROIs
%   in .mat files created by manualObjectTracker and determine which frames
%   of the original video are labeled or not with both the top and bottom
%   ROI. A frame is considered labeled if it has any nonblank elements in 
%   the x/yPoints x/yFreehands, or absent fields in the ROI structure.
%
% See also: manualObjectTracker, createSegmentationTrainingSet,
%   assembleRandomManualTrackingAnnotations
%
% Version: 1.0
% Author:  Brian Kardon, concept by Teja Bollu
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute botROINum from topROINum
switch topROINum
    case 1
        botROINum = 2;
    case 2
        botROINum = 1;
    otherwise
        error('topROINum must be either 1 or 2');
end

% Load ROI data
s = load(pathToROI, 'outputStruct');
s = s.outputStruct;
xFreehands = s.ROIData.AnonymousUser.xFreehands;
xPoints = s.ROIData.AnonymousUser.xPoints;
absent = s.ROIData.AnonymousUser.absent;

% Determine which frames have a top ROI label for each type of labeling
topFreehandLabeled = cellfun(@(x)~isempty(x), xFreehands(topROINum, :));
topPointsLabeled = cellfun(@(x)~isempty(x), xPoints(topROINum, :));
topAbsentLabeled = absent(topROINum, :);

% Determine which frames have a bottom ROI label for each type of labeling
botFreehandLabeled = cellfun(@(x)~isempty(x), xFreehands(botROINum, :));
botPointsLabeled = cellfun(@(x)~isempty(x), xPoints(botROINum, :));
botAbsentLabeled = absent(botROINum, :);

% Determine which frames are labeled by any time of ROI labeling for the
% top and bottom ROI
topLabeled = topFreehandLabeled || topPointsLabeled || topAbsentLabeled;
botLabeled = botFreehandLabeled || botPointsLabeled || botAbsentLabeled;