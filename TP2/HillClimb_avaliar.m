close all;
clearvars -except iter f_results_hc_restart x_results_hc_restart convergence_rate_hc_restart variation_hc_restart;

% Configurações gerais
if ~exist('iter', 'var')
    iter = 1; % Inicializar o contador de execuções se não existir
end

if ~exist('f_results_hc_restart', 'var')
    f_results_hc_restart = []; % Armazena o melhor valor encontrado em cada execução
    x_results_hc_restart = []; % Armazena o x correspondente em cada execução
    convergence_rate_hc_restart = []; % Taxa de convergência em cada execução
    variation_hc_restart = []; % Variação percentual em cada execução
end

% Definição da função
f = @(x) 4*(sin(5*pi*x+0.5)).^6 .* exp(log2((x-0.8).^2));

% Geração dos pontos para o gráfico da função
x = linspace(0, 1.6, 200); 
y = f(x);
plot(x, y, 'b');
hold on;

% Configurações do Hill Climb Restart
num_total = 100; % Número total de reinícios
num_tent = 1;    % Contador de reinícios
delta = 0.02;    % Incremento para ajustes no x
threshold = 0.95; % Limiar de convergência (95% do máximo teórico)
f_tentativa = []; % Armazena os valores máximos em cada reinício
f_evolucao = [];  % Para rastrear a evolução de f durante reinícios
j = 1;

% Loop principal: Reinicializações
while num_tent <= num_total
    i = 1;
    x_now = rand * 1.6; % Ponto inicial aleatório
    x_old = x_now;

    % Loop de otimização
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
            x_old = x_now;
        end 

        % Armazena a evolução de f(x)
        f_evolucao(j) = f(x_old);
        j = j + 1;
        i = i + 1;
    end

    % Armazena o valor final de f(x) após este reinício
    f_tentativa(num_tent) = f(x_old);
    num_tent = num_tent + 1;
end

% Cálculos de Métricas
f_max = max(f_tentativa); % Melhor valor encontrado
f_mean = mean(f_tentativa); % Média dos valores
f_min = min(f_tentativa); % Pior valor encontrado
num_restarts = num_total; % Número de reinícios realizados
convergence_rate = (sum(f_tentativa >= threshold * max(y)) / num_total) * 100; % Taxa de Convergência (%)
variation = (std(f_tentativa) / f_mean) * 100; % Variação (%)

% Destacar o máximo no gráfico da função
[f_max_value, idx_max] = max(f_evolucao); % Encontra o máximo em f_evolucao
x_max = x(idx_max); % Identifica o valor correspondente de x no vetor x_evolucao
plot(x_max, f_max_value, '-o', 'MarkerSize', 10, ...
     'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'yellow'); % Destaca o ponto no gráfico inicial
title(sprintf('Execução %d - Gráfico da Função', iter));

% Gráfico da evolução de f(x) máximo
figure;
plot(1:num_total, f_tentativa, '-o'); % Plota os valores máximos por reinício
hold on;
[f_max_tent, idx_max_tent] = max(f_tentativa); % Máximo dos testes
plot(idx_max_tent, f_max_tent, '-o', 'MarkerSize', 10, ...
     'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'yellow');
xlabel('Número Teste');
ylabel('f(x) max');
title('Evolução f(x) a cada teste');
legend('f(x)', 'Máximo Encontrado', 'Location', 'Best');
hold off;

% Armazenar resultados finais da execução atual
f_results_hc_restart(iter) = f_max; % Melhor valor de f
x_results_hc_restart(iter) = x_max; % Melhor valor de x correspondente
convergence_rate_hc_restart(iter) = convergence_rate; % Taxa de convergência
variation_hc_restart(iter) = variation; % Variação percentual

% Incrementar o contador e preparar para a próxima execução
iter = iter + 1;

% Resultados acumulados
fprintf('\n---- Resultados da Execução %d ----\n', iter - 1);
fprintf('Melhor Valor Encontrado: %.4f\n', f_max);
fprintf('Média dos Valores: %.4f\n', f_mean);
fprintf('Pior Valor Encontrado: %.4f\n', f_min);
fprintf('Número de Reinícios: %d\n', num_restarts);
fprintf('Taxa de Convergência: %.2f%%\n', convergence_rate);
fprintf('Variação: %.2f%%\n', variation);

% Mensagem ao usuário
disp('Execução concluída! Execute novamente para rodar outra iteração.');
disp('Use "clearvars -except iter f_results_hc_restart x_results_hc_restart convergence_rate_hc_restart variation_hc_restart" para limpar antes de nova execução.');
disp('Resultados até agora:');
fprintf('Melhores valores f(x): [%s]\n', num2str(f_results_hc_restart));
fprintf('Melhores valores x: [%s]\n', num2str(x_results_hc_restart));
fprintf('Taxas de Convergência: [%s]\n', num2str(convergence_rate_hc_restart));
fprintf('Variações: [%s]\n', num2str(variation_hc_restart));
