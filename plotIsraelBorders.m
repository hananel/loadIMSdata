function plotIsraelBorders()

load IsraelBorders.mat;
plot(israelBorders.b1(1:2:end),israelBorders.b1(2:2:end),'color',[0.1,0.1,0.1]); 
hold on;
plot(israelBorders.b2(1:2:end),israelBorders.b2(2:2:end),'color',[0.1,0.1,0.1])
plot(israelBorders.b0.long,israelBorders.b0.lat,'color',[0.1,0.1,0.1],'linewidth',2)
axis equal