function [slm_phase_mask] = dcgs(input, target, bit_res)
% double constraint gerchbergs-saxton

N_it = 10;
input_amp = abs(input); % Intensität eines Gaußstrahls
input_phase = rand(size(input)); % Startwert für Phi (Zufallsverteilung)
target_amp = abs(target); % Amplitude des Targets
target_phase = angle(target);

[image_plane_size, ~] = size(input);
[signal_size, ~] = size(target);
input = input_amp .* exp(1i*input_phase);

start = fix(image_plane_size / 2) - fix(signal_size / 2);
stop = fix(image_plane_size / 2) + fix(signal_size / 2 - 1);

for i=1:N_it
    input_fft = fftshift(fft2(input));

    input_fft_amp = abs(input_fft);
    input_fft_phase = angle(input_fft);
    
    % indirekte indizierung ausprobieren
    input_fft_amp(start:stop, start:stop) = target_amp;
    input_fft_phase(start:stop, start:stop) = target_phase;

    input_fft_combined = input_fft_amp .* exp(1i*input_fft_phase);

    target = ifft2(ifftshift(input_fft_combined));

    input = input_amp .* exp(1i*angle(target));
end

desired_phase = angle(target);
% discretizes the phase
phase_values = linspace(-pi, pi, 2^bit_res);
phase_step = abs(phase_values(1) - phase_values(2));

start_phase = phase_values(1) - phase_step/2;
stop_phase = phase_values(end) + phase_step/2;
phase_edges = start_phase:phase_step:stop_phase;

slm_phase_mask = discretize(desired_phase, phase_edges, phase_values);
end

