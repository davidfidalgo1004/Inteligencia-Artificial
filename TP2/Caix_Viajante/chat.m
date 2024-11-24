% Coordenadas das cidades (latitude, longitude)
cidades = [
    41.8167, -6.7500;  % Bragança
    41.3000, -7.7500;  % Vila Real
    41.7333, -7.4667;  % Chaves
    41.4500, -8.3000;  % Guimarães
    41.5500, -8.4333;  % Braga
    41.7000, -8.8333;  % Viana do Castelo
    42.0333, -8.6333;  % Valença do Minho
    41.5333, -8.6167;  % Barcelos
    41.1833, -8.6000;  % Porto
    40.6333, -8.6500;  % Aveiro
    40.5667, -8.4500;  % Águeda
    40.6500, -7.9167;  % Viseu
    41.1000, -7.8167;  % Lamego
    41.1667, -7.7833;  % Peso da Régua
];

n = size(cidades, 1);  % Número de cidades

% Nomes das cidades
nomes = { ...
    'Bragança', 'Vila Real', 'Chaves', 'Guimarães', 'Braga', ...
    'Viana do Castelo', 'Valença do Minho', 'Barcelos', 'Porto', ...
    'Aveiro', 'Águeda', 'Viseu', 'Lamego', 'Peso da Régua' ...
};

% calculo de distancia entre dois pontos
distancia = @(c1, c2) sqrt((c1(1) - c2(1))^2 + (c1(2) - c2(2))^2)

% Função de custo (soma total das distâncias no percurso)
calculaCusto = @(percurso) sum(arrayfun(@(i) distancia(cidades(percurso(i), :), cidades(percurso(mod(i, n) + 1), :)), 1:n));

% Parâmetros do Simulated Annealing
T_inicial = 100;      % Temperatura inicial
T_final = 1e-3;       % Temperatura final
alpha = 0.99;         % Fator de redução da temperatura
iteracoes = 100;      % Iterações por temperatura

% Inicialização
percursoAtual = randperm(n);
custoAtual = calculaCusto(percursoAtual);
melhorPercurso = percursoAtual;
melhorCusto = custoAtual;

T = T_inicial;

% Algoritmo Simulated Annealing
while T > T_final
    for k = 1:iteracoes
        % Geração de um vizinho (troca de duas cidades aleatórias)
        vizinho = percursoAtual;
        idx = randperm(n, 2);
        vizinho(idx) = vizinho(flip(idx));
        
        % Cálculo do custo do vizinho
        custoVizinho = calculaCusto(vizinho);
        
        % Decisão de aceitação
        delta = custoVizinho - custoAtual;
        if delta < 0 || rand < exp(-delta / T)
            percursoAtual = vizinho;
            custoAtual = custoVizinho;
        end
        
        % Atualização do melhor percurso encontrado
        if custoAtual < melhorCusto
            melhorPercurso = percursoAtual;
            melhorCusto = custoAtual;
        end
    end
    % Atualização da temperatura
    T = T * alpha;
end

% Resultados
disp('Melhor percurso encontrado:');
disp(melhorPercurso);
disp('Distância total:');
disp(melhorCusto);

% Visualização do percurso
figure;
hold on;
for i = 1:n
    % Coordenadas da cidade atual e da próxima no percurso
    cidadeAtual = cidades(melhorPercurso(i), :);
    cidadeProxima = cidades(melhorPercurso(mod(i, n) + 1), :);
    
    % Calcular a diferença entre as cidades para determinar a direção
    dx = cidadeProxima(2) - cidadeAtual(2);  % Diferença em longitude
    dy = cidadeProxima(1) - cidadeAtual(1);  % Diferença em latitude
    
    % Desenhar uma seta usando 'quiver'
    quiver(cidadeAtual(2), cidadeAtual(1), dx, dy, 0, 'r', 'LineWidth', 1.5, 'MaxHeadSize', 0.5);
end

% Adicionar as cidades como pontos e mostrar os nomes
plot(cidades(:, 2), cidades(:, 1), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
for i = 1:n
    % Adicionar o nome de cada cidade próximo ao ponto
    text(cidades(i, 2), cidades(i, 1), nomes{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
end

title('Melhor percurso encontrado com setas');
xlabel('Longitude');
ylabel('Latitude');
grid on;
hold off;
