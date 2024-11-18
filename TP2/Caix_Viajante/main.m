clc
clear all
close all

%MAIN
coordenadas_cities = [ 1 41.49 6.45
     2 41.18 7.24
     3 41.44 7.28
     4 41.42 8.50 
     5 41.33 8.26
     6 40.38 8.39
     7 41.11 8.36
     8 40.39 7.55
     9 41.06 7.49
     10 41.27 8.18 
     11 41.33 8.26
     12 41.31 8.37
     13 41.09 7.47
     14 42.02 8.38
     ];

cities = [coordenadas_cities(:,2)';coordenadas_cities(:,3)'];
apresenta_cidades(cities)