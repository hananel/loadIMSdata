function [EnormYearly,tYearly,EdailyNorm] = averageIECyear(dataPath,plotme);

load([dataPath 'load_base_case.mat']);
timeLine=datenum(t(:,1),t(:,2),t(:,3),t(:,4));

if nargin>1
    figure(11); subplot(211)
    plot(timeLine,w,'.'); 
    datetick('x','keeplimits','keepticks');
    ylabel('Mw')
end
% normalizing each year of data
counter = 1; wNorm = double(w);
wYearlyMax = ones(1,length(unique(t(:,1))));
iVec = unique(t(:,1));

for counter=1:length(iVec)
    loc = find(t(:,1)==iVec(counter));
    wYearlyMax(counter) = double(max(w(loc)));
    wNorm(loc) = double(w(loc))/wYearlyMax(counter);
end

if nargin>1
    figure(11); subplot(212)
    plot(wNorm,'.'); 
    %datetick('x','keeplimits','keepticks');
    ylabel('Yearly normalized Mw')
end

% breaking into diurnal average per month
months = {'January','February','March','April','May','June','July','August','September','October','November','December'};
col = jet(12);
for month=1:12
    for h=0:23
        loc = find(and(t(:,4)>=h,t(:,4)<=h+1,t(:,2)==month));
        Edaily(month,h+1) = double(nanmean(w(loc)));
        EdailyNorm(month,h+1) = double(nanmean(wNorm(loc)));
    end
    if nargin>1
        figure(12);
        plot([0:23]/24,EdailyNorm(month,:),'color',col(month,:));
        hold on;
    end
end
if nargin>1
    xlabel('Hour'); ylabel('Normalized consumed electricity'); 
    axis([0,1,0,1])
    set(gca,"xtick",[0,0.25,0.5,0.75,1])
    datetick('x',15,'keeplimits','keepticks');
    legend(months,'location','south')
end

% averaging - to get a representative year
counter=1;
for month=1:12
    for day=1:max(t(find(t(:,2)==month),3))
        for h=0:23
            loc = find(and(t(:,2)==month,t(:,3)==day,t(:,4)==h));
            EnormYearly(counter) = nanmean(wNorm(loc));
            counter = counter + 1;
        end
    end
end
tYearly = 0:length(EnormYearly)-1;
if nargin>1
    figure;
    plot(tYearly/365/24*12,EnormYearly);
end
% consult with Pinhas what's better - comparing between average month, or the real time series i have for the appx. same years, or 1 avergae year?
% check the data and see. perhaps i have to make sure with Yoel what is the first year of this data after all...

% comparing with the real data set - according to some year, doesn't matter.
