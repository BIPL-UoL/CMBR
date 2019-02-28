function DATASETS = create_datasets (matcontents, params,srcdir, filenames)

    %%% load each mat file and apply fhandle
    ticstatusid = ticstatus('feval_mats',[],40);
    ncontents = length( matcontents );
    n=length(filenames);
    for i=1:n
        % load mat file and get contents
        S = load( [srcdir '\' filenames{i}] ); 
        errmsg = ['Unexpected contents for mat file: ' filenames{i}];
        if( length(fieldnames(S))<ncontents) error( errmsg ); end;
        inputs = cell(1,ncontents);
        for j=1:ncontents
            if( ~isfield(S,matcontents{j}) ) error( errmsg ); end;
            inputs{j} = getfield(S,matcontents{j});
        end; clear S;
        
        [~,IDX] = ismember(inputs{2}, params{2});
        DATASETS.IDX(i,1)=uint8(IDX);
        DATASETS.subs{i} =inputs{4};
        DATASETS.desc{i,1} = inputs{3};
        DATASETS.cubcount(i) = size(inputs{4},1);
        tocstatus( ticstatusid, i/n );
    end;
    DATASETS.nclips = n;

