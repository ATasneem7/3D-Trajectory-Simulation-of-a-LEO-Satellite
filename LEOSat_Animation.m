%% ----Low Earth Orbit (LEO) Satellite Motion Animation---- %%

% Defining Earth Parameters
R_E = 6378;                                      % in km
go  = 9.81e-3;                                   % km/s^2

% Initial Conditions
s01 = 3858.213;                                  % in km
s02 = -5798.143;                                 % in km
s03 = 14.693;                                    % in km
s04 = -0.863;                                    % in km/s                
s05 = -0.542;                                    % in km/s
s06 = 7.497;                                     % in km/s
initial_states = [s01;s02;s03;s04;s05;s06];

% Defining a Time Interval
tspan = 0:0.01:30000;                             % in secs 

% Error Tolerance
tolerance = 1e-9;
options = odeset("RelTol",tolerance, "AbsTol", tolerance);

% Implementation of ODE45 Numerical Solver
[t, S] = ode45(@LEOSat, tspan, initial_states, options, go, R_E);

% Extracting the Position Data from the State Vector
X_Positions = S(:, 1);
Y_Positions = S(:, 2);
Z_Positions = S(:, 3);

%% Animating the LEO Satellite around the Blue Marble Earth Model 

% Setting Up Figure Properties 
fig = figure('Name','LEO Satellite Trajectory Animation',...
             'Position',[100,100,800,600],'Color','k',...
             'Renderer','opengl');  

% Setting Up axes properties
ax = axes('Parent',fig);
hold(ax,'on'); 
grid(ax,'on'); 
grid(ax,"minor");
axis(ax,'equal');

set(ax,'Color','k','XColor','w','YColor','w','ZColor','w','LineWidth',2,...
       'GridColor','w','GridLineWidth',1.5,'GridAlpha',0.45,...
       'MinorGridLineStyle',':','MinorGridAlpha',0.2,...
       'MinorGridLineWidth',1,'SortMethod','depth');

xlim([-7 7]*1000); ylim([-7 7]*1000); zlim([-7 7]*1000);

xlabel(ax,'x (km)','FontSize',12,'FontWeight','bold','Color','w');
ylabel(ax,'y (km)','FontSize',12,'FontWeight','bold','Color','w');
zlabel(ax,'z (km)','FontSize',12,'FontWeight','bold','Color','w');
title(ax,'3D Orbit Propagation of a LEOSat','Color','w', ...
      'FontSize',12,'FontWeight','bold');

% Camera Positioning & Lighting
view(ax,170,25);                     
camproj(ax,'perspective');           
axis(ax,'manual');                   

camlight(ax,'headlight');            
lighting(ax,'gouraud');             
material(ax,'dull');                

%% Defining Body Geometries

% Static Orbit Trail
orbitPath = plot3(ax, X_Positions, Y_Positions, Z_Positions,...
                  'Color',[1 0.85 0],'LineWidth',2,'Clipping','off');

%Earth Model using NASA Texture
earthImg = imread('2k_earth_daymap.jpg');  
earthImg = flipud(earthImg); 
[Xe,Ye,Ze] = sphere(80);           % smooth sphere
earthSurf = surf(ax, R_E*Xe, R_E*Ye, R_E*Ze,'FaceColor','texturemap', ...
                'CData', earthImg,'FaceLighting','gouraud',...
                'EdgeColor','none');

% Satellite Geometry (Bus + Solar Panels)
satVisualScale = 150;                          % visual scaling
L = 4; W = 2.25; H = 2.25;

V_bus = [-L/2 -W/2 -H/2;
          L/2 -W/2 -H/2;
          L/2  W/2 -H/2;
         -L/2  W/2 -H/2;
         -L/2 -W/2  H/2;
          L/2 -W/2  H/2;                        % bus vertices
          L/2  W/2  H/2;
         -L/2  W/2  H/2];

F_bus = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];

busPatch = patch(ax,'Faces',F_bus,'Vertices',V_bus,'FaceColor',...
          '#DBDFEA','EdgeColor','k', 'lineWidth', 1.10);

% Solar panels
panel_L = 4.5; panel_W = 1.85;

V_panel = [0 -panel_W/2 0;
           panel_L -panel_W/2 0;
           panel_L  panel_W/2 0;
           0  panel_W/2 0];

F_panel = [1 2 3 4];

panel1 = patch(ax,'Faces',F_panel,'Vertices',V_panel,'FaceColor',...
         '#F79A19','EdgeColor', '#F79A19', 'lineWidth', 1.15);

panel2 = patch(ax,'Faces',F_panel,'Vertices',V_panel,'FaceColor',...
        '#F79A19','EdgeColor', '#F79A19', 'lineWidth', 1.15);

% Video Writer Setup
videoFileName = 'LEOSat_Animation.mp4';
videoObj = VideoWriter(videoFileName,'MPEG-4');
videoObj.FrameRate = 15;  
open(videoObj);

% Optimized Animation Loop for Satellite Motion
skip = 2000; 

for k = 1:skip:length(t)
    r = [X_Positions(k), Y_Positions(k), Z_Positions(k)];
    
    % Move satellite bus
    busPatch.Vertices = satVisualScale*V_bus + r;
    
    % Move solar panels
    panel1.Vertices = satVisualScale*(V_panel + [L/2 0 0]) + r;
    panel2.Vertices = satVisualScale*((V_panel.*[-1 1 1]) - [L/2 0 0])+ r;
    
    drawnow nocallbacks;  % Efficient rendering
    
    % Capture frame for video
    frame = getframe(fig);
    writeVideo(videoObj, frame);
end

% Close Video and Open Automatically
close(videoObj);
winopen(videoFileName);