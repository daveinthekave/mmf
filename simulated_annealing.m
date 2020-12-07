function [slm_phase_mask] = simulated_annealing(input, target)
% start temperatur und anzahl an iterationanzahl
T_start = 0.00002;  % sehr niedrig wegen kleinem delta_E
n_it = 2000000;

% Test

% start_phase = angle(fftshift(ifft2(target)));
% input_amp = abs(input);
% input = input_amp .* exp(1i*start_phase);

num_pixel = 1;
probability_threshold = 1 - (num_pixel ./ size(input).^2);

% calcs inital mode result
previous_result = fftshift(fft2(input));
previous_fidelity = abs(innerProduct(target, previous_result))^2;
for T=linspace(T_start, 0, n_it)
    current_input = input;
    index_mat = rand(size(input)) > probability_threshold(1);
    num_rand_pixel = sum(index_mat, 'all');
    
    current_input(index_mat) = current_input(index_mat) .* exp(1i*rand(num_rand_pixel, 1)* 2*pi);
    
    current_result = fftshift(fft2(current_input));
    current_fidelity = abs(innerProduct(target, current_result))^2;
    
    if current_fidelity > previous_fidelity
        input = current_input;
        previous_fidelity = current_fidelity;
    else
        delta_E = previous_fidelity - current_fidelity;
        P = exp(-delta_E/T);
        R = rand();
        if R < P
            input = current_input;
            previous_fidelity = current_fidelity;
        end
    end
end
slm_phase_mask = angle(input);
end

