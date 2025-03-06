function [weightIdx] = learnableLayerss(ParameterCell)
    weightIdx=strcmp(ParameterCell(end-7:end),'/Weights');
end