clear;
cliptypes = { 'rear','groom','eat','drink','hang','rest','walk','head' };
load DATASETSprLG
par_stfeatures = {2, 3, 1, 2e-4, [], 1.85, 1, 1, 0};
test_structure.cliptypes=cliptypes;
test_structure.cubdesc=cubdesc;
test_structure.par_stfeatures=par_stfeatures;
% parameters
%     csigma=0;
%     clfinit = @clf_knn; clfparams = {1,@dist_chisquared};
clfinit = @clf_libsvm; clfparams = {'-t 0 -s 0 -h 0 -c 100 -b 1'};
%     book_method='kmean';
%     par_kmeans={'replicates',5,'minCsize',1,'display',0,'outlierfrac',0 };

book_method='gmm';
k=20;

nsets = length( DATASETS );
nclasses = max( DATASETS(1).IDX );
ticstatusid = ticstatus('recog_test;',[],10 ); cnt=1;
app_data=[];
loc_data=[];
if strcmp(book_method,'kmean')
    %%% normal kmean
    app_clusters = recog_cluster( DATASETS, k, par_kmeans );
    app_data = recog_clipsdesc( DATASETS, app_clusters, csigma );
    app_data=cell2mat(app_data);
    %%% interest point relative location bag of words
    DATASETS=compute_relative_loc(DATASETS);
    
    %%% normal kmean
    l_clusters = loc_cluster(DATASETS, k, par_kmeans);
    loc_data=loc_clipsdesc( DATASETS, l_clusters, csigma );
    loc_data=cell2mat(loc_data);
    kmean.app_clusters=app_clusters;
    kmean.l_clusters=l_clusters;
    kmean.k=k;
    test_structure.kmean=kmean;
else if strcmp(book_method,'gmm')
        %%% interest point appearance bag of words
        [means, covariances, priors]=recog_GMMcluster(DATASETS, k);
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
        [means, covariances, priors] = loc_gmm_cluster(DATASETS, k);
        loc_data=loc_clipsencode( DATASETS, means, covariances, priors );
        loc_data = normalize(cell2mat(loc_data)','Power-L2');
        loc_data=loc_data';
        gmm.means.context=means;
        gmm.covariances.context=covariances;
        gmm.priors.context= priors;
        gmm.k=k;
        
        %%% weight_height
        [means, covariances, priors] = vl_gmm(DATASETS.width_height',10);
        gmm.means.w_h=means;
        gmm.covariances.w_h=covariances;
        gmm.priors.w_h= priors;
        gmm.k=k;
        
        test_structure.gmm=gmm;
    end
end
%%%combine location and appearance features
data=cat(2,app_data,loc_data);

[n,p]=size(data);  
clf = feval( clfinit, p, clfparams{:} );
clf = feval( clf.fun_train, clf, data, DATASETS.IDX);
test_structure.clf=clf;

save('test_structure.mat','test_structure');
