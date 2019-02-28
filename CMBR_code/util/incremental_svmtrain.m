function svmmodel = incremental_svmtrain( DATASETS_train,svmmodel,k,cluster_method,dictionary)
% parameters
%     csigma=0;
%     clfinit = @clf_knn; clfparams = {1,@dist_chisquared};
% clfinit = @clf_libsvm; clfparams = {'-t 0 -s 0 -h 0 -b 1 -c 100'};
if( isempty(svmmodel) )
    svmparams = {'-c 100 -s 0'};
else
    svmparams = {'-c 100 -s 0 -i svmmodel'};
end

app_data_train=[];
loc_data_train=[];
if strcmp(cluster_method,'kmean')
    %%% normal kmean
    par_kmeans={'replicates',5,'minCsize',1,'display',0,'outlierfrac',0 };
    app_clusters = recog_cluster( DATASETS_train, k, par_kmeans );
    app_data_train = recog_clipsdesc( DATASETS_train, app_clusters, csigma );
    app_data_train=cell2mat(app_data_train);
    %%% interest point relative location bag of words
    DATASETS_train=compute_relative_loc(DATASETS_train);
    
    %%% normal kmean
    l_clusters = loc_cluster(DATASETS_train, k, par_kmeans);
    loc_data_train=loc_clipsdesc( DATASETS_train, l_clusters, csigma );
    loc_data_train=cell2mat(loc_data_train);

else if strcmp(cluster_method,'gmm')
        %%% interest point appearance bag of words
        %             [means, covariances, priors]=recog_GMMcluster(DATASETS_train, k);
        means=dictionary.means.visual;
        covariances=dictionary.covariances.visual;
        priors=dictionary.priors.visual;
        %%% fisher vector encoding
        app_data_train=recog_clipsencode(DATASETS_train, means, covariances, priors);
        app_data_train = normalize(cell2mat(app_data_train)','Power-L2');
        app_data_train=app_data_train';
        %
        %%% interest point relative location bag of words
        DATASETS_train=compute_relative_loc(DATASETS_train);
        %%% fisher vector encoding
        %             [means, covariances, priors] = loc_gmm_cluster(DATASETS_train, k);
        means=dictionary.means.context;
        covariances=dictionary.covariances.context;
        priors=dictionary.priors.context;
        loc_data_train=loc_clipsencode( DATASETS_train, means, covariances, priors );
        loc_data_train = normalize(cell2mat(loc_data_train)','Power-L2');
        loc_data_train=loc_data_train';
    end
end
%%%combine location and appearance features
data_train=cat(2,app_data_train,loc_data_train);
%%%train classifier
svmmodel=svmtrain(double(DATASETS_train.IDX),sparse(data_train),svmparams{1});




