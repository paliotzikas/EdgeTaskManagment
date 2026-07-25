%--------------------------------------------------------------
% Generates aggregate comparison plots from output/<simulation_id>/comparison.
% Usage:
%   plotComparison('13-07-2026_19-06')
%   plotComparison('../output/13-07-2026_19-06')
%--------------------------------------------------------------
function [] = plotComparison(baseFolder)
    if(~exist('baseFolder','var') || isempty(baseFolder))
        error('Please provide a simulation id or output folder.');
    end

    if(~exist(baseFolder, 'dir') && exist(fullfile('..', 'output', baseFolder), 'dir'))
        baseFolder = fullfile('..', 'output', baseFolder);
    end

    comparisonFolder = fullfile(baseFolder, 'comparison');
    if(~exist(comparisonFolder, 'dir'))
        error('Cannot find comparison folder: %s. Run analyze_run.py first.', comparisonFolder);
    end

    summaryFile = fullfile(comparisonFolder, 'scenario_summary.csv');
    iterationFile = fullfile(comparisonFolder, 'iteration_comparison.csv');
    if(~isfile(summaryFile) || ~isfile(iterationFile))
        error('Missing comparison CSV files. Run analyze_run.py first.');
    end

    summary = readtable(summaryFile, 'Delimiter', ',');
    iterations = readtable(iterationFile, 'Delimiter', ',');

    plotFolder = fullfile(comparisonFolder, 'plots');
    if(~exist(plotFolder, 'dir'))
        mkdir(plotFolder);
    end

    if(ismember('decision_mode', summary.Properties.VariableNames))
        labels = cellstr(summary.decision_mode);
    else
        labels = cellstr(summary.policy);
    end
    colors = comparisonColors(height(summary));

    plotBarWithError(labels, summary.completion_rate_mean * 100, summary.completion_rate_ci95 * 100, ...
        'Completion Rate (%)', 'comparison_completion_rate_ci95', plotFolder, colors);

    plotBarWithError(labels, summary.offload_rate_mean * 100, summary.offload_rate_ci95 * 100, ...
        'Offload Rate (%)', 'comparison_offload_rate_ci95', plotFolder, colors);

    plotBarWithError(labels, summary.offloaded_mean, summary.offloaded_ci95, ...
        'Offloaded Tasks', 'comparison_offloaded_tasks_ci95', plotFolder, colors);

    plotBarWithError(labels, summary.offload_per_delayed_mean, summary.offload_per_delayed_ci95, ...
        'Offloaded Tasks per Delayed Task', 'comparison_offload_per_delayed_ci95', plotFolder, colors);

    plotBarWithError(labels, summary.mean_actual_execution_time_mean, summary.mean_actual_execution_time_ci95, ...
        'Mean Actual Execution Time (s)', 'comparison_actual_execution_time_ci95', plotFolder, colors);

    if(ismember('deadline_miss_rate_mean', summary.Properties.VariableNames))
        plotBarWithError(labels, summary.deadline_miss_rate_mean * 100, summary.deadline_miss_rate_ci95 * 100, ...
            'Deadline Miss Rate (%)', 'comparison_deadline_miss_rate_ci95', plotFolder, colors);
    end

    if(ismember('queue_imbalance_mean', summary.Properties.VariableNames))
        plotBarWithError(labels, summary.queue_imbalance_mean, summary.queue_imbalance_ci95, ...
            'Queue Imbalance', 'comparison_queue_imbalance_ci95', plotFolder, colors);
    end

    if(ismember('proactive_trigger_events_mean', summary.Properties.VariableNames))
        plotBarWithError(labels, summary.proactive_trigger_events_mean, summary.proactive_trigger_events_ci95, ...
            'Proactive Trigger Events', 'comparison_proactive_triggers_ci95', plotFolder, colors);
        plotBarWithError(labels, summary.reactive_trigger_events_mean, summary.reactive_trigger_events_ci95, ...
            'Reactive Trigger Events', 'comparison_reactive_triggers_ci95', plotFolder, colors);
    end

    plotIterationTrend(iterations, 'completion_rate', 100, 'Completion Rate (%)', ...
        'comparison_completion_rate_trend', plotFolder);
    plotIterationTrend(iterations, 'offload_rate', 100, 'Offload Rate (%)', ...
        'comparison_offload_rate_trend', plotFolder);
    plotIterationTrend(iterations, 'offloaded', 1, 'Offloaded Tasks', ...
        'comparison_offloaded_tasks_trend', plotFolder);
    if(ismember('deadline_miss_rate', iterations.Properties.VariableNames))
        plotIterationTrend(iterations, 'deadline_miss_rate', 100, 'Deadline Miss Rate (%)', ...
            'comparison_deadline_miss_rate_trend', plotFolder);
        plotIterationTrend(iterations, 'queue_imbalance', 1, 'Queue Imbalance', ...
            'comparison_queue_imbalance_trend', plotFolder);
    end
end

function [] = plotBarWithError(labels, values, errors, yLabelText, fileName, plotFolder, colors)
    hFig = figure('Visible', 'off');
    b = bar(values);
    b.FaceColor = 'flat';
    for i = 1:length(values)
        b.CData(i,:) = colors(i,:);
    end
    hold on;
    errorbar(1:length(values), values, errors, 'k.', 'LineWidth', 1.1);
    hold off;
    set(gca, 'XTick', 1:length(labels));
    set(gca, 'XTickLabel', labels);
    xtickangle(25);
    ylabel(yLabelText);
    title('Mean with 95% Confidence Interval');
    applyComparisonStyle();
    saveComparisonFigure(fileName, plotFolder);
end

function [] = plotIterationTrend(iterations, metricName, multiplier, yLabelText, fileName, plotFolder)
    hFig = figure('Visible', 'off');
    hold on;
    if(ismember('decision_mode', iterations.Properties.VariableNames))
        groupValues = iterations.decision_mode;
    else
        groupValues = iterations.policy;
    end
    policies = unique(groupValues, 'stable');
    colors = comparisonColors(length(policies));
    markers = {'-o','-s','-^','-d','-v','-x'};
    for i = 1:length(policies)
        policy = policies{i};
        rows = iterations(strcmp(groupValues, policy), :);
        y = rows.(metricName) * multiplier;
        plot(rows.iteration, y, markers{mod(i-1, length(markers)) + 1}, ...
            'Color', colors(i,:), 'LineWidth', 1.1, 'MarkerSize', 4);
    end
    hold off;
    xlabel('Iteration');
    ylabel(yLabelText);
    legend(policies, 'Location', 'best');
    applyComparisonStyle();
    saveComparisonFigure(fileName, plotFolder);
end

function [colors] = comparisonColors(count)
    baseColors = [
        0.55 0.00 0.00
        0.00 0.15 0.60
        0.00 0.35 0.10
        0.55 0.00 0.55
        0.10 0.10 0.10
        0.00 0.55 0.55
    ];
    colors = zeros(count, 3);
    for i = 1:count
        colors(i,:) = baseColors(mod(i-1, size(baseColors, 1)) + 1, :);
    end
end

function [] = applyComparisonStyle()
    set(0,'DefaultAxesFontName','Times New Roman');
    set(0,'DefaultTextFontName','Times New Roman');
    set(gca,'FontSize',11);
    grid on;
    box on;
end

function [] = saveComparisonFigure(fileName, plotFolder)
    set(gcf, 'Units','centimeters');
    set(gcf, 'Position',[6 3 13 9]);
    print(gcf, fullfile(plotFolder, strcat(fileName, '.png')), '-dpng', '-r300');
    close(gcf);
end
