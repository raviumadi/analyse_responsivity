function fig3 = plotIPI_CR(results)
    fig3 = figure('Color', 'w', 'Position', [100 100 1200 600]);
    tiledlayout(1, 2, 'Padding', 'compact');

    % Plot 1: targetDistance_estimated vs Rc_n
    nexttile;
    plot(results.Rc_n, results.targetDistance_estimated, 'r.', 'MarkerSize', 20);

    ylabel('Estimated Target Distance (m)', 'Interpreter', 'latex', 'FontSize', 14);
    xlabel('Instantaneous Call Rate $R_c$ (Hz)', 'Interpreter', 'latex', 'FontSize', 14);
    title('Target Distance vs. Call Rate', 'Interpreter', 'latex', 'FontSize', 16);
    grid on;
    formatLatex(gca);

    % Plot 2: ipi vs Rc_n
    nexttile;
    plot(results.Rc_n, results.ipi, 'b.', 'MarkerSize', 20);
    ylabel('Inter-Pulse Interval (s)', 'Interpreter', 'latex', 'FontSize', 14);
    xlabel('Instantaneous Call Rate $R_c$ (Hz)', 'Interpreter', 'latex', 'FontSize', 14);
    title('IPI vs. Call Rate', 'Interpreter', 'latex', 'FontSize', 16);
    grid on;
    formatLatex(gca);
end