function [predicts,scores,targets] = recog_test_datasets( DATASETS_train,DATASETS_test, k,stack_parameter,dictionary)

predicts=zeros(max(DATASETS_train.IDX),DATASETS_test.nclips);
scores=zeros(max(DATASETS_train.IDX),DATASETS_test.nclips);
targets=zeros(max(DATASETS_train.IDX),DATASETS_test.nclips);
for i=1:length(DATASETS_test.IDX)
    targets(DATASETS_test.IDX(i),i)=1;
end

%%% train gmm for both visual and context features
if isempty(dictionary)
    dictionary=gmm_train(DATASETS_train, k,0);
end
means=dictionary.means.desc;
covariances=dictionary.covariances.desc;
priors=dictionary.priors.desc;
%%% SFV for visual feature
app_data_train=recog_clipsencode(DATASETS_train, means, covariances, priors,stack_parameter.stackGrid);
app_data_test=recog_clipsencode(DATASETS_test, means, covariances, priors,stack_parameter.stackGrid);
app_data_train = normalize(cell2mat(app_data_train)','Power-L2');
app_data_test = normalize(cell2mat(app_data_test)','Power-L2');
app_data_train=app_data_train';
app_data_test=app_data_test';

DATASETS_train=compute_relative_loc(DATASETS_train);
DATASETS_test=compute_relative_loc(DATASETS_test);
%%% relative spatial position
means=dictionary.means.rel_subs;
covariances=dictionary.covariances.rel_subs;
priors=dictionary.priors.rel_subs;
loc_data_train=loc_clipsencode( DATASETS_train, means, covariances, priors );
loc_data_test=loc_clipsencode( DATASETS_test, means, covariances, priors );
loc_data_train = normalize(cell2mat(loc_data_train)','Power-L2');
loc_data_test = normalize(cell2mat(loc_data_test)','Power-L2');
loc_data_train=loc_data_train';
loc_data_test=loc_data_test';

%%% absolute spatial position
means=dictionary.means.w_h;
covariances=dictionary.covariances.w_h;
priors=dictionary.priors.w_h;
w_h_train=zeros(DATASETS_train.nclips,size(covariances,1)*2*size(covariances,2));
w_h_test=zeros(DATASETS_test.nclips,size(covariances,1)*2*size(covariances,2));
for i=1:DATASETS_train.nclips
    w_h_train(i,:)=vl_fisher(DATASETS_train.width_height(i,:)',means,covariances,priors);
end
for i=1:DATASETS_test.nclips
    w_h_test(i,:)=vl_fisher(DATASETS_test.width_height(i,:)',means,covariances,priors);
end
w_h_train = normalize(w_h_train','Power-L2');
w_h_test = normalize(w_h_test','Power-L2');
w_h_train=w_h_train';
w_h_test=w_h_test';

%%%PCA int
[app_data_train,app_data_test,pcamap]=pca_int(app_data_train,app_data_test,stack_parameter.stackGrid);

%%%combine context and appearance features
data_train=cat(2,app_data_train,loc_data_train, w_h_train);
data_test=cat(2,app_data_test,loc_data_test,w_h_test);

%%%train SAN
[n,p]=size(data_train);

cnnConfig = config1(size(data_train,2),max(DATASETS_train.IDX),pcamap);
[theta meta] = cnnInitParams1(cnnConfig,pcamap);
options.epochs = 10;
options.minibatch = 8;
options.alpha = 3e-2;
options.momentum = .95;

opttheta = minFuncSGD(@(x,y,z) cnnCost(x,y,z,cnnConfig,meta),theta,data_train',DATASETS_train.IDX,options);
for i=1:size(data_test,1)
    [cost,grad,preds,output]=cnnCost(opttheta,data_test(i,:)',DATASETS_test.IDX,cnnConfig,meta,true);
    scores(:,i) = output;
    [~,predict]=max(scores(:,i));
    predicts(predict,i)=1;
end
