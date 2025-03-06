function [outputs] = read_outputsV3(path,out_params)
%Con el path a la carpeta que contiene los resultados de la simulacion y la
%estrucutra params que contiene la infomacion sobre que resutlados cargar
%en funcion del coeficiente de descarga C y el codigo del ensayo y el
%thickness
    

% For resized data

    % outputs=cell(1,4); para el caso de todas las salidas
    temp=load(path);
    outputs= single(temp.(out_params.Output));
    % outputs=getfield(temp,out_params.Output);
    % cont_val=1e-9;
    % Extender thickness del vo;xel hasta dimension fija de 70 
    % y Limpiar separador 1:15
    % outputs(:,:,:,1:15)=[];
    %  dim=size(outputs,4);
    % outputs(:,:,:,dim:70)=cont_val;
    Mask=isnan(outputs(1,:,:,:));
    outputs(isnan(outputs))=out_params.cont_val;% --> evitar Nans
    outputs(end+1,:,:,:)=Mask;
    outputs=shiftdim(outputs,-1);
    % outputs(2,:,:,:,:)=Mask;
    % outputs=permute(outputs,[2 3 4 5 1]);
    outputs = permute(outputs,[3 4 5 2 1]);
    % outputs=cat
    % outputs=squeeze(outputs(1,:,:,:));
    
end
