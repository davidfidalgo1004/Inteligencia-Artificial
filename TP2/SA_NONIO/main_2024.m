%-------------------------------------------------------------------
% TSP 
% Main program
% -to load the cities dataset 
% -to call function to evaluate the trip distance
% --------------------------------------------

clc             % Clear screen
clear all;      % Clear all variables from workspace
close all;      % Close all figures

%------------------------------------------------------------------------
% Loading 14 cities in the north of Portugal 
% pt_nt;
% set_id=1; 
%-----------------------------------------------------------------------
% Loading 20 cities in Portugal 
  % pt_nt_sul_20;
  % set_id=2; 
%-----------------------------------------------------------------------
% Loading 30 cities in Portugal 
  pt_nt_sul_30;
  set_id=2; 


% Input Settings
inputcities=cities;
plotcities_2024(inputcities,set_id);

% % Call function distance to evaluate the round trip geographical distance
dist = distance_24(inputcities);
fprintf(1,'The roundtrip length for %d cities is %4.2f Km\n',length(inputcities),dist);
 
