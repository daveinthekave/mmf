%% main
clear all
% Parameter Multimodefibre
NA=0.1;
nCore = 1.4607;                 % at 20 deg C -> Pure Silica/ fused Silica
nCladding = sqrt(nCore^2-NA^2); % 1.4440375;      % at 20 deg C -> Fluorine-Doped Silica  
wavelength = 0.532;             % in um
coreRadius = 25/2;              % in um

% Modesolver parameters -> build modes
gridSize = 50;             % gridsize for modesolver; Wert am:06.04: 50
modes=build_modes(nCore,nCladding,wavelength,coreRadius,gridSize);
mode_target=2;             % which mode should be generated by SLM?

load('optical_beam')

mode_target_distribution=squeeze(modes(mode_target,:,:));

N_it = 10; % Anzahl der Iterationen

input_phase = rand(100,100) * 2*pi - pi;
input_amp = ones(100,100)/100000;
input = input_amp .* exp(1i*input_phase);

for i=1:N_it
    input_fft = fftshift(fft2(input));

    input_fft_amp = abs(input_fft);
    input_fft_phase = angle(input_fft);

    input_fft_amp(25:74, 25:74) = abs(mode_target_distribution);
    input_fft_phase(25:74, 25:74) = angle(mode_target_distribution);

    input_fft_complete = input_fft_amp .* exp(1i*input_fft_phase);

    target = fftshift(ifft2(input_fft_complete));

    input = input_amp .* exp(1i*angle(target));
end
