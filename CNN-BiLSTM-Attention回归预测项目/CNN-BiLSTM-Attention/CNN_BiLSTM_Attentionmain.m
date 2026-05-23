clc
clear
warning off
close all
%%导入数据
res=xlsread('速度温度.xlsx');


%% 数据分析
num_size=0.7;                                %训练集占数据集比例
outdim=1;                                    %最后一列为输出
num_samples=size(res,1);                     %样本个数
load temp.mat                                %导入数据分布
res=res(temp,:);                             %打乱数据集
num_train_s=round(num_size*num_samples);     %训练集样本个数
f_=size(res,2)-outdim;                       %输入特征维度


%% 划分训练集和测试集
P_train=res(1:num_train_s,1:f_)';
T_train=res(1:num_train_s,f_+1:end)';
M=size(P_train,2);

P_test=res(num_train_s+1:end,1:f_)';
T_test=res(num_train_s+1:end,f_+1:end)';
N=size(P_test,2);


%% 数据归一化
[p_train,ps_input]=mapminmax(P_train,0,1); % 对训练输入数据进行归一化
p_test=mapminmax('apply',P_test,ps_input); % 对测试输入数据进行归一化

[t_train,ps_output]=mapminmax(T_train,0,1); % 对训练输出数据进行归一化
t_test=mapminmax('apply',T_test,ps_output); % 对测试输出数据进行归一化


%% 数据平铺
p_train=double(reshape(p_train,f_,1,1,M));
p_test=double(reshape(p_test,f_,1,1,N));
t_train=double(t_train)';
t_test=double(t_test)';


%% 数据格式转换
for i=1:M
    Lp_train{i,1}=p_train(:,:,1,i);
end

for i=1:N
    Lp_test{i,1}=p_test(:,:,1,i);
end


%% 模型训练
lgraph=createModel(7,f_);
options=trainingOptions('adam', ...
    'MaxEpochs',800, ...
    'InitialLearnRate',0.065, ...
    'L2Regularization',0.0001, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',false);

%训练网络
net=trainNetwork(Lp_train,t_train,lgraph,options);


%% 模型预测
t_sim1=predict(net,Lp_train);
t_sim2=predict(net,Lp_test);


%% 数据反归一化
T_sim1=mapminmax('reverse',t_sim1',ps_output);
T_sim2=mapminmax('reverse',t_sim2',ps_output);
T_sim1=double(T_sim1);
T_sim2=double(T_sim2);


%% 测试集结果分析与绘图
figure;
plotregression(T_test,T_sim2,'回归图');
figure;
ploterrhist(T_test-T_sim2,'误差直方图');


%% 计算评价指标：RMSE, R², MSE, RPD, MAE, MAPE
error1=sqrt(sum((T_sim1-T_train).^2)./M);
error2=sqrt(sum((T_sim2-T_test).^2)./N);

R1=1-norm(T_train-T_sim1)^2/norm(T_train-mean(T_train))^2;
R2=1-norm(T_test-T_sim2)^2/norm(T_test-mean(T_test))^2;

mse1=sum((T_sim1-T_train).^2)./M;
mse2=sum((T_sim2-T_test).^2)./N;

SE1=std(T_sim1-T_train);
RPD1=std(T_train)/SE1;

SE=std(T_sim2-T_test);
RPD2=std(T_test)/SE;

MAE1=mean(abs(T_train-T_sim1));
MAE2=mean(abs(T_test-T_sim2));

MAPE1=mean(abs((T_train-T_sim1)./T_train));
MAPE2=mean(abs((T_test-T_sim2)./T_test));


%% 绘制训练集与测试集预测结果对比图
figure;
plot(1:M,T_train,'r-*','LineWidth',1.5); hold on;
plot(1:M,T_sim1,'b-o','LineWidth',1.5);
legend('真实值','DE-CNN-BiLSTM-Attention预测值');
xlabel('预测样本');
ylabel('预测结果');
title({'训练集预测结果对比',['(R^2 =' num2str(R1) ' RMSE= ' num2str(error1) ' MSE= ' num2str(mse1) ' RPD= ' num2str(RPD1) ')']});
grid on;

figure;
plot(1:N,T_test,'r-*','LineWidth',1.5); hold on;
plot(1:N,T_sim2,'b-o','LineWidth',1.5);
legend('真实值','DE-CNN-BiLSTM-Attention预测值');
xlabel('预测样本');
ylabel('预测结果');
title({'测试集预测结果对比',['(R^2 =' num2str(R2) ' RMSE= ' num2str(error2) ' MSE= ' num2str(mse2) ' RPD= ' num2str(RPD2) ')']});
grid on;


%% 测试集误差图
figure;
plot(T_test-T_sim2,'b-*','LineWidth',1.5);
xlabel('测试集样本编号');
ylabel('预测误差');
title('测试集预测误差');
grid on;
legend('预测输出误差');


%% 绘制线性拟合图
figure;
plot(T_train,T_sim1,'*r');
xlabel('真实值');
ylabel('预测值');
title({'训练集效果图',['R^2_c=' num2str(R1)  '  RMSEC=' num2str(error1)]});
hold on; h=lsline;
set(h,'LineWidth',1,'LineStyle','-','Color',[1 0 1]);

figure;
plot(T_test,T_sim2,'ob');
xlabel('真实值');
ylabel('预测值');
title({'测试集效果图',['R^2_p=' num2str(R2)  '  RMSEP=' num2str(error2)]});
hold on; h=lsline;
set(h,'LineWidth',1,'LineStyle','-','Color',[1 0 1]);


%% 计算平均值
R3=(R1+R2)/2;
error3=(error1+error2)/2;


%% 所有数据的线性预测拟合图
tsim=[T_sim1,T_sim2]';
S=[T_train,T_test]';

figure;
plot(S,tsim,'ob');
xlabel('真实值');
ylabel('预测值');
string1={'所有样本拟合预测图';['R^2_p=' num2str(R3)  '  RMSEP=' num2str(error3)]};
title(string1);
hold on;
h=lsline();
set(h,'LineWidth',1,'LineStyle','-','Color',[1 0 1]);


%% 打印出评价指标
disp(['-----------------------误差计算--------------------------']);
disp(['评价结果如下所示：']);
disp(['平均绝对误差MAE为：',num2str(MAE2)]);
disp(['均方误差MSE为：',num2str(mse2)]);
disp(['均方根误差RMSE为：',num2str(error2)]);
disp(['决定系数R^2为：',num2str(R2)]);
disp(['剩余预测残差RPD为：',num2str(RPD2)]);
disp(['平均绝对百分比误差MAPE为：',num2str(MAPE2)]);
grid on;
