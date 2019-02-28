% Applies descriptor to every cuboid of every clip of every set.
%
% Loads each cuboids_[activity].mat, describues cuboids, then saves result to
% features_[activity].mat.  Each original mat file should contain the fields: 'clipname',
% 'cliptype', 'cuboids', 'subs', resulting mat file will contain the fields:
% 'clipname', 'cliptype', 'subs', 'desc'.
%
% INPUTS
%   nsets       - number of sets
%   cubdesc     - cuboid descriptor
%
% See also FEATURESLG, IMAGEDESC, IMAGEDESC_GENERATE

function featuresLGdesc( cubdesc )
cuboidsdir = [datadir '\cuboids'];
featuresdir=[datadir '\features'];
clips_files=dir(cuboidsdir);
for n=3:length(clips_files)
    if ~exist(fullfile(featuresdir,clips_files(n).name), 'dir')
        mkdir(fullfile(featuresdir,clips_files(n).name));
    end
    matcontents = {'clipname','cliptype','cuboids','subs'};
    params = {cubdesc, [featuresdir '\' clips_files(n).name]};
    feval_mats( @featuresLGdesc1, matcontents, params, [cuboidsdir '\' clips_files(n).name], 'cuboids' );
end
    
function x = featuresLGdesc1( vals, params )
    [clipname, cliptype, cuboids, subs] = deal( vals{:} );
    [cubdesc, destdir] = deal( params{:} );
    desc = imagedesc( cuboids, cubdesc );
    destname = [destdir '/features_' clipname];
    save( destname, 'clipname', 'cliptype', 'subs', 'desc' );
    x=[];

