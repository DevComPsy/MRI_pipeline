clear all ; close all
global param

run('D:\MPM_pilot\load_param.m');
param = ans;

%add path
addpath 'C:\Users\Kenza Kedri\Documents\GitHub\MRI_pipeline'
cd(param.mri_path)

list = (dir('sub-*'));


%Subjectl level
for i = 1:length(list)
    ID = list(i).name(5:end);
    if ismember(str2double(ID), param.exclude)
        fprintf('Sub-%s: excluded, skipping.\n', ID);
        continue
    end
    mr = run_MRI(ID);
end


% group level
if param.avgbrain  == 1; create_average_brain(list, param); end
if any(structfun(@(x) x, param.dartel))
    run_dartel(list, param);
end