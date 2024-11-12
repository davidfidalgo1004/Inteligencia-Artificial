close all
clear all
f = @(x) 4*(sin(5*pi*x+0.5)).^6 .* exp(log2((x-0.8).^2)); % função
x = linspace(0,1.6,200);
y=f(x);
plot(x,y,'b');
hold on

t = 0; % iteração
T = 90; % temperatura max use
nRep = 300; % n_reps
alfa = 0.94; % fator decaimento
t_rand = rand * 200;
while(t <= nRep)
    while (n <= )
        xi = (rand - 0.5) * delta;
        x_new = x_old + 2 * xi;
        % Verifica se x_now está dentro do intervalo [0, 1.6]
        if x_new < 0
            x_new = 0;
        elseif x_new > 1.6
            x_new = 1.6;
        end
        dE = f(x_new)-f(xi); % delta
        p = exp(-abs(dE)/T); % probabilidade
        if (f(x_new)- f(x(t))) > 0 % Uphill movement
            x(t)=x_new; 
            f(x(t))=f(x_new);
        elseif rand(0,1) > p % Downhill movement
            x(t)=x_new;
            f(x(t))=f(x_new);
        end
        n=n+1;
        plot(x(t),f(x(t)), 'o')
        fprintf("nao")
    end
    T=Tnew;
    t=t+1;
end
plot(1:(i - 1), f_evolucao); % plota a evolução de f(x_now)
xlabel('Iteração');
ylabel('f(x_{now})');
title('Evolução de f(x_{now}) a cada iteração');

