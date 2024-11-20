function f = apresenta_cidades(inputcities)
    shg  % Show graph window
    clf
    temp_2 = line(inputcities(1,:),inputcities(2,:),'Marker','o','Markersize',6,'Markerfacecolor','r');
    set(temp_2,'color','r');
    xlabel('Latitude')
    ylabel('Longitude')
    axis([37 43 7 9])
    x = [inputcities(1,1) inputcities(1,length(inputcities))];
    y = [inputcities(2,1) inputcities(2,length(inputcities))];

    temp_3 = line(x,y);
    set(temp_3,'color','r');
    temp_3 = line(x,y);
    set(temp_3,'color','r');
end