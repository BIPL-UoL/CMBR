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

function data = loc_clipsdesc( DATASETS, clusters, csigma )
    reqfs = {'nclips','rel_subs'};
    if( ~isfield2( DATASETS, reqfs, 1) ) 
        ermsg=[]; for i=1:length(reqfs) ermsg=[ermsg reqfs{i} ', ']; end
        error( ['Each DATASET must have: ' ermsg 'initialized'] ); end;

    %%% assign cuboids to clusters and creat descriptor for each clip in DATASET
    k = size( clusters,1 );
    nsets = length(DATASETS);
    nclips = cell2mat({DATASETS.nclips});
    for i=1:nsets
        clipdesc = zeros(nclips(i),k); 
        for j=1:nclips(i)  
            desclust = imagedesc2clusters( DATASETS(i).rel_subs{j}, clusters, csigma );           
            clipdesc(j,:) = recog_clipdesc( desclust, k ); 
        end;
        data{i} = clipdesc;
    end;

