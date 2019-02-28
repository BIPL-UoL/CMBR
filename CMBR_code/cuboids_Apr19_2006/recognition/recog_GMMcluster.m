% Clusters all cuboids in DATASETS (based on their descriptions).
%
% INPUTS
%   DATASETS    - array of structs, should have the fields:
%           .cuboids    - [optional] length N cell vector of sets of cuboids
%           .desc       - length N cell vector of cuboid descriptors
%   k           - number of clusters to use
%   par_kmeans  - parameters for kmeans2
%
% OUTPUTS
%   clusters    - cluster centers
%   M           - cluster movie, slow to calculate
%
% See also RECOG_TEST

function [means, covariances, priors] = recog_GMMcluster( DATASETS, k )
%     maxsamples = min(6000,k*30);
    maxsamples = 6000;
    % get all the cuboids / cuboid descriptors
    nsets = length( DATASETS );
    isCuboid = isfield( DATASETS, 'cuboids' );
    cuboids=[]; desc=[];
    for s=1:nsets
        if(isCuboid) cuboids=cat(4,cuboids,cell2mat( DATASETS(s).cuboids )); end;
        desc = cat(1,desc,cell2mat( DATASETS(s).desc ));
    end;
    
    % subsample
    n = size(desc,1);
    if( maxsamples < n )
         keeplocs=randperm(n); keeplocs=keeplocs(1:maxsamples);
         if(isCuboid) cuboids=cuboids(:,:,:,keeplocs); end;
         desc = desc(keeplocs,:);
     end;

    % get GMM
    [means, covariances, priors] = vl_gmm(desc', k);
    
