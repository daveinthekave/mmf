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
verhaeltnis = 0.4;

% Speicherordner
root = 'Plots/DirectSearch/Ortsfrequenzen/';
mkdir(root);

load("data_mode_combos_spatial_frequencies_2.mat");
vectors = cat(3, mode_vec_r3, mode_vec_r4, mode_vec_r5, mode_vec_r6, mode_vec_r7);

b = [1, 4, 8];
g = [50, 150];


for radius=3:7
    
    mode_vector = vectors(:,:,radius-2);

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
            maxFidelities = zeros(1,10);

            for i=1:10
    %             mode_target_distribution = mix_modes(modes, squeeze(all_mix_vector(i,:,:)));
                mode_target_distribution = zeros(size(modes, 2, 3));
                for mode=1:size(modes, 1)
                    current_mode = squeeze(modes(mode,:,:));
                    current_mix = mode_vector(i,mode);
                    mode_target_distribution = mode_target_distribution + current_mode .* current_mix;        % aktuelle Mode * Gewicht addieren
                end

                % Algorithmus
                [simann_mask, fidelity_vals] = simulated_annealing(optical_beam, mode_target_distribution, mask, n_it, bit_resolution);

                maxFidelities(i) = max(fidelity_vals);


            %     % Modulation
            %     modulated_input = abs(optical_beam) .* exp(1i*angle(simann_mask));
            %     modulated_input_prop = prop(modulated_input,dx,dy,lambda,dist);

            end  %i

            save(fullfile(root, strcat(num2str(radius), 'px_radius_', strcat(num2str(bit_resolution), 'bit_', num2str(gridSize), 'gridSize'))), 'maxFidelities');

    %         maxFid_mean(x,y) = mean(maxFidelities(x,y,:));
    %         maxFid_var(x,y) = var(maxFidelities(x,y,:));

        end  %y

    end  %x

end %radius

%% save

% save(strcat(root, '/maxFidelities'), 'maxFidelities');
% save(strcat(root, '/maxFidelities_mean'), 'maxFid_mean');
% save(strcat(root, '/maxFidelities_var'), 'maxFid_var');

% save(fullfile(root, strcat(num2str(bit_resolution), '-bit-fidelity_vals')), 'fidelity_vals');

