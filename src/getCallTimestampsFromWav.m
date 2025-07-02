function [timestamps, waveform, fs] = getCallTimestampsFromWav(filename)
% getCallTimestampsFromWav - Interactively select call timestamps from waveform.
% - Click to mark peaks.
% - Press 'x' to stop.
% - Press 'p' to pause and zoom/pan.
% - Press 'r' to resume input.

    % Read audio file
    [waveform, fs] = audioread(filename);
    t = (0:length(waveform)-1)/fs;

    % Plot the waveform
    hFig = figure('Name', 'Click to mark peaks. Press ''p'' to pause, ''r'' to resume, ''x'' to stop.');
    plot(t, waveform, 'k');
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Click to mark peaks. [p]=Pause, [r]=Resume, [x]=Exit');
    grid on;
    hold on;

    % State can be 'input', 'paused', or 'stopped'
    state = 'input';
    setappdata(hFig, 'state', state);

    % Key press callback
    set(hFig, 'KeyPressFcn', @(src, event) ...
        setappdata(src, 'state', keyToState(event.Key)));

    % Init
    timestamps = [];

    % Main loop
    while ishandle(hFig)
        state = getappdata(hFig, 'state');

        switch state
            case 'stopped'
                break;

            case 'paused'
                pause(0.1);  % Just wait, allow zoom/pan
                continue;

            case 'input'
                k = waitforbuttonpress;
                state = getappdata(hFig, 'state'); % Recheck in case of keypress

                if k == 0 && strcmp(state, 'input') % Mouse click
                    cp = get(gca, 'CurrentPoint');
                    clickTime = cp(1,1);
                    if clickTime >= 0 && clickTime <= t(end)
                        timestamps(end+1) = clickTime;
                        plot(clickTime, 0, 'ro', 'MarkerFaceColor', 'r');
                    end
                end
        end
    end

    timestamps = sort(timestamps);

    if ishandle(hFig)
        close(hFig);
    end
end

function state = keyToState(key)
% Maps keyboard key to state
    switch lower(key)
        case 'x'
            state = 'stopped';
        case 'p'
            state = 'paused';
        case 'r'
            state = 'input';
        otherwise
            state = get(gcf, 'state'); % keep previous state
    end
end