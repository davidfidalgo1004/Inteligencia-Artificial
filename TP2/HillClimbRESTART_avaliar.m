iter = 1; % Contador de execuções globais
tolerancia = 0.01; % Tolerância para determinar convergência
mve_x = zeros(100, 1); % Armazena os melhores x por execução
mve_y = zeros(100, 1); % Armazena os melhores y por execução
num_reinicios_total = zeros(100, 1); % Número de reinícios por execução

while iter <= 100
    clc;
    close all;
    clearvars -except iter tolerancia mve_x mve_y num_reinicios_total; % Mantém variáveis principais

    % Definição da função
    f = @(x) 4*(sin(5*pi*x+0.5)).^6 .* exp(log2((x-0.8).^2));

    % Geração dos pontos para o gráfico da função
    x = linspace(0, 1.6, 200); 
    y = f(x);
    figure(1)
    plot(x, y, 'b');
    hold on;

    % Configurações iniciais do Multiple Restart
    num_tent = 1;
    delta = 0.02; % Tamanho do passo
    f_tentativa = [];
    reinicios = 0;
    x_best_tentativas = []; % Para capturar os melhores valores de x em cada reinício

    while num_tent <= 5 % Número de reinícios (alterável conforme necessário)
        i = 1;
        x_now = rand * 1.6; % Valor inicial aleatório
        x_old = x_now;
        f_evolucao = [];
        x_evolucao = [];
        convergiu = false; % Controle de convergência para cada reinício

        while i <= 300 % Máximo de iterações por reinício
            valor_rand = (rand - 0.5) * delta; % Perturbação aleatória
            x_now = x_old + 2 * valor_rand;

            % Verifica se x_now está dentro do intervalo [0, 1.6]
            if x_now < 0
                x_now = 0;
            elseif x_now > 1.6
                x_now = 1.6;
            end

            % Atualiza x_old se f(x_now) for maior
            if f(x_now) > f(x_old)
                x_old = x_now;
            end 

            % Registra a evolução de f(x) e x
            f_evolucao(i) = f(x_old);
            x_evolucao(i) = x_old;

            % Verifica convergência
            if i > 1
                taxa_convergencia = abs(f_evolucao(i) - f_evolucao(i - 1)) / abs(f_evolucao(i - 1));
                if taxa_convergencia <= tolerancia
                    convergiu = true;
                end
            end

            i = i + 1;
        end

        % Registra o valor máximo encontrado neste reinício
        f_tentativa(num_tent) = f(x_old);
        x_best_tentativas(num_tent) = x_old; % Adiciona x correspondente
        num_tent = num_tent + 1;
        reinicios = reinicios + 1; % Incrementa o contador de reinícios
    end

    % Identifica o máximo global dos reinícios
    [f_max_value, idx_max] = max(f_tentativa); % Máximo global
    x_max = x_best_tentativas(idx_max); % Encontra o x correspondente ao f_max_value

    % Salva os melhores resultados desta execução
    mve_x(iter) = x_max;
    mve_y(iter) = f_max_value;
    num_reinicios_total(iter) = reinicios;

    % Destaca o máximo no gráfico
    plot(x_max, f_max_value, '-o', 'MarkerSize', 10, ...
         'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'yellow'); % Ponto máximo
    title(sprintf('Multiple Restart - Execução %d', iter));

    iter = iter + 1;
end

% Resultados finais agregados
melhor_y = max(mve_y);
melhor_x = mve_x(mve_y == melhor_y);

pior_y = min(mve_y);
pior_x = mve_x(mve_y == pior_y);

media_y = mean(mve_y);
media_x = mean(mve_x);

% Taxa de convergência (%)
taxa_convergencia_percentual = (sum(abs(mve_y - melhor_y) / melhor_y <= tolerancia) / length(mve_y)) * 100;

% Variação (%)
variancia_x = var(mve_x);
variancia_y = var(mve_y);
varxp = (sqrt(variancia_x) / mean(mve_x)) * 100;
varyp = (sqrt(variancia_y) / mean(mve_y)) * 100;
variacao_percentual = (varxp + varyp) / 2;

% Número médio de reinícios
media_reinicios = mean(num_reinicios_total);

% Exibição dos resultados
fprintf('Melhor Valor Encontrado: (x = %.4f, y = %.4f)\n', melhor_x, melhor_y);
fprintf('Média dos Valores: (x = %.4f, y = %.4f)\n', media_x, media_y);
fprintf('Pior Valor Encontrado: (x = %.4f, y = %.4f)\n', pior_x, pior_y);
fprintf('Taxa de Convergência: %.2f%%\n', taxa_convergencia_percentual);
fprintf('Variação: %.2f%%\n', variacao_percentual);
fprintf('Número Médio de Reinícios: %.2f\n', media_reinicios);
