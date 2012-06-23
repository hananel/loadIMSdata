function [stationVec,UmeanVec,hVec,AneVec,a1,a2,a3,a4] = CapacityCreditWindIsrael(stationVec,Ulimit,plotme);
% calculates the Capacity credit for wind, solar and combined solar+wind.
% this is done by the load method:
% 1. A average load year is calculated from the 20 year data available from the IEC
% 2. The load data is ordered from high to low, and the sorting vector is saved.
% 3. The wind stations are chosen acording to minimum wind and location criterions
% 4. Each wind station is normalized to Katif data to give a 350 watt/m^2 energy density (or other values)
% 5. Each station is multiplied by a representative power curve of a big wind turbine of 1 Mw rated power
% 6. For each station The capacity factor for each percent of loads is calculaed by P_avg/P_rated and plotted
% 7. The average capacity credit of all ststions is summed to give an average station
% 8. The same is done for solar energy (only sde boker data)
% 9. The same is done for combined solar and wind (same rated power of both plants)

global dataDirectory
dataDirectory = '/home/hanan/Documents/measurements/'
global resultsDirectory
resultsDirectory = '/home/hanan/Documents/measurements/results/';
dataPath = '/home/hanan/Dropbox/MyPHDArticles/InProgress/IsraelDiurnalWind/YoelCohenData/';
months = {'January','February','March','April','May','June','July','August','September','October','November','December'};
windDataYearVec = 2006:2011;
CFper = NaN * ones(83,length(windDataYearVec),100);
debug_on_warning(0);
debug_on_error(0);
legendText={};
tY = 0:1/6:365*24; % [hour]
EWYIsrael = zeros(length(windDataYearVec),length(tY));
W = zeros(len(t));

more off;
close all;
set(0,'defaultaxesfontsize',20);
set(0,'defaulttextfontsize',20);

% 1. calculate average load year
[EnormYearly,tYearly,EdailyNorm] = averageIECyear(dataPath); %TODO - wierd number. 366 days??
% interpolating to a 10 minute time vector, for 365 days.
EnY = interp1(tYearly,EnormYearly,tY);

% 2. ordering the load data from high to low
[EnYsort,sortVector]=sort(EnY,'descend');

if plotme
    figure(15);
    subplot(1,2,1); set(gca,'fontsize',18)
    plot((1:length(EnYsort))/24/6/365*12,EnY,'k','LineWidth',3);
    set(gca,"xtick",[0:12]);
    set(gca,"ytick",[0 1])
    axis([0 12 0 1])
    xlabel('month'); ylabel('normalized load');
    title('typical yearly load')
    subplot(1,2,2)
    plot((1:length(EnYsort))/24/6/365*100,EnYsort,'k','LineWidth',3);
    set(gca,"xtick",[0 30 50 100]);
    set(gca,"ytick",[0 1])
    grid on;
    axis([0 100 0 1])
    xlabel('percent of maximum load'); ylabel('normalized load');
    title('sorted yearly load')
    print([resultsDirectory 'typicalLoadIEC_2011_2030.png'],'-dpng');   
end

% 3. choosing wind stations
% stationVec = [1,4,10,11,12,13,14,16,21,34,39,40,47,68,76,79,83];
% ZEFAT HAR KENAAN 9
load stationMeta
metaAll = loadMeta;

% finding the stations that are above Ulimit
stationVec = find(round(UmeanVec*10)/10>=Ulimit);
% throwing away zefat har kenan - the peak of july is very different from the rest, doesn't make sense
stationVec(find(stationVec==9))=[];
% throwing away coast stations
stationVec(find(stationVec==44))=[];
stationVec(find(stationVec==48))=[];
stationVec(find(stationVec==62))=[];
stationVec(find(stationVec==35))=[];
% throwing away bikaa stations
stationVec(find(stationVec==79))=[];
stationVec(find(stationVec==74))=[];
stationVec(find(stationVec==51))=[];
stationVec(find(stationVec==64))=[];
stationVec(find(stationVec==66))=[];
% adding Eilat station
stationVec(end+1) = 83;
col = jet(length(stationVec));
%figure(1); plotStationLocations(stationVec,col)

[V,P,Prated] = VestasV903Mw102db();

stationNum = 0;
stationVecOrig = stationVec;

for Num=stationVec
    Num
    stationNum = stationNum + 1;
    % load data (dataDirectory get's run over by load(matFile)
    dataDirectory = '/home/hanan/Documents/measurements/';
    resultsDirectory = '/home/hanan/Documents/measurements/results/';
    pathname = [dataDirectory,'/IMS-data/STATIONS DATA/',metaAll(Num).name,'/',metaAll(Num).name,'/'];
    matFile = [pathname, 'Data_',num2str(Num),'.mat'];
    if exist(matFile)
        disp(['loading ', metaAll(Num).name , ' matFile'])
        load(matFile);
        t = datenum(y,m,d,h,mi); % making sure this is ok

        % calculating and plotting data existance plot
        
        % 4. Normalizing power of stations to "normPower" watt/m^2 (Katif=390 W/m^2 @ 60 m)
        normFac = 0.5*1.2*nansum(U.^3)/length(U); % W/m^2
        normPower = 400; % W/m^2
        Unorm(1:length(U),Num) = U * (normPower/normFac)^(1/3);
        
        % 5. multiplying by 1 Mw power curve
        EWindnorm(1:length(U),Num) = interp1(V,P,Unorm(1:length(U),Num));
        
        % 6. the Capacity credit is calculated and plotted, for each year of data
        yearVec=unique(y)
        if length(yearVec)>7
            [y, m, d, h, mi, s] = datevec (t);
            yearVec=[unique(y)]';
            yearVec(yearVec==2012) = []
        end
        if plotme
            figure(33+Num);
            set(gcf,'name',meta.name)
        end
        sp1=2; sp2=3;
        if length(yearVec)>6
            sp1=3; sp2=3;
        end
        
        clear CFtemp CF50 CF30 Cor
        CFtemp = NaN*ones(1,length(windDataYearVec));
        CF50 = NaN*ones(1,length(windDataYearVec));
        CF30 = NaN*ones(1,length(windDataYearVec));
        Cor = NaN*ones(1,length(windDataYearVec));
        
        for year=yearVec
            keyboard;
            
            % Pout = zeros(len(t))
            % W = zeros(len(t))
            % for st_num in range(len(P)):
            %   ind = find(P[st_num] != -1)
            %   Wind = W[ind]
            %   Pout[ind] = Pout[ind] * Wind / (Wind + 1) + P[st_num, ind] / (Wind + 1)
            %   W[ind] += 1
    
            temp = EWindnorm(find(y==year),Num);
            EWindnormYear(1:length(temp),year-windDataYearVec(1)+1) = temp;
            % interpolating to tY
            tOneYearWind = t(find(y==year))-t(find(y==year))(1); %[day]
            EWnormY = interp1(tOneYearWind,EWindnormYear(1:length(temp),year-windDataYearVec(1)+1),tY/24);
            CF(Num,year-windDataYearVec(1)+1) = nansum(EWnormY)/length(EWnormY)/Prated;
            
            % point 7. summing all stations - for representing all Israel
            figure(999); hold on;
            plot(EWnormY)
            if isempty(EWYIsrael)
                EWYIsrael = zeros(length(windDataYearVec),length(EWnormY));
                EWYIsrael(year-windDataYearVec(1)+1,1:length(EWnormY)) = EWnormY;
            else
                nanloc = isnan(EWYIsrael(year-windDataYearVec(1)+1,1:length(EWnormY)));
                EWYIsrael(year-windDataYearVec(1)+1,nanloc) = 0;
                EWYIsrael(year-windDataYearVec(1)+1,1:length(EWnormY)) = EWYIsrael(year-windDataYearVec(1)+1,1:length(EWnormY)) + EWnormY;
            end

            % arranging the wind data in the sorted order of the load
            EWnormYsort = EWnormY(sortVector);
            % comparing for 1%-100% top loads
            
            for percent=1:100
                loc = round(24*365*percent/100*6); % the 6 factor is for the 1 hour resolution for the load data vs. the 10 minute wind data
                CFper(Num,year-windDataYearVec(1)+1,percent) = nansum(EWnormYsort(1:loc))/loc/Prated;
                tempCF(percent) = CFper(Num,year-windDataYearVec(1)+1,percent);
            end
            if plotme
                figure(33+Num); subplot(sp1,sp2,year-windDataYearVec(1)+1);  hold on;
                plot(1:100,tempCF,'.'); title(year); hold on;
                set(gca,"xtick",[0,30, 50, 100]);
                minCF = min(tempCF); maxCF = max(tempCF);
                if isinf(minCF)
                    minCF = 0;
                end
                if isinf(maxCF)
                    maxCF = 1;
                end    
                axis([0 100 minCF maxCF])
                % plotting 30% and 50% lines          
                plot([30 30],[0 1],'b')
                plot([50 50],[0 1],'r')
            end
            CFtemp(year-windDataYearVec(1)+1) = CF(Num,year-windDataYearVec(1)+1);
            CF50(year-windDataYearVec(1)+1) = tempCF(50);
            CF30(year-windDataYearVec(1)+1) = tempCF(30);
            
            % calculating correlation
            EWnormY(isnan(EWnormY)) = 0;
            Cor(year-windDataYearVec(1)+1) = corr(EWnormY,EnY);
        end
        for year=windDataYearVec
            if ~(yearVec==year)
                if plotme
                    subplot(sp1,sp2,year-windDataYearVec(1)+1);
                    axis off; box off;
                end
            end
        end
        
        if plotme
            subplot(sp1,sp2,sp1*sp2-1); xlabel(meta.name);
            print([resultsDirectory 'CCfull_', strrep(meta.name,' ',''),'.png'],'-dpng');
            
            % plotting yearly 30 and 50 markers, plus correlation
            figure(103+Num);
            set(gcf,'name',meta.name)
            plot(windDataYearVec,CFtemp,'k-^',windDataYearVec,CF50,'r-v',windDataYearVec,CF30,'b-+',windDataYearVec,Cor,'g-o');
            legend('CF','CC_{50}','CC_{30}','correleation');
            ylabel('Capacity Credit/Factor/correlation'); xlabel('year'); title(meta.name)
            set(gca,"xtick",yearVec);
            grid on;
            print([resultsDirectory 'CC_', strrep(meta.name,' ',''),'.png'],'-dpng');
             
            % sanity check - each months's daily profile (avg. over al years of data) comparisom to load
            figure(203+Num); hold on;
            set(gcf,'name',meta.name)
            for month=1:12
                subplot(4,3,month); hold on;
                plot(0:23,EdailyNorm(month,:),'k','LineWidth',3);
                EDailyNorm(month,:) = UDaily(month,:).^3/max(UDaily(month,:).^3);
                plot((0:143)/6,EDailyNorm(month,:),'r--','LineWidth',3)
                title(months(month))
                axis([0 24 0 1])
                if sum(month==[2,3,5,6,8,9])
                    axis off
                else if sum(month==[1,4,7])
                         set(gca,"xtick",[-100])
                         set(gca,"ytick",[0,1]);
                     else if sum(month==[11,12])
                            set(gca,"xtick",[0,12,24]);
                            set(gca,"ytick",[-100])
                         else
                            set(gca,"xtick",[0,12,24]);
                            set(gca,"ytick",[0,1]);
                         end
                     end
                end
            end
            subplot(4,3,11); xlabel(meta.name);
            print([resultsDirectory 'correlation_', strrep(meta.name,' ',''),'.png'],'-dpng');
        end
    end
end

% 7. average capacity credit for each year for all of Israel, including solar
% loading solar data
[NIPDailyNorm_summer,NIPDailyNorm_winter,tDailyS, ax, NIP, d,m,y,h,mi] = loadIMSradiation(75,5003,dataDirectory,0);

for year=windDataYearVec
    keyboard;
    figure(999)
    plot(EWYIsrael(year-windDataYearVec(1)+1,1:length(EWnormY)))
    % WIND DATA
    % normalizing
    EWnormYIsrael(year-windDataYearVec(1)+1,:) = EWYIsrael(year-windDataYearVec(1)+1,:)/max(EWYIsrael(year-windDataYearVec(1)+1,:));
    % sorting
    EWnormYIsraelSort = EWnormYIsrael(sortVector);
    % 8.
    % SOLAR DATA: doing the same for solar data
    % normalizing (same as above - all the 6 year meteorological data)
    NIPnorm = NIP/max(NIP);
    temp = NIPnorm(find(y==year));
    NIPnormYear(1:length(temp),year-windDataYearVec(1)+1) = temp;
    % interpolating to tY
    tOneYearWind = t(find(y==year))-t(find(y==year))(1); %[day]
    NIPnormY = interp1(tOneYearWind,NIPnormYear(1:length(temp),year-windDataYearVec(1)+1),tY/24);
    % sorting
    NIPnormYSort = NIPnormY(sortVector);
    % 9.
    % WIND+SOLAR DATA
    EWNIPYsort = NIPnormY + EWnormYIsrael;
    
    % plotting - sanity check
    figure(300); hold on; 
    set(gcf,'name','Israel sorted time line')
    subplot(3,6,year-windDataYearVec(1)+1);  hold on;
    plot(EWnormYIsraelSort,'k.')
    subplot(3,6,6+year-windDataYearVec(1)+1);  hold on;
    plot(NIPnormYSort,'r.')
    subplot(3,6,12+year-windDataYearVec(1)+1);  hold on;
    plot(EWNIPYsort,'b.')
    title(year)
    
    % calculating CC
    for percent=1:100
        loc = round(24*365*percent/100*6); % the 6 factor is for the 1 hour resolution for the load data vs. the 10 minute wind data
        % Israel wind
        CFperIsrael(year-windDataYearVec(1)+1,percent) = nansum(EWnormYIsraelSort(1:loc))/loc/Prated;
        % Israel solar
        CFperIsraelS(year-windDataYearVec(1)+1,percent) = nansum(NIPnormYSort(1:loc))/loc/Prated;
        % Israel wind+solar (same rated power for both)
        CFperIsraelSW(year-windDataYearVec(1)+1,percent) = nansum(EWNIPYsort(1:loc))/loc/Prated;
    end
    CFIsrael30(year-windDataYearVec(1)+1) = nanmean(CFperIsrael(year-windDataYearVec(1)+1,30));
    CFIsrael50(year-windDataYearVec(1)+1) = nanmean(CFperIsrael(year-windDataYearVec(1)+1,50));
    CFIsraelS30(year-windDataYearVec(1)+1) = nanmean(CFperIsraelS(year-windDataYearVec(1)+1,30));
    CFIsraelS50(year-windDataYearVec(1)+1) = nanmean(CFperIsraelS(year-windDataYearVec(1)+1,50));
    CFIsraelSW30(year-windDataYearVec(1)+1) = nanmean(CFperIsraelSW(year-windDataYearVec(1)+1,30));
    CFIsraelSW50(year-windDataYearVec(1)+1) = nanmean(CFperIsraelSW(year-windDataYearVec(1)+1,50));
end

% plotting
figure(400)
bar(windDataYearVec,CFIsrael30,'r',windDataYearVec,CFIsraelS30,'b',windDataYearVec,CFIsraelSW30,'k')
legend('Wind','Solar','Wind+Solar');
title('Israel 30% CC')

figure(401)
bar(windDataYearVec,CFIsrael50,'r',windDataYearVec,CFIsraelS50,'b',windDataYearVec,CFIsraelSW50,'k')
legend('Wind','Solar','Wind+Solar');
title('Israel 50% CC')
