close all;
clear all;
f = @(x) 4*(sin(5*pi*x+0.5)).^6.*exp(log2((x-0.8).^2));
x = linspace(0,1.6,200);
y=f(x);
plot(x,y, 'B');
hold on;
xi=rand*1.6;
plot(xi, f(xi), 'ro');