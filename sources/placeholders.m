function params=placeholders(params,cData_Cell,Condiciones_Contorno_Cell)
    params.YminusOnePlaceHolder=gpuArray(dlarray(zeros([size(cData_Cell{1},1:3),1,params.batchSize],"single"),'SSSCB'));
    params.outMaskPlaceHolder=gpuArray(dlarray(zeros([size(cData_Cell{1},1:3),1,params.batchSize],"single"),'SSSCB'));
    params.YtargetPlaceHolder=gpuArray(dlarray(zeros([size(cData_Cell{1},1:3),1,params.batchSize],"single"),'SSSCB'));
    params.Condiciones_Contorno_batchPlaceHolder=gpuArray(dlarray(zeros([size(Condiciones_Contorno_Cell{1},1:3),3,params.batchSize]),'SSSCB'));
    params.inMaskPlaceHolder=gpuArray(dlarray(zeros([size(Condiciones_Contorno_Cell{1},1:3),1,params.batchSize]),'SSSCB'));

end