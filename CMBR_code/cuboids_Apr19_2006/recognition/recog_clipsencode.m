
function data = recog_clipsencode( DATASETS, means, covariances, priors,stackGrid)
    reqfs = {'nclips','desc'};
    if( ~isfield2( DATASETS, reqfs, 1) ) 
        ermsg=[]; for i=1:length(reqfs) ermsg=[ermsg reqfs{i} ', ']; end
        error( ['Each DATASET must have: ' ermsg 'initialized'] ); end;

    %%% assign cuboids to clusters and creat descriptor for each clip in DATASET
    k =size(means,2);
    d =size(means,1);
    nsets = length(DATASETS);
    nclips = cell2mat({DATASETS.nclips});
    for i=1:nsets
        clipdesc = zeros(nclips(i),2*k*d*(stackGrid(1)*stackGrid(2)*stackGrid(3)+1)); 
        for j=1:nclips(i) 
            %%% encode each sample in datasets
            if(size(DATASETS(i).desc{j})~=0)
                encoding_sfv=sfv_encoding(DATASETS(i).desc{j},DATASETS(i).subs{j}, means, covariances, priors,stackGrid);
                clipdesc(j,:) = encoding_sfv;
            end
        end
        data{i} = clipdesc;
    end
