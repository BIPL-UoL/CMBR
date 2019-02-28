function teststructure = recog_teststructure( DATASETS_train, k,cluster_method,teststructure)
% parameters
%     csigma=0;
%     clfinit = @clf_knn; clfparams = {1,@dist_chisquared};
% clfinit = @clf_libsvm; clfparams = {'-t 0 -s 0 -h 0 -b 1 -c 100'};
clfinit = @clf_libsvm; clfparams = {'-c 100 -s 0'};
videoSize=[480,640,40];
app_data_train=[];
loc_data_train=[];
if strcmp(cluster_method,'kmean')

else if strcmp(cluster_method,'gmm')
        dictionary=gmm_train(DATASETS_train, k,0,videoSize);
        teststructure.dictionary=dictionary;
        %%% interest point appearance bag of words
%                     [means, covariances, priors]=recog_GMMcluster(DATASETS_train, k);
        means=dictionary.means.desc;
        covariances=dictionary.covariances.desc;
        priors=dictionary.priors.desc;
        %%% fisher vector encoding
        app_data_train=recog_clipsencode(DATASETS_train, means, covariances, priors);
        app_data_train = normalize(cell2mat(app_data_train)','Power-L2');
        app_data_train=app_data_train';
        %
        %%% interest point relative location bag of words
        DATASETS_train=compute_relative_loc(DATASETS_train);
        %%% fisher vector encoding
%         [means, covariances, priors] = loc_gmm_cluster(DATASETS_train, k);
        means=dictionary.means.rel_subs;
        covariances=dictionary.covariances.rel_subs;
        priors=dictionary.priors.rel_subs;
        loc_data_train=loc_clipsencode( DATASETS_train, means, covariances, priors );
        loc_data_train = normalize(cell2mat(loc_data_train)','Power-L2');
        loc_data_train=loc_data_train';
        
        %%% mouse width_height
        %%% fisher vector encoding
        means=dictionary.means.w_h;
        covariances=dictionary.covariances.w_h;
        priors=dictionary.priors.w_h;
%         [means, covariances, priors] = vl_gmm(DATASETS.width_height',10);
        w_h_train=zeros(DATASETS_train.nclips,size(covariances,1)*2*size(covariances,2));
        for i=1:DATASETS_train.nclips
        w_h_train(i,:)=vl_fisher(DATASETS_train.width_height(i,:)',means,covariances,priors);
        end
        w_h_train = normalize(w_h_train','Power-L2');
        w_h_train=w_h_train';
    end
end
%%%combine location and appearance features
data_train=cat(2,app_data_train,loc_data_train,w_h_train);

% %%%PCA+whiten
% whiten=1;
% [pcamap, centre] = xpca(data_train', whiten, size(data_train,2)*0.04);
% data_train = bsxfun(@minus,data_train,centre) * pcamap;
% data_train=normalize(data_train,'Power-L2');
% data_test=bsxfun(@minus,data_test,centre) * pcamap;
% data_test=normalize(data_test,'Power-L2');
%%%train classifier
[n,p]=size(data_train);

%%%svm
%%%set the weights of C
% weights=zeros(max(DATASETS_train.IDX),1);
% for i=1:max(DATASETS_train.IDX)
%     weights(i)=fix((length(DATASETS_train.IDX)-sum(DATASETS_train.IDX==i))/sum(DATASETS_train.IDX==i));
%     clfparams{:} = [clfparams{:} sprintf(' w%d %d',i,weights(i))];
% end
% 
% clf = feval( clfinit, p, clfparams{:} );
% clf = feval( clf.fun_train, clf, data_train, DATASETS_train.IDX);
% %%% add location information and h_w information
% %             data=location_desc(DATASETS,data);
% for i=1:size(data_test,1)
%     [predict,scores(:,i)] = feval( clf.fun_fwd, clf, data_test(i,:) );
%     predicts(predict,i)=1;
% end

% %%% neural network
% net=patternnet(100);
% net.layers{1}.transferFcn='satlin';
% net.divideParam.trainRatio=85/100;
% net.divideParam.valRatio=15/100;
% net.divideParam.testRatio=0;
% targets_train=zeros(length(unique(DATASETS_train.IDX)),length(DATASETS_train.IDX));
% for i=1:length(DATASETS_train.IDX)
%     targets_train(DATASETS_train.IDX(i),i)=1;
% end
% [net,tr]=train(net,data_train',targets_train);
% for i=1:size(data_test,1)
%     scores(:,i) = net(data_test(i,:)');
%     
%     [~,predict]=max(scores(:,i));
%     predicts(predict,i)=1;
% end

%%% neural network with sgd
%  complete the config.m to config the network structure;
cnnConfig = config1(size(data_train,2),max(DATASETS_train.IDX));
%  calling cnnInitParams() to initialize parameters
[theta meta] = cnnInitParams1(cnnConfig);
% options.epochs = 20;
options.epochs = 10;
options.minibatch = 8;
% options.minibatch = 12;
options.alpha = 3e-2;
options.momentum = .95;

opttheta = minFuncSGD(@(x,y,z) cnnCost(x,y,z,cnnConfig,meta),theta,data_train',DATASETS_train.IDX,options);
cnn.opttheta=opttheta;
cnn.cnnConfig=cnnConfig;
cnn.meta=meta;
teststructure.cnn=cnn;

