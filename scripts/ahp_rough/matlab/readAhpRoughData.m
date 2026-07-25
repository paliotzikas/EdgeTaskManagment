%--------------------------------------------------------------
% Reads task_events.csv and node_state.csv from an AHP + Rough Sets run.
% If iterationNumber is provided, baseFolder is treated as a batch folder:
%   baseFolder/scenarioName/iteN
% Otherwise, baseFolder must directly contain the CSV files.
%--------------------------------------------------------------
function [taskEvents, nodeState, runFolder] = readAhpRoughData(baseFolder, iterationNumber, scenarioName)
    if(~exist('baseFolder','var') || isempty(baseFolder))
        baseFolder = getConfiguration(1);
    end

    if(~exist(baseFolder, 'dir') && exist(fullfile('..', 'output', baseFolder), 'dir'))
        baseFolder = fullfile('..', 'output', baseFolder);
    end

    if(exist('iterationNumber','var') && ~isempty(iterationNumber))
        if(~exist('scenarioName','var') || isempty(scenarioName))
            scenarioName = getConfiguration(2);
        end
        runFolder = fullfile(baseFolder, scenarioName, strcat('ite', int2str(iterationNumber)));
    else
        runFolder = baseFolder;
    end

    taskFile = fullfile(runFolder, 'task_events.csv');
    nodeFile = fullfile(runFolder, 'node_state.csv');

    if(~isfile(taskFile))
        error('Cannot find task events file: %s', taskFile);
    end

    if(~isfile(nodeFile))
        error('Cannot find node state file: %s', nodeFile);
    end

    taskEvents = readtable(taskFile, 'Delimiter', ',');
    nodeState = readtable(nodeFile, 'Delimiter', ',');
end
