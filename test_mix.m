clear all
% Parameter Multimodefibre
NA=0.1;
nCore = 1.4607;                 % at 20 deg C -> Pure Silica/ fused Silica
nCladding = sqrt(nCore^2-NA^2); % 1.4440375;      % at 20 deg C -> Fluorine-Doped Silica  
wavelength = 0.532;             % in um
coreRadius = 25/2;              % in um
d_sig = 100;
modes=build_modes(nCore,nCladding,wavelength,coreRadius,d_sig);

mix_amp = rand(55, 1);
mix_phase = rand(55, 1) * 2*pi;
mix_vector = cat(2, mix_amp, mix_phase);

mixed_modes = mix_modes(modes, mix_vector);

figure;
imagesc(abs(mixed_modes));title('Amp');
figure;
imagesc(angle(mixed_modes));title('Phase');