close all 
clear all
f = @(x) 4*(sin(5*pi*x+0.5)).^6 .* exp(log2((x-0.8).^2)); % what is this
x = linspace(0,1.6,200); 
y=f(x);
plot(x,y,'b');
hold on 
i = 0;
delta = 0.02;
x_now = rand * 1.6;
x_old = x_now;
while i < 300
x_now = x_now + 2 * (rand - 0.5) * delta;
if f(x_now) > f(x_old)
    %ta a subir
    plot(x_now,f(x_now), 'o') 
end 
x_old = x_now;
i = i + 1;

end

