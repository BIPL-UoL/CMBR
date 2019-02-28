function  DATASETS  = compute_relative_loc( DATASETS )
nsets = length( DATASETS );
isSubs = isfield( DATASETS, 'subs' );
rel_subs=[];
width_height=[];
ll=false;
for s=1:nsets
    if(isSubs)
        for i=1:length(DATASETS.subs)
            rel_s={[]};
            mean_sub=round(mean(DATASETS.subs{i},1));           
            mean_subs=repmat(mean_sub,size(DATASETS(s).subs{i},1),1);
            max_distance=max(DATASETS.subs{i},[],1)-min(DATASETS.subs{i},[],1);
            if ~isempty(DATASETS(s).subs{i})
                if(i==1||~ll)
                    v=[0,0];
                else
                    v=mean_sub(:,1:2)-last_location;
                end
                last_location=mean_sub(:,1:2);
                if size(DATASETS(s).subs{i},1)>1
                    rel_s={[DATASETS(s).subs{i}(:,1:2),(DATASETS(s).subs{i} -mean_subs)]};
%                       rel_s={[(DATASETS(s).subs{i} -mean_subs)]}
                end
%                 w_h=[max_distance(:,1:2) mean_sub(:,1:2) v];
                w_h=[max_distance(:,1:2) mean_sub(:,1:2)];
            else
                w_h=[0,0,0,0];
                ll=false;
            end;
            rel_subs=cat(1,rel_subs,rel_s);
            width_height=cat(1,width_height,w_h);
        end;
        DATASETS.rel_subs=rel_subs;
        DATASETS.width_height=width_height;
    end;
end

