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

desired_beam_size = 50;
load('optical_beam');
[optical_beam_size, ~] = size(optical_beam);
optical_beam = imresize(optical_beam, desired_beam_size/optical_beam_size);
% Modesolver parameters -> build modes
gridSize = desired_beam_size;            % gridsize for modesolver; Wert am:06.04: 50

% simple_input = ones(optical_beam_size)*exp(li*2*pi*rand(optical_beam_size));

modes=build_modes(nCore,nCladding,wavelength,coreRadius,gridSize);
mode_target=8;             % which mode should be generated by SLM?
mode_target_distribution=squeeze(modes(mode_target,:,:));
% simann_mask = simulated_annealing(ifft2(ifftshift(optical_beam)), mode_target_distribution);
simann_mask = simulated_annealing(optical_beam, mode_target_distribution);

% moduliere beam
modulated_input = abs(optical_beam) .* exp(1i*angle(simann_mask)); % abs richtig???
modulated_input_fft = fft2(fftshift(modulated_input));

% plot dat
figure;
subplot(3, 2, 1);
imagesc(abs(mode_target_distribution));title('Amplitude of mode target distribution'); axis image
subplot(3, 2, 2);
imagesc(angle(mode_target_distribution));title('Phase of mode target distribution'); axis image
subplot(3, 2, 3);
imagesc(abs(modulated_input_fft));title('Amp moduliert nach fft'); axis image
subplot(3, 2, 4);
imagesc(angle(modulated_input_fft));title('Phase moduliert nach fft'); axis image
subplot(3, 2, 6);
imagesc(simann_mask);title('Phase maske'); axis image
