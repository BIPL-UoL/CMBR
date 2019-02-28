function cnnConfig = config1(input,output,pcamap)
cnnConfig.layer{1}.type = 'input';
cnnConfig.layer{1}.dimension = double(input);

cnnConfig.layer{2}.type = 'pca';
cnnConfig.layer{2}.dimension = size(pcamap{1},2);

cnnConfig.layer{3}.type = 'relu';
cnnConfig.layer{3}.dimension = 100;

% cnnConfig.layer{3}.type = 'sigmoid';
% cnnConfig.layer{3}.dimension = double(input)/8;
% 
% cnnConfig.layer{4}.type = 'sigmoid';
% cnnConfig.layer{4}.dimension = double(input)/8;

cnnConfig.layer{4}.type = 'softmax';
cnnConfig.layer{4}.dimension = double(output);

cnnConfig.costFun = 'crossEntropy';
end