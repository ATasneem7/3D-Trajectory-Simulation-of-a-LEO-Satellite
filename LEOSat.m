%% LEOSAT Capturing the Dynamics of Orbital Motion by a User-Defined Function "LEOSat"

function s_dot = LEOSat(t, s, go, R_E)

R_E = 6378;
s_dot = zeros(6, 1);
s_dot(1) = s(4);
s_dot(2) = s(5);
s_dot(3) = s(6);
s_dot(4) = (-go*R_E^2)*s(1)/(norm(s(1:3))^3);
s_dot(5) = (-go*R_E^2)*s(2)/(norm(s(1:3))^3);
s_dot(6) = (-go*R_E^2)*s(3)/(norm(s(1:3))^3);
end