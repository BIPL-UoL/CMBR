function [predicts,scores] = recog_test_teststructure( DATASETS_test, cluster_method,teststructure)
% parameters
%     csigma=0;
%     clfinit = @clf_knn; clfparams = {1,@dist_chisquared};
% clfinit = @clf_libsvm; clfparams = {'-t 0 -s 0 -h 0 -b 1 -c 100'};
clfinit = @clf_libsvm; clfparams = {'-c 100 -s 0'};
videoSize=[480,640,40];
if strcmp(cluster_method,'kmean')

else if strcmp(cluster_method,'gmm')
        dictionary=teststructure.dictionary;
        means=dictionary.means.desc;
        covariances=dictionary.covariances.desc;
        priors=dictionary.priors.desc;
        %%% fisher vector encoding
        app_data_test=recog_clipsencode(DATASETS_test, means, covariances, priors);
        app_data_test =cell2mat(app_data_test);
        app_data_test= normalize(app_data_test','Power-L2');
        app_data_test=app_data_test';
        %
        %%% interest point relative location bag of words
        DATASETS_test=compute_relative_loc(DATASETS_test);
        %%% fisher vector encoding
%         [means, covariances, priors] = loc_gmm_cluster(DATASETS_train, k);
        means=dictionary.means.rel_subs;
        covariances=dictionary.covariances.rel_subs;
        priors=dictionary.priors.rel_subs;
        loc_data_test=loc_clipsencode( DATASETS_test, means, covariances, priors );
        loc_data_test = cell2mat(loc_data_test);
        loc_data_test=normalize(loc_data_test','Power-L2');
        loc_data_test=loc_data_test';
        
        %%% mouse width_height
        %%% fisher vector encoding
        means=dictionary.means.w_h;
        covariances=dictionary.covariances.w_h;
        priors=dictionary.priors.w_h;
        w_h_test=zeros(DATASETS_test.nclips,size(covariances,1)*2*size(covariances,2));
        for i=1:DATASETS_test.nclips
            w_h_test(i,:)=vl_fisher(DATASETS_test.width_height(i,:)',means,covariances,priors);
        end
        w_h_test = normalize(w_h_test','Power-L2');
        w_h_test=w_h_test';
    end
end
%%%combine location and appearance features
data_test=cat(2,app_data_test,loc_data_test,w_h_test);

% %%%PCA+whiten
% whiten=1;
% [pcamap, centre] = xpca(data_train', whiten, size(data_train,2)*0.04);
% data_train = bsxfun(@minus,data_train,centre) * pcamap;
% data_train=normalize(data_train,'Power-L2');
% data_test=bsxfun(@minus,data_test,centre) * pcamap;
% data_test=normalize(data_test,'Power-L2');
%%%train classifier

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
cnn=teststructure.cnn;
opttheta = cnn.opttheta;
cnnConfig=cnn.cnnConfig;
meta=cnn.meta;
for i=1:size(data_test,1)
    [cost,grad,preds,output]=cnnCost(opttheta,data_test(i,:)',DATASETS_test.IDX,cnnConfig,meta,true);
    scores(:,i) = output;
    [~,predict]=max(scores(:,i));
    predicts(predict,i)=1;
end
