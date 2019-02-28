% Fancy cuboid visualization.
%
% Extracts cuboids of given size from the array I at specified locations, using
% cuboid_extract.  It then displays a fancy visualiztion of the cuboids.  Only works if I
% is MxN or MxNxK (2 or 3 dimensional data).  Tends to work well only if not too much
% overlap between cuboids (otherwise V is very dark).
%
% INPUTS
%   I               - d dimension array
%   cuboids_rs      - the dimensions of the cuboids to find (d x 1)
%   subs            - subscricts of max locations (n x d)
%   show            - [optional] figure to use for display (no display if == 0)
%
% OUTPUTS
%   V           - color version of I with each cuboid being a different color
%   Imasked     - I with everything blocked out except regions belonging to cuboids
%
% See also CUBOID_EXTRACT, CUBOID_DISPLAY_STV

function [ V, Imasked,example ] = cuboid_display( I, cuboids_rs, subs, show )
    n = size( subs, 1 );  nd = ndims(I);  siz=size(I);  
    if( n==0 ) warning('no cuboid specified'); V=[]; Imasked=[]; return; end;
    if( ~(nd==2 || nd==3)) error('no visualization avialable for dims>3'); end             
    if( nargin<4 ) show=0; end;
    make_Imasked = (nargout>1);
    
    
    %%% extract cuboids [to get cuboid locations]
    [ cuboids, cuboid_starts, cuboid_ends, subs] = cuboid_extract( I, cuboids_rs, subs, 0 );
    n = size( subs, 1 );  
    
    %%% create color version of V
    I = double(I); I = I - min(I(:)); I = I / max(I(:));
    if (nd==2)  
        V = repmat( I, [1,1,3] ); 
    else 
        V = permute(I, [1,2,4,3] );
        V = repmat( V, [1,1,3,1] );
    end; 
    
%     %%% overlay maxes (colored cuboids) on V
%     cols = .4 * [ 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; .5 0 0; ...
%                   1 0.620 .40; 0.49 1 0.83 ];
%     for i=1:n
%         c = mod(i-1,length(cols))+1;
% 
%         for d=1:nd extract{d} = cuboid_starts(i,d):cuboid_ends(i,d); end;
%         if (nd==2) extract{3} = 1; end;
%         
%         for j=1:3 if(cols(c,j)>0) 
%             locs={ extract{1:2}, j, extract{3} };
%             V(locs{:}) =  V(locs{:}) + cols(c,j); 
%         end; end;
%     end;
%     V = V / max(V(:));
            
    %%% add white dot at location of response
    r = 1; 
    example=V(5:end-5,5:end-5,:,1);
    for i=1:n
        str = max(1, subs(i,1)-r ); endr = min( subs(i,1)+r, siz(1) );
        stc = max(1, subs(i,2)-r ); endc = min( subs(i,2)+r, siz(2) );
        if (nd==2) zloc = 1; else zloc = subs(i,3); end;
        if (nd==3 && ~(zloc>0 && zloc<siz(3)) ) continue; end;
        
        %red dot
        color(:,:,1)=[1 1 1;1 1 1;1 1 1];
        color(:,:,2:3)=0;
        V( str:endr, stc:endc, :, zloc ) = color; 
        example( str:endr, stc:endc, :) = color; 
        %white dot
%         V( str:endr, stc:endc, :, zloc ) = 0.5; 
    end;    
    V = uint8( V * 255 );
    %%%show image with intrest points
%     figure(10);
%     for i=15:size(V,4)
%         imshow(V(5:end-5,5:end-5,:,i));
%     end
    
    
    %%% [optional] create Imasked
    if( make_Imasked )
        Imasked = I-I;
        for i=1:n
            for d=1:nd extract{d} = cuboid_starts(i,d):cuboid_ends(i,d); end;
            Imasked( extract{:} ) = 1;
        end
        Imasked = I .* Imasked;
        Imasked = uint8(Imasked * 255);
    end;        
    
    % [optional] display
    if (show) 
        if (nd==2)                 
            figure(show);    clf;  im( I );
            figure(show+1);  clf;  im( V );
            figure(show+2);  clf;  montage2( cell2array( cuboids ) );
            if (make_Imasked) figure(show+3);  clf; im( make_Imasked ); end;
        else
            figure(show);    clf;  montage2( I,1 );            
            figure(show+1);  clf;  montage2( V,1 );
            figure(show+2);  clf;  montages2( cuboids ); %, {0,0,[0,1]} );    
            if (make_Imasked) figure(show+3);  clf;  montage2( Imasked ); end;
        end
    end;