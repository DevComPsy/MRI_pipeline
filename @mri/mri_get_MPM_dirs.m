% function mri = mri_get_MPM_dirs(mri)
%
% 10/2020 based on latest MPMs with preprocessed Fieldmap and B1
% corrections
%
% MPMs
% 1) Localizer
% 2) mfc_bloch_siegert
% 3) mfc_bloch_siegert
% 4) mfc_bloch_siegert
% 5) mfc_smaps_v1a_Array
% 6) mfc_smaps_v1a_Body
% 7) t1w_mfc_3dflash_v1k_R4
% 8) mfc_smaps_v1a_Array 
% 9) mfc_smaps_v1a_Body
% 10) pdw_mfc_3dflash_v1k_R4
% 11) mfc_smaps_v1a_Array 
% 12) mfc_smaps_v1a_Body
% 13) mtw_mfc_3dflash_v1k_R4_FAExc_12_200us
%
function mri = mri_get_MPM_dirs(mri)

%% get different sequences that were run
tmp_list = dir([mri.mri_dir 'nii\*FIL*']);
n_seqs = length(tmp_list);
scan_name = tmp_list(1).name(1:7);
clear tmp_list

%% find the folder with 6 scane (MT!)
n_scans = [];
for f = 1:n_seqs
    n_scans(f) =  numel(dir([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(f) '\*.nii']));
end


%% get scan types based on scan number and order
MT_idx = find(n_scans==6,1,'first');
T1_idx = find(n_scans==8,1,'first');
PD_idx = find(n_scans==8,2,'first'); PD_idx(1) = [];

%% rename and save dirs
dirs = [];

% MT
dirs.MT{1} = renameDir([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(MT_idx-2) '\'],[mri.mri_dir 'MPM_raw\MT_smap_array\']);
dirs.MT{2} = renameDir([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(MT_idx-1) '\'],[mri.mri_dir 'MPM_raw\MT_smap_body\']);
dirs.MT{3} = renameDir([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(MT_idx) '\'],[mri.mri_dir 'MPM_raw\MT\']);

% PD
dirs.PD{1} = renameDir([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(PD_idx-2) '\'],[mri.mri_dir 'MPM_raw\PD_smap_array\']);
dirs.PD{2} = renameDir([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(PD_idx-1) '\'],[mri.mri_dir 'MPM_raw\PD_smap_body\']);
dirs.PD{3} = renameDir([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(PD_idx) '\'],[mri.mri_dir 'MPM_raw\PD\']);

% T1
dirs.T1{1} = renameDir([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(T1_idx-2) '\'],[mri.mri_dir 'MPM_raw\T1_smap_array\']);
dirs.T1{2} = renameDir([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(T1_idx-1) '\'],[mri.mri_dir 'MPM_raw\T1_smap_body\']);
dirs.T1{3} = renameDir([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(T1_idx) '\'],[mri.mri_dir 'MPM_raw\T1\']);

% preprocessed B1
mkdir([mri.mri_dir 'MPM_raw\B1_prepro\'])
dirs.B1{1} = [mri.mri_dir 'MPM_raw\B1_prepro\'];
tmp = dir([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(find(n_scans==2,1,'first')) '\*-01*.nii*']);
copyfile([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(find(n_scans==2,1,'first')) '\' tmp(1).name],dirs.B1{1});
copyfile([mri.mri_dir 'nii\' scan_name '_FIL.S' int2str(find(n_scans==1,1,'first')) '\*-01*.nii*'],dirs.B1{1});


mri.mpm.dirs = dirs;

function new = renameDir(old,new)
    mkdir(new);
    movefile([old '*'],new);
    rmdir(old);
end
end
