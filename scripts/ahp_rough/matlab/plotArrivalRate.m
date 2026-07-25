%--------------------------------------------------------------
% Plots observed task arrival rate per node.
%--------------------------------------------------------------
function [] = plotArrivalRate(baseFolder, iterationNumber, scenarioName)
    if(~exist('iterationNumber','var'))
        [~, nodeState, runFolder] = readAhpRoughData(baseFolder);
    elseif(~exist('scenarioName','var') || isempty(scenarioName))
        [~, nodeState, runFolder] = readAhpRoughData(baseFolder, iterationNumber);
    else
        [~, nodeState, runFolder] = readAhpRoughData(baseFolder, iterationNumber, scenarioName);
    end

    hFig = figure;
    hold on;
    nodeIds = unique(nodeState.node_id)';
    styles = getConfiguration(40);
    legends = {};

    for i=1:length(nodeIds)
        nodeId = nodeIds(i);
        rows = nodeState(nodeState.node_id == nodeId, :);
        colorIndex = 20 + mod(i-1, 6);
        plot(rows.time, rows.observed_arrival_rate, char(styles(i)), ...
            'Color', getConfiguration(colorIndex), 'LineWidth', 1.1);
        legends{end+1} = strcat('Node ', int2str(nodeId));
    end

    hold off;
    xlabel('Simulation Time (s)');
    ylabel('Observed Arrival Rate (tasks/s)');
    lgnd = legend(legends, 'Location', 'NorthWest');
    fontSizeArray = getConfiguration(5);
    set(lgnd,'FontSize',fontSizeArray(2));
    applyFigureStyle();
    saveAhpFigure('arrival_rate', runFolder);
end
