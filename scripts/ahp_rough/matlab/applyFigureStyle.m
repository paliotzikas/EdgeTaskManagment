%--------------------------------------------------------------
% Applies the same figure style used by the EdgeCloudSim examples.
%--------------------------------------------------------------
function [] = applyFigureStyle()
    pos = getConfiguration(4);
    fontSizeArray = getConfiguration(5);

    set(gcf, 'Units','centimeters');
    set(gcf, 'Position',pos);
    set(0,'DefaultAxesFontName','Times New Roman');
    set(0,'DefaultTextFontName','Times New Roman');
    set(gca,'FontSize',fontSizeArray(3));
    set(get(gca,'Xlabel'),'FontSize',fontSizeArray(1));
    set(get(gca,'Ylabel'),'FontSize',fontSizeArray(1));
    grid on;
    box on;
end
