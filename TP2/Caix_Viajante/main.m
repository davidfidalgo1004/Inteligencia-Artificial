clc;
clear all;
close all;

% Coordenadas das cidades
coordenadas_cities = [ 
    1 41.49 -6.45;  % Bragança
    2 41.18 -7.45;  % Vila Real
    3 41.44 -7.28;  % Chaves
    4 41.27 -8.18;  % Guimarães
    5 41.33 -8.26;  % Braga
    6 41.42 -8.50;  % Viana do Castelo
    7 42.02 -8.38;  % Valença
    8 41.32 -8.37;  % Barcelos
    9 41.11 -8.36;  % Porto
    10 40.38 -8.39; % Aveiro
    11 40.34 -8.27; % Águeda
    12 40.39 -7.55; % Viseu
    13 41.06 -7.49; % Lamego
    14 41.10 -7.47; % Peso Régua
];
num_cidades = 14;
R_Terra = 6371; %valor do raio da terra para calcular custo em km
% Nomes das cidades
nomes = { 'Bragança', 'Vila Real', 'Chaves', 'Guimarães', 'Braga', ...
          'Viana do Castelo', 'Valença do Minho', 'Barcelos', 'Porto', ...
          'Aveiro', 'Águeda', 'Viseu', 'Lamego', 'Peso da Régua' };

% Coordenadas em matriz
cities = [coordenadas_cities(:, 2)'; coordenadas_cities(:, 3)'];

% Distância Haversine (explicado relatorio)
distancia = @(c1, c2) 2 * R_Terra * ...
    asin(sqrt(sin((deg2rad(c2(1)) - deg2rad(c1(1))) / 2)^2 + ...
              cos(deg2rad(c1(1))) * cos(deg2rad(c2(1))) * ...
              sin((deg2rad(c2(2)) - deg2rad(c1(2))) / 2)^2));

% Função J (soma total das distâncias no percurso)
calculaCusto = @(percurso) sum(arrayfun(@(i) ...
    distancia(cities(:, percurso(i)), cities(:, percurso(mod(i, num_cidades) + 1))), ...
    1:num_cidades));

% Parâmetros do Simulated Annealing
T_inicial = 90;       % Temperatura inicial
T_final = 1e-3;       % Temperatura final
alpha = 0.96;         % Fator de redução da temperatura
iteracoes = 50;       % Iterações por temperatura

% Inicialização
percursoAtual = randperm(num_cidades);
custoAtual = calculaCusto(percursoAtual);
melhorpercurso = percursoAtual;
melhorcusto = custoAtual;

% Iteradores
Tit = T_inicial;

historico_temperatura = [];  % Vetor para guardar a temperatura ao longo das iterações
historico_custos = []; 
historico_probs=[];
it=0;
while Tit > T_final
    i = 0; % Certifique-se de inicializar o contador
    while i < iteracoes
        % Geração de vizinho (troca de duas cidades aleatórias)
        vizinho = percursoAtual;
        idx = randperm(num_cidades, 2);
        vizinho(idx) = vizinho(flip(idx));

        % Cálculo do custo do vizinho
        custoVizinho = calculaCusto(vizinho);

        % Decisão de aceitação
        delta = custoVizinho - custoAtual;

        if delta < 0 || rand < exp(-abs(delta) / Tit)
            percursoAtual = vizinho;
            custoAtual = custoVizinho;
        end
    
        % Atualização do melhor percurso encontrado
        if custoAtual < melhorcusto
            melhorpercurso = percursoAtual;
            melhorcusto = custoAtual;
        end
        i = i + 1;
        historico_probs = [historico_probs, exp(-abs(delta) / Tit)];
        historico_temperatura = [historico_temperatura, Tit];
        historico_custos = [historico_custos, custoAtual];
    end
    
    % Armazenar a temperatura atual e Custos atuais
    historico_temperatura = [historico_temperatura, Tit];
    historico_custos = [historico_custos, custoAtual];
    
    % Atualização da temperatura
    Tit = Tit * alpha;
end



% Reestruturar as coordenadas
cities = [coordenadas_cities(:, 2), coordenadas_cities(:, 3)]; % [latitude, longitude]

% Plotar o percurso corretamente
figure;
hold on;

plot(cities(melhorpercurso, 2), cities(melhorpercurso, 1), '-o', ...
    'LineWidth', 1, 'Color', [0.2 0.2 0.8], 'MarkerSize', 6);

% Plot para conectar a ultima cidade à primeira (ciclo)
plot([cities(melhorpercurso(end), 2), cities(melhorpercurso(1), 2)], [cities(melhorpercurso(end), 1), cities(melhorpercurso(1), 1)], '-', 'LineWidth', 1, 'Color', [0.2 0.2 0.8]);

% Ciclo for para adicionar nomes das cidades apartir da lista "melhor percurso"
for i = 1:num_cidades
    text(cities(melhorpercurso(i), 2), cities(melhorpercurso(i), 1), ...
         nomes{melhorpercurso(i)}, ...
         'FontSize', 8, 'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'bottom', 'Color', 'k');
end

% Cidade de Partida no melhor percurso
scatter(cities(melhorpercurso(1), 2), cities(melhorpercurso(1), 1), 100, ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r', 'LineWidth', 1);
text(cities(melhorpercurso(1), 2), cities(melhorpercurso(1), 1), ...
     'Início', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'r', ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');

% Configuração Chat
title('Melhor Percurso Encontrado', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Longitude', 'FontSize', 10);
ylabel('Latitude', 'FontSize', 10);
grid on;
axis equal;
xlim([min(cities(:, 2)) - 0.5, max(cities(:, 2)) + 0.5]);
ylim([min(cities(:, 1)) - 0.5, max(cities(:, 1)) + 0.5]);
set(gca, 'FontSize', 10); 
hold off;
% Até aqui

% Gráfico da evolução da temperatura e do custo
figure;

% Subplot 1: Evolução da temperatura
subplot(2, 1, 1);
plot(1:length(historico_temperatura), historico_temperatura, '-o');
xlabel('Iteração');
ylabel('Temperatura');
title('Evolução de Temperatura');

% Subplot 2: Evolução do custo
subplot(2, 1, 2);
plot(1:length(historico_custos), historico_custos, '-o');
xlabel('Iterações');
ylabel('Custo Total do Percurso (em km)');
title('Evolução do Custo');
grid on;

% Subplot 3: Evolução da probabilidade
figure;
plot(1:length(historico_probs), historico_probs, '-o');
xlabel('Iterações');
ylabel('Probabilidade atual');
title('Evolução da Probabilidade');


% Ajuste geral
set(gca, 'FontSize', 10);
