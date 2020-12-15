function [slm_phase_mask] = simulated_annealing(input, target)
close all
% Berechnung der Phasenmaske, um target aus input zu erzeugen

T_start = 20;                                              % Starttemperatur
scaleFactor = 5e8;                                          % Skalierungsfaktor, da delta_E sehr klein (fidelity ändert sich wenig bei Änderung eines Pixels)
n_it = 100000;                                               % Anzahl der Iterationen

num_pixel = 1;                                                      % Anzahl der Pixel, die (im Mittel) pro Iteration verändert werden
probability_threshold = 1 - (num_pixel ./ size(input).^2);          % Variation der Pixeländerungsanzahl

% calcs inital mode result
previous_result = fftshift(fft2(input));                            % Startwert
previous_fidelity = abs(innerProduct(target, previous_result))^2;   % Startfidelity

for i=1:n_it                                                        % Temperatur wird schrittweise von T_start auf 0 erniedrigt
    current_input = input;
    index_mat = rand(size(input)) > probability_threshold(1);       % Matrix (bei Pixel P1 =1 --> P1 wird in dieser Iteration verändert)
    num_rand_pixel = sum(index_mat, 'all');                         % Anzahl der Pixel, die in dieser Iteration geändert werden
    
    current_input(index_mat) = current_input(index_mat) .* exp(1i*rand(num_rand_pixel, 1)* 2*pi);   % Veränderung der Pixel
    
    current_result = fftshift(fft2(current_input));                 % Berechnung des Ergebnisses mittels FFT
    current_fidelity = abs(innerProduct(target, current_result))^2; % Berechnung der Fidelity
    fidelitys(i) = current_fidelity;
    
    delta_E = abs(previous_fidelity - current_fidelity);            % Berechnung der Differenz
    deltas(i) = delta_E;
    if current_fidelity > previous_fidelity                         % Ergebnis hat sich gebessert
        input = current_input;                                      % setze die neuen Werte
        previous_fidelity = current_fidelity;
    else                                                            % Ergebnis hat sich nicht verbessert
        T = T_start * (1 - i/ n_it);
        P = exp(-delta_E*scaleFactor/T);                            % Boltzmann-Verteilung
        expons(i) = -(delta_E*scaleFactor)/T;
        ps(i) = P;
        R = rand();                                                 % zufällige Referenzwahrscheinlichkeit
        if R < P                                                    % Schwelle wird überschritten
            input = current_input;                                  % setze die neuen Werte
            previous_fidelity = current_fidelity;
        end
    end
end
figure('name', 'fidelitys');
plot(fidelitys);
figure('name', 'Ps');
plot(ps);
figure('name', 'delta E');
plot(deltas * scaleFactor);
figure('name', 'exponents');
plot(expons);

slm_phase_mask = angle(input);                              % Rückgabe des Ergebnisses
end

