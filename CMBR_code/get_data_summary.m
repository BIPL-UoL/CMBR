function [DATASETS_train,DATASETS_test,hmm,test_index] = get_data_summary(features_path,cliptypes,no_splits, idx,inverse)

if ~exist('idx', 'var')
    idx = 1;
end

vid = dir(features_path);
vid=vid(3:end);
l = length(vid);
DATASETS_train.IDX=[];
DATASETS_train.cubcount = [];
DATASETS_train.subs = [];
DATASETS_train.desc = [];
DATASETS_test.IDX=[];
DATASETS_test.cubcount = [];
DATASETS_test.subs = [];
DATASETS_test.desc = [];
trans_sum=zeros(size(cliptypes));
for i=1:l
    DATASETS_all.IDX=[];
    DATASETS_all.cubcount = [];
    DATASETS_all.subs = {};
    DATASETS_all.desc = {};
    d = dir(fullfile(features_path, vid(i).name,'*.mat'));
    len = length(d);
    files = cell(len, 1);
    ticstatusid = ticstatus('feval_mats');
    for j = 1:len
        files{j} = fullfile(vid(i).name,d(j).name);
        matcontents = {'clipname','cliptype','desc','subs'};
        S = load( [features_path '/' files{j}] );
        errmsg = ['Unexpected contents for mat file: ' [features_path '/' files{j}]];
        if( length(fieldnames(S))<length( matcontents )) error( errmsg ); end;
        inputs = cell(1,length( matcontents ));
        for jj=1:length( matcontents )
            if( ~isfield(S,matcontents{jj}) ) error( errmsg ); end;
            inputs{jj} = S.(matcontents{jj});
        end; clear S;
        xn = feval( @featuresConv, inputs,cliptypes );
        DATASETS_all.IDX = [DATASETS_all.IDX;xn.IDX];
        DATASETS_all.cubcount = [DATASETS_all.cubcount;xn.cubcount];
        DATASETS_all.subs=cat(1,DATASETS_all.subs,xn.subs);
        DATASETS_all.desc=cat(1,DATASETS_all.desc,xn.desc);
        tocstatus( ticstatusid, double(j/len) );
    end
    
    index = true(len, 1);   % training samples
    clips_number_test = fix(len./no_splits);
    index((idx-1)*clips_number_test+1:idx*clips_number_test) = false;
    test_index{i}=~index;
    %%% inverse train and test dataset
    if inverse
        test_index{i}=index;
        index=~index;
    end
    DATASETS_train.IDX=[DATASETS_train.IDX;DATASETS_all.IDX(index)];
    DATASETS_train.cubcount = [DATASETS_train.cubcount;DATASETS_all.cubcount(index)];
    DATASETS_train.subs = cat(1, DATASETS_train.subs,DATASETS_all.subs(index));
    DATASETS_train.desc = cat(1,DATASETS_train.desc,DATASETS_all.desc(index));
    DATASETS_train.nclips = length(DATASETS_train.IDX);
    
    DATASETS_test.IDX=[DATASETS_test.IDX;DATASETS_all.IDX(test_index{i})];
    DATASETS_test.cubcount = [DATASETS_test.cubcount;DATASETS_all.cubcount(test_index{i})];
    DATASETS_test.subs = cat(1, DATASETS_test.subs,DATASETS_all.subs(test_index{i}));
    DATASETS_test.desc = cat(1,DATASETS_test.desc,DATASETS_all.desc(test_index{i}));
    DATASETS_test.nclips = length(DATASETS_test.IDX);
    %%%train HMM
    tran=hmmestimate(ones(1,sum(index)),DATASETS_all.IDX(index));
    tran_full=zeros(length(cliptypes),length(cliptypes));
    tran_full(1:size(tran,1),1:size(tran,2))=tran;
    trans_sum=trans_sum+tran_full;
end

indicator=1;
for i=1:length(test_index)
    test_ind=false(length(DATASETS_test.IDX),1);
    
    test_ind(indicator:indicator+sum(test_index{i})-1)=true;
    indicator=indicator+sum(test_index{i});
    test_index{i}=test_ind;
end

mul=repmat(1./sum(trans_sum,2),[1,size(trans_sum,1)]);
hmm.trans=trans_sum.*mul;
hmm.prior=zeros(length(cliptypes),1);
for i=1:length(cliptypes)
    hmm.prior(i)=1/8;
end
end

function x = featuresConv( vals,cliptypes)
[clipname,cliptype, desc, subs] = deal( vals{:} );
[disc, IDX] = ismember(cliptype, cliptypes);
x.IDX = uint8(IDX);
x.subs = {subs};
x.cubcount = size(subs,1);
x.desc = {desc};
end
