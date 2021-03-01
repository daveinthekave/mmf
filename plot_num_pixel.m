clear all
%% Gerchberg Saxton
% Parameter Multimodefibre
NA=0.1;
nCore = 1.4607;                 % at 20 deg C -> Pure Silica/ fused Silica
nCladding = sqrt(nCore^2-NA^2); % 1.4440375;      % at 20 deg C -> Fluorine-Doped Silica  
wavelength = 0.532;             % in um
coreRadius = 25/2;              % in um

mode = 14;
rel_area = 0.5;
step = 10;
for br=1:1:8
% discretizes the phase
bit_resolution=br

delta_diff = 1e-4;

for d_free=10:step:200
    
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
    
    current_diff = 1;
    old_fid = 1;
    while current_diff > delta_diff
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
        
        modulated = prop(Input,dx,dy,lambda,dist);
        current_fid = our_calc_fidelity(fidelity_target, modulated, area_analysis);
        current_diff = abs(current_fid - old_fid);
        old_fid = current_fid;
    end
    
    modulated = prop(Input,dx,dy,lambda,dist);
    fidelity_vals(d_free/step) = our_calc_fidelity(fidelity_target, modulated, area_analysis);
    ssim_vals(d_free/step) = complex_ssim(fidelity_target, modulated, area_analysis);
    anz_pixel(d_free/step) = d_sig ^2

end
root = strcat('Plots/Gerchberg-Saxton/adapt-fid/', 'bit_resolution/', num2str(bit_resolution), '-bit', '/');
mkdir(root);
save(strcat(root, '/fidelity_vals'), 'fidelity_vals');
save(strcat(root, '/anz_pixel'), 'anz_pixel');
end
% figure;
% plot(anz_pixel, fidelity_vals, 'b--o', anz_pixel, ssim_vals); title('Fidelity vs. number of signal pixel (rel. area 30%, 8 bit, mode 14)');
% xline(256, 'r--');
% axis([0 inf 0 1]);
% xlabel('Number of Pixel'); ylabel('Fidelity');
