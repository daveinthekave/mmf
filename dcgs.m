function [input_modulated] = dcgs(input, target)
% double constraint gerchbergs-saxton
N_it = 10; % Anzahl der Iterationen
I_H = abs(input); % Intensität eines Gaußstrahls
Phi_H_n = rand(size(input)); % Startwert für Phi (Zufallsverteilung)
I_T = abs(target); % Amplitude des Targets
end

