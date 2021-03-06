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
mode_target = 14;               % Nummer der Mode

% Schleife
v = [0.01, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7];
g = [50, 75, 100, 150];

%% 1bit

bit_resolution = 1;             % Bitauflösung
maxFidelities_1bit = zeros(length(v), length(g));
neededIterations_1bit = maxFidelities_1bit;
neededTime_1bit = maxFidelities_1bit;

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
        maxFidelities_1bit(i, j) = max(fidelity_vals)
        neededIterations_1bit(i, j) = size(fidelity_vals, 2)+1;
        neededTime_1bit(i, j) = t_total;

    end
    
end

%% 4bit

bit_resolution = 4;             % Bitauflösung
maxFidelities_4bit = zeros(length(v), length(g));
neededIterations_4bit = maxFidelities_4bit;
neededTime_4bit = maxFidelities_4bit;

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
        maxFidelities_4bit(i, j) = max(fidelity_vals)
        neededIterations_4bit(i, j) = size(fidelity_vals, 2)+1;
        neededTime_4bit(i, j) = t_total;

    end
    
end

%% 8bit

bit_resolution = 8;             % Bitauflösung
maxFidelities_8bit = zeros(length(v), length(g));
neededIterations_8bit = maxFidelities_8bit;
neededTime_8bit = maxFidelities_8bit;

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
        maxFidelities_8bit(i, j) = max(fidelity_vals)
        neededIterations_8bit(i, j) = size(fidelity_vals, 2)+1;
        neededTime_8bit(i, j) = t_total;

    end
end

%% save
root = 'Plots/SimulatedAnnealing/';
mkdir(root);
save(strcat(root, '/maxFidelities_1bit'), 'maxFidelities_1bit');
save(strcat(root, '/maxFidelities_4bit'), 'maxFidelities_4bit');
save(strcat(root, '/maxFidelities_8bit'), 'maxFidelities_8bit');
save(strcat(root, '/neededIterations_1bit'), 'neededIterations_1bit');
save(strcat(root, '/neededIterations_4bit'), 'neededIterations_4bit');
save(strcat(root, '/neededIterations_8bit'), 'neededIterations_8bit');
save(strcat(root, '/neededTime_1bit'), 'neededTime_1bit');
save(strcat(root, '/neededTime_4bit'), 'neededTime_4bit');
save(strcat(root, '/neededTime_8bit'), 'neededTime_8bit');
