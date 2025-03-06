function [NNsubNet] = NNsubnet(params,name,idx)
factor=params.Normalizationfactor;
switch params.NomalizationFunction
    case "Instance"
        NormalizationLayer=instanceNormalizationLayer("Epsilon",params.epsilon,ScaleLearnRateFactor=factor,OffsetLearnRateFactor=factor,ScaleL2Factor=factor,OffsetL2Factor=factor);
    case "Batch"
        NormalizationLayer=batchNormalizationLayer(ScaleLearnRateFactor=factor,OffsetLearnRateFactor=factor,ScaleL2Factor=factor,OffsetL2Factor=factor);
    case "Layer"
        NormalizationLayer=layerNormalizationLayer("OperationDimension","spatial-channel",ScaleLearnRateFactor=factor,OffsetLearnRateFactor=factor,ScaleL2Factor=factor,OffsetL2Factor=factor);
    otherwise
        error("Undefined Normalziation Function")
end

switch params.RectificationLayer
    case "Relu"
        RectificationLayer=reluLayer();
    case "Leaky"
        RectificationLayer=leakyReluLayer();
    case "Clipped"
        RectificationLayer=clippedReluLayer(10);
    case "Elu"
        RectificationLayer=eluLayer();
    otherwise
        error("Undefined Rectification Function")
end


layers = [
        % convolution3dLayer(params.FilterSize*ones(1,3),params.Base_Filter_Number*(idx+1),"Padding","same");
        convolution3dLayer(params.FilterSize,2^(2*(idx+1)-1),"Padding","same")
        NormalizationLayer;
        RectificationLayer;
        % instanceNormalizationLayer("Epsilon",params.epsilon,ScaleLearnRateFactor=factor,OffsetLearnRateFactor=factor,ScaleL2Factor=factor,OffsetL2Factor=factor);
        % CeLuLayer("alpha",params.alpha);
        % reluLayer();
        % eluLayer(params.alpha)
        
        % convolution3dLayer(params.FilterSize*ones(1,3),params.Base_Filter_Number*(idx+1),"Padding","same");
        convolution3dLayer(params.FilterSize,2^(2*(idx+1)-1),"Padding","same")
        NormalizationLayer;
        RectificationLayer;
        % instanceNormalizationLayer("Epsilon",params.epsilon,ScaleLearnRateFactor=factor,OffsetLearnRateFactor=factor,ScaleL2Factor=factor,OffsetL2Factor=factor);
        % CeLuLayer("alpha",params.alpha); 
        % reluLayer();
        % eluLayer(params.alpha)

        % convolution3dLayer(params.FilterSize*ones(1,3),params.Base_Filter_Number*(idx+1),"Padding","same");
        convolution3dLayer(params.FilterSize,2^(2*(idx+1)-1),"Padding","same")
        NormalizationLayer;
        RectificationLayer;
        % instanceNormalizationLayer("Epsilon",params.epsilon,ScaleLearnRateFactor=factor,OffsetLearnRateFactor=factor,ScaleL2Factor=factor,OffsetL2Factor=factor);
        % CeLuLayer("alpha",params.alpha); 
        % reluLayer();
        % eluLayer(params.alpha)

        % convolution3dLayer(params.FilterSize*ones(1,3),params.Base_Filter_Number*(idx+1),"Padding","same");
        convolution3dLayer(params.FilterSize,2^(2*(idx+1)-1),"Padding","same")
        NormalizationLayer;
        RectificationLayer;
        % instanceNormalizationLayer("Epsilon",params.epsilon,ScaleLearnRateFactor=factor,OffsetLearnRateFactor=factor,ScaleL2Factor=factor,OffsetL2Factor=factor);
        % CeLuLayer("alpha",params.alpha); 
        % reluLayer();
        % eluLayer(params.alpha)

        convolution3dLayer(params.FilterSize,2^(2*(idx+1)-1),"Padding","same");
        NormalizationLayer;
        
        % instanceNormalizationLayer("Epsilon",params.epsilon,ScaleLearnRateFactor=factor,OffsetLearnRateFactor=factor,ScaleL2Factor=factor,OffsetL2Factor=factor);        
        
        convolution3dLayer([1 1 1],params.OutVoxelNum);
       ];
NNsubNet=networkLayer(layers,"Name",name);

end