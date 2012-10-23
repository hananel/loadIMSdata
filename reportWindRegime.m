% Project: GreenBuildingCFD
% purpose: use IMS data (or more data when available) to gather the closest 3 stations and present their wind rose, histogram and diurnal cycle for 4 months a year.
% usage: reportWindRegime(lat0,long0,stationNum,Ulimit)

function reportWindRegime(lat0,long0,stationNum,Ulimit)
% returns basic wind regime for lat,long from 3 closest stations
% as a pdf report and png graphs, and data in struct s

global dataDirectory
dataDirectory = '/home/hanan/Documents/measurements'
global resultsDirectory
resultsDirectory = '/home/hanan/Documents/measurements';
debug_on_warning(0);
debug_on_error(0);
more off;
close all;

% wind rose difinition
roseDir = [0:10:350]';

% 1
% 
% finding closest 3 stations and plotting their location and distance from the point

% loading meta
meta = loadMeta;

% plotting all stations
figure(100);

% zoom out plot - all of Israel
subplot(2,2,[1,3]);
plotIsraelBorders
axis tight; hold on;
g = plot(long0,lat0,'or','markersize',6);
set(g,'markerfacecolor','r')
ax = get(gcf); 
set(ax.children,'position',[0.05000   0.11000   0.43466   0.81500]);
set(ax.children,'xlim',[33.5   35.892]);
for i=1:length(meta)
    % checking for anemometer
    yesAnemometer = not(or(strcmp(meta(i).anemometer,'No'),meta(i).h(2)==-1));
    if yesAnemometer
        text(meta(i).long,meta(i).lat,num2str(meta(i).num),'color','g');
        % building distance vector
        distance(i) = haversine(meta(i).lat,meta(i).long,lat0,long0);
    else
        text(meta(i).long,meta(i).lat,num2str(meta(i).num),'color','b');
        distance(i) = 999;
    end

end    

% sorting to find closest stations
distanceOrig = distance;
[distance,stations] = sort(distance);

for i=1:stationNum
    text(meta(stations(i)).long,meta(stations(i)).lat,num2str(meta(stations(i)).num),'color','r','fontweight','bold')
    plot([long0 meta(stations(i)).long],[lat0 meta(stations(i)).lat],'r');
end 
xlabel('longitude [deg]'); ylabel('latitude [deg]'); title('IMS stations');

% zoom in plot
zoomDistance = 0.3; % [deg]
ax = subplot(2,2,4);
plotIsraelBorders
axis tight; hold on;
g = plot(long0,lat0,'or','markersize',6);
set(g,'markerfacecolor','r')
for i=1:length(meta)
    % checking if the station is within the zoom area
    yesZoom = distanceOrig(i)<(0.75*haversine(lat0,long0,lat0+zoomDistance,long0+zoomDistance));
    % checking for anemometer
    yesAnemometer = not(or(strcmp(meta(i).anemometer,'No'),meta(i).h(2)==-1));
    if yesZoom
        if yesAnemometer
            text(meta(i).long,meta(i).lat,num2str(meta(i).num),'color','g');
        else
            text(meta(i).long,meta(i).lat,num2str(meta(i).num),'color','b');
        end
    end
end 

% finding the first stationNum stations
for i=1:stationNum
    text(meta(stations(i)).long,meta(stations(i)).lat,num2str(meta(stations(i)).num),'color','r','fontweight','bold')
    plot([long0 meta(stations(i)).long],[lat0 meta(stations(i)).lat],'r');
end 
xlabel('longitude [deg]'); ylabel('latitude [deg]'); title('Zoom in on close stations');
axis([long0-zoomDistance long0+zoomDistance lat0-zoomDistance lat0+zoomDistance])

% report of location of closest 3 stations
subplot(2,2,2);
axis([0 1 0 1],'off');
text(-0.1,0.9,['For location ',num2str(long0,4),'/',num2str(lat0,4)]);
text(-0.1,0.8,['The closest ',num2str(stationNum),' meteorological stations with ']);
text(-0.1,0.7,'long term wind data are:');
for i=1:stationNum
    text(-0.1,0.5-i*0.15,[num2str(meta(stations(i)).num),': ',meta(stations(i)).name,' ', num2str(distance(i),2),' km away']);
    text(-0.1,0.5-i*0.15-0.1,['with anemometer at ', num2str(meta(stations(i)).h(2)), ' meter']);
end

% print report
reportDirectory = ['lat_',num2str(lat0,4),'_long_',num2str(long0,4)];
reportDirectoryOld = reportDirectory;
mkdir(resultsDirectory,reportDirectory);
print([resultsDirectory,'/',reportDirectory,'/IMS_stations_near_long_', num2str(long0,4),'_lat_',num2str(lat0,4),'.png']);

% 2
%
% loading station data and submitting report for each
% TODO - at the moment this is for the average day of each month. should be representative enough, but I should compare to IMS publications.
disp(['report for ',num2str(stationNum),' stations'])
metaAll = meta;
resultsDirectoryOld = resultsDirectory;
if nargin>3
    % comparison to maximum winter (february 2010) and summer (august 2010) consumption
    % loading IEC consumption trend
    dat = csvread('/Users/hananlevy/src/WindEngineering/WindDataProcessing/IECdata/IsraelDiurnalConsumptionMaximum.csv');
    IECh = dat(:,1); IECw = dat(:,2)/max(dat(:,2)); IECs = dat(:,3)/max(dat(:,3));
    % winter energy
    figure(5001); hold on; plot(IECh/24,IECw,'k','linewidth',4);
    set(gca,"xtick",[0,0.25,0.5,0.75,1])
    set(gca,'fontsize',14)
    xlabel('Hour'); ylabel('normalized power'); 
    axis([0,1,0,1])
    datetick('x',15,'keeplimits','keepticks');
    % winter wind speed
    figure(5002); hold on; plot(IECh/24,IECw,'k','linewidth',4);
    set(gca,"xtick",[0,0.25,0.5,0.75,1])
    set(gca,'fontsize',14)
    xlabel('Hour'); ylabel('normalized power/wind speed'); 
    axis([0,1,0,1])
    datetick('x',15,'keeplimits','keepticks');
    % summer energy
    figure(5003); hold on; plot(IECh/24,IECs,'k','linewidth',4);
    set(gca,"xtick",[0,0.25,0.5,0.75,1])
    set(gca,'fontsize',14)
    xlabel('Hour'); ylabel('normalized power'); 
    axis([0,1,0,1])
    datetick('x',15,'keeplimits','keepticks');
    % summer wind speed
    figure(5004); hold on; plot(IECh/24,IECs,'k','linewidth',4);
    set(gca,"xtick",[0,0.25,0.5,0.75,1])
    set(gca,'fontsize',14)
    xlabel('Hour'); ylabel('normalized power/wind speed'); 
    axis([0,1,0,1])
    datetick('x',15,'keeplimits','keepticks');
end
legendText = {};
colOld = rainbow(12);
dataDirectoryOld = dataDirectory;
for Num=stations(1:stationNum)
    % load data
    pathname = [dataDirectory,'/IMS-data/STATIONS DATA/',metaAll(Num).name,'/',metaAll(Num).name,'/'];
    matFile = [pathname, 'Data_',num2str(Num),'.mat'];
    disp('loading matFile')
    % clearing UMonthly
    if exist('Umonthly')
        clear Umonthly;
    end
    load(matFile);
    col = colOld; dataDirectory = dataDirectoryOld;
    reportDirectory = reportDirectoryOld;
    resultsDirectory = resultsDirectoryOld;
    M = length(tDaily)-1;
    % make station directory
    stationDirectory = strrep(meta.name,' ','');
    mkdir([resultsDirectory,'/',reportDirectory],stationDirectory); 
    legendText = {legendText{:},meta.name}

    %
    % TODO this has been disabled after trial in the week af the 15/4/12 - if not relevant - remove.
    %
    % calculating (if it hasn't been done already) the following:
    % 1. monthly average variation with sdt
    % 2. monthly data set for wind rose - 
    % make sure the averaging of the "avg day per month" isn't too restrictive on the results
    if 0 %not(exist('UMonthly'))
        Umonthly = []; directionmonthly = []; 
        monthlyAvgTime = 1/6; % [hr]
        for month=1:12
            if sum(month==[2,4,6,9,11])>0
                if month==2
                    daysPerMonth = 28;
                else
                    daysPerMonth = 30;
                end
            else
                daysPerMonth = 31;
            end
            tMonthly = 0:monthlyAvgTime:(24*daysPerMonth);
            M = length(tMonthly)-2;
            for i=1:M
                loc = [];
                for year=min(y):max(y)
                    loct = find(and(t>=datenum(year,month,d(i),h(i),mi(i)),t<datenum(year,month,d(i+1),h(i+1),mi(i+1))));
                    loc = [loc,loct];
                end
                UMonthly(month,i) = nanmean(U(loc));
                
                %UStdMonthly(month,i) = nanstd(U(loc));
                %directionMonthly(month,i) = nanmean(direction(loc));

                % unAveraged monthly combined
                %Umonthly(month,end+1:end+length(loc)) = U(loc);
                %directionmonthly(month,end+1:end+length(loc)) = direction(loc);
                
                directionStdMonthly(month,i) = nanstd(direction(loc));
                TDaily(month,i) = nanmean(T(loc));
                RHDaily(month,i) = nanmean(RH(loc));
                disp(datestr(t(loc(1))))
            end
        end
        % save with new data
        save(matFile);
    end
    % calculating average yearly data - by a running average filter
    % first connecting the month time line
    %UYear = []; 
    for i=1:12
        %UYear = [UYear,UMonthly(i,:)];
        um(i) = nanmean(U(find(m==i)));
        ustd(i)=nanstd(U(find(m==i)));
    end
    %tYear = 0:monthlyAvgTime:((length(UYear)-1)*monthlyAvgTime);
    % running average TODO - not used at the moment
    %wndw = length(UYear)/24; % every half month
    %output1 = filter(ones(wndw,1)/wndw, 1, UYear); % problem with start and end - no speacial tratment
    
    M = length(tDaily)-1;
    totalHours = 0;

    % plotting diurnal and wind rose for 4 representative months
    sprintf('average wind speed is %g\n',nanmean(U))
    for month=[1,4,7,10]% winter - January
        
        figure(month+12*Num); 
        ax = errorbar(tDaily(1:M)/24,UDaily(month,1:M),UStdDaily(month,1:M));
        set(ax,'color',col(month,:))
        set(gca,"xtick",[0,0.25,0.5,0.75,1])
        title([{'Inter annual monthly average diurnal wind speed [m/s]'},{[meta.name ' , ', monthString{month}]}]);
        xlabel('Hour'); ylabel('U [m/s]'); 
        axis([0,1,0,nanmax(nanmax(UDaily)+nanmax(UStdDaily))])
        datetick('x',15,'keeplimits','keepticks');
        
        if nargin>3
            if and(month==1,nanmean(U)>Ulimit)
                % plot comparison to peak winter electricity consumption - normalized power vs power
                EDaily = UDaily(month,1:M).^3; EDaily = EDaily/max(EDaily);
                if Num>9 keyboard; end
                figure(5001); hold on; plot(tDaily(1:M)/24,EDaily,'color',col(Num,:),'linewidth',4);        
                figure(5002); hold on; plot(tDaily(1:M)/24,UDaily(month,1:M)/max(UDaily(month,1:M)),'color',col(Num,:),'linewidth',4); 
            end
            if and(month==7,nanmean(U)>Ulimit)
                % plot comparison to peak summer electricity consumption - normalized power vs power
                EDaily = UDaily(month,1:M).^3; EDaily = EDaily/max(EDaily);
                figure(5003); hold on; plot(tDaily(1:M)/24,EDaily,'color',col(Num,:),'linewidth',4);        
                figure(5004); hold on; plot(tDaily(1:M)/24,UDaily(month,1:M)/max(UDaily(month,1:M)),'color',col(Num,:),'linewidth',4);
            end
        end
        
        % print
        print([resultsDirectory,'/',reportDirectory,'/',stationDirectory,'/Diurnal_month_', monthString{month},'.png']);
        
        figure(200+month+12*Num); close all;
        % plotting wind rose
        title(['wind rose from ',meta.name, ' for ', monthString{month}]);
        axis off
        % rotating by 180 degrees to get the direction of comming wind instead the vector pointer as 
        % recorded by data logger. Additionally using the meteo flag, since the 0 is north (rather then 
        % east as in a cartesian axis system). This was verified against the IMS climate analysis for some 
        % stations (Shani and Sede Boqer from the 2003 southern wind atlas)
        [handles, data, Ag] = wind_rose(direction(find(m==month))+180,U(find(m==month)),'dtype','meteo');

        % print
        print([resultsDirectory,'/',reportDirectory,'/',stationDirectory,'/Rose_month_', monthString{month},'.png'],'-dpng');
        
    end
    

    % wind rose of all year, calculating for simulation input parameters
    figure(1000); close all;
    title(['wind rose from ',meta.name, ' for ', datestr(t(1)), ' to ' , datestr(t(end))]);
    axis off;
    [handles, data, Ag] = wind_rose(direction+180,U,'dtype','meteo','di',0:25);
    disp('wind rose data')
    disp(data)
    
    clf
    % plotting wind rose (a nicer configuration)
    title(['wind rose from ',meta.name, ' for ', datestr(t(1)), ' to ' , datestr(t(end))]);
    axis off;
    wind_rose(direction+180,U,'dtype','meteo');
    print([resultsDirectory,'/',reportDirectory,'/',stationDirectory,'/WindRose.png'],'-dpng');
    % 3
    %
    % report and text file creation for OpenFOAM input
    %
    % The necassery cases:
% נקבעים בהתאם לנוחות יחסית
% מתוך פרק 5.1  "תכנון ביו-אקלימי רוח" - 
% לפי שכיחות כיווני הרוחות יקבעו מספר הסימולציות
% סביר להניח שסימולציה במהירות רוח כלשהיא (10 מטר לשניה נאמר) תספק, כדי לקבל מקדם הגברה. אבל בתור התחלה יבדקו 2 מהירויות רוח - אחת מהן מן הסתם תהיה זו שמתאימה לשכיחות של הכיוון).
%                   
    % מה זה "כיווני הרוחות הרצויים והלא רצויים??"                      
    %
    % simplified rectengular domain plot
    % cases:
    % * bin direction into 22.5 degrees and get direction histogram
    
    fid = fopen([resultsDirectory,'/',reportDirectory,'/',stationDirectory,'/CaseReport.txt'],'a+');
    fprintf(fid,'\ndata from %s to %s, total of %f years',datestr(t(1)),datestr(t(end)),round((t(end)-t(1))/365*100)/100)
    fprintf(fid,'\n**********************\n')
    fprintf(fid,'The following cases should be examined in the order of occurance:\n');
    
    
    for Vi=length(Ag):-1:2
        % sorting wind rose
        [s,index] = sort(data(:,Vi-1),'descend');
        occuranceMoreThen0 = 1;
        counter = 1;
        fprintf(fid,'\nwind speed bin %2.1f-%2.1f\n',Ag(Vi-1),Ag(Vi));
        disp(sprintf('\nwind speed bin %2.1f-%2.1f',Ag(Vi-1),Ag(Vi)));
        while occuranceMoreThen0
            if counter>length(s)
                occuranceMoreThen0=0; 
                break;
            end
            if s(counter)<0.1
                occuranceMoreThen0=0;
                hoursPerYear=0; 
            else
                hoursPerYear = s(counter)/sum(sum(data))*8760;
                fprintf(fid,'case %d direction %3.0f occurred for %4.0f hours per year\n',counter, roseDir(index(counter)),hoursPerYear);
                disp(sprintf('case %d direction %3.0f occurred for %4.0f hours per year',counter, roseDir(index(counter)),hoursPerYear));
                counter = counter + 1;
            end
            
            totalHours = totalHours + hoursPerYear;
        end
    end
    fclose(fid);
    % make sure it all adds up to 8760
    disp(sprintf('total hours per year for %s are %d',meta.name, totalHours));
    
    % avg. monthly wind speed
    figure(2000); clf
    monthNum = [datenum(0,1,15),datenum(0,2,15),datenum(0,3,15), ...
                datenum(0,4,15),datenum(0,5,15),datenum(0,6,15), ...
                datenum(0,7,15),datenum(0,8,15),datenum(0,9,15), ...
                datenum(0,10,15),datenum(0,11,15),datenum(0,12,15)];

    ax = errorbar(monthNum,um,ustd);
    set(gca,'xtick',monthNum)
    axis([monthNum(1)-monthNum(1)/2 monthNum(end)+monthNum(1)/2 0 max(um)+max(ustd)*1.2])
    datetick('x',4,'keeplimits','keepticks');
    xlabel('months'); ylabel('avg. U [m/s]');
    title(sprintf('average monthly wind speed during measurement\nduration and standard deviation'));
    print([resultsDirectory,'/',reportDirectory,'/',stationDirectory,'/Monthlyaverage.png'],'-dpng');
    
    % avg. yearly wind speed
    figure(3000); clf
    year = min(y) : max(y);
    Uy = []; meanU = nanmean(U);
    for i=1:length(year)
        ys = find(y==year(i),1,'first');
        ye = find(y==year(i),1,'last');
        Uy(i) = nanmean(U(ys:ye)-meanU)/meanU*100; % [percent]
    end
    
    plot(year,Uy); 
    xlabel('year'); ylabel('% difference'); title(['Average interanuual wind speed difference. Uavg = ', num2str(meanU) ,' [m/s]' ]);
    print([resultsDirectory,'/',reportDirectory,'/',stationDirectory,'/YearlyAverage.png'],'-dpng');
end

if nargin>3
    % finalyzing maximum consumption and production comparison
    legendText = {'Normalized electricity consumption', legendText{:}};
    figure(5001); a = legend(legendText,'location','south'); set(a,'fontsize',16)
    title('Comparison between winter peak electricity consumption and wind energy');
    print([resultsDirectory,'/',reportDirectory,'/',stationDirectory,'/ElectricityVsEnergyWinter.png'],'-dpng');
    figure(5002); a = legend(legendText,'location','south'); set(a,'fontsize',16)
    title('Comparison between winter peak electricity consumption and wind speed');
    print([resultsDirectory,'/',reportDirectory,'/',stationDirectory,'/ElectricityVsWindWinter.png'],'-dpng');
    figure(5003); a = legend(legendText,'location','south'); set(a,'fontsize',16)
    title('Comparison between summer peak electricity consumption and wind energy');
    print([resultsDirectory,'/',reportDirectory,'/',stationDirectory,'/ElectricityVsEnergySummer.png'],'-dpng');
    figure(5004); a = legend(legendText,'location','south'); set(a,'fontsize',16)
    title('Comparison between summer peak electricity consumption and wind speed');
    print([resultsDirectory,'/',reportDirectory,'/',stationDirectory,'/ElectricityVsWindSummer.png'],'-dpng');
end    

function d = haversine(lat1,lon1,lat2,lon2)
% a = sin²(Δlat/2) + cos(lat1).cos(lat2).sin²(Δlong/2)
% c = 2.atan2(√a, √(1−a))
% d = R.c
R = 6371; % km
dLat = (lat2-lat1)*pi/180;
dLon = (lon2-lon1)*pi/180;
lat1 = lat1*pi/180;
lat2 = lat2*pi/180;
a = (sin(dLat/2))^2 + (sin(dLon/2))^2 * cos(lat1) * cos(lat2); 
c = 2 * atan2(sqrt(a), sqrt(1-a)); 
d = R * c;

function makeReport(s)
% accepts structure s and creates pdf report and png graphs
