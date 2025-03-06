function plotSetup = setupMeanGradientplot(weightLayerNames,params,figidx)
f = figure(figidx);
t = tiledlayout(f,"flow",TileSpacing="tight");
t.Title.String = "Gradient Mean Value";
% title ("Gradient Mean Value")

% To avoid updating the same values every epoch, set up axis 
% information before the training loop.
for jj=0:params.Scales      
    for ii = 1:6
    tiledAx = nexttile(t,ii+(6*jj));

    % Set up the label names and titles.
    xlabel(tiledAx,"Epoch")
    ylabel(tiledAx,"Average Gradient")
    grid(tiledAx,"on")
    title(tiledAx,weightLayerNames(ii+(6*jj)))
    

    % Rotate the view.
    % view(tiledAx, [-130, 50]);
    % xlim(tiledAx,[-0.5,0.5]*1e-7);
    % xlim([1,Inf]);
     xlim(tiledAx,[1,Inf]);
    end
end

plotSetup.ColorMap = parula(params.numEpochs);
plotSetup.TiledLayout = t;
% plotSetup=[];

end