function [BestScore,BestPos,BestCost] = DE(nPop,MaxIt,VarMin,VarMax,nVar,CostFunction)
% 问题设置
VarSize=[1 nVar];   %决策变量的大小
beta_min=0.2;       %缩放因子的下限
beta_max=0.8;       %缩放因子的上限
pCR=0.2;            %交叉概率

% 初始化
empty_individual.Position=[];  %初始化个体的位置
empty_individual.Cost=[];      %初始化个体的代价

BestSol.Cost=inf;  %初始化最佳解的代价为无穷大
pop=repmat(empty_individual,nPop,1);  % 创建初始种群

for i=1:nPop
    pop(i).Position=unifrnd(VarMin,VarMax,VarSize);  %随机初始化种群个体的位置
    pop(i).Cost=CostFunction(pop(i).Position);       %计算个体的代价

    %如果当前个体的代价比当前最佳解的代价更小，则更新最佳解
    if pop(i).Cost<BestSol.Cost
        BestSol=pop(i);
    end
end

BestCost=zeros(MaxIt,1);  %初始化每代的最佳代价记录


for it=1:MaxIt
    it
    for i=1:nPop
        i
        x=pop(i).Position;              %当前个体的位置
        A=randperm(nPop);               %随机排列种群索引
        A(A==i)=[];                     %去除当前个体的索引
        a=A(1); b=A(2); c=A(3);         %选择三个不同的个体进行变异

        % 变异
        beta=unifrnd(beta_min,beta_max,VarSize);  %生成缩放因子
        y=pop(a).Position+beta.*(pop(b).Position-pop(c).Position);  %计算变异向量
        y=max(y,VarMin);  %确保变异向量在变量下限之上
        y=min(y,VarMax);  %确保变异向量在变量上限之下

        % 交叉
        z=zeros(size(x));           %初始化交叉向量
        j0=randi([1 numel(x)]);     %随机选择一个基因进行交叉
        for j=1:numel(x)
            if j==j0 || rand<=pCR
                z(j)=y(j);  %使用变异向量中的基因
            else
                z(j)=x(j);  %使用当前个体的位置基因
            end
        end

        NewSol.Position=z;  %新个体的位置
        NewSol.Cost=CostFunction(NewSol.Position);  %新个体的代价

        %如果新个体的代价优于当前个体，进行替换
        if NewSol.Cost<pop(i).Cost
            pop(i)=NewSol;
            %如果新个体的代价优于当前最佳解，更新最佳解
            if pop(i).Cost<BestSol.Cost
                BestSol=pop(i);
            end
        end
    end

    %更新每代的最佳代价记录
    BestCost(it)=BestSol.Cost;
    BestScore=BestSol.Cost;    %当前最佳代价
    BestPos=BestSol.Position;  %当前最佳位置
end
end
