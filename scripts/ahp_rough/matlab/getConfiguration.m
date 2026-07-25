%--------------------------------------------------------------
% Configuration for the AHP + Rough Sets Matlab plots.
%--------------------------------------------------------------
function [ret_val] = getConfiguration(argType)
    if(argType == 1)
        ret_val = '../output/manual/default_config'; %folder with task_events.csv and node_state.csv
    elseif(argType == 2)
        ret_val = 'default_config'; %scenario name for batch output folders
    elseif(argType == 3)
        ret_val = 1; %number of iterations for batch output folders
    elseif(argType == 4)
        ret_val=[6 3 12 9]; %figure position in centimeters
    elseif(argType == 5)
        ret_val = [13 11 11]; %font sizes: axis labels, legend, ticks
    elseif(argType == 6)
        ret_val = 1; %save figures
    elseif(argType == 7)
        ret_val = 'plots'; %plot output folder name under the current run folder
    elseif(argType == 9)
        ret_val = 'png'; %figure format: png, pdf, jpg, tif
    elseif(argType == 8)
        ret_val = {'Node 0','Node 1','Node 2','Node 3','Node 4'};
    elseif(argType == 20)
        ret_val=[0.55 0 0]; %color 1
    elseif(argType == 21)
        ret_val=[0 0.15 0.6]; %color 2
    elseif(argType == 22)
        ret_val=[0 0.23 0]; %color 3
    elseif(argType == 23)
        ret_val=[0.6 0 0.6]; %color 4
    elseif(argType == 24)
        ret_val=[0.08 0.08 0.08]; %color 5
    elseif(argType == 25)
        ret_val=[0 0.55 0.55]; %color 6
    elseif(argType == 40)
        ret_val={'-','--',':','-.','-','--',':','-.'}; %line styles
    end
end
