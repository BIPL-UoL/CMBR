function [feat_all,IDX] = encodeClips1( featurs_path,gmm,cliptypes,normalize_method,used_file )
stackGrid=[2 2 1];
if  exist(featurs_path,'file')
    n=1;
    clips_files=dir(featurs_path);
    clips_files=clips_files(3:end);
    if ~exist('used_file')
        used_file=true(1,length(clips_files));
    end
    for i=1:length(clips_files)
        if used_file(i)
            clips=dir([featurs_path '/' clips_files(i).name]);
            clips=clips(3:end);
            for ii=1:length(clips)
                clipname{n}=[clips_files(i).name '/' clips(ii).name];
                n=n+1;
            end
        end
    end
    IDX=zeros(numel(clipname),1,'int8');
    stackSize=stackGrid(1)*stackGrid(2)*stackGrid(3)+1;
    feat_rel_subs = zeros( numel(clipname),stackSize*size(gmm.means.rel_subs,1)*2*size(gmm.means.rel_subs,2));
    feat_desc = zeros( numel(clipname),stackSize*size(gmm.means.desc,1)*2*size(gmm.means.desc,2));
    for i = 1 : numel(clipname)
        %%% load features file
        timest = tic();
        matcontents = {'clipname','clipsize','cliptype','desc','subs'};
        S = load( [featurs_path '/' clipname{i}] );
        errmsg = ['Unexpected contents for mat file: ' [featurs_path '/' clipname]];
        if( length(fieldnames(S))<length( matcontents )) error( errmsg ); end;
        inputs = cell(1,length( matcontents ));
        for j=1:length( matcontents )
            if( ~isfield(S,matcontents{j}) ) error( errmsg ); end;
            inputs{j} = S.(matcontents{j});
        end; clear S;
        xn = feval( @featuresConv, inputs,cliptypes);
        xn=compute_relative_loc(xn);
        if ~isempty(xn)&&~isempty(xn.rel_subs)
            subVolumeSize = [xn.clipsize(3), xn.clipsize(2), xn.clipsize(1)];
            %%%subs(sizeVid.Height-height,width,time),the input of sfv_video are,
            %%%time,width,height
            a=xn.subs(:,1);
            xn.subs(:,1)=xn.subs(:,3);
            xn.subs(:,3)=xn.clipsize(1)-a;
            descrsInfo=xn.subs';
            smin=min(xn.subs,[],1);
            smax=max(xn.subs,[],1);
            if ~isfield(gmm,'pcamap')
                psi1 = encode_grid(1, 1, 1, subVolumeSize, xn.desc',xn.rel_subs',[1,1,1], descrsInfo, gmm,normalize_method);
                subVolumeSize=smax-smin;
                psi2 = encode_grid(smin(1), smin(2), smin(3), subVolumeSize, xn.desc',xn.rel_subs',stackGrid, descrsInfo, gmm,normalize_method);
                feat_desc(i,:)=[psi1{1};psi2{1}];
                feat_rel_subs(i,:)=[psi1{2};psi2{2}];
            else
                %%%bsxfun(@minus,dt.hog,gmm.centre.hog)*gmm.pcamap mean that use pca map to reduce the dimension
                psi = encode_grid(1, 1, 1, subVolumeSize, (bsxfun(@minus,xn.desc,gmm.centre)*gmm.pcamap)',xn.rel_subs',stackGrid, descrsInfo, gmm,normalize_method);
                feat_rel_subs(i,:)=psi{2};
                feat_desc(i,:)=psi{1};
            end
        else
            feat_rel_subs(i,:) = 1/size(feat_rel_subs,2);
            feat_desc(i,:)=1/size(feat_desc,2);
            %             fv_desc(i,:) = 0;
        end
        IDX(i)=xn.IDX;
        timest = toc(timest);
        fprintf('%d -> %s -->  %1.1f sec.\n',i,clipname{i},timest);
    end
    feat_rel_subs=normalize(feat_rel_subs',normalize_method)';
    feat_desc=normalize(feat_desc',normalize_method)';
    feat_all={feat_desc,feat_rel_subs};
%     feat_all=[feat_desc,feat_rel_subs];
%     feat_all=normalize(feat_all',normalize_method)';
end
end
function x = featuresConv( vals,cliptypes)
[clipname,clipsize,cliptype, desc, subs] = deal( vals{:} );
[disc, IDX] = ismember(cliptype, cliptypes);
x.IDX=uint8(IDX);
x.subs = subs;
x.cubcount = size(subs,1);
x.desc = desc;
x.clipsize=clipsize;
end
% function for encoding features in grids
function psi = encode_grid(start_t, start_c, start_r, subVolumeSize, descrs_active,rel_subs_active, stackGrid, descrsInfo, encoder,normalize_method)
k = 0; psi = {};
tsize = subVolumeSize(1);
csize = subVolumeSize(2);
rsize = subVolumeSize(3);
for i_stack_t = 1:stackGrid(3)
    range_t2 = [start_t+(i_stack_t-1)*tsize/stackGrid(3),...
        start_t+i_stack_t*tsize/stackGrid(3)-1];
    ind_t2 = (descrsInfo(1,:)>=range_t2(1)) & (descrsInfo(1,:)<=range_t2(2));
    for i_stack_col = 1:stackGrid(2)
        range_c2 = [start_c+(i_stack_col-1)*csize/stackGrid(2),...
            start_c+i_stack_col*csize/stackGrid(2)-1];
        ind_c2 = (descrsInfo(2,:)>=range_c2(1)) & (descrsInfo(2,:)<=range_c2(2));
        for i_stack_row = 1:stackGrid(1)
            range_r2 = [start_r+(i_stack_row-1)*rsize/stackGrid(1),...
                start_r + i_stack_row*rsize/stackGrid(1)-1];
            ind_r2 = (descrsInfo(3,:)>=range_r2(1)) & (descrsInfo(3,:)<=range_r2(2));
            descrs_active2 = descrs_active(:,ind_t2&ind_c2&ind_r2);
            rel_subs_active2=rel_subs_active(:,ind_t2&ind_c2&ind_r2);
            if size(descrs_active2,2)>5 % threshold of number in one cell
                fv_desc=vl_fisher(descrs_active2, encoder.means.desc, encoder.covariances.desc, encoder.priors.desc);
                fv_rel=vl_fisher(rel_subs_active2, encoder.means.rel_subs, encoder.covariances.rel_subs, encoder.priors.rel_subs);
            else
                fv_desc= zeros(2*size(encoder.means.desc,1)*size(encoder.means.desc,2),1);
                fv_rel= zeros(2*size(encoder.means.rel_subs,1)*size(encoder.means.rel_subs,2),1);
            end
            k = k+1;
            desc{k} = fv_desc(:);
            rel{k} = fv_rel(:);
        end
    end
end
% psi2 = {};
% for i=1:length(psi)
%     psi2{i}=psi{i};
%     for j=1:length(psi)
%         if i~=j
%             dif=psi{i}-psi{j};
%             psi2{i}=[psi2{i}; dif];
%         end
%     end
% end
desc = cat(1, desc{:});
rel = cat(1, rel{:});
psi={desc,rel};
end
