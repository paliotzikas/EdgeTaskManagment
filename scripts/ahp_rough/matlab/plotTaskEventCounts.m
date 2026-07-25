%--------------------------------------------------------------
% Plots the number of ARRIVED, FINISHED, and OFFLOADED tasks per node.
%--------------------------------------------------------------
function [] = plotTaskEventCounts(baseFolder, iterationNumber, scenarioName)
    if(~exist('iterationNumber','var'))
        [taskEvents, ~, runFolder] = readAhpRoughData(baseFolder);
    elseif(~exist('scenarioName','var') || isempty(scenarioName))
        [taskEvents, ~, runFolder] = readAhpRoughData(baseFolder, iterationNumber);
    else
        [taskEvents, ~, runFolder] = readAhpRoughData(baseFolder, iterationNumber, scenarioName);
    end

    nodeIds = unique(taskEvents.node_id)';
    eventNames = {'ARRIVED','FINISHED','OFFLOADED'};
    results = zeros(length(nodeIds), length(eventNames));

    for i=1:length(nodeIds)
        for j=1:length(eventNames)
            results(i,j) = sum(taskEvents.node_id == nodeIds(i) & strcmp(taskEvents.event, eventNames{j}));
        end
    end

    hFig = figure;
    bar(nodeIds, results);
    xlabel('Node ID');
    ylabel('Task Count');
    lgnd = legend(eventNames, 'Location', 'NorthWest');
    fontSizeArray = getConfiguration(5);
    set(lgnd,'FontSize',fontSizeArray(2));
    applyFigureStyle();
    saveAhpFigure('task_event_counts', runFolder);
end
