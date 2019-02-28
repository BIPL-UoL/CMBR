% Test the performance of behavior recognition using the cuboid representation.
%
% Given n sets of data, each containing multiple data instances, we train on 1 set at a
% time, and then test on each of the remaining sets.  Thus there are (n x n) separate
% training/testing scenarios. [Note: to get performance on set i given training on i we
% use cross validation WITHIN the set].   Note that this is not cross validation where
% training occurs on all but (n-1) of the sets and testing on the remaining one, giving a
% total of (n) training/testing scenarios.  
%
% Clustering is performed (using recog_cluster) on cuboids from the single training set.
% Once the clustering is obtained, each cuboid in all the clips in all the sets is
% assigned a type and each clip is converted to a histogram of cuboid types (using
% recog_clipsdesc).  Afterwards standard classification techniques are used to train/test.
%
% Parameters for clustering and classification can be specified inside this file.
%
% INPUTS
%   DATASETS    - array of structs, should have the fields:
%           .IDX        - length N vector of clip types
%           .desc       - length N cell vector of cuboid descriptors
%           .ncilps     - N: number of clips
%   k           - number of clusters
%   nreps       - number of repetitions
%   
% OUTPUTS
%   ER      - error matricies [nsets x nsets] - averaged over nreps
%   CMS     - confusion matricies [nclass x nclass x nsets x nsets] - averaged over nreps
%
% See also RECOGNITION_DEMO, RECOG_TEST_NFOLD, NFOLDXVAL, RECOG_CLUSTER, RECOG_CLIPSDESC

function [ER,CMS] = recog_test( DATASETS,test_structure, k, nreps )
    % parameters
%     csigma=0; 
%     clfinit = @clf_knn; clfparams = {1,@dist_chisquared};
    clfinit = @clf_libsvm; clfparams = {'-t 0 -s 0 -h 0 -c 100 -b 1'};
%     book_method='kmean';
%     par_kmeans={'replicates',5,'minCsize',1,'display',0,'outlierfrac',0 };

    book_method='gmm';

    nsets = length( DATASETS );
    nclasses = max( DATASETS(1).IDX );
    ER = zeros(nsets,nsets,nreps);
    CMS = zeros(nclasses,nclasses,nsets,nsets,nreps);
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
%                 loc_data=loc_clipsdesc( DATASETS, l_clusters, csigma );
%                 loc_data=cell2mat(loc_data);
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
            data=cat(2,app_data,loc_data);
            data={data};
            %%% add location information and h_w information
%             data=location_desc(DATASETS,data);
            
            IDXs = {DATASETS.IDX};
            for j=1:nsets 
                if( i==j )
                    [e,cm,clf]=recog_test1( data{i}, IDXs{i}, clfinit, clfparams);
                    test_structure.clf=clf;
                else
                    [e,cm]=recog_test2( data{i}, IDXs{i}, data{j}, IDXs{j}, ... 
                                               clfinit, clfparams );
                end;
                ER(i,j,h)=e;  CMS(:,:,i,j,h)=cm;
            end;
            tocstatus( ticstatusid, cnt/(nsets*nreps) ); cnt=cnt+1;
        end;
    end;
    save('test_structure.mat','test_structure');
    CMS = mean(CMS,5);
    ER = mean(ER,3);
    

%%% perform nfoldxval for every clip in dataset
function [e,cm,clf] = recog_test1( X, IDX, clfinit, clfparams)
    [nclips,p] = size(X); nclasses=max(IDX);
    IDXcell = mat2cell(IDX,ones(1,nclips),1);  
    data = mat2cell(X,ones(1,nclips),p);
    data={data{:}}; IDXcell={IDXcell{:}};
    [cm,clf] = nfoldxval( data, IDXcell, clfinit, clfparams,[],[],[],0 );
    e = 1- sum(diag(cm))/sum(cm(:));

%%% train on 1 dataset, test on other
function [er,cm] = recog_test2( Xtrain, IDXtrain, Xtest, IDXtest, clfinit, clfparams )
    [ntrain,p] = size(Xtrain); 
    net = feval( clfinit, p, clfparams{:} );
    net = feval( net.fun_train, net, Xtrain, IDXtrain );
    IDXpred = feval( net.fun_fwd, net, Xtest );
    cm = confmatrix( IDXtest, IDXpred, max(IDXtrain) );
    er = 1- sum(diag(cm))/sum(cm(:));
