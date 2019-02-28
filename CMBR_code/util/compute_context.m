function  context  = compute_context( subs,videoSize )
rel_subs=[];
width_height=[];
ll=false;
for i=1:size(subs,1)
    rel_s={[]};
    mean_sub=round(mean(subs{i},1));
    mean_subs=repmat(mean_sub,size(subs{i},1),1);
    range_subs=repmat(videoSize,size(subs{i},1),1);
    max_distance=max(subs{i},[],1)-min(subs{i},[],1);
    if ~isempty(subs{i})
        if(i==1||~ll)
            v=[0,0];
        else
            v=mean_sub(:,1:2)-last_location;
        end
        last_location=mean_sub(:,1:2);
        if size(subs{i},1)>1
            rel_s={[subs{i}(:,1:2)./range_subs(:,1:2),(subs{i} -mean_subs)./range_subs]};
            %                       rel_s={[(subs{i} -mean_subs)./range_subs]}
        else
            rel_s={[subs{i}(:,1:2)./range_subs(:,1:2),[0,0,0]]};
            %                       rel_s={[subs{i}-subs{i}]};
        end
        w_h=[max_distance(:,1:2)./videoSize(:,1:2), max_distance(:,1)./max_distance(:,2), mean_sub(:,1:2)./videoSize(:,1:2),v./videoSize(:,1:2)];
    else
        w_h=[0,0,0,0,0,0,0];
        ll=false;
    end;
    rel_subs=cat(1,rel_subs,rel_s);
    width_height=cat(1,width_height,w_h);
end;

