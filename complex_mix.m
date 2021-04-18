function mixed_modes = complex_mix(modes, mix_vector)
    mixed_modes = zeros(size(modes, 2, 3));
    for mode=1:size(modes, 1)
        current_mode = squeeze(modes(mode,:,:));
        current_mix = mix_vector(mode);
        mixed_modes = mixed_modes + current_mode .* current_mix;
    end
end

