% ----------------------------------------------------------
% Function to evaluate the geographical distance 
% Conversion from coordinates
% Inputs: [ lat1, long1], [lat2, long2]
%-----------------------------------------------------------


function [dist] = geo_distance(city_1,city_2)


% City 1
x_graus_city_1 = fix(city_1(1));
min_x_city_1 = city_1(1)-x_graus_city_1;
lati_city_1=pi*(x_graus_city_1 + 5*min_x_city_1/3)/180;

y_graus_city_1 = fix(city_1(2));
min_y_city_1 = city_1(2)-y_graus_city_1;
longi_city_1=pi*(y_graus_city_1 + 5*min_y_city_1/3)/180;

% City 2
x_graus_city_2 = fix(city_2(1));
min_x_city_2 = city_2(1)-x_graus_city_2;
lati_city_2=pi*(x_graus_city_2 + 5*min_x_city_2/3)/180;

y_graus_city_2 = fix(city_2(2));
min_y_city_2 = city_2(2)-y_graus_city_2;
longi_city_2=pi*(y_graus_city_2 + 5*min_y_city_2/3)/180;


RRR = 6378.388;   % Idealized sphere radius
q1 = cos( longi_city_1 - longi_city_2 );
q2 = cos( lati_city_1 - lati_city_2 );
q3 = cos( lati_city_1 + lati_city_2 );
dist = fix ( RRR * acos( 0.5*((1.0+q1)*q2 - (1.0-q1)*q3) ) + 1.0);








