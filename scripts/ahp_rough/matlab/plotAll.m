%--------------------------------------------------------------
% Generates all plots for one AHP + Rough Sets run.
% Usage:
%   plotAll()
%   plotAll('../output/manual/default_config')
%   plotAll('../output/13-07-2026_10-30', 1)
%   plotAll('../output/13-07-2026_10-30', 1, 'random_offloading')
%--------------------------------------------------------------
function [] = plotAll(baseFolder, iterationNumber, scenarioName)
    if(~exist('baseFolder','var') || isempty(baseFolder))
        baseFolder = getConfiguration(1);
    end

    if(~exist('iterationNumber','var'))
        plotArrivalRate(baseFolder);
        plotQueueSize(baseFolder);
        plotTaskEventCounts(baseFolder);
        plotOffloadScores(baseFolder);
        plotExecutionDelay(baseFolder);
    elseif(~exist('scenarioName','var') || isempty(scenarioName))
        plotArrivalRate(baseFolder, iterationNumber);
        plotQueueSize(baseFolder, iterationNumber);
        plotTaskEventCounts(baseFolder, iterationNumber);
        plotOffloadScores(baseFolder, iterationNumber);
        plotExecutionDelay(baseFolder, iterationNumber);
    else
        plotArrivalRate(baseFolder, iterationNumber, scenarioName);
        plotQueueSize(baseFolder, iterationNumber, scenarioName);
        plotTaskEventCounts(baseFolder, iterationNumber, scenarioName);
        plotOffloadScores(baseFolder, iterationNumber, scenarioName);
        plotExecutionDelay(baseFolder, iterationNumber, scenarioName);
    end
end
