function x = features_conv( vals, params )
    [clipname, cliptype, desc, subs] = deal( vals{:} ); 
    [destdir, cliptypes] = deal( params{:} );
    [disc, IDX] = ismember(cliptype, cliptypes);
    x.IDX = uint8(IDX);
    x.subs = subs;
    x.cubcount = size(subs,1);
    x.desc = desc;
end

