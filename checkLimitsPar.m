function [maximun,minimun]=checkLimitsPar(params,outData)
    previousMin=inf;
    previousMax=-inf;
    minimun_per_exp=zeros([length(outData),1],"single");
    maximun_per_exp=zeros([length(outData),1],"single");
    params.cont_val=single(params.cont_val);
    parfor idx=1:length(outData)
        outVar=outData{idx};
        outVar=outVar(:,:,:,:,1);
        outVar(outVar==params.cont_val)=NaN;

        % minimun=min(outVar(:,:,:,1:end-1),[],"all");
        % maximun=max(outVar(:,:,:,1:end-1),[],"all");

        minimun_per_exp(idx)=min(outVar(:,:,:,1:end-1),[],"all");
        maximun_per_exp(idx)=max(outVar(:,:,:,1:end-1),[],"all");

        % previousMin=min(minimun,previousMin);
        % minimun=previousMin;
        % 
        % previousMax=max(maximun,previousMax);
        % maximun=previousMax;

    end
    minimun=min(minimun_per_exp);
    maximun=max(maximun_per_exp);

end