function [slm_phase_mask] = simulated_annealing(input, target)
%UNTITLED Summary of this function goes here
T_start = 20;
start_input = input;
% calcs inital mode result
previous_result = fftshift(fft2(input));
previous_fidelity = abs(innerproduct(target, previous_result))^2;
for T=Tstart:-1:0
    current_input = input;
    random_index = round(rand(1, 2) .* size(input), 0);
    current_input(random_index) = current_input(random_index) * exp(1i*rand() * 2 * pi);
    
    current_result = fftshift(fft2(current_input));
    current_fidelity = abs(innerproduct(target, current_result))^2;
    
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
slm_phase_mask = angle(input);  % - angle(start_input);
end

