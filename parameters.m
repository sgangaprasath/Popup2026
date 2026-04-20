function params = parameters()

%%%%%%%%%%%%%% Surface Generator for Kirigami Cut pattern %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameters to be defined
n = 9;% n=7 % Number of layers
%w = 1/n; % Step size

group_size = floor((7*n-1)/5); % 3
w = [ones(1,group_size-4)*(1/9), ...           % First 3 elements: 1/11
     ones(1,2*group_size-7)*(1/9), ...           % Next 3 elements: 2/11
     ones(1,group_size*5)*(1/9)];         % Remaining 5 elements: 3/11

starting_points = [0, cumsum(w(1:end-1))]; % starting_points(i) is the start of layer i
disp(starting_points);

% Define radius r externally (as an array corresponding to each starting point)

r = sqrt(abs(5+1*(starting_points).^2)) % inverted sphere
%r = sqrt(abs(1)) % cylinder
%r = sqrt(abs(36-starting_points.^2)); %Sphere 
%r = sqrt(abs(1-starting_points.^2)); %Saddle 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE ALL f OPTIONS (KEEP ALL EXPERIMENTS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%f = @(x,radius)  (1 - sqrt(abs(radius.^2 - (x).^2))); %used for cylinder, sphere and saddle


%%% >>> ACTIVE FUNCTION (THIS ONE IS USED) <<< for inverted sphere
f = @(x,radius) ...
    (x < (0.1*radius)).*(radius) + ...
    (x >= (0.1*radius) ).* ...
    ( sqrt( (radius-1) + 2*(x - 0.5*(radius-1)) ...
    - (x - 0.5*(radius-1)).^2 ) ...
    - (radius-1) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

csv_filename = 'Inverted_Sphere.csv';

% Store parameters
params.n = n;
params.w = w;
params.starting_points = starting_points;
params.r = r;
params.f = f;
params.csv_filename = csv_filename;

end
