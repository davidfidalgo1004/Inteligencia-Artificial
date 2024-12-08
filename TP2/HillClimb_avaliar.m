iter = 1; % Contador de iterações globais
tolerancia = 0.01; % Tolerância para determinar convergência
mve_x = zeros(100, 1); % Armazena os valores de x correspondentes ao máximo
mve_y = zeros(100, 1); % Armazena os valores de y correspondentes ao máximo

while iter <= 100
    clc;
    close all;
    clearvars -except iter tolerancia mve_x mve_y; % Mantém as variáveis principais

    % Definição da função
    f = @(x) 4*(sin(5*pi*x+0.5)).^6 .* exp(log2((x-0.8).^2));

    % Geração dos pontos para o gráfico da função
    x = linspace(0, 1.6, 200); 
    y = f(x);
    figure(1)
    plot(x, y, 'b');
    hold on;

    % Configurações iniciais do Hill Climb
    delta = 0.02; % Tamanho do passo
    x_now = rand * 1.6; % Valor inicial aleatório para x
    x_old = x_now; % Variável de comparação

    % Armazena os valores de evolução
    f_evolucao = [];
    x_evolucao = [];
    iteracoes_convergentes = 0;

    for i = 1:300 % Número fixo de iterações do algoritmo Hill Climb
        valor_rand = (rand - 0.5) * delta; % Gera valor aleatório para perturbação
        x_now = x_old + 2 * valor_rand;

        % Verifica se x_now está dentro do intervalo [0, 1.6]
        if x_now < 0
            x_now = 0;
        elseif x_now > 1.6
            x_now = 1.6;
        end

        % Atualiza o valor de x se f(x_now) for maior
        if f(x_now) > f(x_old)
            x_old = x_now;
        end 

        % Armazena os valores atuais
        f_evolucao(i) = f(x_old);
        x_evolucao(i) = x_old;

        % Verifica convergência
        if i > 1
            taxa_convergencia = abs(f_evolucao(i) - f_evolucao(i - 1)) / abs(f_evolucao(i - 1));
            if taxa_convergencia <= tolerancia
                iteracoes_convergentes = iteracoes_convergentes + 1;
            end
        end
    end

    % Identificar o valor máximo da função e o x correspondente
    [f_max_value, idx_max] = max(f_evolucao); % Máximo da evolução
    x_max = x_evolucao(idx_max);

    % Salvar o melhor x e y desta execução
    mve_x(iter) = x_max;
    mve_y(iter) = f_max_value;

    % Destacar o máximo no gráfico da função
    plot(x_max, f_max_value, '-o', 'MarkerSize', 10, ...
         'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'yellow'); % Ponto máximo
    title('Hill Climb - Gráfico da Função');
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
iteracoes_totais = 300 * 100; % 300 iterações por execução, 100 execuções
taxa_convergencia_percentual = (sum(abs(mve_y - melhor_y) / melhor_y <= tolerancia) / length(mve_y)) * 100;

% Variação (%)
variancia_x = var(mve_x);
variancia_y = var(mve_y);
varxp = (sqrt(variancia_x) / mean(mve_x)) * 100;
varyp = (sqrt(variancia_y) / mean(mve_y)) * 100;
variacao_percentual = (varxp + varyp) / 2;

% Exibição dos resultados
fprintf('Melhor Valor Encontrado: (x = %.4f, y = %.4f)\n', melhor_x, melhor_y);
fprintf('Média dos Valores: (x = %.4f, y = %.4f)\n', media_x, media_y);
fprintf('Pior Valor Encontrado: (x = %.4f, y = %.4f)\n', pior_x, pior_y);
fprintf('Taxa de Convergência: %.2f%%\n', taxa_convergencia_percentual);
fprintf('Variação: %.2f%%\n', variacao_percentual);
