%--------------------------------------------------------------
% Plots max_offloads_per_event sensitivity from comparison/scenario_summary.csv.
% Usage:
%   plotSensitivityMaxOffloads('13-07-2026_20-30')
%   plotSensitivityMaxOffloads('../output/13-07-2026_20-30')
%--------------------------------------------------------------
function [] = plotSensitivityMaxOffloads(baseFolder)
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
    if(~ismember('max_offloads_per_event_mean', summary.Properties.VariableNames))
        error('scenario_summary.csv does not include max_offloads_per_event columns. Re-run analyze_run.py.');
    end

    summary = sortrows(summary, 'max_offloads_per_event_mean');
    x = summary.max_offloads_per_event_mean;

    plotFolder = fullfile(comparisonFolder, 'sensitivity_plots');
    if(~exist(plotFolder, 'dir'))
        mkdir(plotFolder);
    end

    plotSensitivityMetric(x, summary.offload_rate_mean * 100, summary.offload_rate_ci95 * 100, ...
        'Offload Rate (%)', 'sensitivity_max_offloads_offload_rate', plotFolder);

    plotSensitivityMetric(x, summary.offloaded_mean, summary.offloaded_ci95, ...
        'Offloaded Tasks', 'sensitivity_max_offloads_offloaded_tasks', plotFolder);

    plotSensitivityMetric(x, summary.total_waiting_tasks_mean, summary.total_waiting_tasks_ci95, ...
        'Final Waiting Tasks', 'sensitivity_max_offloads_final_queue', plotFolder);

    plotSensitivityMetric(x, summary.completion_rate_mean * 100, summary.completion_rate_ci95 * 100, ...
        'Completion Rate (%)', 'sensitivity_max_offloads_completion_rate', plotFolder);
end

function [] = plotSensitivityMetric(x, values, errors, yLabelText, fileName, plotFolder)
    hFig = figure('Visible', 'off');
    errorbar(x, values, errors, '-o', 'Color', [0.55 0 0], ...
        'MarkerFaceColor', 'w', 'LineWidth', 1.2, 'MarkerSize', 5);
    xlabel('max\_offloads\_per\_event');
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
