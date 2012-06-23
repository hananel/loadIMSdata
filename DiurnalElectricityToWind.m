function [stationVec,UmeanVec,hVec,AneVec,a1,a2,a3,a4] = DiurnalElectricityToWind(stationVec,Ulimit);
% returns basic wind regime for lat,long from 3 closest stations
% as a pdf report and png graphs, and data in struct s
global dataDirectory
dataDirectory = '/home/hanan/Documents/measurements/'
global resultsDirectory
resultsDirectory = '/home/hanan/Documents/measurements/';
debug_on_warning(0);
debug_on_error(0);
more off;
close all;
load stationMeta

% stationVec = [1,4,10,11,12,13,14,16,21,34,39,40,47,68,76,79,83];
% ZEFAT HAR KENAAN 9

% 2
%
% loading station data and submitting report for each
% TODO - at the moment this is for the average day of each month. should be representative enough, but I should compare to IMS publications.

metaAll = loadMeta;

% comparison to maximum winter (february 2010) and summer (august 2010) consumption
% loading IEC consumption trend
dat = csvread('/home/hanan/Documents/src/WindEngineering/WindDataProcessing/IECdata/IsraelDiurnalConsumptionMaximum.csv');
IECh = dat(:,1); IECw = dat(:,2)/max(dat(:,2)); IECs = dat(:,3)/max(dat(:,3));
% winter energy
figure(5001); hold on; 
set(gca,"xtick",[0,0.25,0.5,0.75,1])
set(gca,"ytick",[0,1])
set(gca,'fontsize',14)
xlabel('Hour'); ylabel('normalized power'); 
axis([0,1,0,1])
datetick('x',15,'keeplimits','keepticks');
% winter wind speed
figure(5002); hold on; 
set(gca,"xtick",[0,0.25,0.5,0.75,1])
set(gca,"ytick",[0,1])
set(gca,'fontsize',14)
xlabel('Hour'); ylabel('normalized power/wind speed'); 
axis([0,1,0,1])
datetick('x',15,'keeplimits','keepticks');
% summer energy
figure(5003); hold on; 
set(gca,"xtick",[0,0.25,0.5,0.75,1])
set(gca,"ytick",[0,1])
set(gca,'fontsize',14)
xlabel('Hour'); ylabel('normalized power'); 
axis([0,1,0,1])
datetick('x',15,'keeplimits','keepticks');
% summer wind speed
figure(5004); hold on; 
set(gca,"xtick",[0,0.25,0.5,0.75,1])
set(gca,"ytick",[0,1])
set(gca,'fontsize',14)
xlabel('Hour'); ylabel('normalized power/wind speed'); 
axis([0,1,0,1])
datetick('x',15,'keeplimits','keepticks');
legendText = {};
stationNum = 0;

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
figure(1); plotStationLocations(stationVec,col)

for Num=stationVec
    stationNum = stationNum + 1;
    % load data
    pathname = [dataDirectory,'/IMS-data/STATIONS DATA/',metaAll(Num).name,'/',metaAll(Num).name,'/'];
    matFile = [pathname, 'Data_',num2str(Num),'.mat'];
    if exist(matFile)
        disp(['loading ', metaAll(Num).name , ' matFile'])
        load(matFile);
        % col gets run over by matFile
        col = jet(length(stationVec));
        M = length(tDaily)-1;
        totalHours = 0;
        % plotting diurnal and wind rose for 4 representative months
        temp = meta.h;
        hVec(Num) = temp(1); AneVec(Num) = temp(2);
        disp(sprintf('average wind speed in %s is %g\n',meta.name,UmeanVec(Num)))
        legendText = {legendText{:},meta.name};
        % plot comparison to peak winter electricity consumption - normalized power vs power
        EDaily = UDaily(1,1:M).^3; EDaily = EDaily/max(EDaily);
        figure(5001); hold on; plot(tDaily(1:M)/24,EDaily,'color',col(Num,:));        
        figure(5002); hold on; plot(tDaily(1:M)/24,UDaily(1,1:M)/max(UDaily(1,1:M)),'color',col(Num,:)); 
        Ew(Num,:) = EDaily;
        % plot comparison to peak summer electricity consumption - normalized power vs power
        EDaily = UDaily(7,1:M).^3; EDaily = EDaily/max(EDaily);
        figure(5003); hold on; plot(tDaily(1:M)/24,EDaily,'color',col(Num,:));        
        figure(5004); hold on; plot(tDaily(1:M)/24,UDaily(7,1:M)/max(UDaily(7,1:M)),'color',col(Num,:));
        Es(Num,:) = EDaily;

    end
end

% finalyzing maximum consumption and production comparison
figure(5003);
[NIPDailyNorm_summer,NIPDailyNorm_winter,tDailyS, ax] = loadIMSradiation(75,5003,dataDirectory,1);
plot(IECh/24,IECs,'k','linewidth',4);
legendTextSol = {legendText{:},'Noarmalized Solar radiation - Sede Boqer','Normalized electricity consumption'};
a3 = legend(legendTextSol,'location','northwest'); set(a3,'fontsize',16)
title('Summer peak electricity consumption, wind and solar energy in Israel');
print('ElectricityVsEnergySummer.png','-dpng');

legendText = {legendText{:},'Normalized electricity consumption'};
figure(5001); plot(IECh/24,IECw,'k','linewidth',4);
a1 = legend(legendText,'location','northwest'); set(a1,'fontsize',16)
title('Comparison between winter peak electricity consumption and wind energy');
print('ElectricityVsEnergyWinter.png','-dpng');
figure(5002); plot(IECh/24,IECw,'k','linewidth',4);
a2 = legend(legendText,'location','northwest'); set(a2,'fontsize',16)
title('Comparison between winter peak electricity consumption and wind speed');
print('ElectricityVsWindWinter.png','-dpng');
figure(5004); plot(IECh/24,IECs,'k','linewidth',4);
a4 = legend(legendText,'location','northwest'); set(a4,'fontsize',16)
title('Comparison between summer peak electricity consumption and wind speed');
print('ElectricityVsWindSummer.png','-dpng');

save comparison tDaily Ew Es IECh IECw IECs
% summing all up 
EsTot = sum(Es); EsTot = EsTot/max(EsTot);
EsMax = max(Es);
figure(5005); hold on; 
set(gca,"xtick",[0,0.25,0.5,0.75,1])
set(gca,"ytick",[0,1])
set(gca,'fontsize',14)
xlabel('Hour'); ylabel('normalized power'); 
axis([0,1,0,1])
datetick('x',15,'keeplimits','keepticks');
plot(IECh/24,IECs,'k','linewidth',4);
plot(tDaily(1:M)/24,EsTot,'b','linewidth',4);
plot(tDaily(1:M)/24,EsMax,'b');
% adding Sde Boquer radiation for July - to compare solar/wind/demand
[NIPDailyNorm_summer,NIPDailyNorm_winter,tDailyS, ax] = loadIMSradiation(75,5005,dataDirectory,1);
ax = plot(tDaily(1:M)/24,NIPDailyNorm_summer,'r-.','lineWidth',4)
a3 = legend({'Normalized electricity consumption','Average wind energy','Max wind energy','Noarmalized Solar radiation - Sede Boqer'},'location','northwest'); set(a3,'fontsize',16)
title('Solar,wind and consumption in peak summer Israel')
print('ElectricitySolarWindSummer_summary.png','-dpng');
