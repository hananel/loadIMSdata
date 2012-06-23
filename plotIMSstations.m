function plotIMSstations(stationVec,dataDirectory)
% calls plotIMS for a vector of stations
for i=stationVec
    [tDaily,month,UDaily(i+1-stationVec(1),:,:)] = plotIMS(i,dataDirectory);
end
