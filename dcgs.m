function [slm_phase_mask] = dcgs(input, target)
% double constraint gerchbergs-saxton

N_it = 10;
input_amp = abs(input); % Intensität eines Gaußstrahls
input_phase = rand(size(input)); % Startwert für Phi (Zufallsverteilung)
target_amp = abs(target); % Amplitude des Targets
target_phase = angle(target);

image_plain_size = size(input);
signal_size = size(target);
input = input_amp .* exp(1i*input_phase);

for i=1:N_it
    input_fft = fftshift(fft2(input));

    input_fft_amp = abs(input_fft);
    input_fft_phase = angle(input_fft);
    
    start = fix(image_plain_size(1) / 2) - fix(signal_size(1) / 2);
    stop = fix(image_plain_size(1) / 2) + fix(signal_size(1) / 2 - 1);
    input_fft_amp(start:stop, start:stop) = target_amp;
    input_fft_phase(start:stop, start:stop) = target_phase;

    input_fft_combined = input_fft_amp .* exp(1i*input_fft_phase);

    target = ifft2(ifftshift(input_fft_combined));

    input = input_amp .* exp(1i*angle(target));
end
slm_phase_mask = angle(target);
end

