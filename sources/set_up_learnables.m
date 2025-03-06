function [params]=set_up_learnables(net,params)
params.best_net=net;
params.bestVal_net=net;


% check learnable layers
expNet=expandLayers(net);
weightIdx=cellfun(@learnableLayerss, net.Learnables.Parameter);
weightLayerNames =expandLayers(net).Learnables.Layer(weightIdx);
numLearnables=cellfun(@numel,expandLayers(net).Learnables.Value);
numLearnables=numLearnables(weightIdx);
params.weightIdx=weightIdx;
params.weightLayerNames=weightLayerNames;
params.numLearnables=numLearnables;

end