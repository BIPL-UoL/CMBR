function [predicts,scores,targets] = incremental_svmpredict( DATASETS_test,svmmodel,k,cluster_method,dictionary)
% parameters
%     csigma=0;
%     clfinit = @clf_knn; clfparams = {1,@dist_chisquared};
% clfinit = @clf_libsvm; clfparams = {'-t 0 -s 0 -h 0 -b 1 -c 100'};
predicts=zeros(length(svmmodel.Label),DATASETS_test.nclips);
scores=zeros(length(svmmodel.Label),DATASETS_test.nclips);
targets=zeros(length(svmmodel.Label),DATASETS_test.nclips);
for i=1:length(DATASETS_test.IDX)
    targets(DATASETS_test.IDX(i),i)=1;
end

app_data_test=[];
loc_data_test=[];
if strcmp(cluster_method,'kmean')
    %%% normal kmean
    par_kmeans={'replicates',5,'minCsize',1,'display',0,'outlierfrac',0 };
    app_clusters = recog_cluster( DATASETS_test, k, par_kmeans );
    app_data_test = recog_clipsdesc( DATASETS_test, app_clusters, csigma );
    app_data_test=cell2mat(app_data_test);
    %%% interest point relative location bag of words
    DATASETS_test=compute_relative_loc(DATASETS_test);
    
    %%% normal kmean
    l_clusters = loc_cluster(DATASETS_test, k, par_kmeans);
    loc_data_test=loc_clipsdesc( DATASETS_test, l_clusters, csigma );
    loc_data_test=cell2mat(loc_data_test);

else if strcmp(cluster_method,'gmm')
        %%% interest point appearance bag of words
        %             [means, covariances, priors]=recog_GMMcluster(DATASETS_train, k);
        means=dictionary.means.visual;
        covariances=dictionary.covariances.visual;
        priors=dictionary.priors.visual;
        %%% fisher vector encoding
        app_data_test=recog_clipsencode(DATASETS_test, means, covariances, priors);
        app_data_test = normalize(cell2mat(app_data_test)','Power-L2');
        app_data_test=app_data_test';
        %
        %%% interest point relative location bag of words
        DATASETS_test=compute_relative_loc(DATASETS_test);
        %%% fisher vector encoding
        %             [means, covariances, priors] = loc_gmm_cluster(DATASETS_train, k);
        means=dictionary.means.context;
        covariances=dictionary.covariances.context;
        priors=dictionary.priors.context;
        loc_data_test=loc_clipsencode( DATASETS_test, means, covariances, priors );
        loc_data_test = normalize(cell2mat(loc_data_test)','Power-L2');
        loc_data_test=loc_data_test';
    end
end
%%%combine location and appearance features
data_test=cat(2,app_data_test,loc_data_test);
%%%train classifier
for i=1:size(data_test,1)
    [p1,p2,p3]= svmpredict(1,sparse(data_test(i,:)), svmmodel,'-b 1');  
    [predict,scores(:,i)] = feval( clf.fun_fwd, clf, data_test(i,:) );
    predicts(predict,i)=1;
end




