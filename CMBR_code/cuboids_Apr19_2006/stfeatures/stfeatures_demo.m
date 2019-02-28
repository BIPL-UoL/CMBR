% Demo of stfeatures on the "oscillating example".
%
% From Laptev & Lindeberg papers.
%
% INPUTS
%   periodic    - if 1 uses periodic detector else uses harris detector

function stfeatures_demo(  )

    %%% SETTABLE PARAMETERS
    sigma = 2; % a good range appears to be [.2,1.5]?
    tau = 3; 
    thresh = 2e-4; maxn = []; 
    show = 1;
    par_stfeatures = {sigma, tau, 1, thresh, maxn, 1.85, 1, 1, show};

    %%% get parameters for mesh (width must be ints!)
    xstart = .5; xend = 2.2; xstep = .02;
    xwidth = round( (xend-xstart) / xstep )+1;
    tstart = .8; tend = 1.9; tstep = .02;
    twidth = round( (tend-tstart) / tstep )+1;
    ystart = -3; yend = 3; ystep = 1/30; 
    ywidth = round( (yend-ystart) / ystep )+1;
    
    %%% create images
    [X,Y] = meshgrid( xstart:xstep:xend, ystart:ystep:yend );
    sinX4 = sin(X.^4);   tvec = tstart:tstep:tend;
    
    load('clip_video4_groom_013.mat');
%%%add noise
%      for i=1: size(I,3);
%          I(:,:,i)=I(:,:,i)+round(rand(1)*10-10);
%      end
%%%test
%     M=[];
%     for i=1: size(I,4);
%         t=rgb2gray(I(:,:,:,i));
%         M=cat(3,M,t);
%     end
%     clear I;
%     I=M;    
    
%     I=I(:,:,4:24);
    
%     load('DATASETS.mat');
%     I=DATASETS.IS(:,:,:,120);

%     I = zeros( ywidth, xwidth, twidth );
%     for i=1:length(tvec);
%         t = tvec(i);
%         Z = -sign( Y - sinX4 * sin(t^4) );
%         I(:,:,i) = Z;
%     end
    
    I=padarray(I,[5 5 15],'both','replicate');
    
    %%% run harris corner detector
    [R,subs,vals] = stfeatures( I, par_stfeatures{:} );

%     [R,subs,vals] = stfeatures_allscales( I, sigma, tau, {periodic, thresh, maxn, [],[],[], show});
%     subs=cell2array(subs);
    
    nfeatures = size(subs,1)

%     %%% create and dipslay surface mesh with detected interest points
% 
%     % create surface mesh
%     [X,T] = meshgrid( xstart:xstep:xend, tstart:tstep:tend );
%     Y = sin( X.^4 ) .* sin( T.^4 );
%         
%     % transform X,Y,T to have correct coordinates
%     Y = (Y - ystart) ./ ystep +1;  %rows
%     X = (X - xstart) ./ xstep +1;  %cols
%     T = (T - tstart) ./ tstep +1;  %time
%         
%     % display surface mesh
%     figure(show+4); clf;
%     surf(X,T,Y,'FaceColor','red','EdgeColor','none');
%     set(gca,'YDir','reverse'); set(gca,'ZDir','reverse'); 
%     camlight left; lighting phong; %lighting Gouraud;
%     xlabel('col'); ylabel('time'); zlabel('row');
%     view(-15,55);
        
    % plot detected interest points on top of mesh
    hold('on');
    for i=1:nfeatures
        ellipsoid( subs(i,2), subs(i,3), subs(i,1), 2.5*sigma, 2.5*tau, 2.5*sigma, 8 );
    end
    hold('off');      
