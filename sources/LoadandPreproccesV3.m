function [trainingData,params] = LoadandPreproccesV3(params)
params.OutVoxelNum=1;
params.epsilon=0.00001;
params.alpha=0.1; % For CeLu Layers
params.Normalization_Dimension="channel";

%% Set paths
%   En estas carpetas se encuentran los datos y resutlados de las
%   simualcioens realziadas.
%   Estructurados por ensayos siguiendo el codigo: rsa_CFD-92-75-PS1-TS1 To FIX

%   Para las entradas, dentro de cada carpeta de ensayo se encuentran distintas
%   configuraciones iniciales indicando en el nombre del fichero por "ThickXXum"
%   donde XX representa el espesor del conductor.

%   Para las salidas, se indexan mediante el codigo PXX_TYY_ZXC donde:
%   XX--> identificador del ensayo
%   YY--> thickness
%   ZZ--> Coeficiente "C" de descarga


%% Get simulation list
s=dir(params.input_paths); % Get all folder names
T = struct2table(s); % convert the struct array to a table
sortedT = sortrows(T, 'name'); % sort the table by 'name'
sim_List = table2struct(sortedT); % change it back to struct array if necessary

% limpair residuos de la estructura tras ordenarlso y colocarlos en las 2
% priemras posiciones

sim_List(1:2)=[];

%% Get output list
s=dir(params.output_paths); % Get all folder names
T = struct2table(s); % convert the struct array to a table
sortedT = sortrows(T, 'name'); % sort the table by 'name'
out_List = table2struct(sortedT); % change it back to struct array if necessary
% limpair residuos de la estructura tras ordenarlso y colocarlos en las 2
% priemras posiciones

out_List(1:2)=[];

%% Define DatafileStructures
%   con la carpeta de los ensayos definida se definen los ds para realizar
%   la lectura de lso datos directamente desde disco.
%   To DO. Simplificado a un ensayo

% Define parameters for reading data
in_params.max_thickness=70;
in_params.cont_val=params.cont_val;

out_params.C=1;
out_params.max_thickness=70;
% out_params.Output="clData";
out_params.Output=params.OutputVar;
out_params.cont_val=params.cont_val;
% Define anonymous functions
fcnIn = @(path) read_inputsV3(path, in_params);
% fcAM_CBD_pore_distrib_cell=@(path) read_AM_CBD_pore_distrib(path, in_params);
% fcGr_dist=@(path) read_Gr_dist(path, in_params);
% fcSep_CC_dist=@(path) read_Sep_CC_dist(path, in_params);

fcnOut = @(path) read_outputsV3(path, out_params);

% inputcell=cell(4,1);
% outputcell=cell(4,1);

if params.test==true
    number_of_experiments=2;
    inputs=strings(number_of_experiments,1);
    outputs=strings(number_of_experiments,1);
elseif params.test==false
    number_of_experiments=length(sim_List);
    inputs=strings(number_of_experiments,1);
    outputs=strings(number_of_experiments,1);
end

for ii=1:number_of_experiments
    % inputcell{ii,1}=fullfile(params.input_paths,sim_List(ii).name);
    % outputcell{ii,1}=fullfile(params.output_paths,out_List(ii).name);
    inputs(ii,1)=fullfile(params.input_paths,sim_List(ii).name);
    outputs(ii,1)=fullfile(params.output_paths,out_List(ii).name);
    
end


% Inputs_df=fileDatastore(fullfile(params.input_paths,sim_List(1).name),"IncludeSubfolders",true,"ReadFcn",fcnIn);
Inputs_df=fileDatastore(inputs,"IncludeSubfolders",false,"ReadFcn",fcnIn);

% AM_CBD_pore_distrib_df=fileDatastore(inputs,"IncludeSubfolders",true,"ReadFcn",fcAM_CBD_pore_distrib_cell);
% Gr_dist_df=fileDatastore(inputs,"IncludeSubfolders",true,"ReadFcn",fcGr_dist);
% Sep_CC_dist_df=fileDatastore(inputs,"IncludeSubfolders",true,"ReadFcn",fcSep_CC_dist);


% Outputs_df=fileDatastore(fullfile(params.output_paths,out_List(1).name),"ReadFcn",fcnOut);
Outputs_df=fileDatastore(outputs,"IncludeSubfolders",false,"ReadFcn",fcnOut);
Outputs_df=chooseCvalue(Outputs_df,params);


comDS=combine(Inputs_df,Outputs_df);
% comDS=combine(AM_CBD_pore_distrib_df,Gr_dist_df,Sep_CC_dist_df,Outputs_df);

trainingData=comDS;
end