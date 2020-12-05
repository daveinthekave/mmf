function [slm_phase_mask] = simulated_annealing(input, target)
%UNTITLED Summary of this function goes here
T_start = 200000;
start_input = input;
% calcs inital mode result
previous_result = fftshift(fft2(input));
previous_fidelity = abs(innerProduct(target, previous_result))^2;
for T=T_start:-1:0
    current_input = input;
    rindex = fix(rand(1, 2) .* size(input)) + 1;
    current_input(rindex(1), rindex(2)) = current_input(rindex(1), rindex(2)) * exp(1i*rand() * 2 * pi);
    
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
slm_phase_mask = angle(input);  % - angle(start_input);
end

