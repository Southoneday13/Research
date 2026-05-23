%创建CNN-BiLSTM-Attention模型的函数
function lgraph=createModel(neuronNum,f_)
lgraph=layerGraph();

% 输入层和折叠层
tempLayers=[
    sequenceInputLayer([f_,1,1],"Name","sequence")
    sequenceFoldingLayer("Name","seqfold")];
lgraph=addLayers(lgraph,tempLayers);

% 卷积层和激活层
tempLayers=convolution2dLayer([2,1],32,"Name","conv_1");
lgraph=addLayers(lgraph,tempLayers);

tempLayers=[
    reluLayer("Name","relu_1")
    convolution2dLayer([2,1],64,"Name","conv_2")
    reluLayer("Name","relu_2")];
lgraph=addLayers(lgraph,tempLayers);

% 全局池化层和全连接层
tempLayers=[
    globalAveragePooling2dLayer("Name","gapool")
    fullyConnectedLayer(16,"Name","fc_2")
    reluLayer("Name","relu_3")
    fullyConnectedLayer(64,"Name","fc_3")
    sigmoidLayer("Name","sigmoid")];
lgraph=addLayers(lgraph,tempLayers);

% 乘法层
tempLayers=multiplicationLayer(2,"Name","multiplication");
lgraph=addLayers(lgraph,tempLayers);

% 解折叠层、双向LSTM和回归输出层
tempLayers=[
    sequenceUnfoldingLayer("Name","sequnfold")
    flattenLayer("Name","flatten")
    bilstmLayer(neuronNum,"Name","lstm","OutputMode","last")
    fullyConnectedLayer(1,"Name","fc")
    regressionLayer("Name","regressionoutput")];
lgraph=addLayers(lgraph,tempLayers);

% 连接网络层
lgraph=connectLayers(lgraph,"seqfold/out","conv_1");
lgraph=connectLayers(lgraph,"seqfold/miniBatchSize","sequnfold/miniBatchSize");
lgraph=connectLayers(lgraph,"conv_1","relu_1");
lgraph=connectLayers(lgraph,"conv_1","gapool");
lgraph=connectLayers(lgraph,"relu_2","multiplication/in2");
lgraph=connectLayers(lgraph,"sigmoid","multiplication/in1");
lgraph=connectLayers(lgraph,"multiplication","sequnfold/in");
end
