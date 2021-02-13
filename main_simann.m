% main
clear all;

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
n_it = 60e3;                     % Iterationsanzahl
bit_resolution = 8;             % Bitauflösung
desired_signal_size = 30;       % Größe des Signalbereichs
verhaeltnis = .2;               % Verhältnis zwischen Signal- und Gesamtbereich
mode_target = 14;               % Nummer der Mode

% Modenerzeugung
gridSize = round(desired_signal_size/sqrt(verhaeltnis));
modes=build_modes_SA(nCore,nCladding,wavelength,coreRadius, desired_signal_size, plot_distance);       
mode_target_distribution=squeeze(modes(mode_target,:,:));

% Maske für Fidelity-Berechnung
[X,Y] = meshgrid(1:gridSize,1:gridSize);
k = sqrt(verhaeltnis);
mask = (X-gridSize/2).^2+(Y-gridSize/2).^2<(k*gridSize/2).^2;

% Laserstrahl
% optical_beam = max(max(abs(mode_target_distribution)))*ones(gridSize,gridSize);
optical_beam = ones(gridSize,gridSize);

% Algorithmus
tic;
[simann_mask, fidelity_vals] = simulated_annealing(optical_beam, mode_target_distribution, mask, n_it, bit_resolution);
t_total = toc/60;

% Modulation
modulated_input = abs(optical_beam) .* exp(1i*angle(simann_mask));
modulated_input_prop = prop(modulated_input,dx,dy,lambda,dist);

% Graphische Darstellung
maxFidelity = max(fidelity_vals)
figure;
subplot(3, 2, 1);
imagesc(abs(mode_target_distribution));title('Amplitude of mode target distribution'); axis image
subplot(3, 2, 2);
imagesc(angle(mode_target_distribution));title('Phase of mode target distribution'); axis image
subplot(3, 2, 3);
imagesc(abs(modulated_input_prop).*mask);title('Amp moduliert nach fft'); axis image
subplot(3, 2, 4);
imagesc(angle(modulated_input_prop.*mask));title('Phase moduliert nach fft'); axis image
% imagesc((angle(modulated_input_prop)+pi/2).*mask);title('Phase moduliert nach fft'); axis image
subplot(3, 2, 6);
imagesc(angle(simann_mask));title('Phase maske'); axis image
subplot(3, 2, 5);
plot(fidelity_vals);title(['Entwicklung fidelity, max = ',num2str(100*maxFidelity), '%']);