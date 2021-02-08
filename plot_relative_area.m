clear all
%% Gerchberg Saxton
% Parameter Multimodefibre
NA=0.1;
nCore = 1.4607;                 % at 20 deg C -> Pure Silica/ fused Silica
nCladding = sqrt(nCore^2-NA^2); % 1.4440375;      % at 20 deg C -> Fluorine-Doped Silica  
wavelength = 0.532;             % in um
coreRadius = 25/2;              % in um
mode = 14;

step = 10;
d_free=100;
bit_resolution=8;

N=50;
for rel_area=0.1:0.1:0.9
    d_sig = round(d_free * sqrt(rel_area));
    modes=build_modes(nCore,nCladding,wavelength,coreRadius,d_sig);
    target=squeeze(modes(mode,:,:));

    mask=zeros(d_free,d_free);
    start = round(d_free/2 - d_sig/2);
    stop = round(d_free/2 + d_sig/2 - 1);
    mask(start:stop, start:stop) = ones(d_sig,d_sig);

    %%
    target_amp=abs(target)./max(max(abs(target)));
    target_phase=angle(target);

    input_amp=ones(d_free,d_free);
    input_phase=ones(d_free,d_free);

    Input=input_amp.*exp(1i*input_phase);

    % discretizes the phase
    phase_values = linspace(-pi, pi, 2^bit_resolution);
    phase_step = abs(phase_values(1) - phase_values(2));

    start_phase = phase_values(1) - phase_step/2;
    stop_phase = start_phase + 2^bit_resolution * phase_step;
    phase_edges = start_phase:phase_step:stop_phase;

    %% Popagation parameter
    dx=8e-6;dy=dx;      % pixel size SLM [m]
    lambda=532e-9;      % wavelength [m]
    dist=0.5;           % propagation distance [m]

    for i=1:N
        target_plane=prop(Input,dx,dy,lambda,dist);

        target_plane_amp=abs(target_plane);
        target_plane_phase=angle(target_plane);

        target_plane_amp(start:stop, start:stop) = target_amp;
        target_plane_phase(start:stop, start:stop) = target_phase;

        backprop_field=target_plane_amp.*exp(1i*target_plane_phase);

        Input_phase_next_iteration=angle (prop(backprop_field,dx,dy,lambda,-dist));

        disc_phase = discretize(Input_phase_next_iteration, phase_edges, phase_values);

        Input=input_amp.*exp(1i*disc_phase);
    end
    modulated_input = prop(Input,dx,dy,lambda,dist) .* mask;
    modulated_signal = modulated_input(start:stop, start:stop);
    fidelity_vals(round(rel_area*10)) = abs(innerProduct(target, modulated_signal))^2;
    rel_areas(round(rel_area*10)) = rel_area
end
figure;
plot(rel_areas, fidelity_vals, 'b--o'); title('Fidelity vs. relative area (Free space 100x100, 8 bit, mode 14)');
axis([0 1 0 1]);
xlabel('Relative area'); ylabel('Fidelity');