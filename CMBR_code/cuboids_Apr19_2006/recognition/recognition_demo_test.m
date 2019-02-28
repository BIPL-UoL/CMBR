% Describes all steps of behavior recognition; example for facial expressions.
%
% The file describes the following:
%   1) data format [3 choices]
%   2) feature detection & description [2 choices]
%   3) behavior classification 
%
% Data and additional information can be obtained at:
%   http://vision.ucsd.ed u/~pdollar/research/research.html
%
% ----------------------------------------------------------------------------------------
% DATA FORMAT
%
% First the directory of the data must be specified.  
% Alter datadir.m to point to the location of the data. 
%
% Behavior data can be represented in 1 of 3 ways.  In each case data is divided into a
% number of 'sets', each set contains data that should be treated together (for training
% and testing, see generating results for more info).  In each case, a set contains a
% number of behavior clips. The three methods for representing a set are:
%       [set_ind] the 2 digit set index, '00','01',...
%       [cliptype] represents behavior type, such as 'grooming' or 'smiling'  
%       [instance] represents the 3 digit instance number - '000','001',...
%   1) .avi files in a datadir/set[set_ind]/, named '[cliptype][instance].avi'
%   2) .mat files in a datadir/set[set_ind]/, named 'clip_[cliptype][instance].mat'
%      When loaded the file contains two matlab variables: 'I' and 'clipname'
%   3) a single DATASETS struct, kept in memory as DATASETS, described below.  
%
% If all the sets can be stored in memory at once, the third option can be used.  DATASETS
% is an array of nsets elements,  where each element is a struct representing a set of
% data.  Each DATASETS should initally have the following two fields: IS and IDX.  IS is
% either a ...xN 4D array of N clips or an N element cell array of clips (3D arrays).  IDX
% should be a length N uint8 vector of clip types.  Note that as processing proceeds the
% contents of DATASETS will change.
%
% One can convert between the formats using the conv_* functions. To go from DATASETS
% format to .avi format, go through the .mat format.
%
% ----------------------------------------------------------------------------------------
% FEATURE DETECTION & DESCRIPTION
%
% These functions are used to detect cuboids and than apply descriptors to them, creating
% data that can than be used in various training / testing scenarios described next.  The
% two function featuresSM and featuresLG both return the same output.  The difference is
% that featuresSM works with data fully in memory (the DATASETS format), while featuresLG
% writes things back and forth to the hard disk (using the .mat format).  If the files are
% originally in .avi format, they need to be converted to either .mat format or the
% DATASETS format.
%
% ----------------------------------------------------------------------------------------
% BEHAVIOR CLASSIFICATION
%   See recog_test or recog_test_nfold
%
% ----------------------------------------------------------------------------------------
% EXAMPLE below 

% set directory in datadir.m
nsets = 1; 
clip_length=40;
load('teststructure');
test_structure=teststructure;
cliptypes = test_structure.cliptypes;
par_stfeatures=test_structure.par_stfeatures;
cubdesc=test_structure.cubdesc;
kpca=test_structure.kpca;

srcdir = datadir;
dircontent = dir( [srcdir '\test\database.avi'] );
nfiles = length(dircontent);
if(nfiles==0) warning('No files found.'); return; end;

if ~exist(fullfile(srcdir,'\result'), 'dir')
    mkdir(fullfile(srcdir,'\result'));
end

ticstatusid = ticstatus('recog_test;',[],10 ); cnt=1;
% for i=1:nfiles
%     fname = dircontent(i).name;
%     V = VideoReader( [srcdir '\original\' fname] );
%     output=zeros(V.Height,V.Width,3,V.NumberOfFrames.-clip_length,'uint8');
%     if V.NumberOfFrames>clip_length
%         for ii= fix(clip_length/2):V.NumberOfFrames-fix(clip_length/2)
% %        for i= 1:8900
%             clip=read(V,[ii-fix(clip_length/2)+1 ii+fix(clip_length/2)]);
% %             clip=read(V,[4416 4446]);
%             M=makemovie(clip);
%             I = movie2images( M );
% %             I=padarray(I,[5 5 15],'both','replicate'); %small/short clips, pad!
% %             %%%detect cuboids
% %             [d,subs,d,cuboids,h_w] = stfeatures(I,par_stfeatures{:} ); 
% %             cubcount= size(cuboids,4); 
% %             %%%describe cuboids
% %             desc=imagedesc( cuboids, cubdesc ); 
% %             %%%predict
% %             label=clip_recog(subs,desc,test_structure);
% %             p=clip(:,:,:,round(clip_length/2));
% %             rgb=insertText(p,[size(p,2)/2 size(p,1)-20],cliptypes{label},'FontSize',20,'AnchorPoint','Center','BoxOpacity',0);
% %             output(:,:,:,ii)=uint8(rgb);
%             tocstatus( ticstatusid, cnt/(V.NumberOfFrames- clip_length+1)); cnt=cnt+1;
%         end
%     end
%     save('output.mat','output');
% end;
for i=1:nfiles
    fname = dircontent(i).name;
    V = VideoReader( [srcdir '\test\' fname] );
    %%%initialize a slide window
    n=1;
    window=uint8(zeros(480,640,3,clip_length));
    %%% prepare a slide window which leave the first image empty
    while hasFrame(V)&& n<clip_length
        f=readFrame(V);
%         f=f(40:370,80:550,:);
%         f=imresize(f,[240 360]);
        window(:,:,:,n+1)=f;
        n=n+1;
    end
    scores=zeros(length(test_structure.cliptypes),fix(V.Duration*V.FrameRate)-clip_length+1);
    ii=1;
    while hasFrame(V)
        f=readFrame(V);
%         f=f(40:370,80:550,:);
%         f=imresize(f,[240 360]);
        for t=1:clip_length-1
            window(:,:,:,t)=window(:,:,:,t+1);
        end
        window(:,:,:,clip_length)=f;
        M=makemovie(window);
        I = movie2images( M );
        I=padarray(I,[5 5 15],'both','replicate'); %small/short clips, pad!
        %%%detect cuboids
        [d,subs,d,cuboids] = stfeatures(I,par_stfeatures{:} );
        cubcount= size(cuboids,4);
        %%%describe cuboids
        desc=imagedesc( cuboids, cubdesc, 0 );
        %%%predict
        DATASETS_test.nclips = 1;
        DATASETS_test.IDX = [];
        DATASETS_test.cubcount = cubcount;
        DATASETS_test.subs{1} = subs;
        DATASETS_test.desc{1,1} = desc;
        [predict,score]=recog_test_teststructure(DATASETS_test,'gmm',test_structure);
        scores(:,ii)=score;
%         p=window(:,:,:,fix(clip_length/2)+1);
%         rgb=insertText(p,[size(p,2)/2 size(p,1)-20],cliptypes{label},'FontSize',20,'AnchorPoint','Center','BoxOpacity',0);
        ii=ii+1;
        if V.CurrentTime/V.Duration<1
            tocstatus( ticstatusid, V.CurrentTime/V.Duration);
        else
            tocstatus( ticstatusid, 1);
            break;
        end
    end
    save('scores.mat','scores')
end;






