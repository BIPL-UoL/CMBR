function gmm = gmm_train( DATASETS_train, gmmSize,PCA_flag,videoSize)
samples = 60000;
gmm.gmmSize = gmmSize;
warning('getFV1Encoder : generate encoder from subset of videos...')
num_clips = 5000;
if num_clips>DATASETS_train.nclips, num_clips = DATASETS_train.nclips; end
num_samples_per_vid = ceil(samples/ num_clips);
index_samples=randperm(DATASETS_train.nclips);
DATASETS_samples.subs = DATASETS_train.subs(index_samples);
DATASETS_samples.desc = DATASETS_train.desc(index_samples);
DATASETS_samples=compute_relative_loc(DATASETS_samples);
descAll = zeros(samples,100);
rel_subsAll = zeros(samples,5);
w_hAll=zeros(num_clips,size(DATASETS_samples.width_height,2));
st = 1;
for i = 1 : num_clips
    xn.rel_subs=DATASETS_samples.rel_subs{i};
    xn.desc=DATASETS_samples.desc{i};
    xn.w_h=DATASETS_samples.width_height(i,:);
    %%% load features file
    timest = tic();
    rnsam=[];
    if ~isempty(xn.rel_subs)
        rnsam = randperm(size(xn.rel_subs,1));
        if numel(rnsam) > num_samples_per_vid
            rnsam = rnsam(1:num_samples_per_vid);
        end
        send = st + numel(rnsam) - 1;
        descAll(st:send,:) = xn.desc(rnsam,:);
        rel_subsAll(st:send,:) = xn.rel_subs(rnsam,:);
        w_hAll(i,:)=xn.w_h;
    end
    st = st + numel(rnsam);
    timest = toc(timest);
    fprintf('%d/%d --> %1.2f sec\n',i,num_clips,timest);
end
if send ~= samples
    descAll(send+1:samples,:) = [];
    rel_subsAll(send+1:samples,:) = [];
end
%=========gmm & kmeans=============
if PCA_flag
    fprintf('start computing pca\n');
    pcaFactor=0.5;
    whiten=1;
    [gmm.pcamap, gmm.centre] = xpca(descAll', whiten, size(descAll,2)*pcaFactor);
    descAll=bsxfun(@minus,descAll,repmat(gmm.centre,size(descAll,1),1))*gmm.pcamap;
end
fprintf('start create gmm desc\n');
[gmm.means.desc, gmm.covariances.desc, gmm.priors.desc] = vl_gmm(descAll', gmmSize);

fprintf('start create gmm rel_subs\n');
[gmm.means.rel_subs, gmm.covariances.rel_subs, gmm.priors.rel_subs] = vl_gmm(rel_subsAll', gmmSize);

fprintf('start create gmm w_h\n');
[gmm.means.w_h, gmm.covariances.w_h, gmm.priors.w_h] = vl_gmm(w_hAll', 10);

end

