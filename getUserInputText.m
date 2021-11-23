function outText = getUserInputText(numLines, initialText)
if ~exist('initialText', 'var')
    initialText = {''};
end

% Create a figure
f = figure;
% Add an edit box to the figure
inputBox = uicontrol('style','edit', 'Max', numLines, 'Min', 1);
borderWidth = 50;
inputBox.Position = [borderWidth, borderWidth, f.InnerPosition(3:4)-borderWidth*2];

% Prepare intial text, including truncating it to numLines if necessary
if ~iscell(initialText)
    initialText = {initialText};
end

text = repmat({''}, [1, numLines]);
for k = 1:min([numLines, length(initialText)])
    text{k} = initialText{k};
end
inputBox.String = text;

uiwait(f);
