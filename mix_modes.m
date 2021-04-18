function mixed_modes = mix_modes(modes, mix_vector)
% modes: shape = (num_modes, img_size, img_size)
% mix vector: shape = (num_modes, (amp, phase)) 
    mixed_modes = zeros(size(modes, 2, 3));
    for mode=1:size(modes, 1)
        current_mode = squeeze(modes(mode,:,:));
        current_mix = mix_vector(mode, 1) .* exp(1i*mix_vector(mode, 2));
        mixed_modes = mixed_modes + current_mode .* current_mix;
    end
end

