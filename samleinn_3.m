%%
% Innhenting av data

%clear
%close all

% For å unngå å opne/lukke tilkopling heile tida, sparer nokre sekund
% if(~exist('s', 'var'))
%     porter = serialportlist
%     s = serialport(porter(1), 250000);
% else if(isempty(s))
%     end
% if(isempty(s))
%     porter = serialportlist
%     s = serialport(porter(1), 250000);
% end
%s.BaudRate=250000;
%fopen(s)
%fgetl(s)
if(~exist('s', 'var'))
    porter = serialportlist
    s = serialport(porter(1), 500000);
    pause(5);
end

% Tøm input-buffer for uønska data, vent lenge nok til at arduino er kopla
% til
startmeldinger = [];
pause(5)
while(s.NumBytesAvailable > 0)
    startmeldinger = readline(s);
end

rawut=[];
cnt=0;
pause(1)
flag=1;

%write(s, "START", "string");
writeline(s,'START')
disp('Starter avlesing...')
% Må finne ut kor lang tid det tar totalt å logge, samt når knappen går lav 

while flag==1
raw=readline(s);
if(cnt == 0)
    %tid_startLogg = datetime('now');
    tic_knappEndra = tic;
    cnt = 1;
end
if (~isempty(rawut) && cnt<2 && ~all(rawut(:,5)))
    %tid_knappEndra = datetime('now');
    toc_knappEndra = toc(tic_knappEndra);
    tic_stopp = tic;
    cnt = 2;
end
flag=isempty(strfind(raw,'Avslutter'));

try
    
raw2=str2num(raw);
rawut=[rawut;raw2];
catch
    disp('Problem med konvertering fra tekst til tall')

end

%time_raw=now;
end
toc_stopp = toc(tic_stopp);
tid_slutt=datetime('now');
% tider = [tid_knappEndra tid_slutt];
% dt = diff(tider);
tid_slutt=datestr(tid_slutt,'yyyy_mm_dd_HH_MM_SS');
   
    
fil=strcat('C:\Users\siver\OneDrive\Dokumenter\EAU\ELE150 Bachelor\Datafiler\data_',tid_slutt,'.csv');
dlmwrite(fil,rawut,'precision',8);

fil2 = strcat('C:\Users\siver\OneDrive\Dokumenter\EAU\ELE150 Bachelor\Datafiler\data_',tid_slutt);
% save(fil2, 'rawut'); % standard format er .mat
% disp(strcat('data_',tid_slutt, ' er lagra til fil'))
%skriv til fil
%dlmwrite('temp1.txt',[time_raw,temp_raw],'-append','precision',12)
%end

tidsintervall = (toc_knappEndra + toc_stopp) / length(rawut);
tidVec_forKnapp = toc_knappEndra:-tidsintervall:0;
tidVec_forStopp = 0:tidsintervall:toc_stopp;

% Tidsvektoren må vere like stor som antall målinger, kutter sluttida då
% den ikkje er kritisk
while(length(tidVec_forKnapp) + length(tidVec_forStopp) > length(rawut))
    tidVec_forStopp = tidVec_forStopp(1:end-1);
end
tidVec = [-tidVec_forKnapp tidVec_forStopp];




%%
% Plotting av data
data=rawut;

 
Ax=data(:,1);
Ay=data(:,2);
Az=data(:,3);
P=data(:,4);
knapp=data(:,5);

% dP = max(P) - min(P);
% rho = 1.2;
% g = -9.81;
% dh = dP/(-rho*g)

% standardverdi, burde korrigerast for vêr og temp.
trykk_havnivaa = 101325;

hogde = P;
for i=1:length(P)
    hogde(i) = 44330.0 * (1.0 - (P(i)/trykk_havnivaa )^0.1903);
end


% P2 = [P]
%  for i=1:length(P)
%     if(abs(P(i) - mode(P)) > 2000)
%         P2(i) = NaN; 
%     else
%         P2(i) = P(i)/10^3;
%     end 
%  end
 
 
 
 
 
A_tot=sqrt(Ax.^2+Ay.^2+Az.^2);

%%
% Finn ut om fallalarmen har gått:
% TODO: Finn variabel som indikerer enten tid eller samples etter knappen 
% går lav

knapp_lav = find(~knapp,1); % Første sample der knappen er lav

if(~isempty(A_tot(A_tot(knapp_lav+1000:end)<900 | A_tot(knapp_lav+1000:end)>1100)))
   fall = true; 
else
    fall = false;
end
disp(strcat("Fall: ", string(fall))) % Bruk "" i staden for '' for å få med mellomrom

save(fil2, 'rawut', 'fall'); % standard format er .mat
disp(strcat('data_',tid_slutt, ' er lagra til fil'))

%%

 % Samplingsfrekvens er mest sannsynleg lavare enn 200Hz, kanskje 135Hz?
 % Får feilmeldinger dersom eg prøver å endre dette.
[A_tot_lp, A, B] = butterfiltfilt(A_tot, 10, 200, 2, 'lowpass', 'both');
[A_tot_bp, A, B] = butterfiltfilt(A_tot_lp, [10,99], 200, 2, 'bandpass', 'both');

p(1)=subplot(4,1,1);
plot(tidVec, A_tot)
hold on
plot(tidVec, A_tot_lp)
%xlim([-toc_knappEndra toc_stopp+5])
ylim([900 1100])

p(2)=subplot(4,1,2);
plot(tidVec, A_tot_bp)
ylim([-100,100])
p(3)=subplot(4,1,3);
plot(tidVec, P)
ylim([min(P)-200 max(P)+200])

p(4)=subplot(4,1,4);
plot(tidVec, knapp)
ylim([-0.2 1.2])
linkaxes(p,'x')
%xlim([-toc_knappEndra toc_stopp+5])
hold off
%xlim([-1, 10])

[hogde_tot_lp, PP, PB] = butterfiltfilt(hogde, 10, 400, 2, 'lowpass', 'both');

figure;
avg = mean(hogde);
p2(1) = subplot(2,1,1);
plot(tidVec, hogde)
hold on
plot([tidVec(1) tidVec(end)], [avg avg])

% Kan ikkje rekne ut gjennomsnitt med endane frå filter
p2(2) = subplot(2,1,2);
plot(tidVec, hogde_tot_lp)
hold on
plot([tidVec(1) tidVec(end)], [avg avg])
linkaxes(p2,'x')
beep
