function [params] = customcyclicalLearnRate(params)
    if strcmp(params.frequencyUnit,'iteration')
        if mod(params.iteration-1,params.learnDropPeriod)<params.learnStepRatio*params.learnDropPeriod
            params.learnRate=params.initialLearnRate*(1+(params.learnMaxFactor-1)*(mod(params.iteration-1,params.learnDropPeriod))/(params.learnStepRatio*params.learnDropPeriod));
        elseif mod(params.iteration-1,params.learnDropPeriod)>= params.learnStepRatio*params.learnDropPeriod
            params.learnRate=params.initialLearnRate*(params.learnMaxFactor-(params.learnMaxFactor-1)*((mod(params.iteration-1,params.learnDropPeriod))-params.learnStepRatio*params.learnDropPeriod)/(params.learnDropPeriod-params.learnStepRatio*params.learnDropPeriod));
        end
    elseif strcmp(params.frequencyUnit,'epoch')
        if mod(params.epoch-1,params.learnDropPeriod)<params.learnStepRatio*params.learnDropPeriod
            params.learnRate=params.initialLearnRate*(1+(params.learnMaxFactor-1)*(mod(params.epoch-1,params.learnDropPeriod))/(params.learnStepRatio*params.learnDropPeriod));
        elseif mod(params.epoch-1,params.learnDropPeriod)>= params.learnStepRatio*params.learnDropPeriod
            params.learnRate=params.initialLearnRate*(params.learnMaxFactor-(params.learnMaxFactor-1)*((mod(params.epoch-1,params.learnDropPeriod))-params.learnStepRatio*params.learnDropPeriod)/(params.learnDropPeriod-params.learnStepRatio*params.learnDropPeriod));
        end
    end
    params.learnRate=params.learnRate*params.cyclicalLearnfactor; 
end

% function [params] = customcyclicalLearnRate(params)
%     if mod(params.iteration-1,params.learnDropPeriod)<params.learnStepRatio*params.learnDropPeriod
%         params.learnRate=params.baselearnRatio*(1+(params.learnMaxFactor-1)*(mod(params.iteration-1,params.learnDropPeriod))/(params.learnStepRatio*params.learnDropPeriod));
%     elseif mod(params.iteration-1,params.learnDropPeriod)>= params.learnStepRatio*params.learnDropPeriod
%         params.learnRate=params.baselearnRatio*(params.learnMaxFactor-(params.learnMaxFactor-1)*((mod(params.iteration-1,params.learnDropPeriod))-params.learnStepRatio*params.learnDropPeriod)/(params.learnDropPeriod-params.learnStepRatio*params.learnDropPeriod));
%     end
% end