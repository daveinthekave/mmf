function [slm_phase_mask, fidelity_vals] = simulated_annealing(input, target, mask, n_it, bit_resolution)

% Algorithmusparameter
T_start = 200;                                              % Starttemperatur
scaleFactor = 10e8;                                         % Skalierungsfaktor, da delta_E sehr klein (fidelity ändert sich wenig bei Änderung eines Pixels)
input_size = max(size(input));

% Propagationsparameter
dx=8e-6;dy=dx;      % pixel size SLM [m]
lambda=532e-9;      % wavelength [m]
dist=0.5;           % propagation distance [m]

% Diskretisierungssparameter

% Davids Version einpflegen
phase_values = linspace(-pi, pi, 2^bit_resolution);
phase_step = abs(phase_values(1) - phase_values(2));
start_phase = phase_values(1) - phase_step/2;
stop_phase = start_phase + 2^bit_resolution * phase_step;
phase_edges = start_phase:phase_step:stop_phase;
if (bit_resolution == 1)
    versatz = 0; %pi/4;
    phase_values = [-pi/2-versatz, pi/2-versatz];
    phase_edges = [-pi, 0, pi];
end

% Iterationsparameter
fidelity_vals=zeros(1,n_it);
index=1;

previous_result = prop(input,dx,dy,lambda,dist);                            % Startwert

[previous_result_abs_cut,previous_result_angle_cut] = cutout(abs(previous_result), angle(previous_result), mask);
zero_padding = size(target,1)-size(previous_result_abs_cut,1);          
previous_result_abs_cut_padded = symmetric_zero_padding(previous_result_abs_cut,zero_padding);
previous_result_angle_cut_padded = symmetric_zero_padding(previous_result_angle_cut,zero_padding);
previous_result_cut_padded = previous_result_abs_cut_padded.*exp(1i*previous_result_angle_cut_padded);
previous_fidelity = (abs(innerProduct(target, previous_result_cut_padded)))^2;      % Startfidelity

T = T_start;
delta_T = T_start/n_it;

while T>0      
    current_input = input;
    % Pixeländerung
    change_indX = round(rand*(input_size-1))+1;
    change_indY = round(rand*(input_size-1))+1;
    current_input(change_indX, change_indY) = current_input(change_indX, change_indY) * exp(1i*rand*2*pi);
    % Diskretisierung
    current_input_angle = discretize(angle(current_input), phase_edges, phase_values);
    current_input = abs(current_input).*exp(1i*current_input_angle);
    % Propagation
%     tic;
    current_result = prop(current_input,dx,dy,lambda,dist); 
%     t_prop = toc;
    % Fidelity-Berechnung
    [current_result_abs_cut,current_result_angle_cut] = cutout(abs(current_result), angle(current_result), mask);
    zero_padding = size(target,1)-size(current_result_abs_cut,1);          
    current_result_abs_cut_padded = symmetric_zero_padding(current_result_abs_cut,zero_padding);
    current_result_angle_cut_padded = symmetric_zero_padding(current_result_angle_cut,zero_padding);
    current_result_cut_padded = current_result_abs_cut_padded.*exp(1i*current_result_angle_cut_padded);
    current_fidelity = (abs(innerProduct(target, current_result_cut_padded)))^2;  
    % Abspeichern des Werts
    fidelity_vals(index) = current_fidelity;
    index=index+1;
    % Vergleich der Fidelity
    if current_fidelity > previous_fidelity                         % Ergebnis hat sich gebessert
        input = current_input;                                      % setze die neuen Werte
        previous_fidelity = current_fidelity;
    else                                                            % Ergebnis hat sich nicht verbessert
        delta_E = previous_fidelity - current_fidelity;             % Berechnung der Differenz
        P = exp(-delta_E*scaleFactor/T);                            % Boltzmann-Verteilung
        R = rand();                                                 % zufällige Referenzwahrscheinlichkeit
        if R < P                                                    % Schwelle wird überschritten
            input = current_input;                                  % setze die neuen Werte
            previous_fidelity = current_fidelity;
        end
    end     
    % Abbruchbedingung
%     if ((index > 5000) && (mod(index,1000) == 0))
%         if ((fidelity_vals(index) - fidelity_vals(index-1000) < 1e-3) && (fidelity_vals(index-500) - fidelity_vals(index-1000) < 1e-3))
%             T = 0;
%         end
%     end
    T = T - delta_T;
end
slm_phase_mask = input;                              % Rückgabe des Ergebnisses
end

