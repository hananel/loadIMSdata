function [tDaily,month,UDaily] = plotZeira(pathname);
% Hanan Einav Levy 18/06/2012
% Alonei Habashan's location:
% 33.038691,35.833517

more off;
tic;
matFile = [pathname, '/Data_zeira.mat'];
if isempty(dir(matFile))
    % load data from station directory
    counter = 1;
    filenames = dir(pathname);
    for i=1:length(filenames)
        if or(~isempty(strfind(filenames(i).name,'csv')),~isempty(strfind(filenames(i).name,'CSV')))>0
            % read file
            DataFilename = [pathname '/' filenames(i).name];
            disp(DataFilename)
            
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
                    %                                           V60 STD Max Min 50...
                    %                          1  2  3  4  5 6   7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 
                    [temp,num] = sscanf(Line,'%d/%d/%d,%d:%d:%d,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g',[1,inf]);
                    if num>23
                        d(counter) = temp(2);
                        m(counter) = temp(1);
                        y(counter) = temp(3); 
                        h(counter) = temp(4); 
                        mi(counter) = temp(5);
                        U60(counter) = temp(7);
                        U60std(counter) = temp(8);
                        U60max(counter) = temp(9);
                        U60min(counter) = temp(10);
                        U50(counter) = temp(11);
                        U50std(counter) = temp(12);
                        U50max(counter) = temp(13);
                        U50min(counter) = temp(14);
                        U40(counter) = temp(15);
                        U40std(counter) = temp(16);
                        U40max(counter) = temp(17);
                        U40min(counter) = temp(18);
                        U30(counter) = temp(19);
                        U30std(counter) = temp(20);
                        U30max(counter) = temp(21);
                        U30min(counter) = temp(22);
                        direction(counter)=temp(23);
                        directionStd(counter)=temp(24);
                        disp(sprintf('%d/%d/%d %d:%d',y(counter),m(counter),d(counter),h(counter),mi(counter)));
                        counter = counter + 1;
                    end
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
% histogram
[y,x] = hist(U60,0.5:25);
int = (t(2)-t(1))*24; % [hr] assuming all intervals are the same

% plots
figure(15); clf;
disp('Plotting')
figure(14);
% measurements
plot(t,U60,'.','MarkerSize',4); hold on;
datetick('x','keeplimits','keepticks');
ylabel('U [m/s]');
print(['VelocityTimeLine.png'])

% histogram
clf;
y = y*int; %hr
Umean = round(nanmean(U60)*100)/100; %[m/s]
bar(x,y);
title('histogram')
E = sum(0.5*1.2*x.^3.*y)/sum(y); %[watt/m^2]
title(['Histogram. Power density = ',num2str(E,3), ' [Watt/m^2]']);
xlabel('U [m/s]')
print(['Diurnal.pdf'],'-append')

% diurnal plot for each month - for each height measurement
dailyAvgTime = 1; % [hr]
tDaily = 0:dailyAvgTime:24;
M = length(tDaily)-1;
hTot = mi/60+h;     % hour time vector
monthString = {'January','February','March','April','May','June','July','August','September','October','November','December'};
col = jet(12);
for month=1:12
    for i=1:length(tDaily)-1
        loc = find(and(hTot>=tDaily(i),hTot<=tDaily(i+1),m==month));
        % 60
        UDaily60(month,i) = nanmean(U60(loc));
        UStdDaily60(month,i) = nanmean(U60std(loc));
        % 50
        UDaily50(month,i) = nanmean(U50(loc));
        UStdDaily50(month,i) = nanmean(U50std(loc));
        % 40
        UDaily40(month,i) = nanmean(U40(loc));
        UStdDaily40(month,i) = nanmean(U40std(loc));
        % 30
        UDaily30(month,i) = nanmean(U30(loc));
        UStdDaily30(month,i) = nanmean(U30std(loc));
        % direction
        directionDaily(month,i) = nanmean(direction(loc));
        directionStdDaily(month,i) = nanmean(directionStd(loc));
    end
    if 0
        % plotting diurnal variation for each month, U and Ustd
        figure(month); subplot(141);
        ax = errorbar(tDaily(1:M)/24,UDaily60(month,1:M),UStdDaily60(month,1:M));
        set(ax,'color',col(month,:))
        set(gca,"xtick",[0,0.25,0.5,0.75,1])
        title(['U @ 60 m diurnal [m/s] for ', monthString{month}]);
        xlabel('Hour'); ylabel('U [m/s]'); 
        axis([0,1,0,nanmax(nanmax(UDaily60)+nanmax(UStdDaily60))])
        datetick('x',15,'keeplimits','keepticks');
        subplot(142);
        ax = errorbar(tDaily(1:M)/24,UDaily50(month,1:M),UStdDaily50(month,1:M));
        set(ax,'color',col(month,:))
        set(gca,"xtick",[0,0.25,0.5,0.75,1])
        title(['U @ 50 m diurnal [m/s] for ', monthString{month}]);
        xlabel('Hour'); ylabel('U [m/s]'); 
        axis([0,1,0,nanmax(nanmax(UDaily60)+nanmax(UStdDaily60))])
        datetick('x',15,'keeplimits','keepticks');
        subplot(143);
        ax = errorbar(tDaily(1:M)/24,UDaily40(month,1:M),UStdDaily40(month,1:M));
        set(ax,'color',col(month,:))
        set(gca,"xtick",[0,0.25,0.5,0.75,1])
        title(['U @ 40 m diurnal [m/s] for ', monthString{month}]);
        xlabel('Hour'); ylabel('U [m/s]'); 
        axis([0,1,0,nanmax(nanmax(UDaily60)+nanmax(UStdDaily60))])
        datetick('x',15,'keeplimits','keepticks');
        subplot(144);
        ax = errorbar(tDaily(1:M)/24,UDaily30(month,1:M),UStdDaily30(month,1:M));
        set(ax,'color',col(month,:))
        set(gca,"xtick",[0,0.25,0.5,0.75,1])
        title(['U @ 30 m diurnal [m/s] for ', monthString{month}]);
        xlabel('Hour'); ylabel('U [m/s]'); 
        axis([0,1,0,nanmax(nanmax(UDaily60)+nanmax(UStdDaily60))])
        datetick('x',15,'keeplimits','keepticks');
        
        print(['Diurnal.pdf'],'-append')
    end
    
end
% save output
keyboard;
save(matFile);
