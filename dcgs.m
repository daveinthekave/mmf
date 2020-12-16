function [slm_phase_mask, mask] = dcgs(input, target, bit_res)
% double constraint gerchbergs-saxton

N_it = 100;
input_amp = abs(input); % Intensität eines Gaußstrahls
input_phase = 2*pi * rand(size(input)); % Startwert für Phi (Zufallsverteilung)
% normalizes target amp
target_amp = abs(target);% ./max(max(abs(target))); % Amplitude des Targets
target_phase = angle(target);

[free_space_size, ~] = size(input);
[signal_space_size, ~] = size(target);
input = input_amp .* exp(1i*input_phase);

start = free_space_size / 2 - signal_space_size / 2;
stop = free_space_size / 2 + signal_space_size / 2 - 1;
temp = zeros(free_space_size);
temp(start:stop, start:stop) = ones(signal_space_size);
mask = temp >= 1;
for i=1:N_it
    input_fft = fftshift(fft2(input));

    input_fft_amp = abs(input_fft);
    input_fft_phase = angle(input_fft);
    
    input_fft_amp(mask) = target_amp;
    input_fft_phase(mask) = target_phase;

    input_fft_combined = input_fft_amp .* exp(1i*input_fft_phase);

    target = ifft2(ifftshift(input_fft_combined));

    input = input_amp .* exp(1i*angle(target));
end

desired_phase = angle(input);
% discretizes the phase
phase_values = linspace(-pi, pi, 2^bit_res);
phase_step = abs(phase_values(1) - phase_values(2));

start_phase = phase_values(1) - phase_step/2;
stop_phase = phase_values(end) + phase_step/2;
phase_edges = start_phase:phase_step:stop_phase;

slm_phase_mask = desired_phase; % discretize(desired_phase, phase_edges, phase_values);
end

