% Converts between representations of behavior (mat -> avi).
%
% See RECOGNITION_DEMO for general info.
%   [datadir(set_ind)/namei.avi] --> [datadir(set_ind)/clip_namei.mat]
%
% INPUTS
%   set_ind     - set index, value between 0 and nsets-1
%
% See also RECOGNITION_DEMO, CONV_MOVIES2DIVX, CONV_CLIPS2MOVIES

function conv_movies2clips(clip_length)
srcdir_home = datadir;
oridir=[srcdir_home '\original'];
clipsdir=[srcdir_home '\clips'];
ori_files=dir(oridir);
for n=3:length(ori_files)
    dircontent = dir( [oridir '\' ori_files(n).name '\*.mpg'] );
    dirtext = dir( [oridir '\' ori_files(n).name '\*.txt'] );
    nfiles = length(dircontent);
    if(nfiles==0) warning('No files found.'); return; end;
    ticstatusid = ticstatus('converting movies to clips');
    if ~exist(fullfile(clipsdir,ori_files(n).name), 'dir')
        mkdir(fullfile(clipsdir,ori_files(n).name));
    end
    fname = dircontent.name;
    textname=dirtext.name;
    [labels,range]=conv_text2rang([oridir '\' ori_files(n).name '\' textname]);
    M = VideoReader( [oridir '\' ori_files(n).name '\' fname] );
    i=1;
    index=1;
    clip=zeros(M.Height,M.Width,3,clip_length);
    while hasFrame(M)
        clip(:,:,:,i)=readFrame(M);
        if i>=clip_length
            Mov = makemovie( clip );
            I = movie2images( Mov );
            clipname = [fname(1:end-4) '_' num2str(index-clip_length+1,'%06d') '_' num2str(index,'%06d')];
            cliptype = reco_cliptype(index,clip_length,labels,range);
            save( [clipsdir '\' ori_files(n).name '\clip_' clipname '.mat'], 'I', 'clipname', 'cliptype' );
            if M.CurrentTime/M.Duration>1
                tocstatus( ticstatusid, 1 );                
            else
                tocstatus( ticstatusid, M.CurrentTime/M.Duration );
            end
            i=0;
        end
        i=i+1;
        index=index+1;
    end;
end
end
    
function [labels,range]=conv_text2rang(filename)
    fid=fopen(filename);
range=zeros(1,2000);
labels=cell(1,2000);
n=1;
while ~feof(fid)
    rline =fgetl(fid);
    start=str2double(rline(8:15));
%     stop=str2double(rline(17:24));
    label=rline(26:end);
    if strcmp(label,'micromovement')
        label='head';
    end
    range(n)=start; 
    labels{n}=label;
    n=n+1;
end
range(range==0)=[];
labels(cellfun('isempty',labels))=[];
fclose(fid);
end

function cliptype=reco_cliptype(index,clip_length,labels,range)
clip_labels=cell(1,clip_length);
for i=1:clip_length
    clip_labels{i}=labels{find(index-clip_length+i>= range, 1, 'last')};
end
cliptype=cell2mat(mode(clip_labels));
end