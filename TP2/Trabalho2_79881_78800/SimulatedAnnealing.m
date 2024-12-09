clear;
clc;
close all;
clear all;

% Função
f = @(x) 4*(sin(5*pi*x+0.5)).^6 .* exp(log2((x-0.8).^2));

% Intervalo e visualização inicial
x = linspace(0,1.6,100000);
y = f(x);
figure(1)
plot(x, y, 'b');
hold on;

% Parâmetros do SA
t = 1;
Tmax = 90;        % Temperatura maxima sugerida nos powerpoints do prof
T = Tmax;         % Temperatura inicial
alfa = 0.94;      % Fator de decaimento, parece melhor em 0.94 aqui
cicles = 300;     % Número de ciclos
Tit = 5;          % Iterações por temperatura
t_i = 1;          % Iterações do plot da temperatura
x_t = rand * 1.6; % Solução inicial aleatória
k = 0.8 * 1.6;    % Escalar do passo (tamanho máximo do primeiro passo)
x_max= x_t;        % maximo encontrado x
y_max = f(x_t);       % maximo encontrado y
f_evolucao = zeros(cicles, 1); % Evolução do x
fy_evolucao = zeros(cicles, 1); % Evolução do y
t_evolucao = zeros(cicles * Tit, 1); % Evolução da temperatura
p_evolucao = zeros(cicles * Tit, 1); % Evolução da probabilidade

while t <= cicles
    n = 1;
    while n <= Tit
        xi = k * ((T / Tmax) ^ 0.5); % tamanho do passo a dar
        x_new = x_t + (rand - 0.5) * xi; % x novo para testar
        x_new = max(0, min(1.6, x_new)); % confirmar intervalo
        dE = f(x_new) - f(x_t); % Calcula delta de energia
        p = exp(-abs(dE) / T); % Probabilidade de aceitação

        if dE >= 0 || rand < p % Critérios de movimentação
            x_t = x_new; % se aceite muda

        if f(x_t) > y_max
            y_max = f(x_t);
            x_max = x_t;
        end
    
        end

        f_evolucao(t) = x_t; % guarda x atual num array
        fy_evolucao(t) = f(x_t);
        plot(x_t, f(x_t), 'ro'); % Visualiza ponto atual
        n = n + 1;
        
        t_evolucao(t_i) = T;
        p_evolucao(t_i) = p;       
        t_i = t_i + 1;
    end

    T = alfa * T; % Atualiza temperatura e armazena evolução
    t = t + 1;
end

plot(x_t, f(x_t), 'go'); % último ponto
plot(x_max, y_max, 'ks', 'LineWidth', 2); % ponto máximo

% Gráfico da evolução da função
figure(2);
plot(1:cicles, f(f_evolucao), '-o');
xlabel('Iteração');
ylabel('f(x_{now})');
title('Evolução de f(x_{now})');
grid on;

% Gráfico da evolução da temperatura
figure(3);
plot(1:length(t_evolucao), t_evolucao, '-o');
xlabel('Iteração');
ylabel('Temperatura');
title('Evolução de Temperatura');

% Gráfico da evolução da probabilidade
figure(4);
plot(1:length(t_evolucao), p_evolucao, '-o');
xlabel('Iteração');
ylabel('Probabilidade');
title('Evolução de Probabilidade');

