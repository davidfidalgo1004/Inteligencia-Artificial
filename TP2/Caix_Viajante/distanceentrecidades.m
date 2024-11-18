function d = distanceentrecidades(inputcities)


d = 0;
for n = 1 : length(inputcities)
    if n == length(inputcities)
        d = d + geo_distance(inputcities(:,n),inputcities(:,1)); 
    else    
        d = d + geo_distance(inputcities(:,n),inputcities(:,n+1));
    end
end
