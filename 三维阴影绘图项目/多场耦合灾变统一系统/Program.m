% --- 多场耦合灾变统一模型 ---
clc
clear
close all
%% 导入数据
% 应力-应变曲线
data1=xlsread('data.xlsx','Sheet1');
X_mapped=data1(:,1);
Y_mapped=X_mapped;
Z_mapped=data1(:,2);

% 温度曲线
data2=xlsread('data.xlsx','Sheet2');
X_Temperature=ones(length(data2),1);
Y_Temperature=data2(:,1);
Z_Temperature=data2(:,2);

% 渗流曲线
data3=xlsread('data.xlsx','Sheet3');
X_Seepage=ones(length(data3),1);
Y_Seepage=data3(:,1);
Z_Seepage=data3(:,2);


%% 参数设置
Scaling=0.9;                     %缩放因子
Safety_Rate_C=0.07;              %工程安全率
Safety_Rate_D=0.09;              %工程安全率
Points=[0.246 0.246 0.132; %A
        0.382 0.382 0.348; %B
        0.477 0.477 0.520; %C
        0.667 0.667 0.716; %D
        0.909 0.909 0.145];%E    %5个关键点坐标
Points_Name='A':'E';             %5个关键点名称


%% 建立坐标系
figure('Color','white','Position',[100, 100, 1000, 800],'Name','多场耦合灾变统一模型');
ax=axes('Parent',gcf);
hold(ax,'on');
grid(ax,'on');
box(ax,'on');
view(ax,45,30);
set(ax,'FontSize',12,'FontWeight','bold','LineWidth', 1.5);
set(ax,'XColor',[0.2 0.2 0.7],'YColor',[0.2 0.7 0.2],'ZColor', [0.7 0.2 0.2]);

xlabel('空间位置轴','FontSize', 14,'FontWeight','bold');
ylabel('物理场轴','FontSize', 14,'FontWeight','bold');
zlabel('应力场 (MPa)','FontSize', 14,'FontWeight','bold');

xticks([1.5/7, 3.5/7,5.5/7]);
xticklabels({'米级','十米级','百米级'});

yticks([1.5/7 4.5/7]);
yticklabels({'温度场','渗流场'});

zticks([0.520,0.716]);
zticklabels({'\sigma_s','\sigma_\rho'});


%% 光源设置
light('Position',[1 1 1],'Style','infinite');
lighting gouraud;
material shiny;


%% 绘图
plot3(ax,X_mapped*Scaling,Y_mapped*Scaling,Z_mapped,'r-','LineWidth',3);        %绘制应力-应变曲线
hold on

%绘制关键点及关键点名称
for i=1:size(Points,1)
    plot3(ax,Points(i,1)*Scaling,Points(i,2)*Scaling,Points(i,3),'o','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',8);
    text(ax,Points(i,1)*Scaling,Points(i,2)*Scaling,Points(i,3)-0.05,Points_Name(i),'FontSize',12,'Color','k','FontWeight','bold','FontName','Times New Roman');
end

% 绘制屈服点和峰值强度点
plot3(ax,[0 Points(3,1)*Scaling],[0 Points(3,2)*Scaling],[Points(3,3) Points(3,3)],'k--','LineWidth',1);
plot3(ax,[0 Points(4,1)*Scaling],[0 Points(4,1)*Scaling],[Points(4,3) Points(4,3)],'k--','LineWidth',1);

% 绘制阴影区域并设置标签
patch(ax,[0 Points(3,1)-Safety_Rate_C Points(3,1)-Safety_Rate_C 0],[0 Points(3,2)-Safety_Rate_C Points(3,2)-Safety_Rate_C 0],[0 0 1 1],'b','FaceAlpha',0.2,'EdgeColor','none');
patch(ax,[Points(3,1)-Safety_Rate_C Points(4,1)-Safety_Rate_D Points(4,1)-Safety_Rate_D Points(3,1)-Safety_Rate_C],[Points(3,2)-Safety_Rate_C Points(4,2)-Safety_Rate_D Points(4,2)-Safety_Rate_D Points(3,2)-Safety_Rate_C],[0 0 1 1],'g','FaceAlpha',0.2,'EdgeColor','none');
patch(ax,[Points(4,1)-Safety_Rate_D 1 1 Points(4,1)-Safety_Rate_D],[Points(4,2)-Safety_Rate_D 1 1 Points(4,2)-Safety_Rate_D],[0 0 1 1],'m','FaceAlpha',0.2,'EdgeColor','none');
text(ax,0.2,0.2,0.9,'I','FontSize',20,'Color','k','FontWeight','bold','FontName','Times New Roman');
text(ax,0.4845,0.4845,0.9,'II','FontSize',20,'Color','k','FontWeight','bold','FontName','Times New Roman');
text(ax,0.7810,0.7810,0.9,'III','FontSize',20,'Color','k','FontWeight','bold','FontName','Times New Roman');

% 绘制温度和渗流曲线
plot3(ax,X_Temperature,Y_Temperature,Z_Temperature,'y-','LineWidth',3);
text(ax,X_Temperature(1),Y_Temperature(1)-0.1,Z_Temperature(1)+0.07,'温度','FontSize',12,'Color','k','FontWeight','bold');

plot3(ax,X_Seepage,Y_Seepage,Z_Seepage,'b-','LineWidth',3);
text(ax,X_Seepage(1),Y_Seepage(1)-0.1,Z_Seepage(1)+0.07,'渗流','FontSize',12,'Color','k','FontWeight','bold');