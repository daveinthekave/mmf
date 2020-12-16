function [slm_mask, mask] = my_dcgs(input, target, bit_res)
n_it = 1000;

free = size(input);
signal = size(target);

input_amp = abs(input)./max(max(abs(input)));
input_phase = 2*pi * rand(free);
input = input_amp .* exp(1i*input_phase);
% normalisiere target_amp damit es dcgs schneller konvergiert
target_amp = abs(target)./max(max(abs(target)));
target_phase = angle(target);

start = round(free / 2 - signal / 2);
stop = round(free / 2 + signal / 2 - 1);
temp = zeros(free);
temp(start(1):stop(1), start(1):stop(1)) = ones(signal);
mask = temp >= 1;

% discretizes the phase
phase_values = linspace(-pi, pi, 2^bit_res);
phase_step = abs(phase_values(1) - phase_values(2));

start_phase = phase_values(1) - phase_step/2;
stop_phase = start_phase + 2^bit_res * phase_step;
phase_edges = start_phase:phase_step:stop_phase;

for i=0:n_it
    input_fft = fftshift(fft2(input));
    
    fft_amp = abs(input_fft);
    fft_phase = angle(input_fft);
    
    fft_amp(mask) = target_amp;
    fft_phase(mask) = target_phase;
    
    new_input = ifft2(ifftshift(fft_amp .* exp(1i*fft_phase)));
    
    disc_phase = discretize(angle(new_input), phase_edges, phase_values);
    input = input_amp .* exp(1i*disc_phase);
end
slm_mask = angle(input);
end

