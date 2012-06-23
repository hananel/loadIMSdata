function s = readLine(Line,form)
%read line according to format and return struct with relevant data

%replace InVld with NaN
Line = strrep(Line,'InVld','NaN');
Line = strrep(Line,'Down','NaN');
Line = strrep(Line,'NoData','NaN');
Line = strrep(Line,'<Samp','NaN');
Line = strrep(Line,'Samp','NaN');
Line = strrep(Line,'Samp>','NaN');
% take out seconds statement if exists
loc = strfind(Line,':');
if length(loc)>1
    Line(loc(2):(loc(2)+2))='';
end                 
dash = strfind(Line,'-');
% date is sometimes dd/mm/yy and sometimes dd-mm-yy           
if ~isempty(dash)
    if dash(1)<4
        Line(dash(1:2)) = '/'; %replace dd-mm-yy with dd/mm/yy and live - marks in the data intact
    end
end
% read data according to form
if form==1
% format 1: <this is the typical structure>
                            % 123      45   6    7     8     9  10 11    12 13  
                            % Date,    Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
    [temp,num] = sscanf(Line,'%d/%d/%d,%d:%d,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g',[1,inf]);
    s.d = temp(1); 
    s.m = temp(2);
    s.y = temp(3); 
    s.h = temp(4); 
    s.mi = temp(5);
    s.Ugust = temp(7);
    s.U = temp(9);
    s.direction = temp(10); 
    s.directionStd = temp(11);
    s.T = temp(12); 
    s.RH = temp(13); end
if form==2
% format 2:
                            % 123      45   6    7     8     9  10 11    12 13 
                            % Date,    Time,Rain,WSmax,WDmax,WS,WD,STDwd,RH,TD,TDmax,TDmin
    [temp,num] = sscanf(Line,'%d/%d/%d,%d:%d,%g,%g,%g,%g,%g,%g,%g,%g',[1,inf]);
    s.d = temp(1); 
    s.m = temp(2);
    s.y = temp(3); 
    s.h = temp(4); 
    s.mi = temp(5);
    s.Ugust = temp(7);
    s.U = temp(9);
    s.direction = temp(10); 
    s.directionStd = temp(11);
    s.T = temp(13); 
    s.RH = temp(12); end
if form==3
% format 3:
                             % 123      45   6     7     8  9  10    11 12 
                             % Date,Time,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,Grad,NIP,DiffR,WS1mm,Ws10mm,Time,Rain    
    [temp,num] = sscanf(Line,'%d/%d/%d,%d:%d,%g,%g,%g,%g,%g,%g,%g',[1,inf]);
    s.d = temp(1); 
    s.m = temp(2);
    s.y = temp(3); 
    s.h = temp(4); 
    s.mi = temp(5);
    s.Ugust = temp(6);
    s.U = temp(8);
    s.direction = temp(9); 
    s.directionStd = temp(10);
    s.T = temp(11); 
    s.RH = temp(12); end
if form==4
% format 4
                             % 123  45   6    7     8     9  10 11    12 13    14    15    16     17   18   19
                             % Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,Grad,RH
    [temp,num] = sscanf(Line,'%d/%d/%d,%d:%d,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g',[1,inf]);
    s.d = temp(1); 
    s.m = temp(2);
    s.y = temp(3); 
    s.h = temp(4); 
    s.mi = temp(5);
    s.Ugust = temp(7);
    s.U = temp(9);
    s.direction = temp(10); 
    s.directionStd = temp(11);
    s.T = temp(12); 
    s.RH = temp(19); end
if form==5
% format 5
                            % 123  45   6    7     8     9  10 11    12 13    14    15    16     17   18
                            % Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,RH
    [temp,num] = sscanf(Line,'%d/%d/%d,%d:%d,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g',[1,inf]);
    s.d = temp(1); 
    s.m = temp(2);
    s.y = temp(3); 
    s.h = temp(4); 
    s.mi = temp(5);
    s.Ugust = temp(7);
    s.U = temp(9);
    s.direction = temp(10); 
    s.directionStd = temp(11);
    s.T = temp(12);
    s.RH = temp(18); end
if form==6
% format 6
                            % 123      45    6  7  8     9    10 11   12    13    14    15     16   17
                            % Date,    Time, WS,WD,STDwd,Grad,RH,Rain,WSmax,WDmax,WS1mm,Ws10mm,Time,TD,TDmax,TDmin
    [temp,num] = sscanf(Line,'%d/%d/%d,%d:%d,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g',[1,inf]);
    s.d = temp(1); 
    s.m = temp(2);
    s.y = temp(3); 
    s.h = temp(4); 
    s.mi = temp(5);
    s.Ugust = temp(12);
    s.U = temp(6);
    s.direction = temp(7); 
    s.directionStd = temp(8);
    s.T = temp(17);
    s.RH = temp(10); end
if form==7
% format 7
                            % 123  45   6    7     8     9  10 11    12 13    14    15    16     17   18 19
                            % Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,BP,RH
    [temp,num] = sscanf(Line,'%d/%d/%d,%d:%d,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g',[1,inf]);
    s.d = temp(1); 
    s.m = temp(2);
    s.y = temp(3); 
    s.h = temp(4); 
    s.mi = temp(5);
    s.Ugust = temp(7);
    s.U = temp(9);
    s.direction = temp(10); 
    s.directionStd = temp(11);
    s.T = temp(12); 
    s.RH = temp(19); end
if form==8
% format 8
                            % 123  45   6    7     8   9  10 11 12 13    14   15    16    17
                            % Date,Time,Grad,DiffR,NIP,RH,TD,WS,WD,STDwd,Rain,TDmax,TDmin,WSmax,WDmax,WS1mm,Ws10mm,Time
    [temp,num] = sscanf(Line,'%d/%d/%d,%d:%d,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g',[1,inf]);
    s.d = temp(1); 
    s.m = temp(2);
    s.y = temp(3); 
    s.h = temp(4); 
    s.mi = temp(5);
    s.Ugust = temp(17);
    s.U = temp(11);
    s.direction = temp(12); 
    s.directionStd = temp(13);
    s.T = temp(10); 
    s.RH = temp(9); end

if form==1000    
% format R
    % 1  2 3 4 5 6 7  8         9         10   11       12       13        14            15        16
    % ID time         windspeed direction temp humidity solarRad windChill BaromPressure RainToday rainWeek rainMonth RainYear rainSeason rainRate hailToday heatIndex DewPoint max10MinWind
    % 9,15/2/2011 10:39:17,19.31,259,14.56,41.00,446.69,9.39,92.21,.25,.51,84.84,282.70,,.00,.00,.00,,,
    [temp,num] = sscanf(line,'%d,%d/%d/%d %d:%d:%d,%g,%d,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,',[1,inf]);
    s.num = temp(1);
    s.d = temp(2); 
    s.m = temp(2);
    s.y = temp(3); 
    s.h = temp(4); 
    s.mi = temp(5);
    s.s  = temp(6);
    s.Ugust = temp(24)/3.6; % [m/s] 
    s.U = temp(8)/3.6;      % [m/s]      
    s.direction = temp(9); 
    s.T = temp(10); 
    s.RH = temp(11);
    s.rad = temp(12);
    s.pres = temp(14); end
