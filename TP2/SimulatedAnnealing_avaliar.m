iter = 1;
tolerancia = 0.01; % Tolerância de 1% para considerar uma iteração como "quase ótima"
mve_x = zeros(iter, 1);
mve_y = zeros(iter, 1);
taxa_convergencia_final = zeros(iter, 1);
tstop = zeros(iter, 1);
aceita_pior_fin = zeros(iter, 1);

while iter <= 100
    clc;
    close all;
    clearvars -except iter tolerancia mve_y mve_x taxa_convergencia_final taxa_aceitacao tstop aceita_pior_fin;

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
    Tmax = 90;        % Temperatura máxima sugerida
    T = Tmax;         % Temperatura inicial
    alfa = 0.94;      % Fator de decaimento
    cicles = 300;     % Número de ciclos
    Tit = 5;          % Iterações por temperatura
    x_t = rand * 1.6; % Solução inicial aleatória
    k = 0.8 * 1.6;    % Escalar do passo (tamanho máximo do primeiro passo)
    x_max = x_t;      % máximo encontrado x
    y_max = f(x_t);   % máximo encontrado y
    f_evolucao = zeros(cicles, 1); % Evolução do x
    fy_evolucao = zeros(cicles, 1); % Evolução do y
    aceita_pior = 0;
    aceita_tot = 0;

    tic % Inicia a contagem do tempo
    while t <= cicles
        n = 1;
        while n <= Tit
            xi = k * ((T / Tmax) ^ 0.5); % Tamanho do passo
            x_new = x_t + (rand - 0.5) * xi; % Novo x
            x_new = max(0, min(1.6, x_new)); % Restringe intervalo
            dE = f(x_new) - f(x_t); % Calcula delta de energia
            p = exp(-abs(dE) / T); % Probabilidade de aceitação

            if dE >= 0 || rand < p % Critério de aceitação
                x_t = x_new;
                aceita_tot = aceita_tot + 1;
                if rand < p
                    aceita_pior = aceita_pior + 1;
                end
                if f(x_t) > y_max
                    y_max = f(x_t);
                    x_max = x_t;
                end
            end

            f_evolucao(t) = x_t;
            fy_evolucao(t) = f(x_t);
            n = n + 1;
        end

        T = alfa * T; % Atualiza temperatura
        t = t + 1;
    end

    % Guardar resultados desta iteração
    tstop(iter) = toc;
    mve_x(iter) = x_max;
    mve_y(iter) = y_max;
    aceita_pior_fin(iter) = (aceita_pior / aceita_tot) * 100;

    iter = iter + 1;

    plot(x_t, f(x_t), 'go');
    plot(x_max, y_max, 'ks', 'LineWidth', 2);
end

% Cálculo dos resultados finais
melhor_y = max(mve_y);
media_y = mean(mve_y);
pior_y = min(mve_y);

melhor_x = mve_x(mve_y == melhor_y);
media_x = mean(mve_x);
pior_x = mve_x(mve_y == pior_y);

% Percentagem de iterações convergentes
iteracoes_quase_otimas = abs(mve_y - melhor_y) / melhor_y <= tolerancia;
percentagem_convergente = sum(iteracoes_quase_otimas) / length(mve_y) * 100;

% Resultados adicionais
tempo = mean(tstop);
variancia_x = var(mve_x);
variancia_y = var(mve_y);
varxp = (sqrt(variancia_x) / mean(mve_x)) * 100;
varyp = (sqrt(variancia_y) / mean(mve_y)) * 100;
varianciafinal = (varxp + varyp) / 2;

taxa_aceitacao_final = mean(aceita_pior_fin);

% Exibir resultados
fprintf('Melhor Valor Encontrado: y = %.4f, x = %.4f\n', melhor_y, melhor_x);
fprintf('Média dos Valores: y = %.4f\n', media_y);
fprintf('Pior Valor Encontrado: y = %.4f\n', pior_y);
fprintf('Taxa de Convergência: %.2f%%\n', percentagem_convergente);
fprintf('Taxa de Aceitação de Piores Soluções: %.2f%%\n', taxa_aceitacao_final);
fprintf('Tempo Médio por Iteração: %.4fs\n', tempo);
fprintf('Variância Final: %.2f%%\n', varianciafinal);
