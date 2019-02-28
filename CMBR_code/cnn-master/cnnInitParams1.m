function [theta, meta] = cnnInitParams1(cnnConfig,pcamap)
% Initialize parameters
%                            
% Parameters:
%  cnnConfig    - cnn configuration variable
%
% Returns:
%  theta      -  parameter vector
%  meta       -  meta param 
%       numTotalParams : total number of the parameters
%       numParams      : the number of the parameters each layer

numLayers = size(cnnConfig.layer,2);
theta = cell(numLayers,1);
numParams = zeros(numLayers,2);
meta.layersize = cell(numLayers,1);
meta.paramsize = cell(numLayers,1);
for i = 1 : numLayers
    tempLayer = cnnConfig.layer{i};
    
    switch tempLayer.type
        case 'input'
            theta{i}.W = [];
            theta{i}.b = [];
            dimension=tempLayer.dimension;
            meta.layersize{i} = dimension;
        case 'conv'        
            row = row + 1 - tempLayer.filterDim(1);
            col = col + 1 - tempLayer.filterDim(2);          
            meta.paramsize{i} = [tempLayer.filterDim channel tempLayer.numFilters];
            theta{i}.W = 1e-1*randn(meta.paramsize{i});
            numParams(i,:) = [tempLayer.filterDim(1)*tempLayer.filterDim(2)*channel*tempLayer.numFilters tempLayer.numFilters];
            channel = tempLayer.numFilters;
            theta{i}.b = zeros(channel, 1);
            meta.layersize{i} = [row col channel];
        case 'pool'
            theta{i}.W = [];
            theta{i}.b = [];
            row = int32(row/tempLayer.poolDim(1));
            col = int32(col/tempLayer.poolDim(2));
            meta.layersize{i} = [row col channel];
        case 'stack2line'
            theta{i}.W = [];
            theta{i}.b = [];
            row = row * col * channel;
            col = 1;
            channel = 1;
            dimension = row;
            meta.layersize{i} = dimension;
        case {'sigmoid','tanh','relu','softmax','softsign','satlin'}
            % initialisation of dnn method
            meta.paramsize{i} = [tempLayer.dimension dimension];
            r = sqrt(6) ./ sqrt(double(dimension) + tempLayer.dimension);
            theta{i}.W = rand(tempLayer.dimension, dimension) * 2 .* r - r;
            numParams(i,:) = [tempLayer.dimension*dimension tempLayer.dimension];
            dimension = tempLayer.dimension;
            theta{i}.b = zeros(dimension, 1);
            meta.layersize{i} = dimension;
         case {'pca'}
            meta.paramsize{i} = [tempLayer.dimension dimension];
            r = sqrt(6) ./ sqrt(double(dimension) + tempLayer.dimension);
            theta{i}.W = rand(tempLayer.dimension, dimension) * 2 .* r - r;
%             for j=1:length(pcamap)
%                 theta{i}.W(:,(j-1)*size(pcamap{j},1)+1:j*size(pcamap{j},1)) = pcamap{j}';
%             end
            numParams(i,:) = [tempLayer.dimension*dimension tempLayer.dimension];
            dimension = tempLayer.dimension;
            theta{i}.b = zeros(dimension, 1);
            meta.layersize{i} = dimension;
            
    end
end
meta.numTotalParams = sum(sum(numParams));
meta.numParams = numParams;
meta.numLayers = numLayers;
theta = thetaChange(theta, meta, 'stack2vec', cnnConfig);
end
