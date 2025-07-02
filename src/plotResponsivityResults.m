function fig1 = plotResponsivityResults(results)
% plotResponsivityResults - Visualises output from analyse_responsivity_xyz
%
% Inputs:
%   results : structure output from analyse_responsivity
%
% Plots:
%   1) Call rate over time with buzz readiness markers
%   2) Call timings as vertical lines with call durations labeled

% Extract variables
callTimes = results.callTimes;
Rc_n = results.Rc_n;
R = results.R;
Ta = results.Ta;
Tb = results.Tb;
t_call = results.t_call;
readinessTime = results.readinessTime;
readinessIndex = results.readinessIndex;

% Define time axes for plotting
timeMid = callTimes(2:end);    % Corresponds to Rc_n

% Create figure and layout
fig1 = figure('Color','w', 'Position',[100 100 1200 800]);
tiledlayout(2,1, 'Padding','compact');

% --- Subplot 1: Call Rate ---
nexttile;
plot(timeMid, Rc_n, '-o', 'MarkerFaceColor', 'b', 'LineWidth', 1.5);
hold on;
plot(readinessTime, Rc_n(readinessIndex + 1), 'rp', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
legend({'Call Rate', 'Buzz Readiness'}, ...
    'Location', 'northwest', 'Orientation','horizontal', 'Interpreter','latex');
ylabel('Call Rate $R_c$ (Hz)', 'Interpreter','latex', 'FontSize', 14);
xlabel('Time (s)', 'Interpreter','latex', 'FontSize', 14);
title('Call Rate and Buzz Readiness', 'Interpreter','latex', 'FontSize', 16);
grid on;
axis tight;
formatLatex(gca);

% --- Subplot 2: Call Timings as Vertical Lines ---
nexttile;
for i = 1:length(callTimes)
    xline(callTimes(i), 'Color', [0.6 0.6 0.6], 'LineWidth', 1.2);
    if ~isempty(t_call) && i < length(callTimes)
        text(callTimes(i), 0.5, sprintf('%.1f ms', 1000*t_call(i)), ...
            'Rotation', 90, 'HorizontalAlignment', 'right', 'FontSize', 12, 'Interpreter', 'latex');
    end
end
xline(readinessTime, '--b', 'LineWidth', 1.5, 'Label', 'Buzz Readiness', 'LabelVerticalAlignment','bottom', 'Interpreter', 'latex');
title(sprintf('Call Timestamps - Calls %d - Duration %.2f s - $C_{r}$ at $T_{b^*}$ = %.2f ms - $R_c$ = %.2f Hz', ...
    length(callTimes), max(callTimes), abs(round(results.Tb_prime*1000, 2)), round(results.Rc_n(results.readinessIndex), 2)), ...
    'Interpreter','latex', 'FontSize', 14);
xlabel('Time (s)', 'Interpreter','latex', 'FontSize', 14);
ylim([0 1]);
axis tight;
yticklabels([]);
grid off;
formatLatex(gca);

sgtitle('Responsivity Analysis', 'Interpreter','latex', 'FontSize', 18);
end