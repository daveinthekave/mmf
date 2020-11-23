%% main

% Parameter Multimodefibre
NA=0.1;
nCore = 1.4607;                 % at 20 deg C -> Pure Silica/ fused Silica
nCladding = sqrt(nCore^2-NA^2); % 1.4440375;      % at 20 deg C -> Fluorine-Doped Silica  
wavelength = 0.532;             % in um
coreRadius = 25/2;              % in um
load('optical_beam');           %simuliere einen Gaußschen Laserstrahl
load('modes_analyzis');

for scale_factor=0.1:0.1:0.2  
    % Modesolver parameters -> build modes
    scale_factor
    gridSize = size(optical_beam) * scale_factor;           % gridsize for modesolver; Wert am:06.04: 50
    modes = build_modes(nCore,nCladding,wavelength,coreRadius,gridSize(1));
    [num_modes, ~, ~] = size(modes);
    for mode_target=1:num_modes
        % select mode
        mode_target
        mode_target_distribution = squeeze(modes(mode_target,:,:));
        % bitDepthSLM = 8;            % Bit
        % create mask and modulate
        gs_mask = dcgs(optical_beam, mode_target_distribution);
        modulated_beam = abs(optical_beam) .* exp(1i*gs_mask);
        % run beam through lense
        modulated_beam_fft = fftshift(fft2(modulated_beam));
        
        % area in which the generated field quality will be analyzed
        [n_rows, n_cols] = size(optical_beam);
        [X, Y] = meshgrid(1:n_rows, 1:n_cols);
        area_analysis = false(n_rows, n_cols);
        % inner circle of quad of gridSize
        area_analysis((X-n_cols/2).^2+(Y-n_rows/2).^2 <= (gridSize(1)/2-1)^2) = true;
        % cutout the phase and amp of the modulated_beam_fft
        [modulated_beam_fft_cutout_amp, modulated_beam_fft_cutout_phase] = cutout(abs(modulated_beam_fft), angle(modulated_beam_fft), area_analysis);
        % combines amp and phase
        modulated_beam_fft_cutout = modulated_beam_fft_cutout_amp .* exp(1i*modulated_beam_fft_cutout_phase);
        % get analysis mode target distribution
        mode_target_distribution_analyzis = squeeze(modes_analyzis(mode_target, :, :));
        % resizes cutout to analysis mode size
        modulated_beam_fft_cutout_resized = imresize(modulated_beam_fft_cutout, size(mode_target_distribution_analyzis));
        % calcs fidelity with inner product
        g = innerProduct(mode_target_distribution_analyzis, modulated_beam_fft_cutout_resized);
        fidelity_vals(scale_factor*10, mode_target) = abs(g)^2;
    end  
end
%% Visualisierung
figure; imagesc(fidelity_vals);
% figure;
% subplot(2,2,1);
% imagesc(abs(mode_target_distribution));title('Gewünschte Amplitudenverteilung');axis image
% subplot(2,2,2);
% imagesc(angle(mode_target_distribution));title('Gewünschte Phasenverteilung');axis image
% subplot(2,2,3);
% imagesc(abs(modulated_beam_fft));title('Modulierte Amplitudenverteilung');axis image
% subplot(2,2,4);
% imagesc(angle(modulated_beam_fft));title('Modulierte Phasenverteilung');axis image