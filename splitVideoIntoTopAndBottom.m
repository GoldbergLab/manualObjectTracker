function [topVideoData, botVideoData] = splitVideoIntoTopAndBottom(pathToVideo, topOrigin, topSize, botOrigin, botSize, saveToFile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% splitVideoIntoTopAndBottom: Split mouse tongue videos into a top half and
%   bottom half
% usage:  splitVideoIntoTopAndBottom(pathToVideo, topOrigin, topSize, botOrigin, botSize)
%
% where,
%    pathToVideo is the path to a video file of a mouse tongue
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
%    saveToFile is an optional logical indicating whether or not to save 
%       the top and bottom videos to file (default false).
%
% This function is designed to take mouse tongue videos and split it into
%   two separate videos, one of the top half, and one of the bottom half.
%   It accepts as inputs the desired top left coordinates of the top and
%   bottom videos, as well as the desired dimensions of the top and bottom
%   videos. It saves the two videos to the same path as the input video but
%   with "_top" or "_bot" appended to the filename. The output of this is
%   designed to be fed into the mouse tongue segmentation neural network
%   training algorithm.
% Note that due to downstream requirements, the video is arranged with the
%   dimensions in the order [frameNumber, height, width].
%
% See also: convertROIsToMasks, manualObjectTracker
%
% Version: 1.0
% Author:  Brian Kardon, concept by Teja Bollu
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('saveToFile', 'var')
    saveToFile = false;
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
    warning('Warning, top image size does not contain enough factors of 2 to satisfy %d max-pool steps', nMaxPool);
end
if ~validateImageSize(botSize(1), botSize(2), nMaxPool)
    warning('Warning, bot image size does not contain enough factors of 2 to satisfy %d max-pool steps', nMaxPool);
end

% Load video data, swap dimensions so frame # is dimension #1
videoData = permute(squeeze(loadVideoData(pathToVideo)), [3, 1, 2]);
[nFrames, height, width] = size(videoData);
fprintf('Loaded video - %d frames, %d x %d\n', nFrames, height, width);

% Prepare video slice coordinates
tx1 = topOrigin(1);
tx2 = tx1 + topSize(1) - 1;
ty1 = topOrigin(2);
ty2 = ty1 + topSize(2) - 1;
bx1 = botOrigin(1);
bx2 = bx1 + botSize(1) - 1;
by1 = botOrigin(2);
by2 = by1 + botSize(2) - 1;

% Split video data into top and bottom
topVideoData = videoData(:, ty1:ty2, tx1:tx2);
[nFrames, height, width] = size(topVideoData);
fprintf('Created top video - %d frames, %d high x %d wide\n', nFrames, height, width);
botVideoData = videoData(:, by1:by2, bx1:bx2);
[nFrames, height, width] = size(botVideoData);
fprintf('Created bot video - %d frames, %d high x %d wide\n', nFrames, height, width);

if saveToFile
    % Create output filepaths
    [path, name, ext] = fileparts(pathToVideo);
    topVideoPath = [fullfile(path, name), '_top', ext];
    botVideoPath = [fullfile(path, name), '_bot', ext];

    saveVideoData(topVideoData, topVideoPath);
    saveVideoData(botVideoData, botVideoPath);
end

function valid = validateImageSize(w, h, nMaxPool)
% When running images through the U-NET architecture, each max-pool step
% downsamples images by a factor of 2. So each image dimension must contain
% at least as many factors of 2 as the # of max-pool steps.
divisor = 2^nMaxPool;
valid = (mod(w, divisor) == 0) && (mod(h, divisor) == 0);