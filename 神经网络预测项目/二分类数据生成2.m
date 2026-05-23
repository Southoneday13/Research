close;
clear;
clc;
% 作者 M宝可梦
% 引用请注明出处 谢谢合作
%% 二分类:数据生成
data_num = 500;
Features=3;
data=rand(data_num,Features);
label=zeros(data_num,1);
data=[data,ones(data_num,1)];
% 数据预处理：通过设定某种关系进行预先二分类,打乱循序使得每次运行训练集和测试集和不同
for i = 1:data_num
    if 2*data(i,1)-data(i,2)+2*data(i,3)<1.5    % 代码可精简：label(2*data(:,1)-data(:,2)<0.5)=1; % 通过逻辑判断
        label(i)=1;
    end
end
randIndex = randperm(data_num);
data_new=data(randIndex,:);
label_new=label(randIndex,:);

data_num=xlsread('1.csv');

%一半训练  一半测试
k=round(0.8*data_num);
train_data=data_num(1:k,1:4);
train_label=data_num(1:k,5);
test_data=data_num(k+1:end,1:4);
test_label=data_num(k+1:end,5);
[m1,n1] = size(train_data);
[m2,n2] = size(test_data);

%% 训练
%设定学习率delta;正则项系数;迭代次数;模型参数
delta=0.05; 
lambda=0.0001; 
num = 200;
theta=rand(1,Features+1);% 除w之外多一个偏置b
L=zeros(1,num);
for I = 1:num
    dt=zeros(1,Features);
    loss=0;
    for i=1:m1
        Data_Features=train_data(i,1:Features+1);
        Data_Label=train_label(i,1);
        
        h=1/(1+exp(-(theta * Data_Features'))); % h为P(Y=1|X) = exp(w·x)/[1+exp(w·x)]
        dt=(Data_Label-h) * Data_Features;   % 对数似然函数对w的求导
        theta=theta + delta*dt-lambda*theta; % 梯度下降法更新参数w
        loss=loss + Data_Label*log(h)+(1-Data_Label)*log(1-h);% 对数似然函数
    end
    % 由于问题划归为由极大似然估计估计参数，是对似然函数求极大值
    % 统一起见应用梯度下降法，归为对极大似然函数相反数的极小值求解，此处除以了样本数量，为平均损失
    loss=-loss/m1;
    L(I) = loss;% 作损失函数图
    
    if loss<0.001
        break;
    end
end

%% 作图
figure(1);
plot(L);
title('损失函数');
figure(2);
subplot(211);
plot3(data(label==1,1),data(label==1,2),data(label==1,3),'ro');
axis([0 1 0 1]);
title('正样本分类显示');
subplot(212);
plot3(data(label==0,1),data(label==0,2),data(label==0,3),'go');
axis([0 1 0 1]);
title('负样本分类显示');
figure(3);
plot3(data(label==1,1),data(label==1,2),data(label==1,3),'ro');
hold on;
plot3(data(label==0,1),data(label==0,2),data(label==0,3),'go');
axis([0 1 0 1]);
title('总体样本分类显示');
grid on

%% 测试准确率
acc=0;
for i=1:m2
    Data_Features=test_data(i,1:Features+1)';
    Data_Label=test_label(i);
    P_Y1=1/(1+exp(-theta * Data_Features));% P(Y=1|X) = exp(w·x)/[1+exp(w·x)]
    if P_Y1>0.5 && Data_Label==1
        acc=acc+1;
    elseif P_Y1<=0.5 && Data_Label==0
        acc=acc+1;
    end
end

fprintf('训练测试完成!\n应用模型：逻辑斯蒂回归\n优化算法：梯度下降\ntest_acc:%6.2f',acc/m2)
