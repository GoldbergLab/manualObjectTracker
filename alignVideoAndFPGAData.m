function startingTrialNums = alignVideoAndFPGAData(videoRootDirectories, dataFiles)
% dataFiles should be a cell array of either lick_struct files or t_stats
% files

f = figure('Units', 'normalized', 'Position', [0.1, 0, 0.8, 0.85]);
% Overwrite function close callback to prevent user from
% clicking "x", which would destroy data. User must use
% "Accept" button instead


set(f, 'CloseRequestFcn', @customCloseReqFcn);
% Create accept button, which resumes main thread execution
% when clicked.
acceptButton = uicontrol(f, 'Position',[10 10 200 20],'String','Accept trial alignments','Callback','uiresume(gcbf)');
%            pan(f, 'xon');
%            zoom(f, 'xon');

% Max diffs to show. If the FPGA/Video streams are misaligned by more than
% this number of trials, the use will not be able to align them. The
% smaller the number, the faster the interface can be prepared.
maxDiffs = 50;

[tdiffs.FPGA, tdiffs.Video] = get_tdiff_video(videoRootDirectories, dataFiles, maxDiffs);

sgtitle({'For each session, select the earliest starting trial interval',...
         'for FPGA and Video trials so they line up with each other.',...
         'Click Accept when done'});

f.UserData = struct();
f.UserData.seriesList = {'FPGA', 'Video'};
f.UserData.faceColors.FPGA = 'g';
f.UserData.faceColors.Video = 'c';
f.UserData.yVal.FPGA = 0;
f.UserData.yVal.Video = 0.5;
f.UserData.h = 0.5;
for sessionNum = 1:numel(videoRootDirectories)
    fprintf('Preparing interface for session #%d of %d...\n', sessionNum, numel(videoRootDirectories));
    ax(sessionNum) = subplot(numel(videoRootDirectories), 1, sessionNum, 'HitTest', 'off', 'YLimMode', 'manual');
    hold(ax(sessionNum), 'on');
    ax(sessionNum).UserData = struct();
    ax(sessionNum).UserData.selectedRectangle = struct();
    for seriesNum = 1:numel(f.UserData.seriesList)
        % For each series (FPGA and Video), add useful info to
        %   axis UserData
        series = f.UserData.seriesList{seriesNum};
        ax(sessionNum).UserData.sessionNum = sessionNum;
        ax(sessionNum).UserData.StartingTrialNum.(series) = 1;
        ax(sessionNum).UserData.selectedRectangle.(series) = [];
        ax(sessionNum).UserData.rectangles.(series) = matlab.graphics.primitive.Rectangle.empty();
        ax(sessionNum).UserData.tdiff.(series) = tdiffs.(series){sessionNum}; %tdiffs_FPGA{sessionNum};
        ax(sessionNum).UserData.t.(series) = [0, cumsum(ax(sessionNum).UserData.tdiff.(series))];

        seriesShift = ax(sessionNum).UserData.t.(series)(ax(sessionNum).UserData.StartingTrialNum.(series));
        for trialNum = 1:(numel(ax(sessionNum).UserData.t.(series))-1)
            % Create rectangles and save handles to axis UserData
            rectangleID.trialNum = trialNum;
            rectangleID.series = series;
            ax(sessionNum).UserData.rectangles.(series)(trialNum) = ...
                rectangle(ax(sessionNum), ...
                          'Position', [ax(sessionNum).UserData.t.(series)(trialNum) - seriesShift, f.UserData.yVal.(series), ax(sessionNum).UserData.tdiff.(series)(trialNum), f.UserData.h], ...
                          'FaceColor', f.UserData.faceColors.(series), ...
                          'ButtonDownFcn', @tdiffRectangleCallback, ...
                          'UserData', rectangleID);
        end
        xmaxSeries(seriesNum) = ax(sessionNum).UserData.t.(series)(min([numel(ax(sessionNum).UserData.t.(series)), 15]));
    end
    xmax = max(xmaxSeries);
    xlim(ax(sessionNum), [-0.05*xmax, xmax]);
%                 plot(ax(sessionNum), 1:numel(tdiff_FPGA), tdiff_FPGA, 1:numel(tdiff_Video), tdiff_Video);
    title(ax(sessionNum),abbreviateText(videoRootDirectories{sessionNum}, 120), 'Interpreter', 'none', 'HitTest', 'off');
    yticks(ax(sessionNum), [])
end
% Waits until accept button is clicked
uiwait(f);
% If user cancelled alignment, just exit:
if ~isvalid(f)
    startingTrialNums = [];
    return;
end
% Collect results from GUI into struct array
startingTrialNums = struct();
for sessionNum = 1:numel(videoRootDirectories)
    for seriesNum = 1:numel(f.UserData.seriesList)
        series = f.UserData.seriesList{seriesNum};
        startingTrialNums(sessionNum).(series) = ax(sessionNum).UserData.StartingTrialNum.(series);
    end
end
delete(f)

function customCloseReqFcn(src, callbackdata)
    selection = questdlg('Are you sure you want to discard your alignment? Use the ''Accept'' button instead to keep your alignment.',...
        'Are you sure?',...
        'Yes, discard','No, keep','Yes, discard'); 
    switch selection 
        case 'Yes, discard'
            delete(src);
        case 'No, keep'
            return;
    end

function [tdiff_fpga, tdiff_video] = get_tdiff_video(videoRootDirectories, dataFiles, maxDiffs)
% maxDiffs is normally Inf. If an integer, then it limits the # of diffs
% returned. This is for performance, as it can take a long time to
% graphically represent thousands of diffs, and is unnecessary, as the
% video and fpga should never be more than a few trials misaligned.
if ~exist('maxDiffs', 'var') || isempty(maxDiffs)
    maxDiffs = Inf;
end
for sessionNum=1:numel(videoRootDirectories)
    fprintf('Gathering video times for session #%d of %d...\n', sessionNum, numel(videoRootDirectories));
    trial_time = [];
    videoList = dir([videoRootDirectories{sessionNum},'\*.avi']);
    for videoNum=1:min([numel(videoList), maxDiffs])
        [~, videoName, ~] = fileparts(videoList(videoNum).name);
        videoNameParts = strsplit(videoName);
        dateParts = videoNameParts(5:7);
        hours = str2num(dateParts{1});
        minutes = str2num(dateParts{2});
        seconds = str2num(dateParts{3});
        trial_time(videoNum) = hours/24 + minutes/(24*60)+seconds/(24*60*60);
    end
    tdiff_video{sessionNum} = diff(trial_time);
    fprintf('\tRoot: %s\n', videoRootDirectories{sessionNum});
    fprintf('\t# diffs: %d\n', length(tdiff_video{sessionNum}));
end

for sessionNum=1:numel(dataFiles)
    fprintf('Gathering FPGA trial times for session #%d of %d...\n', sessionNum, numel(dataFiles));
    s = load(dataFiles{sessionNum}, 'lick_struct', 'l_sp_struct');
    if isfield(s, 'lick_struct')
        % This must be a lick_struct file.
        lick_struct = s.lick_struct;
    elseif isfield(s, 'l_sp_struct')
        % Data file must be a t_stats file - in that file, the lick struct
        % is stored under a different name.
        lick_struct = s.l_sp_struct;
    else
        error('Data file should either be a lick_struct file, or a t_stats file with the lick_struct stored under the field name l_sp_struct.');
    end
    numDiffs = min([length(lick_struct), maxDiffs]);
    tdiff_fpga{sessionNum} = diff([lick_struct(1:numDiffs).real_time]);
    fprintf('\tRoot: %s\n', dataFiles{sessionNum});
    fprintf('\t# diffs: %d\n', length(tdiff_fpga{sessionNum}));
end

function tdiffRectangleCallback(rectangle, event)
% This is a callback function for the time-alignment rectangles in
% tongueTipTrackerApp.mlapp.

currentSeries = rectangle.UserData.series;
ax = rectangle.Parent;
f = ax.Parent;
if ~isempty(ax.UserData.selectedRectangle)
    % Deselect previously selected rectangle, if any
    ax.UserData.selectedRectangle.(currentSeries).FaceColor = f.UserData.faceColors.(currentSeries);
    ax.UserData.selectedRectangle.(currentSeries) = [];
end
% Make rectangle the selected rectangle
rectangle.FaceColor = [1, 0, 0];
ax.UserData.selectedRectangle.(currentSeries) = rectangle;
% Shift all rectangles in that session/series
rectangles = ax.UserData.rectangles.(currentSeries);
ax.UserData.StartingTrialNum.(currentSeries) = rectangle.UserData.trialNum;
seriesShift = ax.UserData.t.(currentSeries)(ax.UserData.StartingTrialNum.(currentSeries));
for trialNum = 1:numel(rectangles)
    newPosition = [ax.UserData.t.(currentSeries)(trialNum) - seriesShift, f.UserData.yVal.(currentSeries), ax.UserData.tdiff.(currentSeries)(trialNum), f.UserData.h];
    rectangles(trialNum).Position = newPosition;
end