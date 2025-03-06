%% Define path
addpath('/home-nas/ieasacha/CiCe_Project/Cic_Network_clean/')
addpath('/home-nas/ieasacha/CiCe_Project/Cic_Network_clean/sources/')
addpath('/home-nas/ieasacha/CiCe_Project/Cic_Network_clean/sources/gradientFunctions')
clearvars
%% Define GPU resources

gpulist=getenv('CUDA_VISIBLE_DEVICES');
gpunames=split(gpulist,',');
gpucount=size(gpunames,1);

%% Define params
params.Scales=3;
params.FilterSize=6;
params.initialLearnRate=1e-4;
OutVarList={"cData","clData","philData","phisData"};
%params.OutputVar=
params.MaskType="Out";

%%
if ~exist('c',"var")
    c=parpool(gpucount);
    %c=parpool(4);
end
outputCell=cell(gpucount);
%%
% 
spmd 
    sprintf("Starting training on worker %d",spmdIndex)
    gpuMIGid=gpunames(spmdIndex)
    setenv("CUDA_VISIBLE_DEVICES",gpuMIGid);
    mon=experiments.Monitor;
    params.OutputVar=OutVarList{spmdIndex};
    sprintf("Training on %s output Dataset in worker %d",params.OutputVar,spmdIndex)
    
    output=Custom_loop_MainTrain_Clean_func(params,mon);
    outputCell{spmdIndex}=output;
    sprintf("Training finished on %s output Dataset in worker %d",params.OutputVar,spmdIndex)
    save_paralel_helper(output,params);
    sprintf(" Output from %s Dataset saved (worker %d)",params.OutputVar,spmdIndex)
end
%save("Output_cell.mat","outputCell")
%%
clear c
setenv("CUDA_VISIBLE_DEVICES",gpulist);
%% 

