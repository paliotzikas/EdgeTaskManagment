%--------------------------------------------------------------
% Generates plots for every scenario and every iteration in one simulation.
% Usage:
%   plotAllScenarios('13-07-2026_19-06', 50)
%   plotAllScenarios('../output/13-07-2026_19-06', 50)
%--------------------------------------------------------------
function [] = plotAllScenarios(baseFolder, numIterations)
    if(~exist('baseFolder','var') || isempty(baseFolder))
        error('Please provide a simulation id or output folder.');
    end

    if(~exist(baseFolder, 'dir') && exist(fullfile('..', 'output', baseFolder), 'dir'))
        baseFolder = fullfile('..', 'output', baseFolder);
    end

    if(~exist(baseFolder, 'dir'))
        error('Cannot find simulation folder: %s', baseFolder);
    end

    if(~exist('numIterations','var') || isempty(numIterations))
        numIterations = detectIterationCount(baseFolder);
    end

    entries = dir(baseFolder);
    for s = 1:length(entries)
        if(entries(s).isdir == 0)
            continue;
        end

        scenarioName = entries(s).name;
        if(strcmp(scenarioName, '.') || strcmp(scenarioName, '..') || strcmp(scenarioName, 'comparison'))
            continue;
        end

        scenarioFolder = fullfile(baseFolder, scenarioName);
        if(~exist(fullfile(scenarioFolder, 'ite1'), 'dir'))
            continue;
        end

        fprintf('Plotting scenario %s (%d iterations)\n', scenarioName, numIterations);
        for i = 1:numIterations
            iterationFolder = fullfile(scenarioFolder, strcat('ite', int2str(i)));
            if(exist(iterationFolder, 'dir'))
                plotAll(baseFolder, i, scenarioName);
                close all;
            else
                warning('Skipping missing folder: %s', iterationFolder);
            end
        end
    end
end

function [count] = detectIterationCount(baseFolder)
    count = 0;
    entries = dir(baseFolder);
    for s = 1:length(entries)
        if(entries(s).isdir == 0 || strcmp(entries(s).name, '.') || strcmp(entries(s).name, '..'))
            continue;
        end

        scenarioFolder = fullfile(baseFolder, entries(s).name);
        iterationEntries = dir(fullfile(scenarioFolder, 'ite*'));
        scenarioCount = 0;
        for i = 1:length(iterationEntries)
            if(iterationEntries(i).isdir == 1)
                scenarioCount = scenarioCount + 1;
            end
        end
        count = max(count, scenarioCount);
    end
end
