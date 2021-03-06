% Parameter Multimodefibre
NA=0.1;
nCore = 1.4607;                 % bei 20 Grad C -> Pure Silica/ fused Silica
nCladding = sqrt(nCore^2-NA^2); % bei 20 Grad C -> Fluorine-Doped Silica  
wavelength = 0.532;             % in um
coreRadius = 25/2;              % in um
plot_distance = 1.1;

% Propagationsparameter
dx=8e-6;dy=dx;                  % Pixelgröße des SLM [m]
lambda=532e-9;                  % Wellenlänge [m]
dist=0.5;                       % Propagationsdistanz [m]

% Freiheitsgrade
n_it = 1000e3;                  % Iterationsanzahl
bit_resolution = 4;             % Bitauflösung
mode_target = 14;               % Nummer der Mode

% Schleife
v = [0.01, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7];
g = [50, 75, 100, 150];
maxFidelities = zeros(length(v), length(g));
neededIterations = maxFidelities;
neededTime = maxFidelities;

for j = 1:length(g)
    
    gridSize = g(j);                 % Größe des Freespace

    % Verschiedenes vor der Schleife
    optical_beam = ones(gridSize,gridSize);     % Laserstrahl
    [X,Y] = meshgrid(1:gridSize,1:gridSize);


    for i = 1:length(v)

        verhaeltnis = v(i);              % Verhältnis
        desired_signal_size =  round(gridSize*sqrt(verhaeltnis));

        % Modenerzeugung
        modes=build_modes_SA(nCore,nCladding,wavelength,coreRadius, desired_signal_size, plot_distance);       
        mode_target_distribution=squeeze(modes(mode_target,:,:));

        % Maske für Fidelity-Berechnung
        mask = (X-gridSize/2).^2+(Y-gridSize/2).^2<(desired_signal_size/2).^2;

        % Algorithmus
        tic;
        [simann_mask, fidelity_vals] = simulated_annealing(optical_beam, mode_target_distribution, mask, n_it, bit_resolution);
        t_total = toc/60;       % Algorithmus-Dauer [min]

        % Modulation
        modulated_input = abs(optical_beam) .* exp(1i*angle(simann_mask));
        modulated_input_prop = prop(modulated_input,dx,dy,lambda,dist);

        % Abspeichern
        maxFidelities(i, j) = max(fidelity_vals)
        neededIterations(i, j) = size(fidelity_vals, 2)+1;
        neededTime(i, j) = t_total;

    end
    
end
