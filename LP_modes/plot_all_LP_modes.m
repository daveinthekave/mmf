% ------------------------------------------------------------------------
% plot_all_LP_modes
% Version 1.0    October 2016
% ------------------------------------------------------------------------
% Michael Hughes 
% michael.robert.hughes@gmail.com       www.mike-hughes.org
% ------------------------------------------------------------------------
% Plots a series of fibre LP modes. Details of the modes are
% provided in the format returned by find_LP_modes.
% 
% Usage:
%     [modeAmplitude, modeID] = plot_all_LP_modes(modes, coreRadius, ...
%                                 maxPlotRadius, gridSize, plotRotations)
%
% Parameters:
%   modes          : struct returned by find_LP_modes
%   coreRadius     : radius of fibre core (micfons)
%   maxPlotRadius  : radius at edge of grid (microns)
%   gridSize       : number of pixels in grid
%   plotRotations  : if 1, plots both sin and cos orientations of mode
% 
% Returns:
%   modeAmplitude  : 3D array of dimensions (num modes, gridSize, gridSize)
%   modeID         : vector giving the index of the input 'modes' to which
%                    each plot corresponds. This deals with the fact that,
%                    if plotRotations = 1, modeAmplitude will contain 
%                    sin and cos plots consecutively, and so the ith plot 
%                    will not correspond to the ith mode.
% ------------------------------------------------------------------------
function [modeAmplitude, modeID] = plot_all_LP_modes(modes, coreRadius, maxPlotRadius, gridSize, plotRotations)

    % If we are plotting both sin and cos orientations then the number of
    % modes will be increase by the number of modes with m > 1. (m = 1
    % modes are rotationally symmetric)
    
    if (plotRotations==1)
        totalNumModes = length(modes) + sum(cell2mat({modes.m}) > 1);
    else
        totalNumModes = length(modes);
    end
    
    % Initialise output arrays
    modeAmplitude = zeros(totalNumModes, gridSize, gridSize);
    modeID = zeros(1,totalNumModes);
    
    n = 0;
    for i = 1: length(modes)
        n = n + 1;
        
        % Plot this mode
        [modeAmplitude(n,:,:), rotatedMode] = plot_LP_mode(modes(i).order, modes(i).u, modes(i).w, coreRadius, maxPlotRadius, gridSize);
        
        % Record which item from modes it belongs to
        modeID(n) = i;
        
        % If we are plotting cos orientations and this modes is not
        % rotationally invariant then also store the cos orientation
        if (plotRotations == 1) && (modes(i).order > 0)
            n = n + 1;
            modeAmplitude(n,:,:) = rotatedMode;
            modeID(n) = i;
        end    
    end        
            
end