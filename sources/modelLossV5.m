function [loss,gradients,state,nanFlag] = modelLossV5(net,...
                                            Condiciones_Contorno,...
                                            YminusOne,...
                                            Ytarget,...
                                            params, ...
                                            inMask,...
                                            outMask)
% 
persistent previousLoss count

if isempty(previousLoss)     
        previousLoss = inf;
        count=0;
end

persistent previousGradients
% 
nanFlag=false;
% 


% Forward data through network.
% Condiciones_Contorno=dlarray(Condiciones_Contorno,"SSSCB"); % cambiar S por C --Z documentacion

% Condiciones_Contorno=dlarray(Condiciones_Contorno,"SSSCB");
% inMask=dlarray(inMask,"SSSCB");
% 
% YminusOne=dlarray(YminusOne,"SSSBC");
% Ytarget=dlarray(Ytarget,"SSSBC");
% outMask=dlarray(inMask,"SSSBC");
% 
% 
% % Mask=~isnan((Ytarget)) & ~isnan((Condiciones_Contorno(:,:,:,2,:)));
% if canUseGPU
%     Condiciones_Contorno=gpuArray(Condiciones_Contorno);
%     YminusOne=gpuArray(YminusOne);
%     Ytarget=gpuArray(Ytarget);
%     inMask=gpuArray(inMask);
% end
% % Rescaling
% % YminusOne=rescale(YminusOne);
% % close all
% % figure;histogram(extractdata(Ytarget))

% Mask=logical(extractdata(gather(inMask))) | logical(extractdata(gather(outMask)));
switch params.MaskType
    case 'In'
        Mask=single(inMask);
    case 'Out'
        Mask=single(outMask);
    case 'Both'
        Mask=single(inMask | outMask);
    otherwise
        error('Invalid Masktype')
end



% Ytarget=rescale(Ytarget,"InputMin",params.OutMinVal,"InputMax",params.OutMaxVal);

% figure;histogram(extractdata(Ytarget))

OutLayerNames=cell(params.Scales+1,1);
ScaleOutLayer=cell(params.Scales+1,1);
for ii=1:params.Scales
    % ScaleOutLayer{ii}=sprintf('NN%d',ii-1);
    OutLayerNames{ii}=sprintf('Y%d',ii-1);
end
OutLayerNames{params.Scales+1}=sprintf('NN%d',params.Scales);

% [Y0,Y1,Y2,Y3,Y4] = minibatchpredict(net,Condiciones_Contorno(:,:,:,1,:),Condiciones_Contorno(:,:,:,2,:),Condiciones_Contorno(:,:,:,3,:),YminusOne,"Outputs",OutLayerNames);

% [Y,state] = forward(net,Condiciones_Contorno,YminusOne);
switch params.Scales
    case 1
        [Yn0,state] = forward(net,Condiciones_Contorno(:,:,:,1,:),Condiciones_Contorno(:,:,:,2,:),Condiciones_Contorno(:,:,:,3,:),YminusOne,"Outputs",OutLayerNames);

    case 2
        [Yn0,Yn1,state] = forward(net,Condiciones_Contorno(:,:,:,1,:),Condiciones_Contorno(:,:,:,2,:),Condiciones_Contorno(:,:,:,3,:),YminusOne,"Outputs",OutLayerNames);

    case 3 
        [Yn0,Yn1,Yn2,state] = forward(net,Condiciones_Contorno(:,:,:,1,:),Condiciones_Contorno(:,:,:,2,:),Condiciones_Contorno(:,:,:,3,:),YminusOne,"Outputs",OutLayerNames);

    case 4
        [Y0,Y1,Y2,Y3,Y4,state] = forward(net,Condiciones_Contorno(:,:,:,1,:),Condiciones_Contorno(:,:,:,2,:),Condiciones_Contorno(:,:,:,3,:),YminusOne,"Outputs",OutLayerNames);
    otherwise
        error('invalid scale value');
end

Ycell=cell(params.Scales,1);

for kk=1:params.Scales+1
    Ycell{kk}=eval(sprintf("Y%d",kk-1));
end

% Calcular Ytarget a distintas Scalas
YtargetCell=cell(params.Scales,1);
YtargetCell{1}=Ytarget;
for zz=2:params.Scales+1
    YtargetCell{zz}=dlresize(Ytarget,"OutputSize",size(Ycell{zz},1:3));
end

MaskCell=cell(params.Scales,1);
MaskCell{1}=Mask;
for uu=2:params.Scales+1
    MaskCell{uu}=dlresize(Mask,"OutputSize",size(Ycell{uu},1:3));
end

% if unique(extractdata(Y))==0
%     display(params.iteration)
% end
% Calculate loss
lossCell=cell(params.Scales,1);
switch params.lossfunction
    % case "mse"
        % loss = mse(Y,Ytarget);
    case "huber"
        loss = huber(Y,Ytarget,NormalizationFactor="batch-size",Mask=~Mask);
    case "l1loss"        
        for jj=1:params.Scales+1
            temploss=l1loss(Ycell{jj},YtargetCell{jj},Reduction="none");
            temploss=temploss./(abs(YtargetCell{jj})+1e-12);
            % lossCell{jj}=l1loss(Ycell{jj},YtargetCell{jj},Reduction="none")./(YtargetCell{jj}+1e-12);
            temploss(logical(MaskCell{jj}))=0; %% remove nan values
            temploss =sum(temploss,"all")/sum(~MaskCell{jj},"all");
            lossCell{jj}=temploss;
            % loss = l1loss(Y,Ytarget,Reduction="none")./(Ytarget+1e-12);
            % lossCell{jj} = lossCell{jj}.*MaskCell{jj};
        end
        % loss = l1loss(Y,Ytarget,NormalizationFactor="batch-size",Mask=~Mask);
        loss=mean(cellfun(@(x)sum(x,"all"),lossCell),"all");
    case "l2loss"
        Y=Y0 ;
        loss = l2loss(Y,Ytarget,NormalizationFactor="mask-included",Mask=~Mask);
    otherwise
        error(["Loss Function ",params.lossfunction," not exist"]);
end




if isnan(loss)
    nanFlag=true;
end
% Calculate gradients of loss with respect to learnable parameters.
gradients = dlgradient(loss,net.Learnables);
% previousLoss=loss;

% L2 regularization
idx = net.Learnables.Parameter == "Weights";
gradients(idx,:) = dlupdate(@(g,w) g + params.l2Regularization*w, gradients(idx,:), net.Learnables(idx,:));

if isempty(previousGradients)     
        previousGradients = gradients;
        % count=0;
end


switch params.gradientThresholdMethod
    case "global-l2norm"
        [gradients,globalL2Norm] = thresholdGlobalL2Norm(gradients, params.gradientThreshold);
        % disp(globalL2Norm) % depuration
    case "l2norm"
        [gradients,gradientNorm] = dlupdate(@(g) thresholdL2Norm(g, params.gradientThreshold),gradients);
        % disp(gradientNorm)
    case "absolute-value"
        gradients = dlupdate(@(g) thresholdAbsoluteValue(g, params.gradientThreshold),gradients);
end

% check=0;
% for ii=1:size(net.Learnables,1)
%     temp=net.Learnables.Value{ii,1};
%     check=check+sum(isnan(temp),"all");
%     % temp(isnan(temp))=1e-3;
%     % gradients.Value{ii,1}=temp;
% end
% check=0;
% for ii=1:size(gradients,1)
%     temp=gradients.Value{ii,1};
%     check=check+sum(isnan(temp),"all");
%     temp(isnan(temp))=rand()/10000;
%     gradients.Value{ii,1}=temp;
% end
% check=[];
% checkarr=gpuArray(zeros(size(gradients,1),1));
% 
% for ii=1:size(gradients,1)
%     check=sum(isnan(extractdata(gradients.Value{ii})),"all")==numel(gradients.Value{ii,1});
%     checkarr(ii)=check;
% 
% end 
% if sum(checkarr,"all")~=0
%     nanFlag=true;
% end
% numel(checkarr)
% previousGradients=gradients;


end