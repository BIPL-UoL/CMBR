function  DATASETS  = compute_relative_loc2( DATASETS,videoSize )
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
            mean_subs=repmat(mean_sub,size(DATASETS.subs{i},1),1);
            range_subs=repmat(videoSize,size(DATASETS.subs{i},1),1);
            max_distance=max(DATASETS.subs{i},[],1)-min(DATASETS.subs{i},[],1);
            if ~isempty(DATASETS.subs{i})
                if(i==1||~ll)
                    v=[0,0];
                else
                    v=mean_sub(:,1:2)-last_location;
                end
                last_location=mean_sub(:,1:2);
                if size(DATASETS.subs{i},1)>1
                    rel_s={[DATASETS.subs{i}(:,1:2)./range_subs(:,1:2),(DATASETS.subs{i} -mean_subs)./range_subs]};
                    %                       rel_s={[(DATASETS.subs{i} -mean_subs)./range_subs]}
                else
                    rel_s={[DATASETS.subs{i}(:,1:2)./range_subs(:,1:2),[0,0,0]]};
                    %                       rel_s={[DATASETS.subs{i}-DATASETS.subs{i}]};
                end
                ratio=0;
                if(max_distance(:,2)~=0)
                    ratio=max_distance(:,1)./max_distance(:,2);
                end
                w_h=[max_distance(:,1:2)./videoSize(:,1:2), ratio, mean_sub(:,1:2)./videoSize(:,1:2)];
%%%             w_h=[max_distance(:,1:2)./videoSize(:,1:2), ratio, mean_sub(:,1:2)./videoSize(:,1:2),v/videoSize(:,1:2)];  
            else
                w_h=[0,0,0,0,0];
                ll=false;
            end;
            rel_subs=cat(1,rel_subs,rel_s);
            width_height=cat(1,width_height,w_h);
        end;
        DATASETS.rel_subs=rel_subs;
        DATASETS.width_height=width_height;
    end;
end

