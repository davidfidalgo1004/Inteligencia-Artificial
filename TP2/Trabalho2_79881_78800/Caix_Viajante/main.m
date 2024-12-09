clc;
clear all;
close all;
fprintf("1->14 cidades\n2->20 cidades\n3->30 cidades\n")
while true
    opcao = input('Por favor, introduza uma opção (1 | 2 | 3): ');
    if isnumeric(opcao) && ismember(opcao, [1, 2, 3])
        break;
    end
end
if opcao == 1
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
    
    % Nomes das cidades
    nomes = { 'Bragança', 'Vila Real', 'Chaves', 'Guimarães', 'Braga', ...
              'Viana do Castelo', 'Valença do Minho', 'Barcelos', 'Porto', ...
              'Aveiro', 'Águeda', 'Viseu', 'Lamego', 'Peso da Régua' };
    alpha = 0.96;         % Fator de redução da temperatura
    iteracoes = 50;       % Iterações por temperatura
    T_inicial = 90;       % Temperatura inicial
end
if opcao==2
    % Coordenadas das cidades
    coordenadas_cities = [ 
        1 41.49 -6.45;  % Bragança
        2 41.18 -7.45;  % Vila Real
        3 41.44 -7.28;  % Chaves
        4 41.42 -8.50;  % Viana do Castelo
        5 41.33 -8.26;  % Braga
        6 40.38 -8.39;  % Aveiro
        7 41.11 -8.36;  % Porto
        8 40.39 -7.55;  % Viseu
        9 41.06 -7.49;  % Lamego
        10 41.27 -8.18; % Guimarães
        11 40.12 -8.25; % Coimbra
        12 37.01 -7.56; % Faro
        13 38.34 -7.54; % Évora
        14 38.43 -9.10; % Lisboa
        15 39.17 -7.26; % Portalegre
        16 37.07 -7.39; % Tavira
        17 37.00 -8.56; % Sagres
        18 38.32 -8.54; % Setúbal
        19 40.32 -7.16; % Guarda
        20 39.14 -8.41; % Santarém
    ];
    num_cidades = 20;
    
    % Nomes das cidades
    nomes = { 'Bragança', 'Vila Real', 'Chaves', 'Viana do Castelo', 'Braga', ...
              'Aveiro', 'Porto', 'Viseu', 'Lamego', 'Guimarães', ...
              'Coimbra', 'Faro', 'Évora', 'Lisboa', 'Portalegre', ...
              'Tavira', 'Sagres', 'Setúbal', 'Guarda', 'Santarém' };
    alpha = 0.98;         % Fator de redução da temperatura
    iteracoes = 100;       % Iterações por temperatura
    T_inicial = 90;       % Temperatura inicial
end
if opcao==3
    % Coordenadas das cidades
    coordenadas_cities = [ 
        1 41.49 -6.45;  % Bragança
        2 41.18 -7.45;  % Vila Real
        3 41.44 -7.28;  % Chaves
        4 41.42 -8.50;  % Viana do Castelo
        5 41.33 -8.26;  % Braga
        6 40.38 -8.39;  % Aveiro
        7 41.11 -8.36;  % Porto
        8 40.39 -7.55;  % Viseu
        9 41.06 -7.49;  % Lamego
        10 41.27 -8.18; % Guimarães
        11 40.12 -8.25; % Coimbra
        12 37.01 -7.56; % Faro
        13 38.34 -7.54; % Évora
        14 38.43 -9.10; % Lisboa
        15 39.17 -7.26; % Portalegre
        16 37.07 -7.39; % Tavira
        17 37.00 -8.56; % Sagres
        18 38.32 -8.54; % Setúbal
        19 40.32 -7.16; % Guarda
        20 39.14 -8.41; % Santarém
        21 38.01 -7.52; % Beja
        22 37.57 -8.52; % Sines
        23 40.17 -7.30; % Covilhã
        24 39.36 -8.25; % Tomar
        25 40.34 -8.27; % Águeda
        26 39.45 -8.48; % Leiria
        27 39.49 -7.30; % Castelo Branco
        28 38.53 -7.10; % Elvas
        29 41.30 -6.16; % Miranda do Douro
        30 38.48 -9.23; % Sintra
    ];
    num_cidades = 30;
    
    % Nomes das cidades
    nomes = { 'Bragança', 'Vila Real', 'Chaves', 'Viana do Castelo', 'Braga', ...
              'Aveiro', 'Porto', 'Viseu', 'Lamego', 'Guimarães', ...
              'Coimbra', 'Faro', 'Évora', 'Lisboa', 'Portalegre', ...
              'Tavira', 'Sagres', 'Setúbal', 'Guarda', 'Santarém', ...
              'Beja', 'Sines', 'Covilhã', 'Tomar', 'Águeda', ...
              'Leiria', 'Castelo Branco', 'Elvas', 'Miranda do Douro', 'Sintra' };
    alpha = 0.98;         % Fator de redução da temperatura
    iteracoes = 300;       % Iterações por temperatura
    T_inicial = 1000;       % Temperatura inicial
end
% Coordenadas em matriz
cities = [coordenadas_cities(:, 2)'; coordenadas_cities(:, 3)'];

% Distância Haversine 
R_Terra = 6376; %valor do raio da terra para calcular custo em km
distancia = @(c1, c2) 2 * R_Terra * ...
    asin(sqrt(sin((deg2rad(c2(1)) - deg2rad(c1(1))) / 2)^2 + ...
              cos(deg2rad(c1(1))) * cos(deg2rad(c2(1))) * ...
              sin((deg2rad(c2(2)) - deg2rad(c1(2))) / 2)^2));

% Função J (soma total das distâncias no percurso)
calculaCusto = @(percurso) sum(arrayfun(@(i) ...
    distancia(cities(:, percurso(i)), cities(:, percurso(mod(i, num_cidades) + 1))), ...
    1:num_cidades));

% Parâmetros do Simulated Annealing

T_final = 1e-3;       % Temperatura final

historico_temperatura = [];  % Vetor para guardar a temperatura ao longo das iterações
historico_custos = []; 
historico_probs=[];
it=0;
% Inicialização do percurso fixando a cidade inicial (cidade 1 como exemplo)
percursoAtual = randperm(num_cidades);
custoAtual = calculaCusto(percursoAtual);
melhorpercurso = percursoAtual;
melhorcusto = custoAtual;

% Iteradores
Tit = T_inicial;
it=0;
% Loop principal
while Tit > T_final
    i = 0;
    while i < iteracoes
        % Geração de vizinho mantendo a cidade inicial fixa
        vizinho = percursoAtual;
        idx = randperm(num_cidades-1, 2) + 1; % Evita a cidade inicial (fixa em 1)
        vizinho(idx) = vizinho(flip(idx));
        
        custoVizinho = calculaCusto(vizinho);
        delta = custoVizinho - custoAtual;
        
        % Critério de aceitação
        if delta < 0 || rand < exp(-abs(delta) / Tit)
            percursoAtual = vizinho;
            custoAtual = custoVizinho;
        end
        
        % Atualização do melhor percurso
        if custoAtual < melhorcusto
            melhorpercurso = percursoAtual;
            melhorcusto = custoAtual;
            figure(1); clf;
            plot(cities(2, percursoAtual), cities(1, percursoAtual), '-o', ...
                'LineWidth', 1, 'Color', [0.2 0.2 0.8], 'MarkerSize', 6);
            hold on;
            plot([cities(2, percursoAtual(end)), cities(2, percursoAtual(1))], ...
                 [cities(1, percursoAtual(end)), cities(1, percursoAtual(1))], '-', 'Color', [0.2 0.2 0.8]);
            
            for j = 1:num_cidades
                text(cities(2, percursoAtual(j)), cities(1, percursoAtual(j)), ...
                     nomes{percursoAtual(j)}, 'FontSize', 8, ...
                     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
            end
            
            scatter(cities(2, percursoAtual(1)), cities(1, percursoAtual(1)), 100, 'r', 'filled');
            title(sprintf('Iteração %d - Custo: %.2f km', it, custoAtual));
            xlabel('Longitude');
            ylabel('Latitude');
            grid on; axis equal;
            drawnow;
        end
        
        % Armazenamento de histórico
        historico_probs = [historico_probs, exp(-abs(delta) / Tit)];
        historico_temperatura = [historico_temperatura, Tit];
        historico_custos = [historico_custos, custoAtual];
        i = i + 1;
        it=it+1;
    end
    
    Tit = Tit * alpha;
end
close all;



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
