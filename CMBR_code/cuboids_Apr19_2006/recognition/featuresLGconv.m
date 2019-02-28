% Convert features to DATASETS format so output is same as after featuresSM.
%
% Loads each features_[activity].mat, for each clip in each set, and merges the results
% into DATASETS format. Does not try to add cuboids to the datasets as potentially this
% could take too much memory. 
%
% INPUTS
%   nsets           - number of sets
%   cliptypes       - types of clips (cell of strings)
%
% OUTPUTS
%   DATASETS    - array of structs, will have additional fields:
%           .IDX        - length N vector of clip types
%           .ncilps     - N: number of clips
%           .cubcount   - length N vector of cuboids counts for each clip clip
%           .subs       - length N cell vector of sets of locations of cuboids
%           .desc       - length N cell vector of cuboid descriptors
%
% See also FEATURESLG, FEATURESSM

function DATASETS = featuresLGconv(cliptypes )
% convert to DATASETS format
DATASETS = [];

featuresdir=[datadir '\features'];
clips_files=dir(featuresdir);
X=[];
for n=3:length(clips_files)
    matcontents = {'clipname','cliptype','desc','subs'};
    params = {[featuresdir '\' clips_files(n).name], cliptypes};
    xn = feval_mats( @featuresLGconv1, matcontents, params, [featuresdir '\' clips_files(n).name], 'features' );
    X=cat(2,X,xn);
end;
nclips = length(X);
DATASETS.IDX=zeros(nclips,1);
DATASETS.cubcount = zeros(nclips,1);
DATASETS.subs = cell(nclips,1);
DATASETS.desc = cell(nclips,1);
for i=1:nclips
    DATASETS.IDX(i,1) = X(i).IDX;
    DATASETS.cubcount(i) = X(i).cubcount;
    DATASETS.subs{i} = X(i).subs;
    DATASETS.desc{i,1} = X(i).desc;
end;
DATASETS.nclips = nclips;

function x = featuresLGconv1( vals, params ) 
    [clipname, cliptype, desc, subs] = deal( vals{:} ); 
    [destdir, cliptypes] = deal( params{:} );
    [disc, IDX] = ismember(cliptype, cliptypes);
    x.IDX = uint8(IDX);
    x.subs = subs;
    x.cubcount = size(subs,1);
    x.desc = desc;
    
    
    
    
    
        
        
    
    
    