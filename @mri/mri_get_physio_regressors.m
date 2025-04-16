function mri = mri_get_physio_regressors(mri)



try
    addpath(mri.settings.dir_physio)
catch
    mri = alert('could not add path to "physio" toolbox.',mri);
end

%% set up options
nslices = mri.epi_params.nSlicesPerTR;
ndummies = mri.ndummies;
TRperSlice = mri.epi_params.TRperSlice;


%% load and convert data
for b = 1:mri.nblocks

    rp_file = dir([mri.fun_dir,'\rp*']);
    [~,ind]=sort({rp_file.name}); %make sure that it reads the block from 1 to 4
    rp_file = rp_file(ind);

    
end

%% load realignment parameters (if available) and put everything together


if mri.verbose
    figure()
    imagesc(mul_reg);
    colormap('gray')
    title('multiple regressors')
    ylabel('scan No.')
end
mri.physio.mul_reg{b} = mul_reg;







%%
mri.physio.physio = physio;

mri = mri_set_history(mri,'aggregated noise parameters');
end