function [inputs] = read_inputsV3(path,in_params)
% Dado la direccion de una carpeta que contiene los ficheros .mat con las 
% configuraciones de los ensayos y la estructura params que contiene los
% parametros P y thickness para indentificar el ensayo, leer el fichero
% .mat que contine siguientes estas variables y devovlerlas en el cellarray inputs:
%  AM_CBD_pore_distrib
%  Gr_dist
%  Sep_CC_dist

% For Resized Data
    
    % inputs=cell(1,3);
    

    % temp=load(path);

    load(path);
    % temp.AM_CBD_pore_distrib=AM_CBD_pore_distrib;
    % temp.Gr_dist=Gr_dist;
    % temp.Sep_CC_dist=Sep_CC_dist;

    
    data_size=size(Gr_dist);
    inputs=zeros([data_size,3],"single");
    
    % inputs{1,1}=temp.AM_CBD_pore_distrib;
    % inputs{1,2}=temp.Gr_dist;
    % inputs{1,3}=temp.Sep_CC_dist;
    inputs(:,:,:,1)=AM_CBD_pore_distrib;
    inputs(:,:,:,2)=Gr_dist;
    inputs(:,:,:,3)=Sep_CC_dist;
    inputs(:,:,:,4)=isnan(Gr_dist);


    % Actual_thickness=data_size(3);
    % Fix AM_CBD_pore_distrib
    % fix_value_AM_CBD_pore_distrib=3; % Asignar clase 3 a los espacios no definidos
    % inputs(:,:,Actual_thickness+1:in_params.max_thickness,1)=fix_value_AM_CBD_pore_distrib;
    % inputs(isnan(inputs))=fix_value_AM_CBD_pore_distrib;

    % Fix Gr_dist
    fix_value_Gr_dist=in_params.cont_val; % Asignar cte muy pequeña para puntos fuera de las esferas
    % inputs(:,:,Actual_thickness+1:in_params.max_thickness,1)=fix_value_Gr_dist;
    inputs(isnan(inputs))=fix_value_Gr_dist;

    % Fix Sep_CC_dist
    % fix_value_Sep_CC_dist=2; % Asignar un valor mayor a 1 para espacio completado => Se podria sustituir por un incremento porporcional desde 1 a 1+(max_Thikness-Actual_thickness)/Actual_thickness*100
    % inputs(:,:,Actual_thickness+1:in_params.max_thickness,1)=fix_value_Sep_CC_dist;
    % inputs(isnan(inputs))=fix_value_Sep_CC_dist;
end