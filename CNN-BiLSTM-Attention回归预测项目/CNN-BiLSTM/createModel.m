function lgraph=createModel(neuronNum,f_)
lgraph=layerGraph();
tempLayers=[
    sequenceInputLayer([f_,1,1],"Name","sequence")
    sequenceFoldingLayer("Name","seqfold")];
lgraph=addLayers(lgraph,tempLayers);

tempLayers=[
    convolution2dLayer([2,1],32,"Name","conv_1")
    reluLayer("Name","relu_1")
    convolution2dLayer([2,1],64,"Name","conv_2")
    reluLayer("Name","relu_2")];
lgraph=addLayers(lgraph,tempLayers);

tempLayers=[
    sequenceUnfoldingLayer("Name","sequnfold")
    flattenLayer("Name","flatten")
    bilstmLayer(neuronNum,"Name","lstm","OutputMode","last")
    fullyConnectedLayer(1,"Name","fc")
    regressionLayer("Name","regressionoutput")];
lgraph=addLayers(lgraph,tempLayers);

lgraph=connectLayers(lgraph,"seqfold/out","conv_1");
lgraph=connectLayers(lgraph,"seqfold/miniBatchSize","sequnfold/miniBatchSize");
lgraph=connectLayers(lgraph,"relu_2","sequnfold/in");
end
