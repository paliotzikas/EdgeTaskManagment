%--------------------------------------------------------------
% Saves the active figure under the selected run folder.
%--------------------------------------------------------------
function [] = saveAhpFigure(fileName, runFolder)
    if(getConfiguration(6) ~= 1)
        return;
    end

    if(~exist('runFolder','var') || isempty(runFolder))
        runFolder = getConfiguration(1);
    end

    outputFolder = fullfile(runFolder, getConfiguration(7));
    if(~exist(outputFolder, 'dir'))
        mkdir(outputFolder);
    end

    fileFormat = getConfiguration(9);
    pos = getConfiguration(4);
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition',[0 0 pos(3) pos(4)]);
    set(gcf, 'PaperSize', [pos(3) pos(4)]);

    if(strcmp(fileFormat, 'png'))
        print(gcf, fullfile(outputFolder, strcat(fileName, '.png')), '-dpng', '-r300');
    elseif(strcmp(fileFormat, 'jpg') || strcmp(fileFormat, 'jpeg'))
        print(gcf, fullfile(outputFolder, strcat(fileName, '.jpg')), '-djpeg', '-r300');
    elseif(strcmp(fileFormat, 'tif') || strcmp(fileFormat, 'tiff'))
        print(gcf, fullfile(outputFolder, strcat(fileName, '.tif')), '-dtiff', '-r300');
    else
        saveas(gcf, fullfile(outputFolder, fileName), fileFormat);
    end
end
