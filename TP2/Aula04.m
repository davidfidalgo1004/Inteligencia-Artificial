close all
clear all
f = @(x) 4*(sin(5*pi*x+0.5)).^6 .* exp(log2((x-0.8).^2)); % what is this
x = linspace(0,1.6,200);
y=f(x);
plot(x,y,'b');
hold on
i = 1;

t = 0;
T = Tmax;
nRep = 300; % n_reps
alfa = 0.94; % fator decaimento
dE = E_new - E(t); % delta
p = exp(-dE/T); % probabilidade
x(t) = rand * 1.6;
while(t <= nRep)
    while n <= Tit
        if (f(x_new)- f(x(t))) < 0 % Downhill movement
            x(t)=x_new;
            f(x(t))=f(x_new);
        elseif rand(0,1)<p % Uphill movement
            x(t)=x_new;
            f(x(t))=f(x_new);
        end
        n=n+1;
        plot(x(t),f(x(t)), 'o')
    end
    T=Tnew;
    t=t+1;
end
plot(1:(i - 1), f_evolucao); % plota a evolução de f(x_now)
xlabel('Iteração');
ylabel('f(x_{now})');
title('Evolução de f(x_{now}) a cada iteração');

