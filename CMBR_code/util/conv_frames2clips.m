function conv_frames2clips(clip_length)
srcdir_home = datadir;
oridir=[srcdir_home '\original'];
clipsdir=[srcdir_home '\clips'];
ori_files=dir(oridir);
for n=3:length(ori_files)
    dircontent = dir( [oridir '\' ori_files(n).name '\*.avi'] );
    dirtext = dir( [oridir '\' ori_files(n).name '\*.txt'] );
    nfiles = length(dircontent);
    if(nfiles==0) warning('No files found.'); return; end;
    ticstatusid = ticstatus('converting movies to clips');
    if ~exist(fullfile(clipsdir,ori_files(n).name), 'dir')
        mkdir(fullfile(clipsdir,ori_files(n).name));
    else
        continue
    end
    fname = dircontent.name;
    textname=dirtext.name;
    [labels,range]=conv_text2rang([oridir '\' ori_files(n).name '\' textname]);
    M = VideoReader( [oridir '\' ori_files(n).name '\' fname] );
    clip=uint8(zeros(M.Height,M.Width,3,clip_length));
    ii=0;
    %%% prepare a window which leave the first image empty
    i=1;
    while hasFrame(M)&& i<=clip_length
        f=readFrame(M);
        clip(:,:,:,i)=f;
        i=i+1;
        ii=ii+1;
    end
    
    Mov=makemovie(clip);
    I = movie2images( Mov );
    clipname = [fname(1:end-4) '_' num2str(ii-clip_length+1,'%06d') '_' num2str(ii,'%06d')];
    cliptype = reco_cliptype(ii-fix(clip_length/2),1,labels,range);
    save( [clipsdir '\' ori_files(n).name '\clip_' clipname '.mat'], 'I', 'clipname', 'cliptype' );
    
    stride=20;
    skip=1;
    while hasFrame(M)
        f=readFrame(M);
        for t=1:clip_length-1
            clip(:,:,:,t)=clip(:,:,:,t+1);
        end
        clip(:,:,:,clip_length)=f;
        if skip>stride
            Mov=makemovie(clip);
            I = movie2images( Mov );
            clipname = [fname(1:end-4) '_' num2str(ii-clip_length+1,'%06d') '_' num2str(ii,'%06d')];
            cliptype = reco_cliptype(ii-fix(clip_length/2),1,labels,range);
            save( [clipsdir '\' ori_files(n).name '\clip_' clipname '.mat'], 'I', 'clipname', 'cliptype' );
            if M.CurrentTime/M.Duration>1
                tocstatus( ticstatusid, 1 );
            else
                tocstatus( ticstatusid, M.CurrentTime/M.Duration );
            end
            skip=1;
        end
        ii=ii+1;
        skip=skip+1;
    end
end
end
    
function [labels,range]=conv_text2rang(filename)
fid=fopen(filename);
range=zeros(1,2000)-1;
labels=cell(1,2000);
n=1;
while ~feof(fid)
    rline =fgetl(fid);
    loc_space=strfind(rline,';');
    start=str2double(rline(1:loc_space(1)-1));
    %     stop=str2double(rline(17:24));
    label=rline(loc_space(end-1)+1:loc_space(end)-1);
    if n==1 || ~strcmp(label,labels{n-1})
        range(n)=start;
        labels{n}=label;
        n=n+1;
        
    end
end
range(range==-1)=[];
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


