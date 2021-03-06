%% main
clear all

% Parameter Multimodefibre
NA=0.1;
nCore = 1.4607;                 % at 20 deg C -> Pure Silica/ fused Silica
nCladding = sqrt(nCore^2-NA^2); % 1.4440375; at 20 deg C -> Fluorine-Doped Silica  
wavelength = 0.532;             % in um
coreRadius = 25/2;              % in um

% SLM & Superpixel parameters  
bitDepthSLM = 16;                % Bit

desired_beam_size = 100;
rel_area = 0.2;
disc_in_loop = true;
gridSize = round(desired_beam_size * sqrt(rel_area));

modes = build_modes(nCore, nCladding, wavelength, coreRadius, gridSize);
mode_target = 1;             % which mode should be generated by SLM?
mode_target_distribution = squeeze(modes(mode_target,:,:));
load('optical_beam');
optical_beam = imresize(optical_beam, desired_beam_size/800);

[slm_mask, mask] = my_dcgs(optical_beam, mode_target_distribution, bitDepthSLM, disc_in_loop);

normed_beam_amp = abs(optical_beam)./max(max(abs(optical_beam)));
modulated = normed_beam_amp .* exp(1i*slm_mask);

res = fftshift(fft2(modulated));

figure;
subplot(3, 2, 1);
imagesc(abs(mode_target_distribution));title('Amplitude of mode target distribution'); axis image
subplot(3, 2, 2);
imagesc(angle(mode_target_distribution));title('Phase of mode target distribution'); axis image
subplot(3, 2, 3);
imagesc(abs(res .* mask));title('Amp moduliert nach fft'); axis image
subplot(3, 2, 4);
imagesc(angle(res .* mask));title('Phase moduliert nach fft'); axis image
subplot(3, 2, 6);
imagesc(slm_mask);title('Phase maske'); axis image
    
