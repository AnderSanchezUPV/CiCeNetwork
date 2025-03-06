function plotSetup = setupGradientDistributionAxes(weightLayerNames,params,figidx)
f = figure(figidx);
t = tiledlayout(f,"flow",TileSpacing="tight");
t.Title.String = "Gradient Distributions";

% To avoid updating the same values every epoch, set up axis 
% information before the training loop.
for i = 1 : numel(weightLayerNames)
    tiledAx = nexttile(t,i);

    % Set up the label names and titles.
    xlabel(tiledAx,"Gradients");
    ylabel(tiledAx,"Epochs");
    zlabel(tiledAx,"Counts");
    grid(tiledAx,"on")
    title(tiledAx,sprintf("%s (%d)",weightLayerNames(i),params.numLearnables(i)));

    % Rotate the view.
    view(tiledAx, [-130, 50]);
    % xlim(tiledAx,[-0.5,0.5]*1e-7);
    ylim(tiledAx,[1,Inf]);
end

plotSetup.ColorMap = parula(params.numEpochs);
plotSetup.TiledLayout = t;
end