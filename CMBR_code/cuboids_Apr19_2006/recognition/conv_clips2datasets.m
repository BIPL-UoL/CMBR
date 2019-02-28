% Converts between representations of behavior (mat -> DATASETS).
%
% See RECOGNITION_DEMO for general info.
%   [datadir(set_ind)/namei.mat] --> DATASETS
%
% INPUTS
%   nsets       - number of sets
%   cliptypes       - types of clips (cell of strings)
%
% OUTPUTS
%   DATASETS    - array of structs, will have fields:
%           .IS         - the N behavior clips 
%           .IDX        - length N vector of clip types
%
% See also RECOGNITION_DEMO, CONV_DATASETS2CLIPS

function DATASETS = conv_clips2datasets( nsets, cliptypes )
matcontents = {'I','cliptype'};
for s=0:(nsets-1)
    clipsdir = [datadir(s) '\clips'];
    clips_files=dir(clipsdir);
    X=[];
    for n=3:length(clips_files)
        xn = feval_mats( @clips2datasets1, matcontents, {}, [clipsdir '\' clips_files(n).name], 'clip' );
        X=cat(2,X,xn);
    end
    cliptype = {X.cliptype};
    IS=cell2array({X.I});
    [disc, IDXn] = ismember(cliptype, cliptypes);
    IDX =uint8(IDXn)';
    DATASETS(s+1).IS = IS;
    DATASETS(s+1).IDX = IDX;
end;

function x = clips2datasets1( vals, params ) 
    %%%find name
    [I,cliptype] = deal( vals{:} );
    x.cliptype = cliptype;
    x.I = I;

    

    
    
