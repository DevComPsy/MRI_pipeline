% This tool shows the warped T1, the warped EPI, the warped smoothed EPI and the T1
% Template and sets the mapping_gl to histeq so that T1 has more contrast
% and it activates reorient to get a wireframe
%
% written by Steffen Bollmann, adapted by Tobias Hauser, 08.08.2013
%
function mri = mri_check_preproc(mri)

% addpath('D:\myDocuments\work\Projects\gen_funct\Steffens\preprocessingCheckingScripts\subfunctions\');
pathToTemplates = [spm('dir') '\canonical\'];




    %get image-paths
    
    % T1 reference
    images(1,:) = {[pathToTemplates,'single_subj_T1.nii']};
    
    % normalized MT
    images(2,:) = {mri.mpm.norm_MT};
    
%     % normalized wMT
%     [p,n,e] = fileparts(mri.mpm.wMT);
%     mri.mpm.norm_wMT = [p '\w' n e];
%     mri.save;
%     images(3,:) = {mri.mpm.norm_wMT};
    
    % normalized EPI
    tmp = randi(mri.nblocks);
    epi = mri.epis{tmp}{randi(length(mri.epis{tmp}))};
    images(3,:) = {epi};
    
    % original MRI
    images(4,:) = {mri.mpm.MTsat_preproc};
%     
%     % original EPI
%     [p,n,e] = fileparts(epi);
%     images(6,:) = {[p '\' n(3:end) e]};
    

    %call SPM checkreg
    spm_check_registration(char(images));
    
    %show wireframe by opening reorient
    spm_orthviews('reorient','context_init',1);
    
    %set global mapping to histeq to see more details in T1
%     spm_orthviews('context_menu','mapping_gl','histeq');
    
     
end
