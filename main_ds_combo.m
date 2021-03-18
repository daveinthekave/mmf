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
n_it = 1;                  % Iterationsanzahl
verhaeltnis = 0.4;

load("all_mix_vector.mat");

b = [1, 4, 8];
g = [50, 150];

% Schleife
for x=1:length(g)

    gridSize = g(x);
    
    % Verschiedenes vor der Schleife
    optical_beam = ones(gridSize,gridSize);     % Laserstrahl
    [X,Y] = meshgrid(1:gridSize,1:gridSize);
    desired_signal_size = round(gridSize*sqrt(verhaeltnis));

    % Maske für Fidelity-Berechnung
    mask = (X-gridSize/2).^2+(Y-gridSize/2).^2<(desired_signal_size/2).^2;

    % Modenerzeugung
    modes = build_modes_SA(nCore,nCladding,wavelength,coreRadius, desired_signal_size, plot_distance);  

    for y=1:length(b)
        
        bit_resolution = b(y);
        
        for i=1:100
            mode_target_distribution = mix_modes(modes, squeeze(all_mix_vector(i,:,:)));

            % Algorithmus
            [simann_mask, fidelity_vals] = simulated_annealing(optical_beam, mode_target_distribution, mask, n_it, bit_resolution);

            maxFidelities(x,y,i) = max(fidelity_vals);
            

        %     % Modulation
        %     modulated_input = abs(optical_beam) .* exp(1i*angle(simann_mask));
        %     modulated_input_prop = prop(modulated_input,dx,dy,lambda,dist);
        
        end  %i
        
        maxFid_mean(x,y) = mean(maxFidelities(x,y,:));
        maxFid_var(x,y) = var(maxFidelities(x,y,:));

    end  %y
    
end  %x



%% save
root = 'Plots/DirectSearch/Modenkombinationen/';
mkdir(root);
save(strcat(root, '/maxFidelities'), 'maxFidelities');
save(strcat(root, '/maxFidelities_mean'), 'maxFid_mean');
save(strcat(root, '/maxFidelities_var'), 'maxFid_var');


