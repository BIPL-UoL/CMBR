clear;

[encode_method, normalize_method, gmm1_Size, gmm2_Size,dataset,stack_parameter] = initial_parameters();
clip_length=40;
cliptypes = { 'dig','eat','groom','micro','rear','walk' };
par_stfeatures = {2, 3, 1, 2e-4, [], 1.85, 1, 1, 0};
cubdesc = imagedesc_generate( 1, 'GRAD', -1 ); kpca = 100;

no_splits=10;
inverse=false;
features_path=[dataset '\features'];
if  exist(features_path,'file')
    for idx=1:no_splits
        [DATASETS_train,DATASETS_test,hmm,test_index] ...
            = get_data_summary(features_path,cliptypes,no_splits, idx,inverse);
        % %%% Using .mat format
        [predicts,nn_scores,targets] = recog_test_datasets( DATASETS_train,DATASETS_test, 20, stack_parameter,[]);
        scores=nn_scores;
        %%%Transform based on Bayes
        prior=zeros(length(cliptypes),1);
        for i=1:length(cliptypes)
            prior(i)=sum(DATASETS_train.IDX==i)/length(DATASETS_train.IDX);
        end
        prior=repmat(prior,[1 length(scores)]);
        scores=scores./prior;
        
        %%apply HMM model
        labels=zeros(size(scores));
        for i=1:length(test_index)
            [path] = viterbi_path(hmm.prior, hmm.trans, scores(:,test_index{i}));
            label=zeros(size(scores(:,test_index{i})));
            for j=1:length(path)
                label(path(j),j)=1;
            end
            labels(:,test_index{i})=label;
        end
        scores=labels;
        %%%intergrate all datas
        all_nnscores{idx}=nn_scores;
        all_scores{idx}=scores;
        all_predicts{idx}=predicts;
        all_IDX{idx}=DATASETS_test.IDX;
        %         [ER,CMS]=classification_model(data,double(IDX),cliptypes);
        % save('result.mat','ER','CMS');
        % confmatrix_show( CMS, cliptypes );
    end
    save('all_scores.mat','all_scores');
    save('all_IDX.mat','all_IDX');
    save('all_nnscores.mat','all_nnscores');
    allIDX=cell2mat(all_IDX');
    targets=zeros(max(allIDX),size(allIDX,1));
    for i=1:size(allIDX,1)
        targets(allIDX(i),i)=1;
    end
    outputs=cell2mat(all_scores);
    predicts=cell2mat(all_predicts);
    
    figure(1), h1=plotconfusion(targets,outputs);
    set(gca,'xticklabel',[cliptypes,' ']);
    set(gca,'yticklabel',[cliptypes,' ']);
    saveas(h1,'confusion.fig');
end







