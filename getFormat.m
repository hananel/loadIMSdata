function form = getFormat(DataFilename)
% find Line format 
% format 1: 
% Afeq
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time,BP
% Afula
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,RH,TD,TDmax,TDmin 
% AMMIAD
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% ARAD
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,RH,TD,TDmax,TDmin,Grad,DiffR,NIP,WS1mm,Ws10mm,Time -- TD/RH switched places
% ARIEL
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% ASHDOD PORT
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% ASHQUELON PORT
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% AVDAT
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time,BP
% AVNEI EITAN
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% BEER SHEVA
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,RH,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,BP
% BESOR FARM
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,Grad,NIP,DiffR,WS1mm,Ws10mm,Time
% BET DAGAN
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,RH,BP
% BET HAARAVA
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% BET ZAYDA
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% DAFNA
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% DEIR HANA
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% DOROT
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,Grad,RH
% EDEN FARM
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time,Grad
% ELAT
% Date,Time,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Grad,NIP,DiffR,Rain,Ws10mm,Time,BP
% ELON
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,RH
% EIN GEDI
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% EN HASHOFET
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time,Grad
% EN CARMEL
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% ESHHAR
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% EZUZ
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% GAMLA
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% GILGAL
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% HADERA PORT
% Date,Time,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,Rain,WS1mm,Ws10mm,Time
% HAFECH HAIM
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% HAIFA PORT
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% HAIFA TECHNION
% Date,Time,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,Grad,NIP,DiffR,WS1mm,Ws10mm,Time,Rain
%
%
% 
% format 1: <this is the typical structure>
% 123  45     6      7        8       9    10   11    12  13  
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,WS1mm,Ws10mm,Time
% 
% format 2:
% 123  45   6    7     8     9  10 11    12 13 
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,RH,TD,TDmax,TDmin
% 
% format 3:
% 123   45  6     7     8  9  10    11 12 
% Date,Time,WSmax,WDmax,WS,WD,STDwd,TD,RH,TDmax,TDmin,Grad,NIP,DiffR,WS1mm,Ws10mm,Time,Rain
%
% format 4
% 123  45   6    7     8     9  10 11    12 13    14    15    16     17   18   19
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,Grad,RH
%
% format 5
% 123  45   6    7     8     9  10 11    12 13    14    15    16     17   18
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,RH
%
% format 6
% 123  45   6  7  8     9    10 11   12    13    14    15     16   17
% Date,Time,WS,WD,STDwd,Grad,RH,Rain,WSmax,WDmax,WS1mm,Ws10mm,Time,TD,TDmax,TDmin
%
% format 7
% 123  45   6    7     8     9  10 11    12 13    14    15    16     17   18 19
% Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,BP,RH
%
% format 8
% 123  45   6    7     8   9  10 11 12 13    14   15    16    17
% Date,Time,Grad,DiffR,NIP,RH,TD,WS,WD,STDwd,Rain,TDmax,TDmin,WSmax,WDmax,WS1mm,Ws10mm,Time
fid = fopen(DataFilename,'r');
condition = 1;
% looking for header lines
while condition
    Line = fgetl(fid);               
    % checking for end of file
    if Line == -1
        break;
    end

    if findstr(Line,'Date')
        if findstr(Line,'Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,RH'); form=1; end
        if findstr(Line,'Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,RH,TD'); form=2; end
        if findstr(Line,'Date,Time,WSmax,WDmax,WS,WD,STDwd,TD,RH'); form=3; end
        if findstr(Line,'Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,Grad,RH'); form=4; end
        if findstr(Line,'Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,RH'); form=5; end
        if findstr(Line,'Date,Time,WS,WD,STDwd,Grad,RH,Rain,WSmax,WDmax,WS1mm,Ws10mm,Time,TD,TDmax,TDmin'); form=6; end
        if findstr(Line,'Date,Time,Rain,WSmax,WDmax,WS,WD,STDwd,TD,TDmax,TDmin,WS1mm,Ws10mm,Time,BP,RH'); form=7; end
        if findstr(Line,'Date,Time,Grad,DiffR,NIP,RH,TD,WS,WD,STDwd,Rain,TDmax,TDmin,WSmax,WDmax,WS1mm,Ws10mm,Time'); form=8; end
        break;
    end   
end
fclose(fid);
