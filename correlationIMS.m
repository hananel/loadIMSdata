function correlationIMS(stationVec,dataDirectory)
% the function finds correlation between the daily time series of different stations in Israel, according to certain criterions
% 1. comparing all stations
% 2. comparing stations in specific areas only (this will use a definition of the wind areas in Israel, according to a rectangular definition 
% 3. comparing the stations to the diurnal consumption in typical months

addpath('~/src/util');
monthVec = 1:12;
more off;
tic
counter = 1;
for Num=stationVec
    disp(sprintf('Analyzing station %d',Num))
    % open METADATA.csv (TODO - change to xls, from matlab) and look up station data
    meta = loadMeta(Num);
    % checking if there's an anemometer
    if or(strcmp(meta.anemometer,'No'),meta.h(2)==-1)
        tDaily = zeros(144,1); month = 1:12; UDaily = zeros(12,144);
        ane = 0;
    else
        ane = 1;
    end
    if ane
        pathname = [dataDirectory,'/IMS-data/STATIONS DATA/',meta.name,'/',meta.name,'/'];
        matFile = [pathname, 'Data_',num2str(Num),'.mat'];
    
        % loading workspace
        clear UDaily
        disp('loading matFile')
        load(matFile);
    
        % checking if diurnal plots have already been made and creating them if needed
        if ~exist('UDaily')
            disp('UDaily doesnt exist - creating')
            t = datenum(y,m,d,h,mi);
            int = (t(2)-t(1))*24; % [hr] assuming all intervals are the same       
            dailyAvgTime = 1/6; % [hr]
            tDaily = 0:dailyAvgTime:24;
            M = length(tDaily)-1;
            hTot = mi/60+h;     % hour time vector
            monthString ={'January','February','March','April','May','June','July','August','September','October','November','December'};
            col = jet(max(monthVec));
            for month=monthVec
                fprintf('%s\n',monthString{month})
                for i=1:length(tDaily)-1
                    loc = find(and(hTot>=tDaily(i),hTot<=tDaily(i+1),m==month));
                    UDaily(month,i) = nanmean(U(loc));
                    UStdDaily(month,i) = nanstd(U(loc));
                    directionDaily(month,i) = nanmean(direction(loc));
                    directionStdDaily(month,i) = nanstd(direction(loc));
                    TDaily(month,i) = nanmean(T(loc));
                    RHDaily(month,i) = nanmean(RH(loc));
                end
            end
            save(matFile);
        else
            disp('UDaily exists')
        end
        % saving UDdaily into bigger vector - station wise
        new_Ud(counter,:,:) = UDaily(:,:);
        new_UdStd(counter,:,:) = UStdDaily(:,:);
        new_Td(counter,:,:) = TDaily(:,:);
        save corBaseData new_Ud new_UdStd new_Td monthVec stationVec
        counter = counter+1;
    else
        disp('no anemometer')
    end    
end
toc

save corBaseData new_Ud new_UdStd new_Td monthVec stationVec
% using gathered data and performing correlations
% for the same month - acros the stationVecs

% between single stations
for month=monthVec
    for Num1=stationVec
        for Num2=stationVec
            disp([month,Num1,Num2])
            corMat(month,Num1,Num2) = cor(vectorFrom3DMat(new_Ud,3,Num1,month),vectorFrom3DMat(new_Ud,3,Num2,month));
        end
    end
end

[X,Y] = meshgrid(stationVec, stationVec);

save corData corMat X Y monthVec monthString
for month=monthVec
    figure(month);
    title(['correlation between stations, by numbers, for ', monthString{month}]);
    [C,H] = contour(X,Y,XYMatrixFrom3DMat(corMat,1,month));
end

% crude attitude
% 0. use only stations in the good areas (according to new energy maps, and common sense)
% 1. find correlation matrix
% 2. take the lowest 10 correlation stations (average yearly correlation, could be weighted average)
% 3. show the time line for them all together (1,2,3,... stations together on the same graph)

% calculate capacity credit

% LOLE - loss of load expectation

