function mri = mri_prepare_epis(mri)

mri = mri_get_epi_dirs(mri,0);
mri.epi_dirs_org = mri.epi_dirs;
mri.epi_dirs_org = {};

for b = 1:length(mri.epi_dirs)
    fprintf(['block ' int2str(b) ': create new directory and more relevant data.\n'])
    mkdir([mri.res_dir 'sub-' num2str(mri.ID) '\func\'])
    
    % remove dummies

    niftiFilePath =[mri.fun_dir mri.epi_dirs{b}];      % Path to the original NIfTI file
    outputFilePath = [mri.res_dir 'sub-' num2str(mri.ID) '\func\sub-' num2str(mri.ID) '_run-' num2str(b) '_TrHu-bold.nii']; % Path for the modified output file
    mri.epi_dirs_org{b} = outputFilePath;


    removeFirstNVolumes(niftiFilePath, outputFilePath, mri.ndummies);
    
    
  
end
end
    
function removeFirstNVolumes(niftiFilePath, outputFilePath, n_dummies)
    % Load the NIfTI file
    niftiData = niftiread(niftiFilePath);
    niftiInfo = niftiinfo(niftiFilePath);
    
    % Remove the first n_dummies volumes
    niftiData = niftiData(:, :, :, (n_dummies+1):end);
    
    % Update the NIfTI info to reflect the new number of volumes
    niftiInfo.ImageSize(4) = size(niftiData, 4);
    niftiInfo.Description = sprintf('%s - First %d volumes removed', niftiInfo.Description, n_dummies);
    
    % Save the modified data to a new NIfTI file
    niftiwrite(niftiData, outputFilePath, niftiInfo);
    fprintf('The first %d volumes have been removed and saved to "%s".\n', n_dummies, outputFilePath);
end


