% function mri = mri_get_MPM_dirs(mri)
%
% 10/2020 based on latest MPMs with preprocessed Fieldmap and B1
% corrections
%
% MPMs
% 1) Localizer
% 2) mfc_smaps_v1a_Array
% 3) mfc_smaps_v1a_Body
% 4) t1w_mfc_3dflash_v1k_R4
% 5) pdw_mfc_3dflash_v1k_R4
% 6) mtw_mfc_3dflash_v1k_R4_FAExc_12_200us

function mri = mri_get_MPM_dirs(mri)

%% get different sequences that were run
% List of folder names to search for
% List of folder name patterns to search for
folderPatterns = {'*array*', '*body*', '*kp*', '*t1w*', '*pdw*', '*mtw*'};
folderNames = {'smaps_array','smaps_body','kp_b0','t1w','pdw','mtw'};
% Initialize a structure to hold file paths
filePaths = struct();

% Loop through each folder pattern
for i = 1:length(folderPatterns)
    clear unzippedNames
    folderPattern = folderPatterns{i}; % Current folder pattern to look for

    % Find all matching folders
    matchingfiles = dir(fullfile(mri.ana_dir, folderPattern ));
    scanfiles = matchingfiles(contains({matchingfiles.name}, 'nii.gz'));

    for unzip = 1:length(scanfiles)
    gzFilePath = fullfile(scanfiles(unzip).folder, scanfiles(unzip).name);
    
    % Remove .gz to get target .nii filename
    niiName = erase(scanfiles(unzip).name, '.gz');
    niiPath = fullfile(scanfiles(unzip).folder, niiName);

    % Only unzip if the .nii file doesn't already exist
    if ~exist(niiPath, 'file')
        gunzip(gzFilePath);
    end

    % Store the (existing or newly unzipped) path
    unzippedNames(unzip) = string(niiPath);
    end



    % Get all .nii files in the folder
    % Extract full file paths into a string vector
    % folderNames = matlab.lang.makeValidName(scanname); % Ensure valid field name
    filePaths.(folderNames{i}) = unzippedNames;

end

% Get all field names
fields = fieldnames(filePaths);
if length(fields) ~=6
    error('Too much folder')
end



%% rename and save dirs
dirs = [];

% MT
dirs.MT{1} = filePaths.mtw;
if length(dirs.MT{1}) ~= 6
    error('Incorrect number of MTw files')
end

% PD
dirs.PD{1} = filePaths.pdw;
if length(dirs.PD{1}) ~= 8
    error('Incorrect number of PDw files')
end
% T1
dirs.T1{1} = filePaths.t1w;
if length(dirs.T1{1}) ~= 8
    error('Incorrect number of T1w files')
end

% smaps
dirs.smaps{1} = filePaths.smaps_array;
if length(dirs.smaps{1}) ~= 1
    error('Incorrect number of smaps_array files')
end
dirs.smaps{2} = filePaths.smaps_body;
if length(dirs.smaps{2}) ~= 1
    error('Incorrect number of smaps_body files')
end

%b0 (change files order for next script)
dirs.b0{1} = filePaths.kp_b0{2};
if length(dirs.b0) ~= 1
    error('Incorrect number of b0 files')
end

dirs.b0{2} = filePaths.kp_b0{1};
if length(dirs.b0) ~= 2
    error('Incorrect number of b0 files')
end



mri.mpm.dirs = dirs;


end
