function [experimentIndex,trainingIndex,validationIndex]=defineExpIndex( ...
                                        Condiciones_Contorno_Cell, ...
                                        cData_Cell,...
                                        params)

experimentIndex=cell(length(Condiciones_Contorno_Cell),1);
for jj=1:length(cData_Cell)
    % [Condiciones_Contorno_Cell{jj},cData_Cell{jj}] = next(mbq);
    index_list=(1:size(cData_Cell{jj},4)-2); % el ultimo elemento es la mascara Nan para los datos de salida
    % index_list=index_list(randperm(length(index_list))); % Sustituir por shuffle
    for kk=1:length(index_list)
        experimentIndex{jj,kk}=[jj,index_list(kk)];
    end
end

experimentIndex=reshape(experimentIndex,[1,numel(experimentIndex)]);
experimentIndex=experimentIndex(~cellfun(@isempty, experimentIndex));
experimentIndex=experimentIndex(randperm(length(experimentIndex)));

limit=round(size(experimentIndex,2)*params.validationdraw);
trainingIndex=experimentIndex(:,1:end-limit);
validationIndex=experimentIndex(:,end-(limit-1):end);

end