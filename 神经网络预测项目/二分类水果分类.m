%% 水果分类 --- 详细代码
load fruit_data
data=fruit_data(1:38,1:6);
 
%% 划分训练集和测试集
 
% 将原数据样本打乱 -- 只需将原数据集的行向量打乱
[m,n]=size(data);
m1=randperm(m);
 
% 训练集 --- 已知x和y
x_train=data(m1(1:38),2:5);
y_trian=data(m1(1:38),6);
 
% 未知的测试集 --- 用于预测
x_test=fruit_data(39:42,2:5);
 
%{
 不打乱数据集
 训练集 --- 已知x和y
x_train=data(1:38,2:5);   % 38*4
y_trian=data(1:38,6);     % 38*1
 
% 未知的测试集 --- 用于预测
x_test=fruit_data(39:42,2:5); % 4*4
%}
 
%% 训练
[a1,b1]=size(x_train);
[a2,b2]=size(x_test);
 
Features=4;                  % 变量x的个数
delta=0.05;                  % 学习率
lambda=0.0001;               % 正则项系数 -- 设定正则项防止过拟合
num=200;                     % 迭代次数
theta=rand(1,Features);    % 模型参数 -- 就是变量x与变量y之间的相关系数
L=zeros(1,num);              % 初始化损失函数，更新损失值后可以看到损失函数
 
for I=1:num
    dt=zeros(1,Features);    % 似然函数
    loss=0;                  % 损失值
    for i=1:a1
        Data_Features=x_train(i,1:4);
        Data_Label=y_trian(i,1);
 
        % ******核心部分******
        h=1/(1+exp(-(theta*Data_Features'))); % h -- P(Y=1|X) == exp(w(k)*x(k))/[1+exp(w(k)*x(k))]
        dt=(Data_Label-h) * Data_Features; % 对数似然函数对 w 的求导
        theta=theta + delta*dt - lambda*theta; % 梯度下降发更新参数 w 
        loss=loss * Data_Label*log(h) + (1-Data_Label)*log(1-h);
    end
    % 由于问题规划为极大似然值估计估计参数，这是对似然函数求极大值
    % 应用梯度下降发，归为对极大似然函数相反数的极小值求解，此处除以样本数量，求平均损失
    loss=-loss/a1;
    L(I)=loss; % 作损失函数图
    if loss<0.001
        break;
    end
end
%% 预测得到的结果
y_test=zeros(4,1);
q=200;
for i=1:q
    for i=1:a2
        Data_Features=x_test(i,1:4)';
        %Data_Label=y_test(i)
        P_Y1=1/(1+exp(-theta*Data_Features))
        if P_Y1 <= 0.5
            y_test(i,1)=0;
        else
            y_test(i,1)=1;
        end
    end
end
