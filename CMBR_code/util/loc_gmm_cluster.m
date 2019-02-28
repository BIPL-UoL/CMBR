% Clusters all cuboids in DATASETS (based on their location).
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

function [means, covariances, priors] = loc_gmm_cluster( DATASETS, k )
%     maxsamples = min(6000,k*30);
    maxsamples = 6000;
    % get all the cuboids / cuboid descriptors
    nsets = length( DATASETS );
    isCuboid = isfield( DATASETS, 'cuboids' );
    cuboids=[]; subs=[];
    for s=1:nsets
        if(isCuboid) 
            cuboids=cat(4,cuboids,cell2mat( DATASETS(s).cuboids )); end;
        subs = cat(2,subs,cell2mat(DATASETS.rel_subs));
    end;
    
    % subsample
    n = size(subs,1);
    if( maxsamples < n )
         keeplocs=randperm(n); keeplocs=keeplocs(1:maxsamples);
         if(isCuboid) 
             cuboids=cuboids(:,:,:,keeplocs); end;
         subs = subs(keeplocs,:);
     end;

    % get clusters
    [means, covariances, priors] = vl_gmm(subs', k);
    


