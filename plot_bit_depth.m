clear all
%% Gerchberg Saxton
% Parameter Multimodefibre
NA=0.1;
nCore = 1.4607;                 % at 20 deg C -> Pure Silica/ fused Silica
nCladding = sqrt(nCore^2-NA^2); % 1.4440375;      % at 20 deg C -> Fluorine-Doped Silica  
wavelength = 0.532;             % in um
coreRadius = 25/2;              % in um

mode = 14;
rel_area = 0.3;
d_free=100;
    
N=50;
for bit_resolution=1:1:16
    d_sig = round(d_free * sqrt(rel_area));
    modes=build_modes(nCore,nCladding,wavelength,coreRadius,d_sig);
    target=squeeze(modes(mode,:,:));

    start = round(d_free/2 - d_sig/2);
    stop = round(d_free/2 + d_sig/2 - 1);

    [X,Y] = meshgrid(1:d_free,1:d_free);
    area_analysis=false(d_free,d_free);
    area_analysis((X-d_free/2).^2+(Y-d_free/2).^2 <= (d_sig/2-1)^2)=true;
    %%
    target_amp=abs(target)./max(max(abs(target)));
    target_phase=angle(target);
    fidelity_target = target_amp .* exp(1i*target_phase);

    input_amp=ones(d_free,d_free);
    input_phase=ones(d_free,d_free);

    Input=input_amp.*exp(1i*input_phase);

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

        % correct phase
        PhaseCorrected=angle(prop(backprop_field,dx,dy,lambda,-dist));
        PhaseCorrected(PhaseCorrected<0) = PhaseCorrected(PhaseCorrected<0) + 2*pi;

        disc_phase = our_disc(PhaseCorrected, bit_resolution);

        Input=input_amp.*exp(1i*disc_phase);
    end
    
    modulated = prop(Input,dx,dy,lambda,dist);
    fidelity_vals(bit_resolution) = our_calc_fidelity(fidelity_target, modulated, area_analysis);
    ssim_vals(bit_resolution) = complex_ssim(fidelity_target, modulated, area_analysis);
    pixel_depth(bit_resolution) = bit_resolution
    
end
save('bit-fids', 'fidelity_vals');
save('bit-ssim', 'ssim_vals');
figure;
plot(pixel_depth, fidelity_vals, 'b--o', pixel_depth, ssim_vals); title('Fidelity vs. bit resolution (rel. area 30%, free space 100x100, mode 14)');
axis([1 16 0 1]);
xlabel('Number of Bits'); ylabel('Fidelity');
