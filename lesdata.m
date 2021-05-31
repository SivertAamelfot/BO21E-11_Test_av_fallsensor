clear
close all
fil='data_2021_02_25_11_34_08.csv'
data=dlmread(strcat('C:\Arbeid\omsorgslaben\akselerometer\data\',fil));
% C:\Users\siver\OneDrive\Dokumenter\EAU\ELE150 Bachelor\Datafiler

Ax=data(50:end,1);
Ay=data(50:end,2);
Az=data(50:end,3);
P=data(50:end,4);







A_tot=sqrt(Ax.^2+Ay.^2+Az.^2);


[A_tot_lp, A, B] = butterfiltfilt(A_tot, 50, 200, 2, 'lowpass', 'both')


p(1)=subplot(2,1,1)
plot(A_tot)
hold on
plot(A_tot_lp)
ylim([900 1000])
p(2)=subplot(2,1,2)
plot(P)

linkaxes(p,'x')
