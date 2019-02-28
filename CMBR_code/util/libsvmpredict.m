function [Y,scores] = libsvmpredict( clf,X )
if( ~strcmp( clf.type, 'svm' ) ) error( ['incorrect type: ' clf.type] ); end;
    if( size(X,2)~= clf.p ) error( 'Incorrect data dimension' ); end;
    model=clf.model;   
    
%     K_test = clf.train*X';
%     score_test = zeros(size(K_test,2), length(model));
%     for class_ind = 1:length(model)  
%         % test it on test
%         score_test(:,class_ind) = model(class_ind).sv_coef' * K_test(model(class_ind).SVs(:,1),:) - model(class_ind).rho ;
%     end
%     [~, Y] = max(score_test');
%     scores=score_test';

% %%%libsvm
% score_test = zeros(1, max(model.Label));
% % K_test = clf.train*X';
% [p1,p2,p3]= svmpredict(1,X, model);  
% for i=1:length(model.Label)
% score_test(i)=p3(model.Label==i);
% end
% [~,Y]=max(score_test);
% scores=score_test';

%%%liblinear
score_test = zeros(1, max(model.Label));
% K_test = clf.train*X';
[p1,p2,p3]= svmpredict(1,sparse(X), model,'-b 1');
if length(unique(p3))~=1
    for i=1:length(model.Label)
        score_test(i)=p3(model.Label==i);
    end
    Y=p1;
    scores=score_test';
else
    Y=7;
    score_test(Y)=1;
    scores=score_test';
end

