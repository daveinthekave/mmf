function [modeAmplitude, map, map1] = LP_modes(nCore,nCladding,wavelength,coreRadius,gridSize,plot_distance)

% Define the fibre characteristics and wavelength
% NA = sqrt(nCore^2-nCladding^2);
% nCore = 1.44;
% nCladding = 1.42;
% wavelength = 0.5;           % in um
% coreRadius = 15;            % in um
% for M14L02 - ?0 µm, 0.22 NA, SMA-SMA Fiber Patch Cable, Low OH, 2 Meters
% nCore = 1.4607; % at 20 deg C --> Pure Silica/ fused Silica
% nCladding = 1.4440375; % at 20 deg C --> Fluorine-Doped Silica  
% wavelength = 0.532;           % in um
% coreRadius = 5;            % in um

% Define the plot area
maxPlotRadius = coreRadius * plot_distance;  % Lets us see the power in the cladding
% simulation needs 60 gridpoints per um

% Find all the LP modes
[modes, nModes, map, map1] = find_LP_modes(coreRadius, nCore, nCladding, wavelength);

% Calculate the 2D field amplitudes of the LP modes
rotations=1;
modeAmplitude = plot_all_LP_modes(modes, coreRadius, maxPlotRadius, gridSize, rotations);


