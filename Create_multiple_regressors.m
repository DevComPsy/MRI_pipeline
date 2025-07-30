% Physiological regressors creation

sub_dir = 'D:\InformationGatheringMRI\derivatives';
% sub_dir = 'F:\trHunt';
listsub = dir([sub_dir '\sub*']);
%sub 8 run-3, timing was restarted at the end of the block, the script
%delete the excess data
%sub 8 run-4 4 more volume in movement file compare to trigger on biopac
%but no error found


%% Run the physio
for sub = 32
    clearvars physio_dir_sub
    subID = listsub(sub).name(end-2:end); %find subject ID
        disp(['Participant no' num2str(subID)])

    physio_dir_sub = dir([sub_dir '\' listsub(sub).name '\physio']); %find physio files (can be done better)
    physio_dir_sub = physio_dir_sub(~ismember({physio_dir_sub(:).name},{'.','..'})); %Remove useless files

    % physio_dir_sub = physio_dir_sub(ismember({physio_dir_sub(:).name},{'multiple','txt'})); %Remove useless files


    rp_file = dir([sub_dir '\' listsub(sub).name '\func\rp*']);
    [~,ind]=sort({rp_file.name}); %make sure that it reads the block from 1 to 4
    rp_file = rp_file(ind);

    for block =1:length(rp_file)

        physio = readtable([physio_dir_sub(block).folder '\' physio_dir_sub(block).name]); %Read filename

        while isnan(physio.Var5(end,1)) %Remove the last line if the time is a NaN
            physio(end,:) = [];
            disp('Last line discarded')
        end
        %if the block was redone, remove first part
        lastZeroIdx = find(physio.Var5 == 0, 1, 'last');

        if lastZeroIdx > 1 
            if block ==1  && sub ==23
                physio = physio(1:lastZeroIdx-1,:);
                
            else
        physio = physio(lastZeroIdx:end,:);
            end
        end


    
        if sub == 8 && block ==3
            timeDiff = diff(physio.Var5);
            threshold = -0.9 * max(physio.Var5);  %threshold to consider a drop of time
            resetPoints = [0, find(timeDiff < threshold), length(physio.Var5)];

            physio(resetPoints(2):end,:) = [];
        end

        %Need to remove the dummies from biopac
        physio.Var1(physio.Var1 > 0.1) = 1; %binarise the triggerpos
        physio.Var1(physio.Var1 <= 0.1) = 0;

        differences = diff(physio.Var1');% Count the number of transitions from 0 to 1
        NUMOFTRIGGERS     = sum(differences == 1); %count how many trigger
        TRIGGERONSET = find(differences ==1); %indices of index

        
        physio(1:TRIGGERONSET(7),:) = [];


        % Find unique values and their indices
        [uniqueVals, ~, uniqueIdx] = unique(physio.Var5);

        % Find counts of each unique value
        valueCounts = histc(uniqueIdx, 1:numel(uniqueVals));

        % Identify values that occur more than once
        repeatingVals = uniqueVals(valueCounts > 1);

        % Find indices of all occurrences of repeating values
        nonUniqueIndices = find(ismember(physio.Var5, repeatingVals));

        %remove the duplicated time if needed

        for i = 1:length(nonUniqueIndices)-1
            physio(nonUniqueIndices(i),:) = [];

        end
        t= physio.Var5; %timing

        respiration = physio.Var2;
        pulse = physio.Var3;
        new_t = t(1):1/100:t(end); %new timing
        respiration_t =  interp1(t,respiration,new_t); %linear interpolation
        pulse_t =  interp1(t,pulse,new_t); %linear interpolation

        respiration_dir = [physio_dir_sub(block).folder '\TrHu1' num2str(subID) '-block' num2str(block) '-respiration.txt'];
        pulse_dir  = [physio_dir_sub(block).folder '\TrHu1' num2str(subID) '-block' num2str(block) '-pulse.txt'];
        writematrix(respiration_t',respiration_dir) %write new file
        writematrix(pulse_t',pulse_dir); %Write new file

        %Check that the rp belong to the correct block
        rp_file_sub = [rp_file(block).folder '\' rp_file(block).name];
        rp_file_sub_line = readtable(rp_file_sub);
        rp_file_sub_line = height(rp_file_sub_line);



        clearvars matlabbatch

        matlabbatch{1}.spm.tools.physio.save_dir = {physio_dir_sub(block).folder };
        matlabbatch{1}.spm.tools.physio.log_files.vendor = 'Custom';
        matlabbatch{1}.spm.tools.physio.log_files.cardiac = {pulse_dir};
        matlabbatch{1}.spm.tools.physio.log_files.respiration = {respiration_dir};
        matlabbatch{1}.spm.tools.physio.log_files.scan_timing = {''};
        matlabbatch{1}.spm.tools.physio.log_files.sampling_interval = 0.01;
        matlabbatch{1}.spm.tools.physio.log_files.relative_start_acquisition = 0;
        matlabbatch{1}.spm.tools.physio.log_files.align_scan = 'first';
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nslices = 60;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.TR = 1.5; %could be done better, by calling MR struct
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Ndummies = 0; %already excluded in all physiological regressors 
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans = rp_file_sub_line;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.onset_slice = 1;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = [];
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nprep = [];
        matlabbatch{1}.spm.tools.physio.scan_timing.sync.nominal = struct([]);
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.modality = 'PPU';
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.filter.yes.type = 'cheby2';
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.filter.yes.passband = [0.3 9];
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.filter.yes.stopband = [];
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min = 0.4;

        matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.max_heart_rate_bpm = 90;
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);
        matlabbatch{1}.spm.tools.physio.preproc.respiratory.filter.passband = [0.01 2];
        matlabbatch{1}.spm.tools.physio.preproc.respiratory.despike = false;
        matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = ['multiple_regressors-run',num2str(block) '.txt'];
        matlabbatch{1}.spm.tools.physio.model.output_physio = ['multiple_regressors-run',num2str(block) '.mat'];
        matlabbatch{1}.spm.tools.physio.model.orthogonalise = 'none';
        matlabbatch{1}.spm.tools.physio.model.censor_unreliable_recording_intervals = false;
        matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.c = 3;
        matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.r = 4;
        matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.cr = 1;
        matlabbatch{1}.spm.tools.physio.model.rvt.no = struct([]);
        matlabbatch{1}.spm.tools.physio.model.hrv.no = struct([]);
        matlabbatch{1}.spm.tools.physio.model.noise_rois.no = struct([]);
        matlabbatch{1}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {rp_file_sub};
        matlabbatch{1}.spm.tools.physio.model.movement.yes.order = 6;
        matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_method = 'FD';
        matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_threshold = 0.5;
        matlabbatch{1}.spm.tools.physio.model.other.no = struct([]);
        matlabbatch{1}.spm.tools.physio.verbose.level = 0;
        
        matlabbatch{1}.spm.tools.physio.verbose.fig_output_file = ['figures_block' num2str(block),'.jpg'];
        matlabbatch{1}.spm.tools.physio.verbose.use_tabs = false;
        spm_jobman('run',matlabbatch(1));

    end
end

%% Check regressors
are_equal = [];
for sub = 16:length(listsub)

        clearvars physio_dir_sub
    subID = listsub(sub).name(end-2:end); %find subject ID
        disp(['Participant no' num2str(subID)])

    physio_dir_sub = dir([sub_dir '\' listsub(sub).name '\physio']); %find physio files (can be done better)
    physio_dir_sub = physio_dir_sub(contains({physio_dir_sub.name}, 'multiple_') & ...
                                 contains({physio_dir_sub.name}, '.txt'));

    rp_file = dir([sub_dir '\' listsub(sub).name '\func\rp*']);
    [~,ind]=sort({rp_file.name}); %make sure that it reads the block from 1 to 4
    rp_file = rp_file(ind);

    %check for error
    if length(rp_file) ~= length(physio_dir_sub)
        warning('Mismatch bitween rp and physio')
    end

    for block = 1:length(rp_file)
        mrf = table2array(readtable([sub_dir '\' listsub(sub).name '\physio\multiple_regressors-run',num2str(block) '.txt']));
        rp = load([rp_file(block).folder '\' rp_file(block).name]);

        %Check that column 18:24

        rp_in_mrf = mrf(:,19:24);
        are_equal(end+1) = isequal(rp_in_mrf, rp);
        if are_equal(end) == 0
            warning('mismatch')
        end

        
% Display the result

    end

end

