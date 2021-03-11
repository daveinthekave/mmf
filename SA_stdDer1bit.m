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
n_it = 1; %1000e3;              % Iterationsanzahl
mode_target = 14;               % Nummer der Mode

% Schleife
v = [0.01, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7];
g = [50, 75, 100, 150];

bit_resolution = 1;             % Bitauflösung

maxFidelities_mean = zeros(length(v), length(g));
maxFidelities_var = zeros(length(v), length(g));
neededIterations_mean = zeros(length(v), length(g));
neededIterations_var = zeros(length(v), length(g));
neededTime_mean = zeros(length(v), length(g));
neededTime_var = zeros(length(v), length(g));

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
        
        for x = 1:9
            
            % Algorithmus
            tic;
            [simann_mask, fidelity_vals] = simulated_annealing(optical_beam, mode_target_distribution, mask, n_it, bit_resolution);
            t_total = toc/60;       % Algorithmus-Dauer [min]
            
            maxFid(x) = max(fidelity_vals);
            neededIt(x) = size(fidelity_vals, 2)+1;
            neededTi(x) = t_total;

            
        end
%             % Modulation
%             modulated_input = abs(optical_beam) .* exp(1i*angle(simann_mask));
%             modulated_input_prop = prop(modulated_input,dx,dy,lambda,dist);

        % Abspeichern
        maxFidelities_mean(i, j) = mean(maxFid);
        maxFidelities_var(i, j) = var(maxFid);
        neededIterations_mean(i, j) = mean(neededIt);
        neededIterations_var(i, j) = var(neededIt);
        neededTime_mean(i, j) = mean(neededTi);
        neededTime_var(i, j) = var(neededTi);

    end
    
end

%% save
root = 'Plots/SimulatedAnnealing/Standardabweichung/';
mkdir(root);
save(strcat(root, '/maxFidelities_mean'), 'maxFidelities_mean');
save(strcat(root, '/maxFidelities_var'), 'maxFidelities_var');
save(strcat(root, '/neededIterations_mean'), 'neededIterations_mean');
save(strcat(root, '/neededIterations_var'), 'neededIterations_var');
save(strcat(root, '/neededTime_mean'), 'neededTime_mean');
save(strcat(root, '/neededTime_var'), 'neededTime_var');

