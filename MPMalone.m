%-----------------------------------------------------------------------
% MPM preprocessing using hMRI toolbox
% Kenza K 2025
%-----------------------------------------------------------------------

% Base directory to search for folders


mainDir = 'F:\OCD_data';

% Get a list of all entries in the main directory
allEntries = dir(mainDir);

% Filter to keep only directories that start with a number
participantFolders = allEntries([allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'}) & ...
    cellfun(@(x) ~isempty(regexp(x, '^\d', 'once')), {allEntries.name}));

% Iterate over each participant folder
for i = 1:length(participantFolders)
    participantName = participantFolders(i).name; % Name of the participant folder
    participantPath = fullfile(mainDir, participantName); % Full path to the participant folder

    % Display participant path (or process the folder as needed)
    disp(['Processing folder: ', participantPath]);

    % Add your processing code here



    cd(participantPath)
    % List of folder names to search for
    % List of folder name patterns to search for
    folderPatterns = {'*array*', '*body*', '*afib1*', '*t1w*', '*pdw*', '*mtw*'};

    % Initialize a structure to hold file paths
    filePaths = struct();

    % Loop through each folder pattern
    for i = 1:length(folderPatterns)
        folderPattern = folderPatterns{i}; % Current folder pattern to look for

        % Find all matching folders
        matchingFolders = dir(fullfile(participantPath, folderPattern));
        matchingFolders = matchingFolders([matchingFolders.isdir]); % Keep only directories

        % Loop through each matching folder
        for j = 1:length(matchingFolders)
            folderName = matchingFolders(j).name; % Get the folder name
            folderPath = fullfile(participantPath, folderName); % Construct full path

            % Get all .nii files in the folder
            niiFiles = dir(fullfile(folderPath, '*.nii'));
            % Extract full file paths into a string vector
            fieldName = matlab.lang.makeValidName(folderName); % Ensure valid field name
            filePaths.(fieldName) = string(fullfile({niiFiles.folder}, {niiFiles.name}));
        end
    end

% Get all field names
fields = fieldnames(filePaths);
if length(fields) ~=6
    error('Too much folder')
end

    spm('defaults', 'FMRI');



    smaps(1) = filePaths.(fields{1});
    smaps(2) = filePaths.(fields{2});

    % Inverse b1 e2 and e1 (needed for the preprocessing
    files = filePaths.(fields{3});

    % Find indices for 'e2' and 'e1'
    e2_idx = contains(files, '_e2');
    e1_idx = contains(files, '_e1');

    % Reorder: e2 before e1
    orderedFiles = [files(e2_idx); files(e1_idx)];

    % Update the structure
    b1 = orderedFiles;

    %finally select T1, MT and DP for mor clarity

    t1w = filePaths.(fields{4});
    if length(t1w) ~=8; error('Too much t1w');end
    pdw = filePaths.(fields{5});
    if length(pdw) ~=8; error('Too much pdw');end
    mtw = filePaths.(fields{6});
    if length(mtw) ~=6; error('Too much mtw');end



    clear matlabbatch
    %Do the job
    matlabbatch{1}.spm.tools.hmri.hmri_config.hmri_setdef.customised = {'C:\Users\Kenza Kedri\Documents\GitHub\MRI\hMR_toolbox_VTASN\hmri_CBS_3TP_defaults.m'};
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.output.outdir = cellstr([participantPath,'\']);
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.sensitivity.RF_once = cellstr(smaps)';
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.b1_type.i3D_AFI.b1input = cellstr(b1);
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.b1_type.i3D_AFI.b1parameters.b1defaults = {'C:\Users\Kenza Kedri\Documents\GitHub\MRI\hMR_toolbox_VTASN\hmri_b1_CBS_3T_AFI3_60_defaults.m'};
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.raw_mpm.MT = cellstr(mtw)';
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.raw_mpm.PD = cellstr(pdw)';
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.raw_mpm.T1 = cellstr(t1w)';
    matlabbatch{2}.spm.tools.hmri.create_mpm.subj.popup = false;

  for m = 1:length(matlabbatch)
    spm_jobman('run',matlabbatch(m));
   end
end