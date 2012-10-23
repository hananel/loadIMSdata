function plotMaxWindMap(stations,directory)
% creats a contour map of the time for maximum wind speed
% two flavors:
% 1. irelevant of station charestraistics
%    a. according to maximum occurance
%    b. according to the maximum of a gaussian fit.
% 2. adds a map of maximum wind speeds (should i take the 3TIER data?? maybe.)
%    can be just a color map - I ould finally learn to "sample" the color and produce wind speed! perhaps. 
%    That will be the most logical thing to do.

more off;
tic;

months = {'January','February','March','April','May','June','July','August','September','October','November','December'};
col = jet(12);
count = 0;
tic
if 1 %checker
    for station=stations
    
        % open METADATA.csv (TODO - change to xls, from matlab) and look up station data
        count
        meta = loadMeta(station);
        
        % checking if there's an anemometer
        if not(or(strcmp(meta.anemometer,'No'),meta.h(2)==-1))
            count = count + 1;
            stationNum(count) = station;
            pathname = [directory,'/IMS-data/STATIONS DATA/',meta.name,'/',meta.name,'/'];
            matFile = [pathname, 'Data_',num2str(station),'.mat'];

            % loading workspace
            disp('loading matFile')
            load(matFile);
        
            % saving long,lat and name vector
            long(count) = meta.long;
            lat(count) = meta.lat;
            name{count} = meta.name;
        
            % diurnal plot for each month
            dailyAvgTime = 1/6; % [hr]
            tDaily = 0:dailyAvgTime:24;
            M = length(tDaily)-1;
            hTot = mi/60+h;     % hour time vector
        
            for month=1:12
                disp(sprintf('Station number %d, for %s',station,months{month}));
                for i=1:length(tDaily)-1
                    loc = find(and(hTot>=tDaily(i),hTot<=tDaily(i+1),m==month));
                    UDaily(month,i) = nanmean(U(loc));
                end
            
                % 1a method: finding maximum in each month
                % can replace with mode
                [maxU(month,count),loc] = max(UDaily(month,:));
                maxTime(month,count) = tDaily(loc);
                
                % 1b method: fitting gaussian
                dataFractionHeight = 0.2; % height fraction of data to fit to gaussian
                dT=8;
                fitTimeVec = (tDaily(loc)-dT): dailyAvgTime:(tDaily(loc)+dT);
                fitUVec = interp1(tDaily(1:end-1),UDaily(month,:),fitTimeVec);
                [sig,mu,A] = mygaussfit(fitTimeVec,fitUVec,dataFractionHeight);
                maxTimeGauss(month,count) = mu;
                if or(mu>24,mu<0)
                    dT = 3;
                    fitTimeVec = (tDaily(loc)-dT): dailyAvgTime:(tDaily(loc)+dT);
                    fitUVec = interp1(tDaily(1:end-1),UDaily(month,:),fitTimeVec);
                    [sig,mu,A] = mygaussfit(fitTimeVec,fitUVec,dataFractionHeight)
                    maxTimeGauss(month,count) = mu;
                end
                maxUGauss(month,count) = A;
                maxSigmaGauss(month,count) = sigma;
                disp(sprintf('MaxWindTime = %g/%g (guass)/(mode)',mu,maxTime(month,count)));
                % debug
                if or(mu>24,mu<0)
                    gausx = A*exp( -(fitTimeVec-mu).^2./2./sig.^2 ); 
                    figure(station); hold on;
                    plot(tDaily(1:end-1),UDaily(month,:),'k');
                    plot(maxTime(month,count), maxU(month,count),'*')
                    plot(maxTimeGauss(month,count),maxUGauss(month,count),'or')
                    plot(fitTimeVec,gausx,'r')
                end

            end
        end
    end
    save('ContourData.mat');
else
    load('ContourData.mat');
end
toc
% plotting
disp('Plotting')
% lat plots
figure(1); hold on;
for month=1:12
    stationPlot = plot(lat,maxTimeGauss(month,:)/24,'o','color',col(month,:));
    set(stationPlot,'markersize',10,'markerfacecolor',col(colLocation,:))
end
axis([min(lat),max(lat),0,1]);
set(gca,"ytick",[0,0.25,0.5,0.75,1])
datetick('y',15,'keeplimits','keepticks');
xlabel('Latitude'); ylabel('Time')
legend(months,'location','eastoutside')
title('Latitude vs. maximum wind speed time')
print('DiurnalMaxWindTime.pdf','-append') 
% long plot
figure(2); hold on;
for month=1:12
    stationPlot = plot(long,maxTimeGauss(month,:)/24,'o','color',col(month,:));
    set(stationPlot,'markersize',10,'markerfacecolor',col(colLocation,:))
end
axis([min(long),max(long),0,1]);
set(gca,"ytick",[0,0.25,0.5,0.75,1])
datetick('y',15,'keeplimits','keepticks');
xlabel('Longtitude'); ylabel('Time')
legend(months,'location','eastoutside')
title('Latitude vs. maximum wind speed time')
print('DiurnalMaxWindTime.pdf','-append') 

% contour plots
N = 100;
col = hsv(N);
x = linspace(min(lat),max(lat),N);
y = linspace(min(long),max(long),N);
[X,Y] = meshgrid(x,y);
rangeZ = linspace(0,24,N);
save('ContourData.mat');

for month=1:12
    % raw data
    figure(month+5);
    
    subplot(121); hold on; 
    
    for i=1:length(lat)
        % adding plot of the actual measurements with the same color scale
        colLocation = find(linspace(0,24,100)>=maxTimeGauss(month,i),1);
        stationPlot = plot(long(i),lat(i),'o','color',col(colLocation,:));
        set(stationPlot,'markersize',12,'markerfacecolor',col(colLocation,:))
    end
    set(gca,'xtick',[34.5,35,35.5])
    title(['Maximum wind speed time - station data for ',months{month}]);
    xlabel('Latitude'); ylabel('Longtitude')
    plotIsraelBorders
    axis tight;
    % add text of average time per longtitude area (+ std in that area)
    % areas are (determined according to high wind speed areas)
    IsrN = [32.5,33.3];
    IsrM = [31,32.5];
    IsrS = [29.5,30];
    stationN = find(and(lat>=IsrN(1),lat<=IsrN(2)));
    stationM = find(and(lat>=IsrM(1),lat<=IsrM(2)));
    stationS = find(and(lat>=IsrS(1),lat<=IsrS(2)));
    avgN(month) = nanmean(maxTimeGauss(month,stationN));
    stdN(month) = nanstd(maxTimeGauss(month,stationN));
    avgM(month) = nanmean(maxTimeGauss(month,stationM));
    stdM(month) = nanstd(maxTimeGauss(month,stationM));
    avgS(month) = nanmean(maxTimeGauss(month,stationS));
    stdS(month) = nanstd(maxTimeGauss(month,stationS));
    txtN = [num2str(round(avgN(month)-stdN(month)),2),':00-',num2str(round(avgS(month)+stdN(month)),2),':00'];
    txtM = [num2str(round(avgM(month)-stdM(month)),2),':00-',num2str(round(avgS(month)+stdM(month)),2),':00'];
    txtS = [num2str(round(avgS(month)-stdS(month)),2),':00-',num2str(round(avgS(month)+stdS(month)),2),':00'];
    ax = get(gcf); 
    set(ax.children,'position',[0.05000   0.11000   0.43466   0.81500]);
    set(ax.children,'xlim',[33.5   35.892]);
    text(33.7,33,txtN);
    text(33.7,31.8,txtM);
    text(33.7,29.7,txtS);
    plot([33.5,34.5],[IsrN(2),IsrN(2)],'b','linewidth',4)
    plot([33.5,34.5],[IsrN(1),IsrN(1)],'b','linewidth',4)
    plot([33.5,34.5],[IsrM(2),IsrM(2)],'r','linewidth',4)
    plot([33.5,34.2],[IsrM(1),IsrM(1)],'r','linewidth',4)
    plot([33.5,34.5],[IsrS(2),IsrS(2)],'g','linewidth',4)
    plot([33.5,34.5],[IsrS(1),IsrS(1)],'g','linewidth',4)

    % contour data
    subplot(122);
    plotIsraelBorders
    Z=griddata(lat,long,maxTimeGauss(month,:),X,Y);
    [c,hh] = contour(Y,X,Z,5);
    caxis([0,24])
    set(gcf,'colormap',hsv)
    set(gca,'xtick',[34.5,35.1,35.7])
    title('Contour')
    xlabel('Latitude'); ylabel('Longtitude')
    g = colorbar;
    set(g,'ytick',[0,6,12,18,24])
    set(g,'yticklabel',{'00:00','06:00','12:00','18:00','24:00'})
    print('DiurnalMaxWindTime.pdf','-append') 
end

save('ContourData.mat');

end

function state = checker;
if isempty(dir('ContourData.mat')) state=1;
else state=0;
end

end
