function [ER,CMS, validationPredictions ] = classification_model( predictors,response,cliptypes )
% Train a classifier
% This code specifies all the classifier options and trains the classifier.
template = templateSVM(...
    'KernelFunction', 'linear', ...
    'PolynomialOrder', [], ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 1, ...
    'Standardize', true);
classification = fitcecoc(...
    predictors, ...
    response, ...
    'Learners', template, ...
    'Coding', 'onevsall');
% Perform cross-validation
partitionedModel = crossval(classification, 'Kfold', 10);

% Compute validation accuracy
ER =kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');

% Compute validation predictions and scores
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);
CMS=confusionmat(response,validationPredictions);
targets=zeros(size(validationScores'));
for i=1:size(validationScores',2)
    targets(response(i),i)=1;
end
outputs=validationScores';
figure(1), h1=plotconfusion(targets,outputs);
set(gca,'xticklabel',[cliptypes,' ']);
set(gca,'yticklabel',[cliptypes,' ']);
saveas(h1,'confusion.fig');

figure(2), roc(targets,outputs);
[tpr,fpr,~] = roc(targets,outputs);
hold on
title('ROC')
set(gca, 'LineStyleOrder', {'-'});
for ii=1:length(cliptypes)
    h2=plot(fpr{ii}, tpr{ii},'LineWidth',2);
end
legend(cliptypes);
saveas(h2,'roc.fig');

end

