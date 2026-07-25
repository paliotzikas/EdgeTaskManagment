%--------------------------------------------------------------
% Plots destination policy comparison.
% Usage:
%   plotDestinationComparison('15-07-2026_02-30')
%   plotDestinationComparison('../output/15-07-2026_02-30')
%--------------------------------------------------------------
function [] = plotDestinationComparison(baseFolder)
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
    requiredColumns = {'destination_policy','total_waiting_tasks_mean','queue_imbalance_mean','received_offloaded_mean'};
    for i = 1:length(requiredColumns)
        if(~ismember(requiredColumns{i}, summary.Properties.VariableNames))
            error('scenario_summary.csv does not include %s. Re-run analyze_run.py.', requiredColumns{i});
        end
    end

    plotFolder = fullfile(comparisonFolder, 'destination_plots');
    if(~exist(plotFolder, 'dir'))
        mkdir(plotFolder);
    end

    labels = cellstr(summary.destination_policy);
    colors = destinationColors(height(summary));

    plotDestinationBar(labels, summary.total_waiting_tasks_mean, summary.total_waiting_tasks_ci95, ...
        'Final Waiting Tasks', 'destination_total_waiting_tasks', plotFolder, colors);

    plotDestinationBar(labels, summary.queue_imbalance_mean, summary.queue_imbalance_ci95, ...
        'Queue Imbalance (max - min)', 'destination_queue_imbalance', plotFolder, colors);

    plotDestinationBar(labels, summary.received_offloaded_mean, summary.received_offloaded_ci95, ...
        'Received Offloaded Tasks', 'destination_received_offloads', plotFolder, colors);

    plotDestinationBar(labels, summary.completed_offloaded_mean, summary.completed_offloaded_ci95, ...
        'Completed Offloaded Tasks', 'destination_completed_offloads', plotFolder, colors);
end

function [] = plotDestinationBar(labels, values, errors, yLabelText, fileName, plotFolder, colors)
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
    xtickangle(20);
    ylabel(yLabelText);
    title('Mean with 95% Confidence Interval');
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

function [colors] = destinationColors(count)
    baseColors = [
        0.55 0.00 0.00
        0.00 0.15 0.60
        0.00 0.35 0.10
        0.55 0.00 0.55
    ];
    colors = zeros(count, 3);
    for i = 1:count
        colors(i,:) = baseColors(mod(i-1, size(baseColors, 1)) + 1, :);
    end
end
