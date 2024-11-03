% Function distance_24
% Evaluates de round trip distance
% Modified by PMO for evaluating geographical distances

function d = distance_24(inputcities)


d = 0;
for n = 1 : length(inputcities)
    if n == length(inputcities)
        d = d + geo_distance(inputcities(:,n),inputcities(:,1)); 
    else    
        d = d + geo_distance(inputcities(:,n),inputcities(:,n+1));
    end
end
