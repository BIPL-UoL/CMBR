function [feat] = sfv_encoding( desc,subs, means, covariances, priors,stackGrid)

stackSize=stackGrid(1)*stackGrid(2)*stackGrid(3)+1;
feat = zeros( 1,stackSize*size(means,1)*2*size(means,2));
gmm.means=means;
gmm.covariances=covariances;
gmm.priors=priors;
if ~isempty(subs)
    smin=min(subs,[],1)-1;
    smax=max(subs,[],1)+1;
    subVolumeSize = smax-smin;
    %%%subs(height,width,time),the input of sfv_video are,
    %%%time,width,height
    descrsInfo=zeros(size(subs));
    descrsInfo(:,2)=subs(:,2);
    descrsInfo(:,3)=subs(:,1);
    descrsInfo(:,1)=subs(:,3);
    descrsInfo=descrsInfo';
    psi = encode_grid(smin(3),smin(2),smin(1), subVolumeSize, desc',[1,1,1], descrsInfo, gmm);
    psi_grid = encode_grid(smin(3),smin(2),smin(1), subVolumeSize, desc',stackGrid, descrsInfo, gmm);
    feat=[psi,psi_grid];
else
    feat = 1/size(feat,2);
end

end

% function for encoding features in grids
function psi = encode_grid(start_t, start_c, start_r, subVolumeSize, descrs_active, stackGrid, descrsInfo, encoder)
k = 0; 
tsize = subVolumeSize(3);
csize = subVolumeSize(2);
rsize = subVolumeSize(1);
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
            if size(descrs_active2,2)>5 % threshold of number in one cell
                fv_desc=vl_fisher(descrs_active2, encoder.means, encoder.covariances, encoder.priors);
            else
                fv_desc= zeros(2*size(encoder.means,1)*size(encoder.means,2),1);
            end
            k = k+1;
            desc{k} = fv_desc(:);
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
psi = cat(1, desc{:});
psi=psi';
end
