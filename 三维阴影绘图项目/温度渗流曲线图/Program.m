clc
clear
close all
%% 导入数据
% 温度曲线
data1=xlsread('data.xlsx','Sheet2');
X_Temperature=data1(:,1);
Y_Temperature=data1(:,2);

% 渗流曲线
data2=xlsread('data.xlsx','Sheet3');
X_Seepage=data2(:,1);
Y_Seepage=data2(:,2);


%% 绘制图形
% 绘制温度曲线
figure
plot(X_Temperature,Y_Temperature,'y-','LineWidth',3);
text(X_Temperature(1)+0.05,Y_Temperature(1)+0.05,'温度','FontSize',12,'Color','k','FontWeight','bold');


% 绘制渗流曲线
hold on
plot(X_Seepage,Y_Seepage,'b-','LineWidth',3);
text(X_Seepage(1)+0.05,Y_Seepage(1)+0.05,'渗流','FontSize',12,'Color','k','FontWeight','bold');
hold off

%设置坐标轴
xlim([0 1]);ylim([0 1]);
xticks([]);yticks([]);
xlabel('温度场','FontSize',14,'FontName','Microsoft YaHei');
ylabel('应力场','FontSize',14,'FontName','Microsoft YaHei');