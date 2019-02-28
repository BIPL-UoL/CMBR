function [ER,CMS] = recog_test_more( DATASETS,test_structure, k, nreps,cliptypes )

%   Detailed explanation goes here
% book_method='kmean';
% csigma=0;
% par_kmeans={'replicates',5,'minCsize',1,'display',0,'outlierfrac',0 };
    book_method='gmm';

nsets = length( DATASETS );
nclasses = max( DATASETS(1).IDX );
ticstatusid = ticstatus('recog_test;',[],10 ); cnt=1;
for h=1:nreps
    for i=1:nsets
        app_data=[];
        loc_data=[];
        if strcmp(book_method,'kmean')
            %%% normal kmean
            app_clusters = recog_cluster( DATASETS(i), k, par_kmeans );
            app_data = recog_clipsdesc( DATASETS, app_clusters, csigma );
            app_data=cell2mat(app_data);
            %%% interest point relative location bag of words
            DATASETS=compute_relative_loc(DATASETS);
            
            %%% normal kmean
            l_clusters = loc_cluster(DATASETS(i), k, par_kmeans);
            loc_data=loc_clipsdesc( DATASETS, l_clusters, csigma );
            loc_data=cell2mat(loc_data);
            kmean.app_clusters=app_clusters;
            kmean.l_clusters=l_clusters;
            kmean.k=k;
            test_structure.kmean=kmean;
        else if strcmp(book_method,'gmm')
                %%% interest point appearance bag of words
                [means, covariances, priors]=recog_GMMcluster(DATASETS(i), k);
                %%% fisher vector encoding
                app_data=recog_clipsencode(DATASETS, means, covariances, priors);
                app_data = normalize(cell2mat(app_data)','Power-L2');
                app_data=app_data';
                gmm.means.visual=means;
                gmm.covariances.visual=covariances;
                gmm.priors.visual= priors;
%                 
                %%% interest point relative location bag of words
                DATASETS=compute_relative_loc(DATASETS);
                %%% fisher vector encoding
                [means, covariances, priors] = loc_gmm_cluster(DATASETS(i), k);
                loc_data=loc_clipsencode( DATASETS, means, covariances, priors );
                loc_data = normalize(cell2mat(loc_data)','Power-L2');
                loc_data=loc_data';
                gmm.means.context=means;
                gmm.covariances.context=covariances;
                gmm.priors.context= priors;
                gmm.k=k;
                test_structure.gmm=gmm;
            end
        end
        %%%combine location and appearance features
        predictors=cat(2,app_data,loc_data);
        response = DATASETS.IDX;
        [ER,CMS,validationScores]=classification_model(predictors,response,cliptypes);
        save('roc.mat','response','validationScores');
        
    end;
end

