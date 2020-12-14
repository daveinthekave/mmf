function [slm_mask, mask] = my_dcgs(input, target)
n_it = 200;

free = size(input);
signal = size(target);

input_amp = abs(input); % ones(desired_beam_size);
input_phase = 2*pi * rand(free);
input = input_amp .* exp(1i*input_phase);

target_amp = abs(target);
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
    
    target = ifft2(ifftshift(fft_amp .* exp(1i*fft_phase)));
    
    input = input_amp .* exp(1i*angle(target));
end
slm_mask = angle(input);
end

