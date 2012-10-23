function [tDaily,month,UDaily] = plotIMS(Num,dataDirectory)
% Hanan Einav Levy 25/2/2012
% Loading IMS wind measurements and displaying average and std. diurnal variation
% by month or season
% input : 
% Num - station number (as given in the METADATA file in the IMS disk)
%
% output : 
% t - diurnal time vector linspace(0,24,N)
% M - vector of months two which averaging applys
% V - matrix of average wind speed for each month over t time vector
% Vstd - same matrix, for standard deviation of velocity 

more off;
tic;
% open METADATA.csv (TODO - change to xls, from matlab) and look up station data
meta = loadMeta(Num)
% checking if there's an anemometer
if or(strcmp(meta.anemometer,'No'),meta.h(2)==-1)
    tDaily = zeros(144,1); month = 1:12; UDaily = zeros(12,144);
    return;
end

pathname = [dataDirectory,'/IMS-data/STATIONS DATA/',meta.name,'/',meta.name,'/'];
matFile = [pathname, 'Data_',num2str(Num),'.mat'];
if isempty(dir(matFile))
    % load data from station directory
    counter = 1;
    filenames = dir(pathname);
    for i=1:length(filenames)
        if or(~isempty(strfind(filenames(i).name,'csv')),~isempty(strfind(filenames(i).name,'CSV')))>0
            % read file
            DataFilename = [pathname filenames(i).name];
            disp(DataFilename)
            % find data format
            form = getFormat(DataFilename);
            
            % read only data lines
            fid = fopen(DataFilename,'r');
            condition = 1;
            while condition
                Line = fgetl(fid);
                % check if end of file
                if Line == -1
                    break;
                end
                % jump over empty lines and header lines
                if and(~isempty(Line),~isempty(str2num(Line(1))))  
                    s = readLine(Line,form);
                    d(counter) = s.d; 
                    m(counter) = s.m;
                    y(counter) = s.y; 
                    h(counter) = s.h; 
                    mi(counter) = s.mi;
                    Ugust(counter) = s.Ugust;
                    U(counter) = s.U;
                    direction(counter) = s.direction; 
                    directionStd(counter) = s.directionStd;
                    T(counter) = s.T; 
                    RH(counter) = s.RH;
                    disp(sprintf('%d/%d/%d %d:%d',y(counter),m(counter),d(counter),h(counter),mi(counter)));
                    counter = counter + 1;
                end
            end
            fclose(fid);
        end
    end    
    lengthTemp = i-1;
    if i==1
        disp(sprintf('problem with data'));
    end
    % saving workspace
    save(matFile)
    disp(['Reading ' DataFilename ' took ' num2str(toc) ' seconds'])
end
%%
% loading workspace
disp('loading matFile')
load(matFile);

% Parsing data
t = datenum(y,m,d,h,mi);
Ustd = (Ugust-U)/3; % not real std - assuming STD = (max-avg)/3
% histogram
[y,x] = hist(U,0.5:25);
int = (t(2)-t(1))*24; % [hr] assuming all intervals are the same

% plots
figure(15); clf;
disp('Plotting')
figure(14);
% measurements
plot(t,U,'.','MarkerSize',4); hold on;
datetick('x','keeplimits','keepticks');
ylabel('U [m/s]');
print([num2str(Num),'_VelocityTimeLine_',strrep(meta.name,' ',''),'.png'])

% histogram
clf;
y = y*int; %hr
Umean = round(nanmean(U)*100)/100; %[m/s]
bar(x,y);
title('histogram')
E = sum(0.5*1.2*x.^3.*y)/sum(y); %[watt/m^2]
title(['Histogram. Power density = ',num2str(E,3), ' [Watt/m^2]']);
xlabel('U [m/s]')
print([num2str(Num), '_diurnal_',strrep(meta.name,' ',''),'.pdf'],'-append')

% diurnal plot for each month
dailyAvgTime = 1/6; % [hr]
tDaily = 0:dailyAvgTime:24;
M = length(tDaily)-1;
hTot = mi/60+h;     % hour time vector
monthString = {'January','February','March','April','May','June','July','August','September','October','November','December'};
col = jet(12);
for month=1:12
    for i=1:length(tDaily)-1
        loc = find(and(hTot>=tDaily(i),hTot<=tDaily(i+1),m==month));
        UDaily(month,i) = nanmean(U(loc));
        UStdDaily(month,i) = nanstd(U(loc));
        directionDaily(month,i) = nanmean(direction(loc));
        directionStdDaily(month,i) = nanstd(direction(loc));
        TDaily(month,i) = nanmean(T(loc));
        RHDaily(month,i) = nanmean(RH(loc));
    end
    [yDaily,xDaily] = hist(UDaily(month,1:M),0.5:25);
    yDaily = yDaily*int; %hr
    % plotting diurnal variation for each month, U and Ustd, with bar histogram
    figure(month); subplot(121);
    ax = errorbar(tDaily(1:M)/24,UDaily(month,1:M),UStdDaily(month,1:M));
    set(ax,'color',col(month,:))
    set(gca,'xtick',[0,0.25,0.5,0.75,1])
    title(['U diurnal [m/s] for ', monthString{month}]);
    xlabel('Hour'); ylabel('U [m/s]'); 
    axis([0,1,0,nanmax(nanmax(UDaily)+nanmax(UStdDaily))])
    datetick('x',15,'keeplimits','keepticks');
    subplot(122);
    bar(xDaily,yDaily,'facecolor',col(month,:),'edgecolor',col(month,:));
    xlabel('U [m/s]')
    ylabel('hours per day')
    E = sum(0.5*1.2*xDaily.^3.*yDaily)/sum(yDaily); %[watt/m^2]
    title(['Histogram. Power density = ',num2str(E,3), ' [Watt/m^2]']);
    axis([0,14,0,24])
    print([num2str(Num), '_diurnal_',strrep(meta.name,' ',''),'.pdf'],'-append')
    % plotting all months together with line histogram
    figure(15); subplot(121); hold on;
    plot(tDaily(1:M)/24,UDaily(month,1:M),'color',col(month,:))
    subplot(122); hold on;
    plot(xDaily,yDaily,'color',col(month,:))
    xlabel('U [m/s]')
    ylabel('hours per day')
    
end

subplot(121);
set(gca,'xtick',[0,0.25,0.5,0.75,1])
axis([0,1,0,nanmax(nanmax(UDaily))])
xlabel('Hour'); ylabel('U [m/s]');
datetick('x',15,'keeplimits','keepticks');
subplot(122)
xlabel('U [m/s]')
ylabel('hours per day')
legend(monthString);
axis([0,14,0,24])
print([num2str(Num), '_diurnal_',strrep(meta.name,' ',''),'.pdf'],'-append')

% save output
save(matFile);
