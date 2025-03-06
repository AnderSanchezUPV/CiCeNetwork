function  plotmeanGradients(plotSetup,meangradients,weightLayerNames,Epoch)
    
    for jj=0:4      
        for ii = 1:6
            nexttile(plotSetup.TiledLayout,ii+(6*jj))
            hold("on");
            plot(Epoch,meangradients(ii+(6*jj)),'b.-')
            hold("off")
            % xlabel("Iteration")
            % ylabel("Average Gradient")
            % title(weightLayerNames(ii+(6*jj)))
            %legend(activationTypes)
            % ii+(6*jj)
        end
    end
    drawnow
end