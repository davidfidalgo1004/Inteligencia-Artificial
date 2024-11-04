close all 
clear all
f = @(x) 4*(sin(5*pi*x+0.5)).^6 .* exp(log2((x-0.8).^2)); % what is this
x = linspace(0,1.6,200); 
y=f(x);
plot(x,y,'b');
hold on 
i = 1;
delta = 0.02;
x_now = rand * 1.6;
x_old = x_now;
f_evolucao = zeros(1, 300);
while i <= 300
valor_rand = (rand - 0.5) * delta;
x_now = x_old + 2 * valor_rand;
if f(x_now) > f(x_old)
    %ta a subir

    plot(x_now,f(x_now), 'o')
    x_old = x_now;
end 
f_evolucao(i) = f(x_old);
i = i + 1;

end

figure;
plot(1:(i - 1), f_evolucao); % plota a evolução de f(x_now)
xlabel('Iteração');
ylabel('f(x_{now})');
title('Evolução de f(x_{now}) a cada iteração');