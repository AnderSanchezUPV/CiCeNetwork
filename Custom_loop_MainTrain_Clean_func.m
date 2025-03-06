function output = Custom_loop_MainTrain_Clean_func(params,monitor)
%% CUSTOM_LOOP_MAINTRAIN_CLEAN Custom Training Experiment
% Use this training function to define the training data, network architecture, 
% training options, and training procedure used by the experiment. Experiment 
% Manager saves the output of this function, so you can export it to the MATLAB 
% workspace when the training is complete. For more information, see <matlab:helpview('deeplearning','exp-mgr-create-custom-experiment') 
% Configure Custom Training Experiment>.
%% Input
%% 
% * |params| is a structure with fields from the Experiment Manager hyperparameter 
% table.
% * |monitor| is an <matlab:doc('experiments.Monitor') experiments.Monitor> 
% object that you can use to track the progress of the training, update information 
% fields in the results table, record values of the metrics used by the training, 
% and produce training plots.
%% Output
%% 
% * |output| is the output returned from the training function.
%% 
% 
clc
close all
%% Define logfile
if ~exist("logFolder",'dir')
    mkdir("logFolder")
end
logfile=strcat("log",datestr(now,'yyyy_mm_dd_HH_MM_SS'),'.txt');
fid = fopen( fullfile("logFolder",logfile), 'at' );
%% Define Monitor & output Objects
monitor.Status = "Loading Data";
monitor.Info=["StartTime" "Epoch" "Iteration" "LearnRate" "Loss" "ValidationLoss" "BestLoss" "BestValidationLoss"];
monitor.Metrics = ["Loss","ValidationLoss","Learnrate"];%monitor.Metrics = ["TrainingLoss" "ValidationAccuracy"];
groupSubPlot(monitor,"Loss",["Loss","ValidationLoss"]);
groupSubPlot(monitor,"LearnRate",["Learnrate"]);
monitor.XLabel = "Iteration";
yscale(monitor,"Loss","log")
yscale(monitor,"LearnRate","log")
% yscale(monitor,"SmoothLoss","log")
output.executionEnvironment = "auto";
output.params=params;
output.network = [];
params.starttime=datestr(now,'HH:MM:SS en dd/mm/yyyy');
updateInfo(monitor,StartTime=params.starttime);
%% Define Parameters & TrainingOptions
params=defineInternalParams(params);
%% Laod and proprocess data
[trainingData,params]=LoadandPreproccesV3(params);
%% Read Data in Memory
monitor.Status = "Reading Data";
data=readall(trainingData,"UseParallel",true);
Condiciones_Contorno_Cell=data(:,1);
cData_Cell=data(:,2);
[maximun,minimun]=checkLimitsPar(params,cData_Cell);
params.OutMinVal=minimun;
params.OutMaxVal=maximun;
%% Define experiment array
[experimentIndex,trainingIndex,validationIndex]=defineExpIndex(Condiciones_Contorno_Cell,cData_Cell,params);
%% Define Network Architecture
monitor.Status = "Creating Network"; 
net=gen_MSNetV7_GroupLayer(params,[75,75,70]);
params=set_up_learnables(net,params);
output.network = net;
%% Define placeHolders
params=placeholders(params,cData_Cell,Condiciones_Contorno_Cell);
%% Trainig Loop
monitor.Status = "Training";
params.IterationsperEpoch=round((numel(trainingIndex)-1)/params.batchSize); %% revisar para determianr le maximo de forma correcta
params.MaxIterations=params.IterationsperEpoch*params.numEpochs;
historicLoss = zeros(1,params.IterationsperEpoch);
meanGradient=zeros(sum(params.weightIdx,"all"));
plotSetup=setupGradientDistributionAxes(params.weightLayerNames,params.numLearnables,params.numEpochs,1);
plotSetupMean= setupMeanGradientplot(params.weightLayerNames,params.numEpochs,2);
gradientValuesCell=cell(params.numEpochs,1);
meanGradientCell=cell(params.numEpochs,1);
output.params=params;
accfun = dlaccelerate(@modelLossV5);
while params.epoch < params.numEpochs && ~monitor.Stop && ~params.NaNFlag && ~params.stopTraining
    monitor.Status = "Training";
    params.epoch = params.epoch + 1;
    updateInfo(monitor,Epoch=params.epoch+" of "+params.numEpochs,Iteration=params.iteration+" of "+params.MaxIterations)
    
    for ii=1:params.batchSize:numel(trainingIndex)-1
        % Iteration LEvel calcultations
        params.iteration = params.iteration + 1;
        if monitor.Stop || params.NaNFlag
           fprintf (fid, 'Trainning stopped: Stop:%s NanFlag:%s \n',monitor.Stop,params.NaNFlag);
           break
        end       
        
       
        try % try catch structure to avoid losing training data
            
            % Read adn prepare batch Data Training
            if ii+(params.batchSize-1)< size(trainingIndex,2)
                temp=trainingIndex(ii:ii+(params.batchSize-1));
            else
                temp=trainingIndex(ii:end);
            end
            
            exp=zeros(length(temp),1);
            idx=zeros(length(temp),1);
            for tmpii=1:length(temp)
                exp(tmpii)=temp{tmpii}(1);
                idx(tmpii)=temp{tmpii}(2);
            end
            Condiciones_Contorno=cellfun(@gpuArray,(cellfun(@(x) dlarray(x,'SSSCB'),(Condiciones_Contorno_Cell(exp)),'UniformOutput',false)),"UniformOutput",false);
            cData=cellfun(@gpuArray,(cellfun(@(x) dlarray(x,'SSSCB'),(cData_Cell(exp)),'UniformOutput',false)),"UniformOutput",false);
            
            [YminusOne,outMask,Ytarget]=cell2batchOutsV3(cData,params,idx);
            [Condiciones_Contorno_batch,inMask]=cell2batchIns(Condiciones_Contorno,params);
            
            % Loss calculation
            [loss,gradients,state,params.NaNFlag] = dlfeval(accfun,net,Condiciones_Contorno_batch,...
                                                        YminusOne,Ytarget,params,inMask,outMask);
            net.State = state;
            historicLoss(params.iteration)=loss;
            if loss<params.minLoss
                params.minLoss=extractdata(gather(loss));
                updateInfo(monitor,BestLoss=params.minLoss + " at epoch " + params.epoch);
                best_net=net;
            end
            
            % Calculate gradients
            if params.trainingAlgorithm == "sgdm"
            % Update the network parameters using the SGDM optimizer.
                [net,params.velocity] = sgdmupdate(net,gradients,params.velocity,params.learnRate,params.momentum);
            elseif params.trainingAlgorithm == "adam"
                % Update the network parameters using the Adam optimizer.
                [net,params.averageGrad,params.averageSqGrad] = adamupdate(net,gradients,params.averageGrad,params.averageSqGrad,params.iteration,params.learnRate,params.gradDecay,params.sqGradDecay);
            end
            % Update the training progress monitor.
            if strcmp(params.frequencyUnit,'iteration')&& strcmp(params.LearnRateSchedule,"cyclical")
            % params=customexponentialLearnRate(params);
                [params] = customcyclicalLearnRate(params);
                recordMetrics(monitor,params.iteration,Learnrate=params.learnRate);
            end
            recordMetrics(monitor,params.iteration,Loss=loss);
    
            updateInfo(monitor,LearnRate=params.learnRate,Loss=loss,Iteration=params.iteration+" of "+params.MaxIterations);
            
        catch ME
            
            monitor.Status = "Error in training Loop";
            msg=getReport(ME);
            disp(msg)
            % display(msg)
            fprintf (fid, '%s \n',msg);
            fclose(fid);
            rethrow(ME)
        end       
        
    end
    %% Epoch level calculations
     % Profiling
    monitor.Progress = min(100 * params.epoch/params.numEpochs,100);
    if params.profiling == true
        if params.epoch == 8
            profile off
            profile on -historysize 1000000000
            profile on 
        elseif params.epoch == 51
            profile off
            profile viewer            
            params.stopTraining = true;
        end
    end
    if strcmp(params.frequencyUnit,'epoch') && strcmp(params.LearnRateSchedule,"cyclical")
        % params=customexponentialLearnRate(params);
        [params] = customcyclicalLearnRate(params);
        recordMetrics(monitor,params.iteration,Learnrate=params.learnRate);
    end
    gradientValues = gradients.Value(params.weightIdx);
    for zz=1:length(gradientValues)
        meanGradient(zz)=mean(gradientValues{zz},"all");
    end
    gradientValuesCell{params.epoch}=gradientValues;
    meanGradientCell{params.epoch}=meanGradient;
    % Calculate Validation
    if mod(params.epoch,params.validationFreq)==0 || params.epoch==1 % one validation every XX epoch
    monitor.Status = "Validation Step";
    vallossArray=zeros(round(numel(validationIndex)/params.valbatch),1);
    valstep=0;
        %Valdiation batchSize
        for jj=1:params.valbatch:numel(validationIndex)-1
                valstep=valstep+1;
            if monitor.Stop
               break
            end
            try
                if jj+(params.batchSize-1)< size(trainingIndex,2)
                    temp=trainingIndex(jj:jj+(params.batchSize-1));
                    
                else
                    temp=trainingIndex(jj:end);
                end
                exp=zeros(length(temp),1);
                idx=zeros(length(temp),1);
                
                for tmpjj=1:length(temp)
                    exp(tmpjj)=temp{tmpjj}(1);
                    idx(tmpjj)=temp{tmpjj}(2);
                end
    
                Condiciones_Contorno=cellfun(@gpuArray,(cellfun(@(x) dlarray(x,'SSSCB'),(Condiciones_Contorno_Cell(exp)),'UniformOutput',false)),"UniformOutput",false);
                cData=cellfun(@gpuArray,(cellfun(@(x) dlarray(x,'SSSCB'),(cData_Cell(exp)),'UniformOutput',false)),"UniformOutput",false);
    
                [YminusOne,outMask,Ytarget]=cell2batchOutsV3(cData,params,idx);
                [Condiciones_Contorno_batch,inMask]=cell2batchIns(Condiciones_Contorno,params);
    
                [valloss] = ValidationLoss(net,    Condiciones_Contorno_batch,YminusOne,Ytarget,params,inMask,outMask);
    
    
                vallossArray(valstep)=valloss;
            catch ME
                monitor.Status = "Error in Validation Process";
                msg=getReport(ME);
                disp(msg)
                % display(msg)
                fprintf (fid, '%s \n',msg);
                fclose(fid);
                rethrow(ME)
            end
        end
        if params.minValLoss>mean(vallossArray)
                params.minValLoss=mean(vallossArray);
                bestVal_net=net;
                updateInfo(monitor,BestValidationLoss=mean(vallossArray))     
        end
        validationIndex=validationIndex(randperm(length(validationIndex)));
        recordMetrics(monitor,params.iteration,ValidationLoss=mean(vallossArray));
        updateInfo(monitor,ValidationLoss=mean(vallossArray));
    end
    updateInfo(monitor,Epoch=params.epoch+" of "+params.numEpochs,Iteration=params.iteration+" of "+params.MaxIterations)
    trainingIndex=trainingIndex(randperm(length(trainingIndex)));
end
fclose(fid);
%% Plot Gradients
for zz=1:params.epoch
    plotGradientDistributions(plotSetup,gradientValuesCell{zz},zz)    
end
drawnow
% figure(plotSetupMean.TiledLayout.Parent)
for zz=1:params.epoch
    plotmeanGradients(plotSetupMean,meanGradientCell{zz},params.weightLayerNames,zz)    
end
drawnow
%% Define Output estructure
params=rmfield(params,{'YminusOnePlaceHolder','outMaskPlaceHolder','YtargetPlaceHolder','Condiciones_Contorno_batchPlaceHolder','inMaskPlaceHolder'});
output.meanGradient=meanGradient;
output.last_network=net;
output.best_network=best_net;
output.bestVal_network=bestVal_net;
output.params=params;
output.historicLoss=historicLoss;
output.gradientValuesCell=gradientValuesCell;
output.meanGradientCell=meanGradientCell;
output.monitor=monitor;
end