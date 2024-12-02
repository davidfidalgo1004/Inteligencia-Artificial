close all;
clear all;

% Definição da função
f = @(x) 4*(sin(5*pi*x+0.5)).^6 .* exp(log2((x-0.8).^2));

% Geração dos pontos para o gráfico da função
x = linspace(0, 1.6, 200); 
y = f(x);
plot(x, y, 'b');
hold on;

% Configurações iniciais
num_total = 1;
num_tent = 1;
f_evolucao = [];
x_evolucao = [];
f_tentativa = [];
j = 1;

% Loop principal
while num_tent <= num_total
    i = 1;
    delta = 0.02;
    x_now = rand * 1.6;
    x_old = x_now;

    % Loop de atualização
    while i <= 300
        valor_rand = (rand - 0.5) * delta;
        x_now = x_old + 2 * valor_rand;

        % Verifica se x_now está dentro do intervalo [0, 1.6]
        if x_now < 0
            x_now = 0;
        elseif x_now > 1.6
            x_now = 1.6;
        end

        % Atualiza o valor de x se f(x_now) for maior
        if f(x_now) > f(x_old)
            plot(x_now, f(x_now), 'o'); % Plota o ponto
            x_old = x_now;
        end 

        % Armazena a evolução de f(x) e de x
        f_evolucao(j) = f(x_old);
        x_evolucao(j) = x_old;
        i = i + 1;
        j = j + 1;
    end

    % Atualiza o número de tentativas e f_max
    if (num_total == 1)
        num_total = num_total + 10;
        f_max = f(x_now);
    end
    if f(x_now) > f_max
        num_total = num_total + 10;
        f_max = f(x_now);
    end
    f_tentativa(num_tent) = f(x_now);
    num_tent = num_tent + 1;
end

% Identificar o valor máximo da função e o x correspondente
[f_max_value, idx_max] = max(f_evolucao); % Encontra o máximo em f_evolucao
x_max = x_evolucao(idx_max); % Identifica o valor correspondente de x no vetor x_evolucao

% Destacar o máximo no gráfico da função
plot(x_max, f_max_value, '-o', 'MarkerSize', 10, ...
     'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'yellow'); % Destaca o ponto no gráfico inicial
title('Gráfico da Função');

% Gráfico da evolução de f(x) e x
figure;
subplot(2, 1, 1);
plot(1:(j - 1), f_evolucao); % Plota a evolução de f(x_now)
hold on;
[f_max_evolucao, idx_max_evolucao] = max(f_evolucao); % Máximo na evolução
plot(idx_max_evolucao, f_max_evolucao, '-o', 'MarkerSize', 8, ...
     'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'yellow');
xlabel('Iteração');
ylabel('f(x)');
title('Evolução de f(x_{now}) a cada iteração');
hold off;

subplot(2, 1, 2);
plot(1:(j - 1), x_evolucao); % Plota a evolução de x
xlabel('Iteração');
ylabel('x');
title('Evolução de x a cada iteração');

% Gráfico da evolução de f(x) máximo
figure;
plot(1:num_total, f_tentativa, '-o'); % Plota os valores
hold on;
[f_max_tent, idx_max_tent] = max(f_tentativa); % Máximo dos testes
plot(idx_max_tent, f_max_tent, '-o', 'MarkerSize', 10, ...
     'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'yellow');
xlabel('Número Teste');
ylabel('f(x) max');
title('Evolução f(x) a cada teste');
legend('f(x)', 'Máximo Encontrado', 'Location', 'Best');
hold off;
