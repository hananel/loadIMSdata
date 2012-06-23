function plotStationLocations(stationVec,col)

meta = loadMeta;
plotIsraelBorders
axis tight; hold on;

ax = get(gcf);
set(ax.children,'xlim',[33.5   35.892]);
for i=1:length(meta)
    % checking for anemometer
    yesAnemometer = not(or(strcmp(meta(i).anemometer,'No'),meta(i).h(2)==-1));
    if yesAnemometer
        plot(meta(i).long,meta(i).lat,'.','color','g');
    end

end    
counter = 0;
for i=stationVec
    counter = counter + 1;
    text(meta(i).long-0.05,meta(i).lat,num2str(meta(i).num),'color',col(counter,:),'fontweight','bold')
end 
xlabel('longitude [deg]'); ylabel('latitude [deg]'); title('IMS stations');
