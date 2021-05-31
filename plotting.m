% Plotting av data
%close all

% Anta at brukaren velger ei fil
% TODO: Legg til feilhandtering f.eks. dersom brukaren lukker vindauget
if(exist('data', 'var'))
    [file,path] = uigetfile('*.mat');
    if isequal(file,0)
        disp('User selected Cancel');
    else
        disp(['User selected ', fullfile(path,file)]);
    end
end

% VAR = 'S';
% T = load(strcat(path,file),VAR);  % Function output form of LOAD
% T = T.(VAR)

data = load(strcat(path,file));
lagraNavn = string(fieldnames(data));
data = data.(lagraNavn);

if(isa(data, 'Klasser.Falldata'))
    
    
    p(1)=subplot(4,1,1);
    plot(data.Akselerasjon)
    %hold on
    %xlim([-toc_knappEndra toc_stopp+5])
    %ylim([900 1100])

    p(2)=subplot(4,1,2);
    plot(data.Akselerasjon_filt)
    %ylim([-100,100])
    p(3)=subplot(4,1,3);
    plot(data.Hogde)
    %ylim([min(P)-200 max(P)+200])

    p(4)=subplot(4,1,4);
    plot(data.Data(:,5))
    ylim([-0.2 1.2])
    linkaxes(p,'x')
    %xlim([-toc_knappEndra toc_stopp+5])
    hold off
    %xlim([-1, 10])

    %[hogde_tot_lp, PP, PB] = butterfiltfilt(hogde, 10, 400, 2, 'lowpass', 'both');

%     figure;
%     avg = mean(hogde);
%     p2(1) = subplot(2,1,1);
%     plot(hogde)
%     hold on
%     plot([avg avg])
% 
%     % Kan ikkje rekne ut gjennomsnitt med endane frå filter
%     p2(2) = subplot(2,1,2);
%     plot(hogde_tot_lp)
%     hold on
%     plot([avg avg])
%     linkaxes(p2,'x')



%  if(~isempty(A_tot(knapp_lav+3000:end)<900 | A_tot(knapp_lav+3000:end)>1100))
%                 obj.Fall = true;
%             else
%                 obj.Fall = false;
%             end
    
else
felt_celle = fieldnames(data);
felt = felt_celle{1};
data = data.(felt);
%data = struct2cell(data);
%data=rawut;

% Treng å lagre tidVec i tillegg, ellers må eg telle samples
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
 
 for i=7542:7548
     sum = A_tot(i) - 1036;
 end
 sum = sum/9.81
 
 
A_tot=sqrt(Ax.^2+Ay.^2+Az.^2);

 % Samplingsfrekvens er mest sannsynleg lavare enn 200Hz, kanskje 135Hz?
 % Får feilmeldinger dersom eg prøver å endre dette.
[A_tot_lp, A, B] = butterfiltfilt(A_tot, 10, 200, 2, 'lowpass', 'both');
[A_tot_bp, A, B] = butterfiltfilt(A_tot_lp, [10,99], 200, 2, 'bandpass', 'both');

% Midlertidig sidan mange tidlegare målinger ikkje har tidVec lagra i
% .mat-fila
if exist('tidVec', 'var')
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
else
    p(1)=subplot(4,1,1);
    plot(A_tot)
    hold on
    plot(A_tot_lp)
    %xlim([-toc_knappEndra toc_stopp+5])
    ylim([900 1100])

    p(2)=subplot(4,1,2);
    plot(A_tot_bp)
    ylim([-100,100])
    p(3)=subplot(4,1,3);
    plot(P)
    ylim([min(P)-200 max(P)+200])

    p(4)=subplot(4,1,4);
    plot(knapp)
    ylim([-0.2 1.2])
    linkaxes(p,'x')
    %xlim([-toc_knappEndra toc_stopp+5])
    hold off
    %xlim([-1, 10])

    [hogde_tot_lp, PP, PB] = butterfiltfilt(hogde, 10, 400, 2, 'lowpass', 'both');

    figure;
    avg = mean(hogde);
    p2(1) = subplot(2,1,1);
    plot(hogde)
    hold on
    plot([avg avg])

    % Kan ikkje rekne ut gjennomsnitt med endane frå filter
    p2(2) = subplot(2,1,2);
    plot(hogde_tot_lp)
    hold on
    plot([avg avg])
    linkaxes(p2,'x')
end
beep
end

%%
% Rekne ut bias til akselerometer
bias = sum(data.Akselerasjon(154:6154)) / (6154 - 154)

aks_tot = 0;
for i=6163:6307
    aks_tot = aks_tot + (data.Akselerasjon(i) - bias); 
end
aks_tot = aks_tot / 1000 * 9.81 % Konverter til [m/s^2]
falltid = (6307-6163)/205 % Falltid i [s]
hastigheit_tot = aks_tot * falltid % Normaliser til [m/s]
fallhogde = hastigheit_tot / 205 % Må dele på samplinsraten av ein eller annan grunn


%%
% Eventuelt

bias_start = 307;
bias_stopp = 4721;

fall_start = 6300;
fall_stopp = 7000;


% Rekne ut bias til akselerometer

bias = sum(data.Akselerasjon(bias_start:bias_stopp)) / (bias_stopp- bias_start)

aks_tot = 0;
for i=fall_start:fall_stopp
    aks_tot = aks_tot + (data.Akselerasjon(i) - bias); 
end
aks_tot = aks_tot / 1000 * 9.81 % Konverter til [m/s^2]
snitt_aks = aks_tot / (fall_stopp-fall_start)
falltid = (fall_stopp-fall_start)/(length(data.Akselerasjon)/120) % Falltid i [s]
fallhogde = snitt_aks * falltid^2 % [m]

% v = zeros(fall_stopp-fall_start,1);
% for i=fall_start:fall_stopp
%     if(i > fall_start)
%         v(i-fall_start+1) = (v(i-fall_start) + (data.Akselerasjon(i) - bias)) / 1000 * 9.81; 
%     else
%         v(i-fall_start+1) = (data.Akselerasjon(i) - bias) / 1000 * 9.81; 
%     end
% end
% figure
% plot(v)

figure
aks_norm = (data.Akselerasjon - bias) / 1000*9.81; %(fall_start:fall_stopp)
cumtrapz(aks_norm);
plot(ans)
hold on
plot(aks_tot)
hold off

%%
% Frekvensspektrum analyse

fall_start = 6200;
fall_stopp = 7000;

%Time specifications:
duration = 120;                  % seconds
Fs = length(data.Akselerasjon) / duration;     % samples per second
dt = 1/Fs;                     % seconds per sample

t = (fall_start*dt:dt:fall_stopp*dt-dt)';
N = size(t,1);

%Fourier Transform:
X = fftshift(fft(data.Akselerasjon(fall_start:(fall_stopp-1))));

%Frequency specifications:
dF = Fs/N;                      % hertz
f = 0:dF:Fs/2-dF;               % området eg vil plotte [Hz]

%Plot the spectrum:
figure;
plot(f,abs(X(N/2+1:end))/N);
xlabel('Frequency (in hertz)');
title('Magnitude Response');
