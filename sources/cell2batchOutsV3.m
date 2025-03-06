function [YminusOne,outMask,Ytarget]=cell2batchOutsV3(cellArray,params,idx)
% Previous instant Input
% YminusOne=cellArray{1}(:,:,:,idx(1),1);
% % yminusOne=tempYminusOne;
% 
% 
% % Mask definition
% outMask=cellArray{1}(:,:,:,idx(1),2);
% 
% % 
% Ytarget=cellArray{1}(:,:,:,idx(1)+1,1);
% persistent YminusOnePlaceHolder outMaskPlaceHolder YtargetPlaceHolder
% 
% if isempty(YminusOnePlaceHolder) && isempty(outMaskPlaceHolder) && isempty(YtargetPlaceHolder)
%     YminusOnePlaceHolder=gpuArray(dlarray(zeros([size(cellArray{1},1:3),1,params.batchSize],"single"),'SSSCB'));
%     outMaskPlaceHolder=gpuArray(dlarray(zeros([size(cellArray{1},1:3),1,params.batchSize],"single"),'SSSCB'));
%     YtargetPlaceHolder=gpuArray(dlarray(zeros([size(cellArray{1},1:3),1,params.batchSize],"single"),'SSSCB'));
% end
% 
len=length(cellArray);
YminusOne=params.YminusOnePlaceHolder(:,:,:,:,1:len);
outMask=params.outMaskPlaceHolder(:,:,:,:,1:len);
Ytarget=params.YtargetPlaceHolder(:,:,:,:,1:len);

% YminusOne=zeros([size(cellArray{1},1:3),1,params.batchSize]);
% outMask=zeros([size(cellArray{1},1:3),1,params.batchSize]);
% Ytarget=zeros([size(cellArray{1},1:3),1,params.batchSize]);


% outMask=zeros([size(cellArray{1},1:3),params.batchSize]);
% Ytarget=zeros([size(cellArray{1},1:3),params.batchSize]);

    for kk=1:len
        YminusOne(:,:,:,1,kk)=cellArray{kk}(:,:,:,idx(kk));
        outMask(:,:,:,1,kk)=cellArray{kk}(:,:,:,end);
        Ytarget(:,:,:,1,kk)=cellArray{kk}(:,:,:,idx(kk)+1);
    end

end
