function fig2 = plotResponsivityCurve(results)
% plotResponsivityFromResults - Plot responsivity curves and highlight inflection point from results struct
%
% Input:
%   results : struct with fields including R, RcMax, readinessIndex, Tb_prime, ipi (or delta_t)

% Extract variables
if isfield(results, 'ipi')
    delta_t = results.ipi;    % Inter-phonation intervals
elseif isfield(results, 'delta_t')
    delta_t = results.delta_t;
else
    error('Results struct must contain ipi or delta_t field.');
end

R = results.R;               % Responsivity values (already 1./diff(delta_t))
Rc_max = results.RcMax;      % Max physiological call rate
readinessIndex = results.readinessIndex;
Tb_prime = results.Tb_prime;

% Calculate Rmax for plotting
Rmax = abs(abs(R) - Rc_max);

% Create figure
fig2 = figure('Color','w', 'Position', [100, 100, 1200, 500]);

% Subplot 1: Responsivity analysis
subplot(1,2,1);
plot(abs(R), 'b--', 'LineWidth', 2); hold on;
plot(Rmax, 'm-', 'LineWidth', 2);
plot(readinessIndex, Rmax(readinessIndex), 'm*', 'MarkerSize', 20, 'LineWidth', 3);
ylabel('Responsivity, $\mathcal{R}$', 'Interpreter', 'latex', 'FontSize', 14);
xlabel('Call Number', 'FontSize', 14);
axis square;
xt = xticks;
xlim([0 max(xt)]);
formatLatex(gca);

annotation('textbox', [0.22, 0.75, 0.25, 0.1], ...
    'String', '$$\mathcal{R}_n = \left|\frac{1}{\Delta t_{n+1} - \Delta t_n}\right|$$', ...
    'Interpreter', 'latex', 'FontSize', 14, 'Color', 'b', 'EdgeColor', 'none');

annotation('textbox', [0.22, 0.65, 0.25, 0.1], ...
    'String', '$$n^* = \arg\min_n |\mathcal{R}_n - C_{r,\mathrm{max}}|$$', ...
    'Interpreter', 'latex', 'FontSize', 14, 'Color', 'm', 'EdgeColor', 'none');

% Subplot 2: Tb* from IPI difference
subplot(1,2,2);
plot(1:length(delta_t), delta_t*1000, '-o', 'MarkerFaceColor', 'b');
xlabel('Call Number', 'FontSize', 14);
ylabel('$\Delta t$ (IPI), ms', 'Interpreter', 'latex', 'FontSize', 14);
title('$T_{b^*}$ from $\mathcal{R}$ \& IPIs', 'Interpreter', 'latex', 'FontSize', 16);
hold on
% Fix x-axis limits and ticks to match call numbers
xlim([1 length(delta_t)]);
xticks(1:length(delta_t));
axis square;

% Mark Tb* on plot
plot([readinessIndex readinessIndex+1], delta_t([readinessIndex readinessIndex+1])*1000, 'go', 'MarkerFaceColor', 'm');
line([readinessIndex+0.5 readinessIndex+0.5], delta_t([readinessIndex readinessIndex+1])*1000, ...
    'Color', 'g', 'LineStyle', '--', 'LineWidth', 2);
text(readinessIndex + 1, mean(delta_t([readinessIndex readinessIndex+1])*1000), ...
    sprintf('$T_{b^*} = %.2f$ ms', abs(1000*Tb_prime)), ...
    'Interpreter', 'latex', 'FontSize', 14, 'Color', 'm');

formatLatex(gca);
end