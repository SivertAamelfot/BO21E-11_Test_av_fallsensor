classdef Falldata
    properties
        Filnavn
        Fallhogde
        Steg
        Type_demping
        Tjukkelse_demping
        Data
        Fall
        Akselerasjon
        Akselerasjon_filt
        Hogde
    end
    
    methods
        function obj = Falldata()
            obj.Filnavn = "";
            obj.Fallhogde = 0;
            obj.Steg = 0;
            obj.Type_demping = "";
            obj.Tjukkelse_demping = 0;
            obj.Fall = 0;
            obj.Data = [];
            % obj.Data_filtrert = {};
        end
              
        function obj = LoggingFerdig(obj)
            % Brukast når logging er ferdig
            % INPUTS: Objekt av datatypen 'Falldata'
            % OUTPUTS: Returnerer input med endra datamedlem. Setter felta
            % Akselerasjon (og _filtrert), Fall og Hogde
            
            % Finner og lagrer absoluttverdien av akselerasjon
            Ax=obj.Data(:,1);
            Ay=obj.Data(:,2);
            Az=obj.Data(:,3);
            A_tot = sqrt(Ax.^2+Ay.^2+Az.^2);
            obj.Akselerasjon = A_tot;
            % Lavpassfiltrert akselerasjon
            [A_tot_lp, ~, ~] = butterfiltfilt(A_tot, 10, 200, 2, 'lowpass', 'both');
            obj.Akselerasjon_filt = A_tot_lp;
            
            % Vurderer om det var fall på bakgrunn av vibrasjoner fra
            % klokka
            knapp = obj.Data(:,5);
            knapp_lav = find(~knapp,1); % Første sample der knappen er lav
            
            % Har valgt nokre tilfeldige verdier som indikerer om fall har
            % oppstått. 900/1100mg, dvs. 1g +- 0.1g
            if(~isempty(A_tot(A_tot(knapp_lav+3000:end)<900 | A_tot(knapp_lav+3000:end)>1100)))
                obj.Fall = true;
            else
                obj.Fall = false;
            end
            
            % Rekner ut høgde i forhold til havnivå. Den absolutte verdien
            % er ikkje av interesse, men heller den relative forskjellen
            % (sjølve fallet på ca. 1m)
            trykk_havnivaa = 101325;
            P = obj.Data(:,4);
            obj.Hogde = P;
            
            for i=1:length(P)
                obj.Hogde(i) = 44330.0 * (1.0 - (P(i)/trykk_havnivaa )^0.1903);
            end
            
        end
        
        function obj = LastData(obj, path, file)
            % INPUT: Filsti- og navn på fila du ønsker å laste inn.
            % OUTPUT: Eit objekt med data frå fila.
            
            try
                S = load(strcat(path, file));
                lagraNavn = string(fieldnames(S));
                obj = S.(lagraNavn);
                
            catch ME
                disp(strcat('Feil: ', ME.message))
            end
        end % LastData
       
        
    end % methods  
end % classdef