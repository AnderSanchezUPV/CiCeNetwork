function plotGradientDistributions(plotSetup,gradientValues,epoch)

for w = 1:numel(gradientValues)
    nexttile(plotSetup.TiledLayout,w)
    color = plotSetup.ColorMap(epoch,:);

    values = extractdata(gradientValues{w});

    % Get the centers and counts for the distribution.
    [centers,counts] = gradientDistributions(values);

    % Plot the gradient values on the x axis, the epochs on the y axis, and the
    % counts on the z axis. Set the edge color as white to more easily distinguish
    % between the different histograms.
    hold("on");
    fill3(centers,zeros(size(counts))+epoch,counts,color,EdgeColor="#D9D9D9");
    % xlim
    % axis 'auto x'
    hold("off")
    
    
end
drawnow
end