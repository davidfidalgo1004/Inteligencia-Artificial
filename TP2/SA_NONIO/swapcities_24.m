% swapcities_24
% returns a set of m cities where n cities are randomly swaped. 

function s = swapcities_24(inputcities,n)


% Stores inputcities
s = inputcities;

for i = 1 : n
    % city_1- random number betweeen 0-nº of cities
    city_1 = round(length(inputcities)*rand(1));
    if city_1 < 1 
        city_1 = 1;
    end
    % city_2- random number betweeen 0-nº of cities
    city_2 = round(length(inputcities)*rand(1));
    if city_2 < 1
        city_2 = 1;
    end
    % temp variable for swapping city_1 with city_2 coordinates
    temp = s(:,city_1);
    s(:,city_1) = s(:,city_2);
    s(:,city_2) = temp;
    
end