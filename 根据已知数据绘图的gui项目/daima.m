clc
clear


%%导入数据
Uc=importdata('Uc.txt');
Uapp=importdata('Uapp.txt');


%%图1
yyaxis left
plot(Uapp(:,1),Uapp(:,2),'b')
xlabel('Time(s)')
ylabel(['U_a_p_p','(V)'])
set(gca,'ycolor','b','ytick',[-1e4:0.5e4:1e4]);

%peak-to-peak
Uapp_y_smooth=smooth(Uapp(:,2),1000);
Uapp_pks=smooth(Uapp_y_smooth,100);
[Uapp_pks,Uapp_locs]=findpeaks(Uapp_pks,'MinPeakDistance',20000);
Uapp_ptp= Uapp_pks(2,1)-Uapp_pks(3,1));

%frequency
Uapp_location = [];
Uapp_j = 1;
Uapp_cross=[];
for i = 1:length(Uapp_y_smooth)-1
 if (Uapp_y_smooth(i+1) > 0) && (Uapp_y_smooth(i) < 0)
      Uapp_location(i) = i;
        Uapp_cross(Uapp_j)=i;
        Uapp_j = Uapp_j+1;
    elseif (Uapp_y_smooth(i+1) < 0) && (Uapp_y_smooth(i) > 0)
       Uapp_location(i) = i;
       Uapp_cross(Uapp_j)=i;
       Uapp_j = Uapp_j+1;
 end
end
Uapp_f=1/((Uapp_cross(1,4) - Uapp_cross(1,2))*0.0001/200000);

%RMS value
Uapp_RMS=rms(Uapp(:,2));








yyaxis right
C=22e-9;
Q=Uc(:,2).*C; 
plot(Uc(:,1),Q)
ylabel('Q(C)')
set(gca,'ycolor','r');
title('Time Resolved High Voltage and Charge Plots','FontWeight','bold')

%peak-to-peak
Uc_y_smooth=smooth(Uc(:,2),1000);
Uc_pks=smooth(Uc_y_smooth,100);
[Uc_pks,Uc_locs]=findpeaks(Uc_pks,'MinPeakDistance',20000);
Uc_ptp= Uc_pks(2,1)-Uc_pks(3,1));

%frequency
Uc_location = [];
Uc_j = 1;
Uc_cross=[];
for i = 1:length(Uc_y_smooth)-1
 if (Uc_y_smooth(i+1) > 0) && (Uc_y_smooth(i) < 0)
      Uc_location(i) = i;
        Uc_cross(Uc_j)=i;
        Uc_j = Uc_j+1;
    elseif (Uc_y_smooth(i+1) < 0) && (Uc_y_smooth(i) > 0)
       Uc_location(i) = i;
       Uc_cross(Uc_j)=i;
       Uc_j = Uc_j+1;
 end
end
Uc_f=1/((Uc_cross(1,4) - Uc_cross(1,2))*0.0001/200000);

%RMS value
Uc_RMS=rms(Uc(:,2));














%%图2无smoot
plot(Uapp(:,2),Q,'b')












%%图2有smoot
Uapp_1=smooth(Uapp(:,2),1000);
Q_1=smooth(Q,100);
plot(Uapp_1,Q_1)




