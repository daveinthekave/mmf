% ------------------------------------------------------------------------
% plot_LP_mode
% ------------------------------------------------------------------------
% Michael Hughes October 2016
% Version 1.0
% ------------------------------------------------------------------------
% Plots a fibre LP mode (sin and cos version)
% 
% Usage:
%     [modeCos, modeSin] = plot_LP_mode(order, u, w, coreRadius, maxPlotRadius, gridSize)
%
% Parameters:
%   coreRadius     : radius of the core (microns)
%   order          : mode order
%   u              : mode core u term (microns)
%   w              : mode core w term (microns)
%   maxPlotRadius  : radius at edge of grid (i.e. grid is 2x this)
%   gridSize       : number of pixels in grid
%
% Returns:
%   modeSin        : 2D array of mode amplitude (sin)
%   modeCos        : 2D array of mode amplitude (cos)
% ------------------------------------------------------------------------
function [modeCos, modeSin] = plot_LP_mode(order, u, w, coreRadius, maxPlotRadius, gridSize)

    % Find centre of grid
    gridCentre = gridSize / 2;
    
    %Initialise output array
    modeCos = zeros(gridSize, gridSize);
    modeSin = zeros(gridSize, gridSize);
    
    % Calculate grid points
    gridPoints = (1:gridSize) - gridCentre;
    [xMesh, yMesh] = meshgrid(gridPoints, gridPoints);
    
    % Convert  to polar co-ordinates
    [angle, rad] = cart2pol(xMesh,yMesh);
    rad = rad ./ (gridSize / 2) * maxPlotRadius;
    
    % Calculate the cos term
    cosTerm = cos(order .* angle);
    sinTerm = sin(order .* angle);
         
    % Calculate the core and cladding functions
    coreBessel = besselj(order,u ./ coreRadius .* rad)/besselj(order,u);
    claddingBessel = besselk(order, w ./ coreRadius .* rad)/besselk(order,w);
    
    % Work out which grid points are in core and which in cladding
    inCore = (rad <= coreRadius) & (rad <= maxPlotRadius);
    inCladding = (rad > coreRadius) & (rad <= maxPlotRadius);
    
    % Calculate sin and cos versions of core field
    modeCos(inCore) = coreBessel(inCore) .* cosTerm(inCore);
    modeSin(inCore) = coreBessel(inCore) .* sinTerm(inCore); 
    
    % Calculate sin and cos versions of cladding field
    modeCos(inCladding) = claddingBessel(inCladding) .* cosTerm(inCladding);
    modeSin(inCladding) = claddingBessel(inCladding) .* sinTerm(inCladding);    
 
end