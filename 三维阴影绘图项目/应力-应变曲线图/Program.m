clc
clear
close all
%% 导入数据
data=xlsread('data.xlsx','Sheet1');
X=data(:,1);
Y=data(:,2);


%% 参数设置
Safety_Rate=0.05;          %工程安全率
Points=[0.246 0.132; %A
        0.382 0.348; %B
        0.477 0.520; %C
        0.667 0.716; %D
        0.909 0.145];%E    %5个关键点坐标
Points_Name='A':'E';       %5个关键点名称


%% 绘制图形
% 绘制应力-应变图
figure
plot(X,Y,'r-','LineWidth',3)
hold on
for i=1:size(Points,1)
    plot(Points(i,1),Points(i,2),'o','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',8);
    text(Points(i,1),Points(i,2)-0.05,Points_Name(i),'FontSize',12,'Color','k','FontWeight','bold','FontName','Times New Roman');
end

%绘制阴影并添加标签
patch([0 Points(3,1)-Safety_Rate Points(3,1)-Safety_Rate 0],[[0 0 1 1]],'b','FaceAlpha',0.2,'EdgeColor','none');
patch([Points(3,1)-Safety_Rate Points(4,1)-Safety_Rate Points(4,1)-Safety_Rate Points(3,1)-Safety_Rate],[[0 0 1 1]],'g','FaceAlpha',0.2,'EdgeColor','none');
patch([Points(4,1)-Safety_Rate 1 1 Points(4,1)-Safety_Rate],[[0 0 1 1]],'m','FaceAlpha',0.2,'EdgeColor','none');
text(0.2,0.9,'I','FontSize',20,'Color','k','FontWeight','bold','FontName','Times New Roman');
text(0.4845,0.9,'II','FontSize',20,'Color','k','FontWeight','bold','FontName','Times New Roman');
text(0.7810,0.9,'III','FontSize',20,'Color','k','FontWeight','bold','FontName','Times New Roman');

%设置坐标轴
set(gca,'FontSize',14,'FontName','Times New Roman')
xlabel('ε','FontSize',20,'FontAngle','italic','FontName','Times New Roman');
ylabel('δ','FontSize',20,'FontAngle','italic','FontName','Times New Roman');

xticks([]);
yticks([0.520,0.716]);
yticklabels({'\sigma_s','\sigma_\rho'});