%--------------------------------------------------------------
% Plots adaptive threshold sensitivity from comparison/scenario_summary.csv.
% Usage:
%   plotSensitivityAdaptiveThreshold('13-07-2026_21-00')
%   plotSensitivityAdaptiveThreshold('../output/13-07-2026_21-00')
%--------------------------------------------------------------
function [] = plotSensitivityAdaptiveThreshold(baseFolder)
    if(~exist('baseFolder','var') || isempty(baseFolder))
        error('Please provide a simulation id or output folder.');
    end

    if(~exist(baseFolder, 'dir') && exist(fullfile('..', 'output', baseFolder), 'dir'))
        baseFolder = fullfile('..', 'output', baseFolder);
    end

    comparisonFolder = fullfile(baseFolder, 'comparison');
    summaryFile = fullfile(comparisonFolder, 'scenario_summary.csv');
    if(~isfile(summaryFile))
        error('Cannot find scenario_summary.csv. Run analyze_run.py first.');
    end

    summary = readtable(summaryFile, 'Delimiter', ',');
    requiredColumns = {'threshold_multiplier_mean','threshold_mode','offload_rate_mean','total_waiting_tasks_mean'};
    for i = 1:length(requiredColumns)
        if(~ismember(requiredColumns{i}, summary.Properties.VariableNames))
            error('scenario_summary.csv does not include %s. Re-run analyze_run.py.', requiredColumns{i});
        end
    end

    adaptiveRows = summary(strcmp(summary.threshold_mode, 'ADAPTIVE_RATE'), :);
    adaptiveRows = sortrows(adaptiveRows, 'threshold_multiplier_mean');
    [~, uniqueIndex] = unique(adaptiveRows.threshold_multiplier_mean, 'stable');
    adaptiveRows = adaptiveRows(uniqueIndex, :);
    fixedRows = summary(strcmp(summary.threshold_mode, 'FIXED'), :);

    plotFolder = fullfile(comparisonFolder, 'adaptive_threshold_plots');
    if(~exist(plotFolder, 'dir'))
        mkdir(plotFolder);
    end

    plotAdaptiveMetric(adaptiveRows, fixedRows, 'offload_rate_mean', 'offload_rate_ci95', 100, ...
        'Offload Rate (%)', 'adaptive_threshold_offload_rate', plotFolder);

    plotAdaptiveMetric(adaptiveRows, fixedRows, 'offloaded_mean', 'offloaded_ci95', 1, ...
        'Offloaded Tasks', 'adaptive_threshold_offloaded_tasks', plotFolder);

    plotAdaptiveMetric(adaptiveRows, fixedRows, 'total_waiting_tasks_mean', 'total_waiting_tasks_ci95', 1, ...
        'Final Waiting Tasks', 'adaptive_threshold_final_queue', plotFolder);

    plotAdaptiveMetric(adaptiveRows, fixedRows, 'completion_rate_mean', 'completion_rate_ci95', 100, ...
        'Completion Rate (%)', 'adaptive_threshold_completion_rate', plotFolder);
end

function [] = plotAdaptiveMetric(adaptiveRows, fixedRows, metricName, ciName, multiplier, yLabelText, fileName, plotFolder)
    hFig = figure('Visible', 'off');
    x = adaptiveRows.threshold_multiplier_mean;
    y = adaptiveRows.(metricName) * multiplier;
    e = adaptiveRows.(ciName) * multiplier;
    errorbar(x, y, e, '-o', 'Color', [0 0.15 0.6], ...
        'MarkerFaceColor', 'w', 'LineWidth', 1.2, 'MarkerSize', 5);
    hold on;
    if(height(fixedRows) > 0)
        fixedValue = fixedRows.(metricName)(1) * multiplier;
        plot([min(x) max(x)], [fixedValue fixedValue], '--', 'Color', [0.55 0 0], 'LineWidth', 1.1);
        legend({'ADAPTIVE\_RATE','FIXED threshold'}, 'Location', 'best');
    end
    hold off;
    xlabel('threshold\_multiplier');
    ylabel(yLabelText);
    title('Mean with 95% Confidence Interval');
    set(gca,'XTick',x);
    set(0,'DefaultAxesFontName','Times New Roman');
    set(0,'DefaultTextFontName','Times New Roman');
    set(gca,'FontSize',11);
    grid on;
    box on;
    set(gcf, 'Units','centimeters');
    set(gcf, 'Position',[6 3 13 9]);
    print(gcf, fullfile(plotFolder, strcat(fileName, '.png')), '-dpng', '-r300');
    close(gcf);
end
