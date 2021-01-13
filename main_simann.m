tic;

%% main
clear all
% Parameter Multimodefibre
NA=0.1;
nCore = 1.4607;                 % at 20 deg C -> Pure Silica/ fused Silica
nCladding = sqrt(nCore^2-NA^2); % 1.4440375;      % at 20 deg C -> Fluorine-Doped Silica  
wavelength = 0.532;             % in um
coreRadius = 25/2;              % in um

% SLM & Superpixel parameters  
bitDepthSLM = 8;            % Bit

% Propagationsparameter
dx=8e-6;dy=dx;      % pixel size SLM [m]
lambda=532e-9;      % wavelength [m]
dist=0.5;           % propagation distance [m]

verhaeltnis = 0.5;
plot_distance = sqrt(1/verhaeltnis);
plot_distance = sqrt(2);

desired_beam_size = 50;
% Modesolver parameters -> build modes
gridSize = desired_beam_size;

% simple_input = ones(optical_beam_size)*exp(li*2*pi*rand(optical_beam_size));

modes=build_modes_SA(nCore,nCladding,wavelength,coreRadius,gridSize, plot_distance);
mode_target = 55;             % which mode should be generated by SLM?
mode_target_distribution=squeeze(modes(mode_target,:,:));

[X,Y]=meshgrid(1:gridSize,1:gridSize);

k=1/plot_distance;
mask=(X-gridSize/2).^2+(Y-gridSize/2).^2<(k*gridSize/2).^2;

optical_beam=max(max(abs(mode_target_distribution)))*ones(gridSize,gridSize); %.*exp(1i*ones(gridSize,gridSize)*2*pi);
% optical_beam=ones(gridSize,gridSize).*exp(1i*ones(gridSize,gridSize)*2*pi);
% simann_mask = simulated_annealing(ifft2(ifftshift(optical_beam)), mode_target_distribution);
[simann_mask, fidelity_vals] = simulated_annealing(optical_beam, mode_target_distribution,mask);

% moduliere beam
modulated_input = abs(optical_beam) .* exp(1i*angle(simann_mask));
modulated_input_prop = prop(modulated_input,dx,dy,lambda,dist);
% modulated_input_prop = fftshift(fft2(modulated_input));

t_total = toc;
% plot dat
% mask2=abs(modulated_input_prop)<1;
figure;
subplot(3, 2, 1);
imagesc(abs(mode_target_distribution));title('Amplitude of mode target distribution'); axis image
subplot(3, 2, 2);
imagesc(angle(mode_target_distribution));title('Phase of mode target distribution'); axis image
subplot(3, 2, 3);
imagesc(abs(modulated_input_prop.*mask));title('Amp moduliert nach fft'); axis image
subplot(3, 2, 4);
imagesc(angle(modulated_input_prop.*mask));title('Phase moduliert nach fft'); axis image
subplot(3, 2, 6);
imagesc(angle(simann_mask));title('Phase maske'); axis image
subplot(3, 2, 5);
plot(fidelity_vals);title('Entwicklung fidelity');

