function mri = mri_get_BEH_onsets(mri)

fprintf('get task onsets (corrected for dummy volumes).\n')

%% load logfile
beh_dir = mri.beh_dir;
list = dir([beh_dir '*_' int2str(mri.ID) '_log.mat']);
if length(list) >1; mri = alert('more than one log-files available - using last.',mri); end
tmp = load([beh_dir list(end).name]);
dat = real(tmp.user.log);
log_desc = tmp.user.log_descr;

%% set up output structure
for b = 1:mri.nblocks
    beh(b).stim_ons(1:40) = nan;
    beh(b).force_ons(1:40) = nan;
    beh(b).outcome_ons(1:40) = nan;
end

%% fill in onsets (relative to the first TR)
ndummies = mri.ndummies;
slPerTR = mri.epi_params.nSlicesPerTR;

for b = 1:mri.nblocks
    for t = 1:40
        i = find(dat(:,1)==b & dat(:,2)==t);
        beh(b).stim_ons(t) = dat(i,finds(log_desc,'slice StimOns'))/slPerTR - ndummies;
        beh(b).force_ons(t) = dat(i,finds(log_desc,'slice ForceExecOns'))/slPerTR - ndummies;
        beh(b).outcome_ons(t) = dat(i,finds(log_desc,'slice OutcomeOns'))/slPerTR - ndummies;
    end
    
    if mri.verbose
        figure()
        subplot(2,1,1)
        stem(beh(b).stim_ons,ones(1,length(beh(b).stim_ons)),'color','m');
        hold on;
        stem(beh(b).force_ons,ones(1,length(beh(b).force_ons)).*2,'color','g');
        stem(beh(b).outcome_ons,ones(1,length(beh(b).outcome_ons)).*3,'color','k');
        ylabel('time from start in TR')
        subplot(2,3,4)
        histogram(beh(b).force_ons-beh(b).stim_ons,'FaceColor','m');
        title('stimulus vs force onset')
        xlabel('TR')
        ylabel('frequency')
        subplot(2,3,5)
        histogram(beh(b).outcome_ons-beh(b).force_ons,'FaceColor','g');
        title('force vs outcome onset')
        xlabel('TR')
        subplot(2,3,6)
        histogram(beh(b).stim_ons(2:end)-beh(b).outcome_ons(1:end-1),'FaceColor','k');
        title('outcome vs stim onset')
        xlabel('TR')
    end
    
end

%% annotate
mri.beh = beh;
mri = mri_set_history(mri,'get task onsets');