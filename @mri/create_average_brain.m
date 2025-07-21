function create_average_brain()

%Group-level scrpts
T1_coregistered = {};
for i = 1:length(list)
    load([list(i).folder,'/',list(i).name,'/',list(i).name(5:end),'.mat'])
    anat_temp = dir([mri.res_dir  'sub-' num2str(mri.ID) '\anat\wsub*']);
    T1_coregistered{i} = [anat_temp.folder,'/',anat_temp.name];

end

T1_coregistered(param.exclude) = [];



nT1 = length(T1_coregistered);
% Create expression for average
exprParts = arrayfun(@(i) sprintf('i%d', i), 1:nT1, 'UniformOutput', false);
expr = ['(' strjoin(exprParts, '+') ') / ' num2str(nT1)];

% Output file name
out_file = fullfile(pwd, 'avg_T1.nii');

% Prepare imcalc input
matlabbatch{1}.spm.util.imcalc.input = T1_coregistered';
matlabbatch{1}.spm.util.imcalc.output = 'avg_T1.nii';
matlabbatch{1}.spm.util.imcalc.outdir = {pwd};
matlabbatch{1}.spm.util.imcalc.expression = expr;
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 16;  % float32

% Run the batch
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

end