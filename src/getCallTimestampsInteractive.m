function [callData, waveform, fs] = getCallTimestampsInteractive(filename)
% Interactive call marker with:
% - Click-to-select region center
% - Adjustable vertical boundaries (← → ↑ ↓)
% - Local peak detection
% - Undo (Y or Cmd/Ctrl+Z)
% - Pause/resume (p/r)
% - Duration calculation
%
% Output:
%   callData: struct array with fields:
%       startTime, endTime, peakTime, peakAmp, duration

[waveform, fs] = audioread(filename);
t = (0:length(waveform)-1)/fs;

% Setup plot
hFig = figure('Name', 'Interactive Call Picker');
plot(t, waveform, 'k');
xlabel('Time (s)');
ylabel('Amplitude');
title('Press "s" to start. "p"=pause, "r"=resume, "x"=exit');
grid on;
hold on;

% Shared data
setappdata(hFig, 'state', 'idle');
setappdata(hFig, 'width', 0.005);  % 5 ms
setappdata(hFig, 'callData', struct([]));
setappdata(hFig, 'undoStack', {});
assignin('base', 'waveform', waveform); assignin('base', 'fs', fs);

% Callbacks
set(hFig, 'KeyPressFcn', @keyHandler);
set(hFig, 'WindowButtonDownFcn', @mouseClickHandler);

% Wait loop
while ishandle(hFig)
    if strcmp(getappdata(hFig, 'state'), 'done')
        break;
    end
    pause(0.05);
end

% Output
callData = getappdata(hFig, 'callData');
if ishandle(hFig), close(hFig); end
end

% ===== CALLBACKS ===== %

function keyHandler(~, event)
hFig = gcf;
state = getappdata(hFig, 'state');
callData = getappdata(hFig, 'callData');
undoStack = getappdata(hFig, 'undoStack');

switch lower(event.Key)
    case 's'
        setappdata(hFig, 'state', 'input');
        title('Click center of call region. [←/→/↑/↓]=adjust, [Y]=undo');

    case 'p'
        setappdata(hFig, 'state', 'paused');
        title('Paused. Press "r" to resume');

    case 'r'
        setappdata(hFig, 'state', 'input');
        title('Click center of call region. [←/→/↑/↓]=adjust, [Y]=undo');

    case 'x'
        setappdata(hFig, 'state', 'done');

    case 'leftarrow'
        moveLast(-0.0005);
    case 'rightarrow'
        moveLast(0.0005);
    case 'uparrow'
        resizeLast(0.0005);
    case 'downarrow'
        resizeLast(-0.0005);

    case 'y'
        if ~isempty(callData)
            % Remove last call and push to undo stack
            undoStack = getappdata(hFig, 'undoStack');
            undoStack{end+1} = callData(end);
            callData(end) = [];
            setappdata(hFig, 'callData', callData);
            setappdata(hFig, 'undoStack', undoStack);
            redrawAll();
        elseif ~isempty(getappdata(hFig, 'undoStack'))
            % Restore last undo
            undoStack = getappdata(hFig, 'undoStack');
            restored = undoStack{end};
            undoStack(end) = [];
            callData = getappdata(hFig, 'callData');
            callData(end+1) = restored;
            setappdata(hFig, 'callData', callData);
            setappdata(hFig, 'undoStack', undoStack);
            redrawAll();
        end

    case 'z'
        if ismac && ismember('command', event.Modifier)
            keyHandler([], struct('Key','y'));
        elseif (ispc || isunix) && ismember('control', event.Modifier)
            keyHandler([], struct('Key','y'));
        end
end
end

function mouseClickHandler(~, ~)
hFig = gcf;
if ~strcmp(getappdata(hFig, 'state'), 'input')
    return;
end

cp = get(gca, 'CurrentPoint');
centerT = cp(1,1);
width = getappdata(hFig, 'width');
[y, fs] = evalin('base', 'deal(waveform, fs)');
t = (0:length(y)-1)/fs;

% Define region
startT = max(0, centerT - width/2);
endT   = min(t(end), centerT + width/2);
idx = find(t >= startT & t <= endT);
if isempty(idx), return; end

% Find peak
[peakAmp, relIdx] = max(abs(y(idx)));
peakT = t(idx(relIdx));

call = struct( ...
    'startTime', startT, ...
    'endTime', endT, ...
    'peakTime', peakT, ...
    'peakAmp', peakAmp, ...
    'duration', endT - startT);

callData = getappdata(hFig, 'callData');
if isempty(callData)
    callData = call;  % initialise
else
    callData(end+1) = call;  % append
end
setappdata(hFig, 'callData', callData);
redrawAll();
end

function redrawAll()
hFig = gcf;
[y, fs] = evalin('base', 'deal(waveform, fs)');
t = (0:length(y)-1)/fs;
cla;
plot(t, y, 'k');
xlabel('Time (s)'); ylabel('Amplitude'); grid on; hold on;

callData = getappdata(hFig, 'callData');
for i = 1:numel(callData)
    r = callData(i);
    xline(r.startTime, 'g', 'LineWidth', 1);
    xline(r.endTime, 'r', 'LineWidth', 1);
    plot(r.peakTime, r.peakAmp, 'ro', 'MarkerFaceColor', 'r');
end
end

% ===== ADJUSTMENTS ===== %

function moveLast(dt)
hFig = gcf;
callData = getappdata(hFig, 'callData');
if isempty(callData), return; end
[y, fs] = evalin('base', 'deal(waveform, fs)');
t = (0:length(y)-1)/fs;

r = callData(end);
r.startTime = max(0, r.startTime + dt);
r.endTime = min(t(end), r.endTime + dt);
idx = find(t >= r.startTime & t <= r.endTime);
[r.peakAmp, relIdx] = max(abs(y(idx)));
r.peakTime = t(idx(relIdx));
r.duration = r.endTime - r.startTime;

callData(end) = r;
setappdata(hFig, 'callData', callData);
redrawAll();
end

function resizeLast(dw)
hFig = gcf;
callData = getappdata(hFig, 'callData');
if isempty(callData), return; end
[y, fs] = evalin('base', 'deal(waveform, fs)');
t = (0:length(y)-1)/fs;

r = callData(end);
r.startTime = max(0, r.startTime - dw/2);
r.endTime   = min(t(end), r.endTime + dw/2);
idx = find(t >= r.startTime & t <= r.endTime);
[r.peakAmp, relIdx] = max(abs(y(idx)));
r.peakTime = t(idx(relIdx));
r.duration = r.endTime - r.startTime;

callData(end) = r;
setappdata(hFig, 'callData', callData);
redrawAll();
end