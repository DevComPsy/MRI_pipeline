clear all ; close all
global param

run('D:\RewardLearningDopamine\code\load_param.m');
param = ans;

%add path
addpath 'C:\Users\Kenza Kedri\Documents\GitHub\MRI_pipeline'
% mri_path = 'D:\pilot/'
cd(param.mri_path)

list = (dir('sub-*'));
param.exclude = 15;
list(param.exclude) = [];

for i = 13:length(list)
    ID = list(i).name(5:end); %remove sub- from subject ID

    mr = run_MRI(ID);
  end
 

if param.avgbrain ==1

    create_average_brain()


end