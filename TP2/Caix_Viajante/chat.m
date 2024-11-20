% Coordenadas das cidades (latitude, longitude)
cidades = [
    41.15, -8.61;  % Porto
    38.72, -9.14;  % Lisboa
    40.64, -8.65;  % Aveiro
    41.54, -8.42;  % Braga
    37.02, -7.93;  % Faro
    39.74, -8.82;  % Leiria
    38.88, -6.97;  % Évora
    40.21, -8.41;  % Coimbra
    41.12, -8.34;  % Guimarães
    41.37, -8.29;  % Vila do Conde
    38.57, -7.91;  % Beja
    40.66, -7.91;  % Viseu
    39.82, -7.49;  % Castelo Branco
    39.68, -8.44   % Tomar
];

n = size(cidades, 1);  % Número de cidades

% Função de cálculo da distância euclidiana
distancia = @(c1, c2) sqrt((c1(1) - c2(1))^2 + (c1(2) - c2(2))^2);

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

% Adicionar as cidades como pontos
plot(cidades(:, 2), cidades(:, 1), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');

title('Melhor percurso encontrado com setas');
xlabel('Longitude');
ylabel('Latitude');
grid on;
hold off;