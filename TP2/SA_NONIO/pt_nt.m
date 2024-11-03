% Set of 14 cities 
% Mostly in the North of Portugal
% Paulo Moura Oliveira, 2017

%-----------------------------------------------------------------------
% 1 Bragança                41N49 6W45
% 2 Vila Real               41N18 7W45
% 3 Chaves                  41N44 7W28
% 4 Viana do Castelo        41N42 8W50 
% 5 Braga                   41N33 8W26
% 6 Aveiro                  40N38 8W39
% 7 Porto                   41N11 8W36
% 8 Viseu                   40N39 7W55
% 9 Lamego                  41N06 7W49
% 10 Águeda                 40N34 8W27
% 11 Régua                  41N10 7W47
% 12 Guimarães              41N27 8W18
% 13 Valença                42N02 8W38 
% 14 Barcelos               41N32 8W37 
%----------------------------------------------------------------------- 

% Lati and Longit\\
temp_x = [ 1 41.49 6.45
 2 41.18 7.45
 3 41.44 7.28
 4 41.42 8.50
 5 41.33 8.26
 6 40.38 8.39
 7 41.11 8.36
 8 40.39 7.55
 9 41.06 7.49
 10 40.34 8.27 
 11 41.10 7.47
 12 41.27 8.18
 13 42.02 8.38
 14 41.32 8.37];

% Stores the cities coordinates in a matrix
cities = [temp_x(:,2)';temp_x(:,3)']

