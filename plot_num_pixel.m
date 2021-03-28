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
N = 50;

root = fullfile('plots', 'num-pixel');
mkdir(root);
start_d_free = round(sqrt(10^2/rel_area));
for bit_resolution=1:1:8
    j = 1;
    for d_free=start_d_free:step:200

        d_sig = round(d_free * sqrt(rel_area));
        if mod(d_sig, 2) == 0
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
            fidelity_vals(j) = our_calc_fidelity(fidelity_target, modulated, area_analysis);
            anz_pixel(j) = d_sig ^2
            j = j + 1;
        end
    end
    save(fullfile(root, strcat(num2str(bit_resolution), '-bit')), 'fidelity_vals');
    save(fullfile(root, 'anz_pixel'), 'anz_pixel');
end
% figure;
% plot(anz_pixel, fidelity_vals, 'b--o', anz_pixel, ssim_vals); title('Fidelity vs. number of signal pixel (rel. area 30%, 8 bit, mode 14)');
% xline(256, 'r--');
% axis([0 inf 0 1]);
% xlabel('Number of Pixel'); ylabel('Fidelity');
