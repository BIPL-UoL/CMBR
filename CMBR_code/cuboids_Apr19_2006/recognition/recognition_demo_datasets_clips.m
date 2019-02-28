% Describes all steps of behavior recognition; example for facial expressions.
%
% The file describes the following:
%   1) data format [3 choices]
%   2) feature detection & description [2 choices]
%   3) behavior classification 
%
% Data and additional information can be obtained at:
%   http://vision.ucsd.edu/~pdollar/research/research.html
%
% ----------------------------------------------------------------------------------------
% DATA FORMAT
%
% First the directory of the data must be specified.  
% Alter datadir.m to point to the location of the data. 
%
% Behavior data can be represented in 1 of 3 ways.  In each case data is divided into a
% number of 'sets', each set contains data that should be treated together (for training
% and testing, see generating results for more info).  In each case, a set contains a
% number of behavior clips. The three methods for representing a set are:
%       [set_ind] the 2 digit set index, '00','01',...
%       [cliptype] represents behavior type, such as 'grooming' or 'smiling'  
%       [instance] represents the 3 digit instance number - '000','001',...
%   1) .avi files in a datadir/set[set_ind]/, named '[cliptype][instance].avi'
%   2) .mat files in a datadir/set[set_ind]/, named 'clip_[cliptype][instance].mat'
%      When loaded the file contains two matlab variables: 'I' and 'clipname'
%   3) a single DATASETS struct, kept in memory as DATASETS, described below.  
%
% If all the sets can be stored in memory at once, the third option can be used.  DATASETS
% is an array of nsets elements, where each element is a struct representing a set of
% data.  Each DATASETS should initally have the following two fields: IS and IDX.  IS is
% either a ...xN 4D array of N clips or an N element cell array of clips (3D arrays).  IDX
% should be a length N uint8 vector of clip types.  Note that as processing proceeds the
% contents of DATASETS will change.
%
% One can convert between the formats using the conv_* functions. To go from DATASETS
% format to .avi format, go through the .mat format.
%
% ----------------------------------------------------------------------------------------
% FEATURE DETECTION & DESCRIPTION
%
% These functions are used to detect cuboids and than apply descriptors to them, creating
% data that can than be used in various training / testing scenarios described next.  The
% two function featuresSM and featuresLG both return the same output.  The difference is
% that featuresSM works with data fully in memory (the DATASETS format), while featuresLG
% writes things back and forth to the hard disk (using the .mat format).  If the files are
% originally in .avi format, they need to be converted to either .mat format or the
% DATASETS format.
%
% ----------------------------------------------------------------------------------------
% BEHAVIOR CLASSIFICATION
%   See recog_test or recog_test_nfold
%
% ----------------------------------------------------------------------------------------
% EXAMPLE b.elow 

% set directory in datadir.m
clear;
clip_length=40;
%%%add some clips from 'clip datasets'
load('C:\Users\40108307\Documents\MATLAB\continouse_video\mouse_data\DATASETS.mat');
% load('test_structure(v_p_context).mat');
% gmm=test_structure.gmm;
cliptypes = { 'drink','eat','groom','hang','head','rear','rest','walk' };
% cliptypes = {'video4_rear_','video4_groom_', 'video4_eat_','video4_drink_','video4_hang_','video4_rest_','video4_walk_' };
par_stfeatures = {2, 3, 1, 2e-4, [], 1.85, 1, 1, 0};
cubdesc = imagedesc_generate( 1, 'GRAD', -1 ); kpca = 100;
%%%they are moved into featuresLG for svaing space
% conv_movies2clips(clip_length);
% conv_frames2clips(clip_length);

% %%% Using .mat format
% [DATASETS,cubdesc,cuboids] = featuresLG( cliptypes, ...
%     par_stfeatures, 20, cubdesc, kpca,clip_length );
% % savefields = {'DATASETS', 'cubdesc', 'cuboids', 'cliptypes'};
% % save( [datadir() '/DATASETSprLG.mat'], savefields{:} );

featuresdir=[datadir '\features'];
clips_files=dir(featuresdir);
clips_files=clips_files(3:end);
clips_files=clips_files([1,2,3,4,5,6,7,8,9,10,11,12]);
predicts=cell(1,length(clips_files));
nn_scores=cell(1,length(clips_files));
scores=cell(1,length(clips_files));
targets=cell(1,length(clips_files));
for t=1:length(clips_files)
    DATASETS_train=[];
    DATASETS_test=[];
    X_test=[];
    X_train=[];
    ticstatusid = ticstatus('recog_test',[],10 ); cnt=1;
    length_train_dataset=zeros(1,length(clips_files)-1);
    number_train_dataset=0;
    
    for n=1:length(clips_files)
        if n~=t
            matcontents = {'clipname','cliptype','desc','subs'};
            params = {[featuresdir '\' clips_files(n).name], cliptypes};
            xn = feval_mats( @features_conv, matcontents, params, [featuresdir '\' clips_files(n).name], 'features' );
            
            number_train_dataset=number_train_dataset+1;
            length_train_dataset(number_train_dataset)=length(xn);
            
            X_train=cat(2,X_train,xn);
        else
            matcontents = {'clipname','cliptype','desc','subs'};
            params = {[featuresdir '\' clips_files(n).name], cliptypes};
            xn = feval_mats( @features_conv, matcontents, params, [featuresdir '\' clips_files(n).name], 'features' );
            X_test=cat(2,X_test,xn);           
        end
        tocstatus( ticstatusid, cnt/(length(clips_files))); cnt=cnt+1;
    end;
    fprintf('start to train and test\n');
    nclips_train = length(X_train);
    nclips_test = length(X_test);
    DATASETS_train.IDX=[zeros(nclips_train,1);DATASETS.IDX];
    DATASETS_test.IDX=zeros(nclips_test,1);
    DATASETS_train.cubcount = [zeros(nclips_train,1);DATASETS.cubcount(:,1)];
    DATASETS_test.cubcount = zeros(nclips_test,1);
    DATASETS_train.subs =cat(1, cell(nclips_train,1),DATASETS.subs);
    DATASETS_test.subs = cell(nclips_test,1);
    DATASETS_train.desc = cat(1,cell(nclips_train,1),DATASETS.desc);
    DATASETS_test.desc = cell(nclips_test,1);
    for i=1:nclips_train
        DATASETS_train.IDX(i,1) = X_train(i).IDX;
        DATASETS_train.cubcount(i) = X_train(i).cubcount;
        DATASETS_train.subs{i} = X_train(i).subs;
        DATASETS_train.desc{i,1} = X_train(i).desc;
    end;
    for i=1:nclips_test
        DATASETS_test.IDX(i,1) = X_test(i).IDX;
        DATASETS_test.cubcount(i) = X_test(i).cubcount;
        DATASETS_test.subs{i} = X_test(i).subs;
        DATASETS_test.desc{i,1} = X_test(i).desc;
    end;
    %%%start to train a classifier
    DATASETS_train.nclips = nclips_train+DATASETS.nclips;
    DATASETS_test.nclips = nclips_test;
    [predicts{t},nn_scores{t},targets{t}] = recog_test_datasets( DATASETS_train,DATASETS_test, 20, 'gmm',[]);
%%%Transform based on Bayes    
    prior=zeros(length(cliptypes),1);
%     for i=1:length(cliptypes)
%         %     prior(i)=sum(DATASETS_train.IDX==i)/length(DATASETS_train.IDX);
%         prior(i)=1/8;
%         %     prior(i)=length(DATASETS_train.IDX)/sum(DATASETS_train.IDX==i);
%     end
    for i=1:length(cliptypes)
        prior(i)=sum(DATASETS_train.IDX==i)/length(DATASETS_train.IDX);
    end
    prior=repmat(prior,[1 length(nn_scores{t})]);
    scores{t}=nn_scores{t}./prior;

    %%apply HMM model
    trans=cell(1,number_train_dataset);
    start_index=1;
    for i=1:number_train_dataset    
        trans{i}=hmmestimate(ones(1,length_train_dataset(i)),DATASETS_train.IDX(start_index:start_index+length_train_dataset(i)-1));
        start_index=start_index+length_train_dataset(i);
        tran=zeros(length(cliptypes),length(cliptypes));
        tran(1:size(trans{i},1),1:size(trans{i},2))=trans{i};
        trans{i}=tran;
    end
    trans_sum=zeros(size(trans{1}));

    for i=1:number_train_dataset
        trans_sum=trans_sum+trans{i};
    end
    mul=repmat(1./sum(trans_sum,2),[1,size(trans_sum,1)]);
    trans=trans_sum.*mul;
    prior=zeros(length(cliptypes),1);
    for i=1:length(cliptypes)
%     prior(i)=sum(DATASETS_train.IDX==i)/length(DATASETS_train.IDX);
    prior(i)=1/8;
%     prior(i)=length(DATASETS_train.IDX)/sum(DATASETS_train.IDX==i);
    end
%     prior=normalise(prior);
    [path] = viterbi_path(prior, trans, scores{t});
    label=zeros(size(scores{t}));
    for i=1:length(path)
        label(path(i),i)=1;
    end
    scores{t}=label;
%     
end
targets=cell2mat(targets);
outputs=cell2mat(scores);
predicts=cell2mat(predicts);
save('outputs.mat','outputs');
save('targets.mat','targets');
save('nn_scores.mat','nn_scores');
figure(1), h1=plotconfusion(targets,outputs);
set(gca,'xticklabel',[cliptypes,' ']);
set(gca,'yticklabel',[cliptypes,' ']);
saveas(h1,'confusion.fig');
