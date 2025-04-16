function mri = mri_get_tapas_physIO_regressors(mri)


%% set up options
nslices = mri.epi_params.slPerTR;
ndummies = mri.ndummies;
mri.epi_params.TRperSlice = 70;
TRperSlice = mri.epi_params.TRperSlice;
sl2coreg = round(nslices/2);


%% load and convert data
for b = 1:4
    tmp_fl = [mri.spk_dir int2str(mri.ID) '_' int2str(b) '.smr'];
    try
        []=make_tapas_physIO_regressors(tmp_fl,nslices,ndummies,TRperSlice,sl2coreg,1,mri.spk.scanner_channel,mri.spk.cardiacTTL_channel,[],mri.spk.resp_channel);
    catch
        mri = alert(['block ' int2str(b) ': it looks like several sessions are in one file - taking last.'],mri)
        []=make_tapas_physIO_regressors(tmp_fl,nslices,ndummies,TRperSlice,sl2coreg,2,mri.spk.scanner_channel,mri.spk.cardiacTTL_channel,[],mri.spk.resp_channel);
    end
    
    if mri.verbose
        figure();
        subplot(1,3,1)
        imagesc(physio(b).cardiac{1});
        colormap('gray')
        ylabel('scan No.')
        title('cardiac')
        subplot(1,3,2)
        imagesc(physio(b).resp{1});
        colormap('gray')
        title('respiration')
        subplot(1,3,3)
        imagesc(physio(b).rvt{1});
        colormap('gray')
        title('rvt')
    end
end

%% load realignment parameters (if available) and put everything together

for b = 1:4
    try
        tmp = dir([mri.epi_dirs{b} 'rp*.txt']);
        rp{b} = dlmread([mri.epi_dirs{b} tmp.name]);
    catch
        warning(['could not load movement parameters for run ' int2str(b) '.'])
        rp{b} = [];
    end
    if length(rp{b}) > size(physio(b).cardiac{end},1)
        mri = alert(['Block ' int2str(b) ': trials of physio-data (' int2str(length(physio(b).cardiac{end})) ') does not match EPIs (' int2str(length(rp{b})) ') - adding mean.'],mri);
        physio(b).cardiac{end}(size(physio(b).cardiac{end},1)+1:length(rp{b}),:) = repmat(mean(physio(b).cardiac{end}),length(rp{b})-length(physio(b).cardiac{end}),1);
        physio(b).resp{end}(size(physio(b).resp{end},1)+1:length(rp{b}),:) = repmat(mean(physio(b).resp{end}),length(rp{b})-length(physio(b).resp{end}),1);
        physio(b).rvt{end}(size(physio(b).rvt{end},1)+1:length(rp{b}),:) = repmat(mean(physio(b).rvt{end}),length(rp{b})-length(physio(b).rvt{end}),1);
    elseif length(rp{b}) < size(physio(b).cardiac{end},1)
        mri = alert(['Block ' int2str(b) ': trials of physio-data (' int2str(length(physio(b).cardiac{end})) ') does not match EPIs (' int2str(length(rp{b})) ') - removing additional vols.'],mri);
        physio(b).cardiac{end}(length(rp{b})+1:end,:) = [];
        physio(b).resp{end}(length(rp{b})+1:end,:) = [];
        physio(b).rvt{end}(length(rp{b})+1:end,:) = [];
    end
    mul_reg = [rp{b} physio(b).cardiac{end} physio(b).resp{end} physio(b).rvt{end}];
    %% save concatenated regressors in MRI directory
    dlmwrite([mri.epi_dirs{b} int2str(mri.ID) '_multiple_regressors.txt'],mul_reg)
    mri.physio.mul_reg_fl{b} = [mri.epi_dirs{b} int2str(mri.ID) '_multiple_regressors.txt'];
    
    if mri.verbose
        figure()
        imagesc(mul_reg);
        colormap('gray')
        title('multiple regressors')
        ylabel('scan No.')
    end
    mri.physio.mul_reg{b} = mul_reg;
end






%%
mri.physio.physio = physio;

mri = mri_set_history(mri,'aggregated noise parameters');