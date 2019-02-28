%%% X: N*M matrix, N is the number of traing sets, M is the dimension of
%%% each sample. 
%%% Y: N*1 dimension vector
function clf = libsvmtrain( clf, X, Y )
 if( ~strcmp( clf.type, 'svm' ) ) error( ['incorrect type: ' clf.type] ); end;
    if( size(X,2)~= clf.p ) error( 'Incorrect data dimension' ); end;

    %%% error check
    n=size(X,1);  Y=double(Y);
    [Y,er] = checknumericargs( Y, [n 1], 0, 0 ); error(er);
    
%     K_train= X*X';
%     for class_ind = 1:max(Y)
%         labels = 2*(Y == class_ind)-1; %pos = 1, neg = -1
%         libsvm_cl = svmtrain(labels(:), double([(1:length(Y))' K_train]), clf.varargin{1}) ;
%         ap = mean(libsvm_cl.sv_coef(labels(libsvm_cl.SVs(:,1)) > 0)) ;
%         am = mean(libsvm_cl.sv_coef(labels(libsvm_cl.SVs(:,1)) < 0)) ;
%         if ap < am
%             % fprintf('svmflip: SVM appears to be flipped. Adjusting.\n') ;
%             libsvm_cl.sv_coef  = - libsvm_cl.sv_coef ;
%             libsvm_cl.rho      = - libsvm_cl.rho ;
%         end   
%         model(class_ind)=libsvm_cl;
%     end
%     clf.model=model;
%     clf.train=X;

% %%%libsvm
% svm=svmtrain(Y,X,clf.varargin{1});
% clf.model=svm;

%%%liblinear
svm=svmtrain(Y,sparse(X),clf.varargin{1});
clf.model=svm;
end

