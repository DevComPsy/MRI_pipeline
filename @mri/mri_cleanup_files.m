function mri = mri_cleanup(mri)
    
    fprintf('Cleaning up intermediate files...\n');
    
    %% Functional data cleanup
    func_dir = [mri.res_dir 'sub-' num2str(mri.ID) '\func\'];
    
    % Keep swu*.nii and rp*.txt 
    all_files = dir([func_dir '*.nii']);
    for i = 1:length(all_files)
        fname = all_files(i).name;
        if ~startsWith(fname, 'swu')
            delete([func_dir fname]);
            fprintf('Deleted: %s\n', fname);
        end
    end

    mri = mri_set_history(mri, 'cleaned up intermediate files');
end