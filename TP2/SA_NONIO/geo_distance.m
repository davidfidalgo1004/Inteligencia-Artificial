% ----------------------------------------------------------
% Function to evaluate the geographical distance 
% Conversion from coordinates
% Inputs: [ lat1, long1], [lat2, long2]
%-----------------------------------------------------------


function [dist] = geo_distance(cidade_partida,cidade_chegada)


    % City 1
    %latitude
    x_graus_city_1 = fix(cidade_partida(1)); %remove a parte decimal
    min_x_city_1 = cidade_partida(1)-x_graus_city_1; %calcula a parte decimal da coordenada de latitude subtraindo a parte inteira (calculada anteriormente) do valor original.
    lati_city_1=pi*(x_graus_city_1 + 5*min_x_city_1/3)/180; %passa para radianos
    
    %longitude
    y_graus_city_1 = fix(cidade_partida(2));
    min_y_city_1 = cidade_partida(2)-y_graus_city_1;
    longi_city_1=pi*(y_graus_city_1 + 5*min_y_city_1/3)/180;
    
    % City 2
    x_graus_city_2 = fix(cidade_chegada(1));
    min_x_city_2 = cidade_chegada(1)-x_graus_city_2;
    lati_city_2=pi*(x_graus_city_2 + 5*min_x_city_2/3)/180;
    
    y_graus_city_2 = fix(cidade_chegada(2));
    min_y_city_2 = cidade_chegada(2)-y_graus_city_2;
    longi_city_2=pi*(y_graus_city_2 + 5*min_y_city_2/3)/180;
    
    
    RRR = 6378.388;   % raio da terra
    q1 = cos( longi_city_1 - longi_city_2 );
    q2 = cos( lati_city_1 - lati_city_2 );
    q3 = cos( lati_city_1 + lati_city_2 );
    dist = fix ( RRR * acos( 0.5*((1.0+q1)*q2 - (1.0-q1)*q3) ) + 1.0);




end



