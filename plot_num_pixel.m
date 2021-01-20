clear all
%% Gerchberg Saxton
% Parameter Multimodefibre
NA=0.1;
nCore = 1.4607;                 % at 20 deg C -> Pure Silica/ fused Silica
nCladding = sqrt(nCore^2-NA^2); % 1.4440375;      % at 20 deg C -> Fluorine-Doped Silica  
wavelength = 0.532;             % in um
coreRadius = 25/2;              % in um

mode = 55;
rel_area = 0.3;
step = 10;
N=50;

for d_free=30:step:50
    %% main

    %d_free=100;
    d_sig = round(d_free * sqrt(rel_area));
    modes=build_modes(nCore,nCladding,wavelength,coreRadius,d_sig);
    target=squeeze(modes(mode,:,:));

    fidelity_sp_pixel(d_free/step) = max(fidelity_vals)
    anz_pixel(d_free/step) = d_free ^2
    
    modulated_input = prop(Input,dx,dy,lambda,dist) .* mask;
    modulated_signal = modulated_input(start:stop, start:stop);
    fidelity_vals(d_free/step) = abs(innerProduct(target, modulated_signal))^2;
    anz_pixel(d_free/step) = d_sig ^2
end
    
figure;
plot(anz_pixel, fidelity_vals); title('Fidelity in Abhänigigkeit von Anzahl an Pixeln');
axis([0 inf 0 1]);
xlabel('Anzahl der Pixel'); ylabel('Fidelity');
