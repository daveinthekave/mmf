clear all
close all
%% Gerchberg Saxton
% Parameter Multimodefibre
NA=0.1;
nCore = 1.4607;                 % at 20 deg C -> Pure Silica/ fused Silica
nCladding = sqrt(nCore^2-NA^2); % 1.4440375;      % at 20 deg C -> Fluorine-Doped Silica  
wavelength = 0.532;             % in um
coreRadius = 25/2;              % in um

N = 50;

% d_free = 150;
% rel_area= 0.5;
d_sig = 150; % round(d_free * sqrt(rel_area));

load("data_mode_combos_spatial_frequencies_2.mat");
vectors = cat(1, mode_vec_r3, mode_vec_r4, mode_vec_r5, mode_vec_r6, mode_vec_r7);
stefan_results = cat(3, mode_dist_r3, mode_dist_r4, mode_dist_r5, mode_dist_r6, mode_dist_r7);

modes = build_modes(nCore,nCladding,wavelength,coreRadius,d_sig);
for i=1:size(mode_vec_r3, 1)
    current_vec = mode_vec_r3(i, :);
    target = complex_mix(modes, current_vec);
    figure(i); subplot(1,2,1);imagesc(abs(target)); colorbar;
    subplot(1,2,2);imagesc(abs(mode_dist_r3(:,:, i))); colorbar;
end
