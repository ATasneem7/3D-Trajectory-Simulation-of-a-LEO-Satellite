%% Trajectory Modeling & Analysis of LEO Satellite

% Earth Parameters
R_E = 6378;                       % in km
go  = 9.81e-3;                    % km/s^2


% Initial States of LEOSat
s01 = 3858.213;                                  % in km
s02 = -5798.143;                                 % in km
s03 = 14.693;                                    % in km
s04 = -0.863;                                    % in km/s                
s05 = -0.542;                                    % in km/s
s06 = 7.497;                                     % in km/s
initial_states = [s01;s02;s03;s04;s05;s06];

%% 
% Time Interval
tspan = 0:0.01:30000;                             % in secs

% Error Tolerance
tolerance = 1e-9;
options = odeset("RelTol",tolerance, "AbsTol", tolerance);

% Implementation of ODE45 Numerical Solver
[t, S] = ode45(@LEOSat, tspan, initial_states, options, go, R_E);

%% 
% Extracting the Position and Velocity Data from the State Vector
X_Positions = S(:, 1);
Y_Positions = S(:, 2);
Z_Positions = S(:, 3);
V_Xcomp = S(:, 4);
V_Ycomp = S(:,5);
V_Zcomp = S(:,6);


% Computation of the Final Position and Velocity of the Satellite
Sat_Positions  = sqrt(X_Positions.^2 + Y_Positions.^2 + Z_Positions.^2);
Sat_Final_Position = Sat_Positions(length(t));
disp('Position (km) at t = 30,000 seconds:');
disp(Sat_Final_Position);

Sat_Velocities = sqrt(V_Xcomp.^2 + V_Ycomp.^2 + V_Zcomp.^2);
Sat_Final_Velocity = Sat_Velocities(length(t));
disp('Velocity (km/s) at t = 30,000 seconds:');
disp(Sat_Final_Velocity);

%% 
% Plotting the Earth as a Perfect Sphere
fig1 = figure();
set(fig1,'color','white')
[X,Y,Z] = sphere(100);
X = X*R_E;
Y = Y*R_E;
Z = Z*R_E;
surf(X,Y,Z,'EdgeColor','none')
colormap();
hold on

% Plotting the Orbital Plane in a 3D Space
plot3(X_Positions,Y_Positions, Z_Positions,'y-o','LineWidth',3,'MarkerSize',2)
xlabel('x (km)','FontSize', 12,'FontWeight','bold');
ylabel('y (km)','FontSize', 12,'FontWeight','bold');
zlabel('z (km)','FontSize', 12,'FontWeight','bold');
legend('Earth', 'Orbit');
title('Numerical Propagation of a LEO Satellite Trajectory in 3D Space');
axis equal
grid on
hold off

%% 
% Computing Total Specific Energy & Angular Momentum at each time step
Energy = zeros(length(t), 1);
AngularMomentum = zeros(length(t), 1);
for i = 1:length(t)
    r = norm(S(i, 1:3));
    v = norm(S(i, 4:6));
    Energy(i) = 0.5 * v^2 - go*R_E^2 / r; % Specific orbital energy (km^2/s^2)
    AngularMomentum(i) = norm(cross(S(i, 1:3), S(i, 4:6)));
end

%% 
% Calculate the initial specific energy
Energy_initial = Energy(1);

% Calculate the relative error in specific energy
Energy_error = abs((Energy - Energy_initial) / Energy_initial);


% Plot energy over time
fig2 = figure();
subplot(2,1,1);
plot(t, Energy, 'b', 'LineWidth', 0.75);
grid on
axis tight
xlabel('Time (s)');
ylabel('Specific Energy (km^2/s^2)');
title('Specific Orbital Energy Over Time');

% Plot Relative Error in Specific Energy
subplot(2,1,2);
plot(t, Energy_error, 'r', 'LineWidth', 0.001);
grid on;
xlim([200 30000]);
xlabel('Time (s)');
ylabel('Relative Energy Error');
title('Relative Error in Specific Orbital Energy');

%%
% Calculate the initial angular momentum
Momentum_initial = AngularMomentum(1);

% Calculate the relative error in angular momentum
Momentum_error = abs((AngularMomentum - Momentum_initial) / Momentum_initial);

% Plot momentum over time
fig3 = figure();
subplot(2,1,1);
plot(t, AngularMomentum, 'g', 'LineWidth', 1.5);
grid on;
xlabel('Time (s)');
ylabel('Specific Angular Momentum (km^2/s)');
title('Specific Angular Momentum Over Time');

% Plot Relative Error in Angular Momentum
subplot(2,1,2);
plot(t, Energy_error, 'r', 'LineWidth', 0.001);
grid on;
xlabel('Time (s)');
ylabel('Relative Momentum Error');
title('Relative Error in Orbital Angular Energy');