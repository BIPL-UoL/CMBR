
% Feature detection and description applied to .mat behavior data. 
%
% See RECOGNITION_DEMO / FEATURESSM for general steps of detection / description and
% differences between this function and FEATURESSM.
% 
% INPUTS
%   nsets           - number of sets
%   cliptypes       - types of clips (cell of strings)
%   par_stfeatures  - parameters for feature detection [see featuresLGdetect]
%   cubdesc         - cuboid descriptor [see featuresLGdesc]
%   ncuboids        - number of cuboids to grab per .mat file [see featuresLGpca]
%   kpca            - number of dimensions to reduce data to [see featuresLGpca]
%
% OUTUPTS
%   DATASETS    - array of structs, will have fields:
%           .IDX        - length N vector of clip types
%           .ncilps     - N: number of clips
%           .cubcount   - length N vector of cuboids counts for each clip clip
%           .subs       - length N cell vector of sets of locations of cuboids
%           .desc       - length N cell vector of cuboid descriptors
%   cubdesc         - output of featuresLGpca
%   cuboids         - output of featuresLGpca
%   
% See also FEATURESLGDETECT, FEATURESLGPCA, FEATURESLGDESC, FEATURESLGCONV

function [DATASETS,cubdesc,cuboids] = featuresLG( cliptypes, ... 
                                par_stfeatures, ncuboids, cubdesc, kpca,clip_length )
    featuresLGdetect2( cliptypes, par_stfeatures,clip_length  );
    [cubdesc,cuboids]  = featuresLGpca( ncuboids, cubdesc, kpca );
    featuresLGdesc(cubdesc );
    DATASETS = featuresLGconv( cliptypes );
    