function [topMasks, botMasks] = convertROIsToMasks(pathToROI, topOrigin, topSize, botOrigin, botSize, topROINum, outputFilePath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convertROIsToMasks: Convert ROI polygon data into binary masks
% usage:  convertROIsToMasks(pathToROI, topOrigin, topSize, botOrigin, 
%                            botSize, topROINum, outputFilepath)
%
% where,
%    pathToROI is the path to a manualObjectTracker .mat file containing
%       manually created ROIs.
%    topOrigin is a 1x2 array of values containing the x and y coordinate
%       of the desired origin for the top ROI
%    topSize is a 1x2 array of values containing the desired width and
%        height of the output top video.
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
% This function is designed to take manually tracings of mouse tongue ROIs
%   in .mat files created by manualObjectTracker and convert them into 
%   stacks of binary masks, one stack for the top view of the tongue, and 
%   one stack for the bottom view. The output of this is designed to be fed
%   into the mouse tongue segmentation neural network training algorithm.
%
% See also: manualObjectTracker, splitVideoIntoTopAndBottom
%
% Version: 1.0
% Author:  Brian Kardon, concept by Teja Bollu
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set default topROINum
if ~exist('topROINum', 'var')
    topROINum = 1;
end
if ~exist('outputFilePath', 'var')
    outputFilePath = '';
end
% Sanity check inputs
if length(topSize) ~= 2 || length(botSize) ~= 2
    error('Top and bottom mask size each expected to be a 2-element array indicating the width and height of the desired output mask');
end
if length(topOrigin) ~= 2 || length(botOrigin) ~= 2
    error('Top and bottom mask origins each expected to be a 2-element array indicating the coordinates in the ROI polygon space where the top left corner of each output mask should be.');
end

nMaxPool = 4;
if ~validateImageSize(topSize(1), topSize(2), nMaxPool)
    warning('Warning, top mask size does not contain enough factors of 2 to satisfy %d max-pool steps', nMaxPool);
end
if ~validateImageSize(botSize(1), botSize(2), nMaxPool)
    warning('Warning, bot mask size does not contain enough factors of 2 to satisfy %d max-pool steps', nMaxPool);
end


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
xROIs = s.ROIData.AnonymousUser.xFreehands;
yROIs = s.ROIData.AnonymousUser.yFreehands;
% Get shape of ROI data
[nROIs, nFrames] = size(xROIs);
% Sanity check number of ROIs found
if nROIs < 2
    error('At least 2 ROIs required to make bottom and top masks.');
elseif nROIs > 2
    warning('More than 2 ROIs found...expected 2, one top and one bottom...only the first two in each frame will be used.');
end

% Set up variables for processing
sizes = {};
sizes{topROINum} = topSize;
sizes{botROINum} = botSize;
origins = {};
origins{topROINum} = topOrigin;
origins{botROINum} = botOrigin;
masks = {};
masks{topROINum} = zeros(nFrames, topSize(2), topSize(1), 'logical');
masks{botROINum} = zeros(nFrames, botSize(2), botSize(1), 'logical');

% Loop over each frame
for frameNum = 1:nFrames
    % Loop over each ROI within each frame
    for roiNum = [topROINum, botROINum]
        % Get origin-shifted ROI coordinates
        xROI = xROIs{roiNum, frameNum} - origins{roiNum}(1);
        yROI = yROIs{roiNum, frameNum} - origins{roiNum}(2);
        % Create binary mask from ROI coordinates, add to stack. 
        % Note: Yes, the order of arguments for poly2mask is:
        %   x, y, height, width
        %   (╯°□°)╯︵ ┻━┻
        masks{roiNum}(frameNum, :, :) = poly2mask(xROI, yROI, sizes{roiNum}(2), sizes{roiNum}(1));
    end
end
% Prepare output variables
botMasks = masks{botROINum};
topMasks = masks{topROINum};

% If outputFilepath has been provided, save output to file
if ~isempty(outputFilePath)
    % Strip extension, if any
    [path, name, ~] = fileparts(outputFilePath);
    outputFilename = fullfile(path, name);
    % Save mask stacks to file
    save([outputFilename, '_top.mat'], 'topMasks');
    save([outputFilename, '_bot.mat'], 'botMasks');
end

function valid = validateImageSize(w, h, nMaxPool)
% When running images through the U-NET architecture, each max-pool step
% downsamples images by a factor of 2. So each image dimension must contain
% at least as many factors of 2 as the # of max-pool steps.
divisor = 2^nMaxPool;
valid = (mod(w, divisor) == 0) && (mod(h, divisor) == 0);