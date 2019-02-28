% Wrapper for svm that makes svm compatible with nfoldxval.
%

function clf = clf_libsvm(p,varargin)
    clf.type='svm';
    clf.p = p;
    clf.varargin=varargin;
    clf.fun_train = @libsvmtrain;
    clf.fun_fwd = @libsvmpredict;
