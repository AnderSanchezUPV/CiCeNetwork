function [cleanFileDatastore]=chooseCvalue(rawFileDatastore,params)
 prelist=rawFileDatastore.Files;
 cleanFileList=cell(0);

 for ii=1:length(prelist)
    if strfind(prelist{ii},params.coeficient_Value)
        cleanFileList{end+1,1}=prelist{ii};
    end
 end
cleanFileDatastore=rawFileDatastore;
cleanFileDatastore.Files=cleanFileList;
end