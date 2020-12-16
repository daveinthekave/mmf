function [slm_mask, mask] = my_dcgs(input, target, bit_res)
n_it = 200;

free = size(input);
signal = size(target);

input_amp = abs(input); % ones(desired_beam_size);
input_phase = 2*pi * rand(free);
input = input_amp .* exp(1i*input_phase);
% normalisiere target_amp damit es dcgs schneller konvergiert
target_amp = abs(target);  % ./max(max(abs(target)));
target_phase = angle(target);

start = free / 2 - signal / 2;
stop = free / 2 + signal / 2 -1;
temp = zeros(free);
temp(start:stop, start:stop) = ones(signal);
mask = temp >= 1;

for i=0:n_it
    input_fft = fftshift(fft2(input));
    
    fft_amp = abs(input_fft);
    fft_phase = angle(input_fft);
    
    fft_amp(mask) = target_amp;
    fft_phase(mask) = target_phase;
    
    new_input = ifft2(ifftshift(fft_amp .* exp(1i*fft_phase)));
    test = ifft2(fft_amp .* exp(1i*fft_phase));
    
    input = input_amp .* exp(1i*angle(new_input));
end
desired_phase = angle(input);
% discretizes the phase
phase_values = linspace(-pi, pi, 2^bit_res);
phase_step = abs(phase_values(1) - phase_values(2));

start_phase = phase_values(1) - phase_step/2;
stop_phase = phase_values(end) + phase_step/2;
phase_edges = start_phase:phase_step:stop_phase;

slm_mask = discretize(desired_phase, phase_edges, phase_values);
test_good = fftshift(fft2(input_amp .* exp(1i*desired_phase)));
test_bad = fftshift(fft2(input_amp .* exp(1i*slm_mask)));
diff = desired_phase - slm_mask;
desired_phase(10, 10) = desired_phase(10, 10) * 1.001;
test_c = fftshift(fft2(input_amp .* exp(1i*desired_phase)));

% figure('name', 'diff phase maske');imagesc(diff);
% figure('name', 'good abs');imagesc(abs(test_good) .* mask);
% figure('name', 'good angle');imagesc(angle(test_good) .* mask);
% figure('name', 'c abs');imagesc(abs(test_c) .* mask);
% figure('name', 'c angle');imagesc(angle(test_c) .* mask);
% figure('name', 'bad abs');imagesc(abs(test_bad) .* mask);
% figure('name', 'bad angle');imagesc(angle(test_bad) .* mask);
end

