% mri
%
% pipeline for preprocessing fMRI data
%
% Tobias Hauser, 2017
classdef mri
    properties
        ID
        mri_dir
        fun_dir
        ana_dir
        epi_dirs
        epi_dirs_org
        beh_dir
        physio_dir
        data_dir
        res_dir
        fmap_dir
        beh
        physio
        nblocks
        ndummies
        history
        warnings
        verbose
        epi_params
        epis
        mpm
        settings
    end
    methods
        function obj = mri(ID)
            obj.ID = num2str(ID);
            obj = mri_initialize(obj);
        end
        function mri = save(mri)
            if ~exist(mri.data_dir,'dir')
                mkdir(mri.data_dir)
            end
            save([mri.data_dir num2str(mri.ID) '.mat'],'mri')
        end
    end
end