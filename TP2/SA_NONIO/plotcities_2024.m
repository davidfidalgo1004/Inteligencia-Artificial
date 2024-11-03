% This function plots the cities with coordinates in
% the array inputcities(2xn)
% rows - coordinates in the form of latitute and longitude
% columns - cities
% set_id - ste identification to adjust plotting scale

function f = plotcities_2024(inputcities,set_id)



shg  % Show graph window
% temp_1  = plot(inputcities(1,:),inputcities(2,:),'b*');
% set(temp_1,'erasemode','none');
clf

temp_2 = line(inputcities(1,:),inputcities(2,:),'Marker','o','Markersize',6,'Markerfacecolor','r');
set(temp_2,'color','r');
xlabel('Lati.')
ylabel('Longi.')

% -------------------------------------------------------------------
% In the case of cities in the North Portugal you can use the following
if set_id == 1
  axis([40.2 42.3 6.2 8.7])
elseif set_id == 2
%--------------------------------------------------------------------
% In the case of cities all over Portugal you can use the following
 axis([36.5 42 6 9.5])
else 
    fprintf(1,'Error in the set_id number');
end

  
% Original----------------------------------------
x = [inputcities(1,1) inputcities(1,length(inputcities))];
y = [inputcities(2,1) inputcities(2,length(inputcities))];

temp_3 = line(x,y);
set(temp_3,'color','r');

