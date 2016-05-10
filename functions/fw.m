function [MEAN, PEAK,x1,x2,y0] = fw(x,y,level)
% findwidth
% 
% 
% Last modified 03.05.2016 by Theodoros Argyropoulos

delta_t_pts = x(2)-x(1);
taux = find(y>level*max(y),1);
x1 = x(taux) - (y(taux)-level*max(y))/(y(taux)-y(taux-1)) * delta_t_pts;
taux = find(y>level*max(y),1,'last');
x2 = x(taux) + (y(taux)-level*max(y))/(y(taux)-y(taux+1)) * delta_t_pts;

MEAN = (x1+x2)/2;               
PEAK = max(y);
y0 = level*max(y);

end