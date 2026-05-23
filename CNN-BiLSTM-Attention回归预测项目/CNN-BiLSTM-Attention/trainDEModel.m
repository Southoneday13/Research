% 差分进化优化代价函数
function score=trainDEModel(Lp_train,t_train,params,f_)
    lgraph=createModel(round(params(1)),f_);        % 使用参数创建模型

    options=trainingOptions('adam', ...
        'MaxEpochs',500, ...
        'InitialLearnRate',params(2), ...
        'L2Regularization',params(3), ...
        'Shuffle','every-epoch', ...
        'Verbose',false);

    net=trainNetwork(Lp_train,t_train,lgraph,options);  % 训练网络
    
    predicted=predict(net,Lp_train);    % 预测训练集
    mse=mean((predicted-t_train).^2);   % 计算均方误差
    score=mse;                          % 使用均方误差作为目标函数值
end
