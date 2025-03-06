function params=defineInternalParams(params)
    params.OutVoxelNum=1;
    params.epsilon=0.000001;
    params.alpha=2; % For CeLu Layers
    params.Normalization_Dimension="channel";
    params.trainingAlgorithm="adam";
    params.FilterSize=[3,3,3];
    % params.minibatchSize=3;
    params.Base_Filter_Number=4;
    params.lossfunction=["l1loss"];
    params.NomalizationFunction=["Instance"];
    params.RectificationLayer=["Relu"];
    params.OutputSign=["default"];
    params.Normalizationfactor=1;
    params.cont_val=single(1e-9);
    params.batchSize=128;
    params.valbatch=round(params.batchSize/4);
    params.skippedDataCounter=0;
    params.validationdraw=0.2;
    params.l2Regularization = 0.8;
    params.gradientThresholdMethod="absolute-value";
    params.gradientThreshold=10;
    params.validationFreq=10;
    params.test=false;
    params.profiling=false;

    params.numEpochs =2000;


    params.learnRate=params.initialLearnRate;
    params.epoch = 0;
    params.iteration = 0;
    params.NaNFlag=false;
    params.stopTraining=false;

    params.minLoss=inf;
    params.minValLoss=inf;
    %%

    monitor.Status = "Defining Training Options"; 
    params.LearnRateSchedule='cyclical';
    params.miniBatchSize =1;
    % params.initialLearnRate = 1e-12;
    params.learndropFactor=0.1;
    params.learnDropPeriod=50;
    params.LearnRatescalingFactor=0.01;
    params.learnStepRatio =0.15;
    params.learnMaxFactor =10;
    params.cyclicalLearnfactor=1;
    params.frequencyUnit = 'epoch';
    
    if params.trainingAlgorithm == "sgdm"
        
        params.decay = 0.01;
        params.momentum = 0.9;
        params.velocity=[];
    
        params.velocity = []; 
    elseif params.trainingAlgorithm == "adam"
    
        params.averageGrad = [];
        params.averageSqGrad = [];
        params.gradDecay = 0.1;
        params.sqGradDecay = 0.1;
    else
        error("Error In training Algorithm")    

    end
    %%
    if ispc
        osPath='C:/Users/asanchez152/Documents/CiCe_Data';
    elseif isunix
        osPath='/gscratch/ieasacha/CiCe_Data';
    else
        return
    end
    % 
    params.input_paths=fullfile(osPath,'/Set2_Corregido/Set2_/Set2/Inputs');
    params.coeficient_Value='3C';
    params.output_paths=fullfile(osPath,'/Set2_Corregido/Set2_/Set2/Outputs/MatlabFiles');
end