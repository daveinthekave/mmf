function [slm_phase_mask, fidelity_vals] = simulated_annealing(input, target, mask)

% Berechnung der Phasenmaske, um target aus input zu erzeugen

T_start = 200;                                              % Starttemperatur
scaleFactor = 10e8;                                         % Skalierungsfaktor, da delta_E sehr klein (fidelity ändert sich wenig bei Änderung eines Pixels)
n_it = 200e3;                                              % Anzahl der Iterationen
input_size = max(size(input));

% Propagationsparameter
dx=8e-6;dy=dx;      % pixel size SLM [m]
lambda=532e-9;      % wavelength [m]
dist=0.5;           % propagation distance [m]

% Diskretisierung
bit_resolution = 8;

phase_values = linspace(-pi, pi, 2^bit_resolution);
phase_step = abs(phase_values(1) - phase_values(2));

start_phase = phase_values(1) - phase_step/2;
stop_phase = start_phase + 2^bit_resolution * phase_step;
phase_edges = start_phase:phase_step:stop_phase;

% num_pixel = 5;                                              % Anzahl der Pixel, die (im Mittel) pro Iteration verändert werden
% probability_threshold = 1 - (num_pixel ./ size(input).^2);  % Variation der Pixeländerungsanzahl

fidelity_vals=zeros(1,n_it);
index=1;

% calcs inital mode result
previous_result = prop(input,dx,dy,lambda,dist);                            % Startwert

% target_angle = discretize(angle(target), phase_edges, phase_values);

% target = abs(target) .* exp(1i*target_angle);
% previous_result_angle = discretize(angle(previous_result), phase_edges, phase_values);
% previous_result = abs(previous_result) .* exp(1i*previous_result_angle);
previous_fidelity = calcFidelity(target.*mask, previous_result.*mask);   % Startfidelity

for T=linspace(T_start, 0, n_it)                                    % Temperatur wird schrittweise von T_start auf 0 erniedrigt
    current_input = input;
       
%     index_mat = rand(size(input)) > (probability_threshold(1));       % Matrix (bei Pixel P1 =1 --> P1 wird in dieser Iteration verändert)
%     num_rand_pixel = sum(index_mat, 'all');                         % Anzahl der Pixel, die in dieser Iteration geändert werden
%     current_input(index_mat) = current_input(index_mat) .* exp(1i*rand(num_rand_pixel, 1)* 2*pi);   % Veränderung der Pixel
    change_indX = round(rand*(input_size-1))+1;
    change_indY = round(rand*(input_size-1))+1;
    current_input(change_indX, change_indY) = current_input(change_indX, change_indY) * exp(1i*rand*2*pi);   % Veränderung der Pixel

    
    current_input_angle = discretize(angle(current_input), phase_edges, phase_values);
    current_input = abs(current_input).*exp(1i*current_input_angle);
    
    % rindex = fix(rand(1, 2) .* size(input)) + 1;
    % current_input(rindex(1), rindex(2)) = current_input(rindex(1), rindex(2)) * exp(1i*rand() * 2 * pi);
    
    current_result = prop(current_input,dx,dy,lambda,dist);                % Berechnung des Ergebnisses mittels FFT
    
%     current_result_angle = discretize(angle(current_result), phase_edges, phase_values);
%     current_result = abs(current_result).*exp(1i*current_result_angle);
    
    current_fidelity = calcFidelity(target.*mask, current_result.*mask);
    
    fidelity_vals(index)=current_fidelity;
    index=index+1;

    if current_fidelity > previous_fidelity                         % Ergebnis hat sich gebessert
        input = current_input; %fftshift(current_input);                                      % setze die neuen Werte
        previous_fidelity = current_fidelity;
    else                                                            % Ergebnis hat sich nicht verbessert
% Ergebnis hat sich nicht verbessert
        delta_E = previous_fidelity - current_fidelity;             % Berechnung der Differenz
        P = exp(-delta_E*scaleFactor/T);                            % Boltzmann-Verteilung
        R = rand();                                                 % zufällige Referenzwahrscheinlichkeit
        if R < P                                                    % Schwelle wird überschritten
            input = current_input;                                  % setze die neuen Werte
            previous_fidelity = current_fidelity;
        end
    end 
end

slm_phase_mask = input;                              % Rückgabe des Ergebnisses
end

