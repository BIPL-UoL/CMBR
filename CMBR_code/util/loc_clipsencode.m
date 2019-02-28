% Create descriptor of every clip.
%
% INPUTS
%   DATASETS    - array of structs, should have the fields:
%           .subs       - length N cell vector of cuboid subs
%           .ncilps     - N: number of clips
%   clusters    - cuboid clusters
%   csigma      - soft assign see clipdesc
%
% OUTPUTS
%   data        - length N cell vector of (nclips x p) arrays of data

function data = loc_clipsencode( DATASETS, means, covariances, priors )
reqfs = {'nclips','rel_subs'};
if( ~isfield2( DATASETS, reqfs, 1) )
    ermsg=[]; for i=1:length(reqfs) ermsg=[ermsg reqfs{i} ', ']; end
    error( ['Each DATASET must have: ' ermsg 'initialized'] ); end;

%%% assign cuboids to clusters and creat descriptor for each clip in DATASET
stackGrid=[1 1 1];
k = size( means,2 );
d =size(means,1);
nsets = length(DATASETS);
nclips = cell2mat({DATASETS.nclips});
for i=1:nsets
    clipdesc = zeros(nclips(i),2*k*d*stackGrid(1)*stackGrid(2)*stackGrid(3));
    for j=1:nclips(i)
        if(size(DATASETS(i).rel_subs{j})~=0)
            encoding = vl_fisher(DATASETS(i).rel_subs{j}', means, covariances, priors);
%             encoding_sfv=sfv_encoding(DATASETS(i).rel_subs{j},DATASETS(i).subs{j}, means, covariances, priors,stackGrid);
            clipdesc(j,:) = encoding;
        end
    end;
    data{i} = clipdesc;
end;

