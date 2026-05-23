function varargout = Assignment(varargin)
% ASSIGNMENT MATLAB code for Assignment.fig
%      ASSIGNMENT, by itself, creates a new ASSIGNMENT or raises the existing
%      singleton*.
%
%      H = ASSIGNMENT returns the handle to a new ASSIGNMENT or the handle to
%      the existing singleton*.
%
%      ASSIGNMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASSIGNMENT.M with the given input arguments.
%
%      ASSIGNMENT('Property','Value',...) creates a new ASSIGNMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Assignment_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Assignment_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Assignment

% Last Modified by GUIDE v2.5 12-Nov-2022 16:41:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Assignment_OpeningFcn, ...
                   'gui_OutputFcn',  @Assignment_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Assignment is made visible.
function Assignment_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Assignment (see VARARGIN)

% Choose default command line output for Assignment
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Assignment wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Assignment_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Uc Q Uc_f Uc_ptp Uc_RMS
Uc=importdata('Uc.txt');

%peak-to-peak
Uc_y_smooth=smooth(Uc(:,2),1000);
Uc_pks=smooth(Uc_y_smooth,100);
[Uc_pks,Uc_locs]=findpeaks(Uc_pks,'MinPeakDistance',20000);
Uc_ptp= Uc_pks(2,1)-Uc_pks(3,1);

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

set(handles.text14,'String','Uc.txt');
set(handles.text15,'String',num2str(Uc_f));
set(handles.text16,'String',num2str(Uc_ptp));
set(handles.text17,'String',num2str(Uc_RMS));

axes(handles.axes1); 

yyaxis right
C=22e-9;
Q=Uc(:,2).*C; 
plot(Uc(:,1),Q)
ylabel('Q(C)')
set(gca,'ycolor','r');
title('Time Resolved High Voltage and Charge Plots','FontWeight','bold')


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Uapp Uapp_ptp Uapp_f Uapp_RMS
Uapp=importdata('Uapp.txt');

%peak-to-peak
Uapp_y_smooth=smooth(Uapp(:,2),1000);
Uapp_pks=smooth(Uapp_y_smooth,100);
[Uapp_pks,Uapp_locs]=findpeaks(Uapp_pks,'MinPeakDistance',20000);
Uapp_ptp= Uapp_pks(2,1)-Uapp_pks(3,1);

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

set(handles.text10,'String','Uapp.txt');
set(handles.text11,'String',num2str(Uapp_f));
set(handles.text12,'String',num2str(Uapp_ptp));
set(handles.text13,'String',num2str(Uapp_RMS));

axes(handles.axes1); 
yyaxis left
plot(Uapp(:,1),Uapp(:,2),'b')
xlabel('Time(s)')
ylabel(['U_a_p_p','(V)'])
set(gca,'ycolor','b','ytick',[-1e4:0.5e4:1e4]);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Uapp Q
axes(handles.axes2); 
plot(Uapp(:,2),Q,'k')
xlabel('U_a_p_p(V)')
ylabel('Q(C)')
set(gca,'xcolor','b','ycolor','r');
title('Raw Data Q-U Lissajous','FontWeight','bold')

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Uapp Q
Uapp_1=smooth(Uapp(:,2),5000);
Q_1=smooth(Q,500);

axes(handles.axes4); 
plot(Uapp_1,Q_1,'k')
xlabel('U_a_p_p(V)')
ylabel('Q(C)')
set(gca,'xcolor','b','ycolor','r');
title('Smoothed Q-U Lissajous','FontWeight','bold')


T=1/35000;
t=1e-4;
time=t/T
area=polyarea(Uapp(:,2),Q)
P=35000*area/time
set(handles.text18,'String',['P=',num2str(P),'W']);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Uapp_ptp Uapp_f Uapp_RMS Uc_ptp Uc_f Uc_RMS
xlswrite('Data.xlsx',{'Uapp_ptp';'Uapp_f';'Uapp_RMS';'Uc_ptp';'Uc_f';'Uc_RMS'},'A1:A6');
xlswrite('Data.xlsx',{num2str(Uapp_ptp);num2str(Uapp_f);num2str(Uapp_RMS);num2str(Uc_ptp);num2str(Uc_f);num2str(Uc_RMS)},'B1:B6');


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text10,'String','');
set(handles.text11,'String','');
set(handles.text12,'String','');
set(handles.text13,'String','');
set(handles.text14,'String','');
set(handles.text15,'String','');
set(handles.text16,'String','');
set(handles.text17,'String','');
set(handles.text18,'String','');
cla(handles.axes1,'reset');
cla(handles.axes2,'reset');
cla(handles.axes4,'reset');
clear all

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all
