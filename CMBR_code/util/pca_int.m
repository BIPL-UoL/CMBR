function[data_train,data_test,pcamap]=pca_int(data_train,data_test,stackGrid)
whiten=0;
stackSize=stackGrid(1)*stackGrid(2)*stackGrid(3)+1;
dim_le=size(data_train,2)/stackSize;
for i=1:stackSize
    [pcamap{i}, centre] = xpca(data_train(:,(i-1)*dim_le+1:i*dim_le)', whiten, 100);
    data_train(:,(i-1)*dim_le+1:i*dim_le) = bsxfun(@minus,data_train(:,(i-1)*dim_le+1:i*dim_le),centre);
    %data_train(:,(i-1)*dim_le+1:i*dim_le)=normalize(data_train(:,(i-1)*dim_le+1:i*dim_le),'Power-L2');
    data_test(:,(i-1)*dim_le+1:i*dim_le)=bsxfun(@minus,data_test(:,(i-1)*dim_le+1:i*dim_le),centre);
    %data_test(:,(i-1)*dim_le+1:i*dim_le)=normalize(data_test(:,(i-1)*dim_le+1:i*dim_le),'Power-L2');
end