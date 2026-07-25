%--------------------------------------------------------------
% Plots base execution time vs delayed execution time for started tasks.
%--------------------------------------------------------------
function [] = plotExecutionDelay(baseFolder, iterationNumber, scenarioName)
    if(~exist('iterationNumber','var'))
        [taskEvents, ~, runFolder] = readAhpRoughData(baseFolder);
    elseif(~exist('scenarioName','var') || isempty(scenarioName))
        [taskEvents, ~, runFolder] = readAhpRoughData(baseFolder, iterationNumber);
    else
        [taskEvents, ~, runFolder] = readAhpRoughData(baseFolder, iterationNumber, scenarioName);
    end

    started = taskEvents(strcmp(taskEvents.event, 'STARTED'), :);
    delayedExecution = started.base_execution_time .* started.delay_multiplier;

    hFig = figure;
    scatter(started.base_execution_time, delayedExecution, 18, started.node_id, 'filled');
    hold on;
    maxValue = max(delayedExecution);
    plot([0 maxValue], [0 maxValue], '--k', 'LineWidth', 1);
    hold off;
    xlabel('Base Execution Time (s)');
    ylabel('Actual Execution Time (s)');
    cb = colorbar;
    ylabel(cb, 'Node ID');
    applyFigureStyle();
    saveAhpFigure('execution_delay', runFolder);
end
