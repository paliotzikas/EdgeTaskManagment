%--------------------------------------------------------------
% Plots rough scores for offloaded tasks over simulation time.
%--------------------------------------------------------------
function [] = plotOffloadScores(baseFolder, iterationNumber, scenarioName)
    if(~exist('iterationNumber','var'))
        [taskEvents, ~, runFolder] = readAhpRoughData(baseFolder);
    elseif(~exist('scenarioName','var') || isempty(scenarioName))
        [taskEvents, ~, runFolder] = readAhpRoughData(baseFolder, iterationNumber);
    else
        [taskEvents, ~, runFolder] = readAhpRoughData(baseFolder, iterationNumber, scenarioName);
    end

    offloaded = taskEvents(strcmp(taskEvents.event, 'OFFLOADED'), :);
    if(isempty(offloaded))
        warning('No OFFLOADED events found.');
        return;
    end

    hFig = figure;
    scatter(offloaded.time, offloaded.rough_score, 18, offloaded.node_id, 'filled');
    xlabel('Simulation Time (s)');
    ylabel('Rough Score');
    cb = colorbar;
    ylabel(cb, 'Node ID');
    applyFigureStyle();
    saveAhpFigure('offload_scores', runFolder);
end
