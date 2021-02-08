function fidelity = our_calc_fidelity(target, modulated, area_analysis)
% target: komplexes feld, größe signal space
% modulated: komplexes feld, größe free space
    modulated_amp = abs(modulated);
    modulated_phase = angle(modulated);
    [modulated_amp_cut, modulated_phase_cut]=cutout(modulated_amp,modulated_phase, area_analysis);

    zero_padding=size(target,1) - size(modulated_amp_cut,1);          
    modulated_amp_padded = symmetric_zero_padding(modulated_amp_cut,zero_padding);
    modulated_phase_padded = symmetric_zero_padding(modulated_phase_cut,zero_padding);
    modulated_beam = modulated_amp_padded .* exp(1i*modulated_phase_padded);
    
    fidelity = abs(innerProduct(target, modulated_beam))^2;
end

